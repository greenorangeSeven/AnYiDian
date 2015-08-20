//
//  IntegralView.m
//  WHDLife
//
//  Created by Seven on 15-1-23.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "IntegralView.h"
#import "IntegralCell.h"
#import "Integral.h"

@interface IntegralView ()
{
    UserInfo *userInfo;
    NSMutableArray *seleteArray;
}

@end

@implementation IntegralView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    userInfo = [[UserModel Instance] getUserInfo];
    
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.frameView.frame.size.height);
    seleteArray = [[NSMutableArray alloc] init];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
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
    
    integrals = [[NSMutableArray alloc] initWithCapacity:40];
    [self refreshIntegralData];
}

- (void)refreshIntegralData
{
    //生成获取物业物品URL
    NSMutableDictionary *param2 = [[NSMutableDictionary alloc] init];
    [param2 setValue:userInfo.defaultUserHouse.cellId forKey:@"cellId"];
    NSString *findExpressinInfoByPageUrl2 = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_peripheralShop] params:param2];
    
    
    //生成获取物业物品URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:userInfo.regUserId forKey:@"regUserId"];
    [param setValue:@"1" forKey:@"pageNumbers"];
    [param setValue:@"40" forKey:@"countPerPages"];
    [param setValue:@"0" forKey:@"isHide"];
    NSString *findExpressinInfoByPageUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findIntegral] params:param];
    [[AFOSCClient sharedClient]getPath:findExpressinInfoByPageUrl parameters:Nil
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   @try {
                                       NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                                       NSError *error;
                                       NSDictionary *billJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                       NSDictionary *totalMap = [[billJsonDic objectForKey:@"data"] objectForKey:@"totalMap"];
                                       int total = [[totalMap objectForKey:@"total_integral"] intValue];
                                       self.totalLb.text = [NSString stringWithFormat:@"总积分:%d", total];
                                       
                                       [integrals removeAllObjects];
                                       integrals = [Tool readJsonStrToIntegralArray:operation.responseString];
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
                                   //如果是刷新
                                   [self doneLoadingTableViewData];
                                   if ([UserModel Instance].isNetworkRunning == NO) {
                                       return;
                                   }
                                   if ([UserModel Instance].isNetworkRunning) {
                                       [Tool showCustomHUD:@"网络不给力" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
                                   }
                               }];
    
}

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([integrals count] == 0)
    {
        return 1;
    }
    else
    {
        return integrals.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    cell.backgroundColor = [Tool getBackgroundColor];
}

//列表数据渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([integrals count] > 0) {
        IntegralCell *cell = [tableView dequeueReusableCellWithIdentifier:IntegralCellIdentifier];
        if (!cell) {
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"IntegralCell" owner:self options:nil];
            for (NSObject *o in objects) {
                if ([o isKindOfClass:[IntegralCell class]]) {
                    cell = (IntegralCell *)o;
                    break;
                }
            }
        }
        int row = [indexPath row];
        Integral *integral = [integrals objectAtIndex:row];
        cell.contentLb.text = integral.content;
        cell.timeLb.text = integral.starttime;
        if(integral.integral > 0)
        {
            cell.integralLb.text = [NSString stringWithFormat:@"+%d", integral.integral];
        }
        else
        {
            cell.integralLb.text = [NSString stringWithFormat:@"%d", integral.integral];
        }
        
        return cell;
    }
    else
    {
        return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:NO andLoadOverString:@"暂无数据" andLoadingString:@"暂无数据" andIsLoading:NO];
    }
}

//表格行点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
        [self refreshIntegralData];
    }
}

- (void)dealloc
{
    [self.tableView setDelegate:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    self.navigationController.navigationBar.hidden = NO;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    _refreshHeaderView = nil;
    [integrals removeAllObjects];
    integrals = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
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

@end