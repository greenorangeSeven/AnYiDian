//
//  PayFeeTableView.m
//  AnYiDian
//
//  Created by Seven on 15/8/13.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "PayFeeTableView.h"
#import "UIImageView+WebCache.h"
#import "PayFeeCell.h"
#import "Bill.h"
#import "PayFeeDetailView.h"
#import "SSCheckBoxView.h"
#import "PayFeeDetailNewsView.h"

@interface PayFeeTableView ()
{
    UserInfo *userInfo;
    BOOL gNoRefresh;
    NSMutableArray *goBillData;
    double totalMoney;
    SSCheckBoxView *selectAllCB;
}

@end

@implementation PayFeeTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    userInfo = [[UserModel Instance] getUserInfo];
    
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = self.frameView.frame.size.height;
    tableFrame.size.width = self.frameView.frame.size.width;
    self.view.frame = tableFrame;
    
//    CGRect viewFrame = self.view.frame;
//    viewFrame.size.height = self.frameView.frame.size.height;
//    viewFrame.size.width = self.frameView.frame.size.width;
//    self.view.frame = viewFrame;
    
    totalMoney = 0.00;
    goBillData = [[NSMutableArray alloc] init];
    
    self.tableView.tableHeaderView = self.headerView;
    
    //图片圆形处理
    self.faceBg1View.layer.masksToBounds = YES;
    self.faceBg1View.layer.cornerRadius = self.faceBg1View.frame.size.height / 2;    //最重要的是这个地方要设成imgview高的一半
    
    self.faceBg2View.layer.masksToBounds = YES;
    self.faceBg2View.layer.cornerRadius = self.faceBg2View.frame.size.height / 2;    //最重要的是这个地方要设成imgview高的一半
    
    self.faceIv.layer.masksToBounds = YES;
    self.faceIv.layer.cornerRadius = self.faceIv.frame.size.height / 2;    //最重要的是这个地方要设成imgview高的一半
    
    self.payfeeBtn.layer.masksToBounds = YES;
    self.payfeeBtn.layer.cornerRadius = 10;
    
    userInfo = [[UserModel Instance] getUserInfo];
    [self.faceIv sd_setImageWithURL:[NSURL URLWithString:userInfo.photoFull] placeholderImage:[UIImage imageNamed:@"default_head.png"]];
    
    self.mobileNoLb.text = [NSString stringWithFormat:@"手机号码：%@", userInfo.mobileNo];
    self.userInfoLb.text = [NSString stringWithFormat:@"%@%@%@    %@", userInfo.defaultUserHouse.cellName, userInfo.defaultUserHouse.buildingName, userInfo.defaultUserHouse.numberName, userInfo.regUserName];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
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
    
    fees = [[NSMutableArray alloc] initWithCapacity:999];
    gNoRefresh = YES;
    [self reload:YES];
    
    selectAllCB = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(12, 12, 30, 30) style:kSSCheckBoxViewStyleGreen checked:NO];
    [selectAllCB setStateChangedBlock:^(SSCheckBoxView *cbv) {
        if (cbv.checked) {
            for (Bill *bill in fees) {
                if (bill.stateId != 1) {
                    bill.ischeck = YES;
                }
            }
        }
        else
        {
            for (Bill *bill in fees) {
                if (bill.stateId != 1) {
                    bill.ischeck = NO;
                }
            }
        }
        [self totalSelectMoney];
        [self.tableView reloadData];
    }];
    [self.operationView addSubview:selectAllCB];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshed:) name:Notification_RefreshPayFeeTableView object:nil];
}

- (void)totalSelectMoney
{
    [goBillData removeAllObjects];
    totalMoney = 0.00;
    NSUInteger nofeeNum = 0;
    NSUInteger checkNum = 0;
    for (Bill *bill in fees) {
        if (bill.ischeck) {
            totalMoney += bill.totalMoney;
            checkNum += 1;
            [goBillData addObject:bill];
        }
        if (bill.stateId != 1) {
            nofeeNum += 1;
        }
    }
    if (nofeeNum == checkNum)
    {
        [selectAllCB setChecked:YES];
    }
    else
    {
        [selectAllCB setChecked:NO];
    }
    
    self.totalMoneyLb.text = [NSString stringWithFormat:@"合计：%0.2f元", totalMoney];
}

- (void)refreshed:(NSNotification *)notification
{
    [self.tableView setContentOffset:CGPointMake(0, -75) animated:YES];
    [self performSelector:@selector(doneManualRefresh) withObject:nil afterDelay:0.4];
}

- (void)doneManualRefresh
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:self.tableView];
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:self.tableView];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    _refreshHeaderView = nil;
    [fees removeAllObjects];
    fees = nil;
    [super viewDidUnload];
}

