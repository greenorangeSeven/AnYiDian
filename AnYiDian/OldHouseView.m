//
//  OldHouseView.m
//  AnYiDian
//
//  Created by Seven on 15/8/4.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "OldHouseView.h"
#import "OldHouseCell.h"
#import "UIImageView+WebCache.h"
#import "CommDetailView.h"
#import "AdView.h"

@interface OldHouseView ()

@end

@implementation OldHouseView

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
    
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    houseData = [[NSMutableArray alloc] initWithCapacity:20];
    [self getTopBusinessInfo];
    [self reload:YES];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    _refreshHeaderView = nil;
    [houseData removeAllObjects];
    houseData = nil;
    [super viewDidUnload];
}

- (void)clear
{
    allCount = 0;
    [houseData removeAllObjects];
    isLoadOver = NO;
}

- (void)getTopBusinessInfo
{
    //生成获取列表URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:self.typeId forKey:@"typeId"];
    NSString *getTopDataUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findTopBusinessInfo] params:param];
    
    [[AFOSCClient sharedClient]getPath:getTopDataUrl parameters:Nil
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   
                                   topHouseData = [Tool readJsonStrToTradeTopArray:operation.responseString];
                                   if ([topHouseData count] > 0) {
                                       [self initAdView];
                                   }
                               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   NSLog(@"列表获取出错");
                                   
                                   if ([UserModel Instance].isNetworkRunning == NO) {
                                       return;
                                   }
                                   if ([UserModel Instance].isNetworkRunning) {
                                       [Tool showCustomHUD:@"网络不给力" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
                                   }
                               }];
}

- (void)initAdView
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    NSMutableArray *imagesURL = [[NSMutableArray alloc] init];
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    if ([topHouseData count] > 0) {
        for (Trade *trade in topHouseData) {
            [imagesURL addObject:trade.imgUrlFull];
            
            NSMutableString *contentMuStr = [[NSMutableString alloc] init];
            if ([trade.area length] > 0) {
                [contentMuStr appendString:[NSString stringWithFormat:@"%@㎡", trade.area]];
            }
            [contentMuStr appendString:[NSString stringWithFormat:@"  评估价格:%.2f%@\n%@", trade.price, trade.priceUnitName, trade.content]];
            
            [titles addObject:contentMuStr];
        }
    }
    
    //如果你的这个广告视图是添加到导航控制器子控制器的View上,请添加此句,否则可忽略此句
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    adView = [AdView adScrollViewWithFrame:CGRectMake(0, 0, width, 200)  \
                              imageLinkURL:imagesURL\
                       placeHoderImageName:@"placeHoder.jpg" \
                      pageControlShowStyle:UIPageControlShowStyleLeft];
    
    //    是否需要支持定时循环滚动，默认为YES
    //    adView.isNeedCycleRoll = YES;
    
    [adView setAdTitleArray:titles withShowStyle:AdTitleShowStyleRight];
    //    设置图片滚动时间,默认3s
    //    adView.adMoveTime = 2.0;
    
    //图片被点击后回调的方法
    adView.callBack = ^(NSInteger index,NSString * imageURL)
    {
        NSLog(@"被点中图片的索引:%ld---地址:%@",index,imageURL);
        Trade *trade = [topHouseData objectAtIndex:index];
        NSString *pushDetailHtm = [NSString stringWithFormat:@"%@%@?accessId=%@&businessId=%@", api_base_url, htm_businessDetail , Appkey, trade.businessId];
        CommDetailView *detailView = [[CommDetailView alloc] init];
        detailView.titleStr = @"交易详情";
        detailView.urlStr = pushDetailHtm;
        [self.navigationController pushViewController:detailView animated:YES];
    };
    [self.headerView addSubview:adView];
}

- (void)reload:(BOOL)noRefresh
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        if (isLoading || isLoadOver) {
            return;
        }
        if (!noRefresh) {
            allCount = 0;
        }
        int pageIndex = allCount/20 + 1;
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:self.typeId forKey:@"typeId"];
        [param setValue:[NSString stringWithFormat:@"%d", pageIndex] forKey:@"pageNumbers"];
        [param setValue:@"20" forKey:@"countPerPages"];
        [param setValue:@"1" forKey:@"stateId"];
        
        NSString *businessInfoUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findBusinessInfoByPage] params:param];
        [[AFOSCClient sharedClient] getPath:businessInfoUrl parameters:nil
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        
                                        NSMutableArray *houseNews = [Tool readJsonStrToTradeArray:operation.responseString];
                                        isLoading = NO;
                                        if (!noRefresh) {
                                            [self clear];
                                        }
                                        
                                        @try {
                                            NSInteger count = [houseNews count];
                                            allCount += count;
                                            if (count < 20)
                                            {
                                                isLoadOver = YES;
                                            }
                                            [houseData addObjectsFromArray:houseNews];
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
            return houseData.count == 0 ? 1 : houseData.count;
        }
        else
            return houseData.count + 1;
    }
    else
        return houseData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    if (row < [houseData count])
    {
        return 100.0;
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
    if ([houseData count] > 0) {
        if (row < [houseData count])
        {
            OldHouseCell *cell = [tableView dequeueReusableCellWithIdentifier:OldHouseCellIdentifier];
            if (!cell) {
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"OldHouseCell" owner:self options:nil];
                for (NSObject *o in objects) {
                    if ([o isKindOfClass:[OldHouseCell class]]) {
                        cell = (OldHouseCell *)o;
                        break;
                    }
                }
            }
            Trade *trade = [houseData objectAtIndex:row];
            cell.titleLb.text = trade.title;
            
            NSMutableString *contentMuStr = [[NSMutableString alloc] init];
            if ([trade.area length] > 0) {
                [contentMuStr appendString:[NSString stringWithFormat:@"面积:%@㎡", trade.area]];
            }
            [contentMuStr appendString:[NSString stringWithFormat:@"  评估价格:%.2f%@\n%@", trade.price, trade.priceUnitName, trade.content]];
            cell.contentLb.text = [NSString stringWithString:contentMuStr];
            
            [cell.phoneBtn setTitle:[NSString stringWithFormat:@"  电话:%@", trade.phone] forState:UIControlStateNormal];
            
            [cell.imageIv sd_setImageWithURL:[NSURL URLWithString:trade.imgUrlFull] placeholderImage:[UIImage imageNamed:@"placeHoder"]];
            
            [cell.phoneBtn addTarget:self action:@selector(telAction:) forControlEvents:UIControlEventTouchUpInside];
            cell.tag = row;
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

- (IBAction)telAction:(id)sender
{
    UIButton *tap = (UIButton *)sender;
    if (tap) {
        Trade *trade = [houseData objectAtIndex:tap.tag];
        if ([trade.phone length] > 0) {
            NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", trade.phone]];
            if (!phoneWebView) {
                phoneWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
            }
            [phoneWebView loadRequest:[NSURLRequest requestWithURL:phoneUrl]];
        }
    }
    
    
}

//表格行点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = [indexPath row];
    //点击“下面20条”
    if (row >= [houseData count]) {
        //启动刷新
        if (!isLoading) {
            [self performSelector:@selector(reload:)];
        }
    }
    else
    {
        Trade *trade = [houseData objectAtIndex:row];
        NSString *pushDetailHtm = [NSString stringWithFormat:@"%@%@?accessId=%@&businessId=%@", api_base_url, htm_businessDetail , Appkey, trade.businessId];
        CommDetailView *detailView = [[CommDetailView alloc] init];
        detailView.titleStr = @"交易详情";
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

@end
