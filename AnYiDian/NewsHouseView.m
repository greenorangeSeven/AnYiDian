//
//  NewsHouseView.m
//  AnYiDian
//
//  Created by Seven on 15/8/4.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "NewsHouseView.h"
#import "Estate.h"
#import "BuildingPageCell.h"
#import "UIImageView+WebCache.h"
#import "CommDetailView.h"

@interface NewsHouseView ()
{
    BOOL gNoRefresh;
}

@end

@implementation NewsHouseView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"新房信息";
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    allCount = 0;
    //添加的代码
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    
    estateData = [[NSMutableArray alloc] initWithCapacity:20];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    gNoRefresh = YES;
    [self reload:YES];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    _refreshHeaderView = nil;
    [estateData removeAllObjects];
    estateData = nil;
    [super viewDidUnload];
}

- (void)clear
{
    allCount = 0;
    [estateData removeAllObjects];
    isLoadOver = NO;
}

- (void)reload:(BOOL)noRefresh
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        if (isLoading || isLoadOver) {
            return;
        }
        if (!gNoRefresh) {
            allCount = 0;
        }
        int pageIndex = allCount/20 + 1;
        
        //生成获取新闻列表URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:[NSString stringWithFormat:@"%d", pageIndex] forKey:@"pageNumbers"];
        [param setValue:@"20" forKey:@"countPerPages"];
        NSString *getEstateListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findEstateInfoByPage] params:param];
        
        [[AFOSCClient sharedClient]getPath:getEstateListUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       
                                       NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                                       NSError *error;
                                       NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                       
                                       NSDictionary *datas = [json objectForKey:@"data"];
                                       NSArray *array = [datas objectForKey:@"resultsList"];
                                       NSMutableArray *dataNews = [NSMutableArray arrayWithArray:[Tool readJsonToObjArray:array andObjClass:[Estate class]]];
                                       isLoading = NO;
                                       if (!gNoRefresh) {
                                           [self clear];
                                       }
                                       
                                       @try {
                                           NSInteger count = [estateData count];
                                           allCount += count;
                                           if (count < 20)
                                           {
                                               isLoadOver = YES;
                                           }
                                           [estateData addObjectsFromArray:dataNews];
                                           [self.tableView reloadData];
                                           [self doneLoadingTableViewData];
                                       }
                                       @catch (NSException *exception) {
                                           [NdUncaughtExceptionHandler TakeException:exception];
                                       }
                                       @finally {
                                           [self doneLoadingTableViewData];
                                       }
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       NSLog(@"列表获取出错");
                                       //如果是刷新
                                       [self doneLoadingTableViewData];
                                       
                                       if ([UserModel Instance].isNetworkRunning == NO) {
                                           return;
                                       }
                                       isLoading = NO;
                                       if ([UserModel Instance].isNetworkRunning) {
                                           [Tool showCustomHUD:@"网络不给力" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
                                       }
                                   }];
        isLoading = YES;
    }
}

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([UserModel Instance].isNetworkRunning) {
        if (isLoadOver) {
            return estateData.count == 0 ? 1 : estateData.count;
        }
        else
            return estateData.count + 1;
    }
    else
        return estateData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    if (row < [estateData count])
    {
        return 83.0;
    }
    else
    {
        return 40.0;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    cell.backgroundColor = [Tool getBackgroundColor];
}

//列表数据渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    if ([estateData count] > 0) {
        if (row < [estateData count])
        {
            BuildingPageCell *cell = [tableView dequeueReusableCellWithIdentifier:BuildingPageCellIdentifier];
            if (!cell) {
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"BuildingPageCell" owner:self options:nil];
                for (NSObject *o in objects) {
                    if ([o isKindOfClass:[BuildingPageCell class]]) {
                        cell = (BuildingPageCell *)o;
                        break;
                    }
                }
            }
            Estate *estate = [estateData objectAtIndex:row];
            cell.titleLb.text = estate.estateName;
            cell.descLb.text = [Tool flattenHTML:estate.content];
            [cell.photoIv sd_setImageWithURL:[NSURL URLWithString:estate.imgUrlFull] placeholderImage:[UIImage imageNamed:@"placeHoder"]];
            [Tool roundTextView:cell.photoIv andBorderWidth:0.0 andCornerRadius:3.0];
            return cell;
            
        }
        else
        {
            return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"已经加载全部" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
        }
    }
    else
    {
        return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"暂无数据" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
    }
}

//表格行点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = [indexPath row];
    //点击“下面20条”
    if (row >= [estateData count]) {
        //启动刷新
        if (!isLoading) {
            gNoRefresh = YES;
            [self performSelector:@selector(reload:)];
        }
    }
    else
    {
        Estate *estate = [estateData objectAtIndex:row];
        NSString *estateDetailHtm = [NSString stringWithFormat:@"%@%@%@", api_base_url, htm_estateInfoDetail ,estate.estateId];
        CommDetailView *detailView = [[CommDetailView alloc] init];
        detailView.titleStr = @"楼盘详情";
        detailView.urlStr = estateDetailHtm;
        [self.navigationController pushViewController:detailView animated:YES];
    }
}

#pragma 下提刷新
- (void)reloadTableViewDataSource
{
    _reloading = YES;
}

- (void)doneLoadingTableViewData
{
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self reloadTableViewDataSource];
    [self refresh];
}

// tableView添加拉更新
- (void)egoRefreshTableHeaderDidTriggerToBottom
{
    if (!isLoading) {
        gNoRefresh = YES;
        [self performSelector:@selector(reload:)];
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return _reloading;
}
- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}
- (void)refresh
{
    if ([UserModel Instance].isNetworkRunning) {
        isLoadOver = NO;
        gNoRefresh = NO;
        [self reload:NO];
    }
}

- (void)dealloc
{
    [self.tableView setDelegate:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