- (void)clear
{
    allCount = 0;
    [fees removeAllObjects];
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
//        int pageIndex = allCount/20 + 1;
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:userInfo.defaultUserHouse.numberId forKey:@"numberId"];
        [param setValue:self.typeId forKey:@"typeId"];
        NSString *getBillListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_getBillDetailsForNotPay] params:param];
        
        [[AFOSCClient sharedClient]getPath:getBillListUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       
                                       NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                                       NSError *error;
                                       NSDictionary *billJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                       if ( billJsonDic == nil || [billJsonDic count] <= 0) {
                                           [Tool showCustomHUD:@"系统异常" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
                                       }
                                       NSString *state = [[billJsonDic objectForKey:@"header"] objectForKey:@"state"];
                                       if ([state isEqualToString:@"0000"] == NO) {
                                           UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                                                        message:[[billJsonDic objectForKey:@"header"] objectForKey:@"msg"]
                                                                                       delegate:nil
                                                                              cancelButtonTitle:@"确定"
                                                                              otherButtonTitles:nil];
                                           [av show];
                                       }
                                       
                                       NSMutableArray *feeNews = [Tool readJsonStrToGuizhouBillArray:operation.responseString];
                                       isLoading = NO;
                                       if (!gNoRefresh) {
                                           [self clear];
                                       }
                                       
                                       @try {
                                           NSInteger count = [feeNews count];
                                           allCount += count;
                                           if (count < 20)
                                           {
                                               isLoadOver = YES;
                                           }
                                           [fees addObjectsFromArray:feeNews];
                                           [self totalSelectMoney];
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
            return fees.count == 0 ? 1 : fees.count;
        }
        else
            return fees.count + 1;
    }
    else
        return fees.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    if (row < [fees count]) {
        return 96.0;
    }
    else
    {
        return 30.0;
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
    if ([fees count] > 0) {
        if (row < [fees count])
        {
            
            PayFeeCell *cell = [tableView dequeueReusableCellWithIdentifier:PayFeeCellIdentifier];
            if (!cell) {
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PayFeeCell" owner:self options:nil];
                for (NSObject *o in objects) {
                    if ([o isKindOfClass:[PayFeeCell class]]) {
                        cell = (PayFeeCell *)o;
                        break;
                    }
                }
            }
            Bill *bill = [fees objectAtIndex:row];
            cell.monthLb.text = bill.monthStr;
            cell.moneyLb.text = [NSString stringWithFormat:@"账单总金额%0.2f元", bill.totalMoney];
            if (bill.stateId == 1) {
                cell.stateLb.text = @"已缴费";
                
                cell.stateLb.textColor = [UIColor colorWithRed:177.0/255.0 green:177.0/255.0 blue:177.0/255.0 alpha:1.0];
                cell.monthLb.textColor = [UIColor colorWithRed:177.0/255.0 green:177.0/255.0 blue:177.0/255.0 alpha:1.0];
                cell.moneyLb.textColor = [UIColor colorWithRed:177.0/255.0 green:177.0/255.0 blue:177.0/255.0 alpha:1.0];
            }
            else
            {
                cell.stateLb.text = @"未缴费";
                cell.stateLb.textColor = [Tool getColorForMain];
                cell.monthLb.textColor = [Tool getColorForMain];
                cell.moneyLb.textColor = [UIColor blackColor];
                
                SSCheckBoxView *cb = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(12, 7, 30, 30) style:kSSCheckBoxViewStyleGreen checked:bill.ischeck];
                cb.tag = row;
                [cb setStateChangedBlock:^(SSCheckBoxView *cbv) {
                    if (cbv.checked) {
                        Bill *bill = [fees objectAtIndex:cbv.tag];
                        bill.ischeck = YES;
                    }
                    else
                    {
                        Bill *bill = [fees objectAtIndex:cbv.tag];
                        bill.ischeck = NO;
                        
                    }
                    [self totalSelectMoney];
                }];
                [cell addSubview:cb];
            }
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
    if (row >= [fees count]) {
        //启动刷新
        if (!isLoading) {
            gNoRefresh = YES;
            [self performSelector:@selector(reload:)];
        }
    }
    else
    {
//        Bill *bill = [fees objectAtIndex:row];
//        if (bill && bill.stateId == 0) {
//            PayFeeDetailView *payDetail = [[PayFeeDetailView alloc] init];
//            payDetail.bill = bill;
//            [self.navigationController pushViewController:payDetail animated:YES];
//        }
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

- (IBAction)goPayAction:(id)sender {
    if(goBillData.count <= 0)
    {
        [Tool showCustomHUD:@"请选择缴费账单" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    PayFeeDetailNewsView *payFeeView = [[PayFeeDetailNewsView alloc] init];
    payFeeView.bills = goBillData;
    payFeeView.totalFee = totalMoney;
    [self.navigationController pushViewController:payFeeView animated:YES];
}

@end