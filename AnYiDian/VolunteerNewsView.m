//
//  VolunteerNewsView.m
//  AnYiDian
//
//  Created by Seven on 15/7/21.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "VolunteerNewsView.h"
#import "PropertyNews.h"
#import "PropertyNewsCell.h"
#import "VolunteerNewsCell.h"
#import "CommDetailView.h"
#import "UIImageView+WebCache.h"

@interface VolunteerNewsView ()
{
    BOOL gNoRefresh;
}

@end

@implementation VolunteerNewsView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = self.frameView.frame.size.height;
    tableFrame.size.width = self.frameView.frame.size.width;
    self.tableView.frame = tableFrame;
    
    CGRect viewFrame = self.view.frame;
    viewFrame.size.height = self.frameView.frame.size.height;
    viewFrame.size.width = self.frameView.frame.size.width;
    self.view.frame = viewFrame;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //    设置无分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    allCount = 0;
    //添加的代码
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    
    newsData = [[NSMutableArray alloc] initWithCapacity:20];
    
    gNoRefresh = YES;
    [self reload:YES];
    
    [self getUrl];
}

- (void)getUrl
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:@"1" forKey:@"pageNumbers"];
    [param setValue:@"20" forKey:@"countPerPages"];
    [param setValue:@"0" forKey:@"typeId"];
    NSString *getNoticeListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findVolunteerNewsInfoByPage] params:param];
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
        
        //生成获取列表URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:[NSString stringWithFormat:@"%d", pageIndex] forKey:@"pageNumbers"];
        [param setValue:@"20" forKey:@"countPerPages"];
        [param setValue:self.typeId forKey:@"typeId"];
        NSString *getNewsListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findVolunteerNewsInfoByPage] params:param];
        
        [[AFOSCClient sharedClient]getPath:getNewsListUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                                       NSError *error;
                                       NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                       
                                       NSDictionary *datas = [json objectForKey:@"data"];
                                       NSArray *array = [datas objectForKey:@"resultsList"];
                                       
                                       NSMutableArray *noticeNews = [NSMutableArray arrayWithArray:[Tool readJsonToObjArray:array andObjClass:[PropertyNews class]]];
                                       isLoading = NO;
                                       if (!gNoRefresh) {
                                           [self clear];
                                       }
                                       
                                       @try {
                                           NSUInteger count = [noticeNews count];
                                           allCount += count;
                                           if (count < 20)
                                           {
                                               isLoadOver = YES;
                                           }
                                           [newsData addObjectsFromArray:noticeNews];
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


- (void)viewDidUnload
{
    [self setTableView:nil];
    _refreshHeaderView = nil;
    [newsData removeAllObjects];
    newsData = nil;
    [super viewDidUnload];
}

- (void)clear
{
    allCount = 0;
    [newsData removeAllObjects];
    isLoadOver = NO;
}

#pragma TableView的处理


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    if (row < [newsData count])
    {
        if (row == 0)
        {
            return 158.0;
        }
        else
        {
            return 91.0;
        }
    }
    else
    {
        return 40.0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([UserModel Instance].isNetworkRunning) {
        if (isLoadOver) {
            return newsData.count == 0 ? 1 : newsData.count;
        }
        else
            return newsData.count + 1;
    }
    else
        return newsData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    if ([newsData count] > 0) {
        if (row < [newsData count])
        {
            if (row == 0) {
                VolunteerNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:VolunteerNewsCellIdentifier];
                if (!cell) {
                    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"VolunteerNewsCell" owner:self options:nil];
                    for (NSObject *o in objects) {
                        if ([o isKindOfClass:[VolunteerNewsCell class]]) {
                            cell = (VolunteerNewsCell *)o;
                            break;
                        }
                    }
                }
                
                NSUInteger row = [indexPath row];
                PropertyNews *news = [newsData objectAtIndex:row];
                
                cell.titleLb.text = news.title;
                [cell.imageIv sd_setImageWithURL:[NSURL URLWithString:news.imgFull] placeholderImage:[UIImage imageNamed:@"placeHoder"]];
                return cell;
            }
            else
            {
                PropertyNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:PropertyNewsCellIdentifier];
                if (!cell) {
                    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PropertyNewsCell" owner:self options:nil];
                    for (NSObject *o in objects) {
                        if ([o isKindOfClass:[PropertyNewsCell class]]) {
                            cell = (PropertyNewsCell *)o;
                            break;
                        }
                    }
                }
                
                NSUInteger row = [indexPath row];
                PropertyNews *news = [newsData objectAtIndex:row];
                
                cell.titleLb.text = news.title;
                cell.contentLb.text = news.desc;
                [cell.imageIv sd_setImageWithURL:[NSURL URLWithString:news.imgFull] placeholderImage:[UIImage imageNamed:@"placeHoder"]];
                [Tool roundTextView:cell.imageIv andBorderWidth:0.0 andCornerRadius:3.0];
                return cell;
            }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = [indexPath row];
    //点击“下面20条”
    if (row >= [newsData count]) {
        //启动刷新
        if (!isLoading) {
            gNoRefresh = YES;
            [self performSelector:@selector(reload:)];
        }
    }
    else
    {
        PropertyNews *news = [newsData objectAtIndex:[indexPath row]];
        NSString *pushDetailHtm = [NSString stringWithFormat:@"%@%@%@", api_base_url, htm_volunteerNewsDetail ,news.newsId];
        CommDetailView *detailView = [[CommDetailView alloc] init];
        detailView.titleStr = @"详情";
        detailView.urlStr = pushDetailHtm;
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
}

@end
