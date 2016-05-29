//
//  PropertyPageView.m
//  AnYiDian
//
//  Created by Seven on 15/7/14.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "PropertyPageView.h"
#import "SettingModel.h"
#import "PropertyPageCell.h"
#import "AdView.h"
#import "PropertyNewsView.h"
#import "NoticeTableView.h"
#import "AddRepairView.h"
#import "AddSuitWorkView.h"
#import "VolunteerFrameView.h"
#import "ADInfo.h"
#import "CommDetailView.h"
#import "MyPageView.h"
#import "SignInView.h"
#import "PayFeeFrameView.h"
#import "NewsCountAll.h"

@interface PropertyPageView ()
{
    NSArray * services;
    AdView * adView;
    UserInfo *userInfo;
    NSMutableArray *advDatas;
    NewsCountAll *newsCountAll;
}

@end

@implementation PropertyPageView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"物业服务";
    self.tabBarItem.title = @"物业";
    
    newsCountAll = [[UserModel Instance] getNewsCountAll];
    
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithTitle: @"签到" style:UIBarButtonItemStyleBordered target:self action:@selector(signInAction:)];
    self.navigationItem.leftBarButtonItem = leftBtn;
    
    UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [rBtn addTarget:self action:@selector(myViewAction:) forControlEvents:UIControlEventTouchUpInside];
    [rBtn setImage:[UIImage imageNamed:@"head_my"] forState:UIControlStateNormal];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    services = [[NSArray alloc] initWithObjects:
                [[SettingModel alloc] initWith:@"物业报修" andImg:nil andTag:1 andTitle2:@"社区物业为您上门维修"],
                [[SettingModel alloc] initWith: @"缴费" andImg:nil andTag:2 andTitle2:@"在线缴纳物业费、停车费等"],
                [[SettingModel alloc] initWith: @"咨询投诉" andImg:nil andTag:3 andTitle2:@"您对物业的意见，说给我们听"],
                [[SettingModel alloc] initWith: @"小区公告" andImg:nil andTag:4 andTitle2:@"小区物业通知公告"],
                [[SettingModel alloc] initWith: @"居委会通知" andImg:nil andTag:5 andTitle2:@""],
                [[SettingModel alloc] initWith: @"志愿者" andImg:nil andTag:6 andTitle2:@""],
                nil];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self getADVData];
}

- (void)signInAction:(id)sender
{
    SignInView *signIn = [[SignInView alloc] init];
    signIn.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:signIn animated:YES];
}

- (void)myViewAction:(id)sender
{
    MyPageView *myPage = [[MyPageView alloc] init];
    myPage.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:myPage animated:YES];
}

- (void)getADVData
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        //生成获取广告URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:@"1141793407977800" forKey:@"typeId"];
        [param setValue:userInfo.defaultUserHouse.cellId forKey:@"cellId"];
        [param setValue:@"1" forKey:@"timeCon"];
        NSString *getADDataUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findAdInfoList] params:param];
        
        [[AFOSCClient sharedClient]getPath:getADDataUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           advDatas = [Tool readJsonStrToAdinfoArray:operation.responseString];
                                           NSInteger length = [advDatas count];
                                           
                                           if (length > 0)
                                           {
                                               [self initAdView];
                                           }
                                       }
                                       @catch (NSException *exception) {
                                           [NdUncaughtExceptionHandler TakeException:exception];
                                       }
                                       @finally {
                                           
                                       }
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       if ([UserModel Instance].isNetworkRunning == NO) {
                                           return;
                                       }
                                       if ([UserModel Instance].isNetworkRunning) {
                                           [Tool showCustomHUD:@"网络不给力" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
                                       }
                                   }];
    }
}

- (void)initAdView
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    NSMutableArray *imagesURL = [[NSMutableArray alloc] init];
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    if ([advDatas count] > 0) {
        for (ADInfo *ad in advDatas) {
            [imagesURL addObject:ad.imgUrlFull];
            [titles addObject:ad.adName];
        }
    }
    
    //如果你的这个广告视图是添加到导航控制器子控制器的View上,请添加此句,否则可忽略此句
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    adView = [AdView adScrollViewWithFrame:CGRectMake(0, 0, width, 183)  \
                              imageLinkURL:imagesURL\
                       placeHoderImageName:@"placeHoder.jpg" \
                      pageControlShowStyle:UIPageControlShowStyleLeft];
    
    //    是否需要支持定时循环滚动，默认为YES
    //    adView.isNeedCycleRoll = YES;
    
    [adView setAdTitleArray:titles withShowStyle:AdTitleShowStyleNone];
    //    设置图片滚动时间,默认3s
    //    adView.adMoveTime = 2.0;
    
    //图片被点击后回调的方法
    adView.callBack = ^(NSInteger index,NSString * imageURL)
    {
        NSLog(@"被点中图片的索引:%ld---地址:%@",index,imageURL);
        ADInfo *adv = (ADInfo *)[advDatas objectAtIndex:index];
        NSString *adDetailHtm = [NSString stringWithFormat:@"%@%@%@", api_base_url, htm_adDetail ,adv.adId];
        CommDetailView *detailView = [[CommDetailView alloc] init];
        detailView.titleStr = @"详情";
        detailView.urlStr = adDetailHtm;
        detailView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detailView animated:YES];
    };
    [self.headerView addSubview:adView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma TableView的处理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SettingModel *action = [services objectAtIndex:[indexPath row]];
    //开始处理
    switch (action.tag) {
        case 1:
        {
            AddRepairView *repairView = [[AddRepairView alloc] init];
            repairView.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:repairView animated:YES];
        }
            break;
        case 2:
        {
            PayFeeFrameView *payfee = [[PayFeeFrameView alloc] init];
            payfee.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:payfee animated:YES];
        }
            break;
        case 3:
        {
            AddSuitWorkView *addSuitView = [[AddSuitWorkView alloc] init];
            addSuitView.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:addSuitView animated:YES];
        }
            break;
        case 4:
        {
            newsCountAll.hisPushCount = newsCountAll.pushCount;
            [[UserModel Instance] saveNewsCountAll:newsCountAll];
            NoticeTableView *noticeView = [[NoticeTableView alloc] init];
            noticeView.hidesBottomBarWhenPushed = YES;
            noticeView.isCommittee = @"0";
            noticeView.title = @"小区公告";
            [self.navigationController pushViewController:noticeView animated:YES];
            [self.tableView reloadData];
        }
            break;
        case 5:
        {
            NoticeTableView *noticeView = [[NoticeTableView alloc] init];
            noticeView.hidesBottomBarWhenPushed = YES;
            noticeView.isCommittee = @"1";
            noticeView.title = @"居委会通知";
            [self.navigationController pushViewController:noticeView animated:YES];
        }
            break;
        case 6:
        {
            VolunteerFrameView *volunteerView = [[VolunteerFrameView alloc] init];
            volunteerView.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:volunteerView animated:YES];
        }
            break;
            
            

        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [services count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PropertyPageCell *cell = [tableView dequeueReusableCellWithIdentifier:PropertyPageCellIdentifier];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PropertyPageCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[PropertyPageCell class]]) {
                cell = (PropertyPageCell *)o;
                break;
            }
        }
    }
    
    NSUInteger row = [indexPath row];
    SettingModel *model = [services objectAtIndex:row];
    cell.titleLb.text = model.title;
    cell.detailLb.text = model.title2;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (model.tag == 4) {
        if(newsCountAll.pushCount > newsCountAll.hisPushCount)
        {
            cell.reddotIv.hidden = NO;
        }
        else
        {
            cell.reddotIv.hidden = YES;
        }
    }
    
    return cell;
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
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    self.navigationController.navigationBar.hidden = NO;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
}

- (IBAction)hydtAction:(id)sender {
    PropertyNewsView *proNewsView = [[PropertyNewsView alloc] init];
    proNewsView.title = @"行业动态";
    proNewsView.typeId = @"0";
    proNewsView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:proNewsView animated:YES];
}

- (IBAction)zcfgAction:(id)sender {
    PropertyNewsView *proNewsView = [[PropertyNewsView alloc] init];
    proNewsView.title = @"政策法规";
    proNewsView.typeId = @"1";
    proNewsView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:proNewsView animated:YES];
}

- (IBAction)zbxxAction:(id)sender {
    PropertyNewsView *proNewsView = [[PropertyNewsView alloc] init];
    proNewsView.title = @"招标信息";
    proNewsView.typeId = @"2";
    proNewsView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:proNewsView animated:YES];
}

- (IBAction)tzggAction:(id)sender {
    PropertyNewsView *proNewsView = [[PropertyNewsView alloc] init];
    proNewsView.title = @"通知公告";
    proNewsView.typeId = @"3";
    proNewsView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:proNewsView animated:YES];
}
@end
