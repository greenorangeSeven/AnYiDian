//
//  MainPageView.m
//  AnYiDian
//
//  Created by Seven on 15/7/13.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "MainPageView.h"
#import "AdView.h"
#import "ADInfo.h"
#import "AddRepairView.h"
#import "AddSuitWorkView.h"
#import "LifeReferView.h"
#import "MyPageView.h"
#import "SignInView.h"
#import "CommDetailView.h"
#import "NewsHouseView.h"
#import "Estate.h"
#import "UIImageView+WebCache.h"
#import "ErShouFangFrameView.h"
#import "ConvenienceTypeView.h"
#import "NoticeTableView.h"
#import "GrouponClassView.h"
#import "PayFeeFrameView.h"

@interface MainPageView ()
{
    AdView * adView;
    UserInfo *userInfo;
    NSMutableArray *advDatas;
}

@end

@implementation MainPageView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    userInfo = [[UserModel Instance] getUserInfo];
//    [self testAction];
    self.title = userInfo.defaultUserHouse.cellName;
    self.tabBarItem.title = @"首页";
    
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithTitle: @"签到" style:UIBarButtonItemStyleBordered target:self action:@selector(signInAction:)];
    self.navigationItem.leftBarButtonItem = leftBtn;
    
    UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [rBtn addTarget:self action:@selector(myViewAction:) forControlEvents:UIControlEventTouchUpInside];
    [rBtn setImage:[UIImage imageNamed:@"head_my"] forState:UIControlStateNormal];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    [Tool roundTextView:self.newsHouseView andBorderWidth:1.0 andCornerRadius:5.0];
    [Tool roundTextView:self.ershouHouseView andBorderWidth:1.0 andCornerRadius:5.0];
    
    [self addTapAction];
    [self getADVData];
    [self getEstateData];
    [self getESFData];
}

- (void)addTapAction
{
    //生活助手点击
    UITapGestureRecognizer *lifeQueryTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lifeQueryTapClick)];
    [self.lifeQueryView addGestureRecognizer:lifeQueryTap];
    
    //生活服务点击
    UITapGestureRecognizer *lifeServiceTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lifeServiceTapClick)];
    [self.lifeServiceView addGestureRecognizer:lifeServiceTap];
    
    //新房信息
    UITapGestureRecognizer *newsHouseTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(newsHouseTapClick)];
    [self.newsHouseView addGestureRecognizer:newsHouseTap];
    
    //二手房交易
    UITapGestureRecognizer *oldHouseTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oldHouseTapClick)];
    [self.ershouHouseView addGestureRecognizer:oldHouseTap];
    
    //生活超市
    UITapGestureRecognizer *supermarketTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(supermarketTapClick)];
    [self.supermarketView addGestureRecognizer:supermarketTap];
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

- (void)lifeQueryTapClick
{
    LifeReferView *lifeReferView = [[LifeReferView alloc] init];
    lifeReferView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:lifeReferView animated:YES];
}

- (void)lifeServiceTapClick
{
    ConvenienceTypeView *lifeServiceView = [[ConvenienceTypeView alloc] init];
    lifeServiceView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:lifeServiceView animated:YES];
}

- (void)newsHouseTapClick
{
    NewsHouseView *newsHouse = [[NewsHouseView alloc] init];
    newsHouse.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:newsHouse animated:YES];
}

- (void)oldHouseTapClick
{
    ErShouFangFrameView *oldHouse = [[ErShouFangFrameView alloc] init];
    oldHouse.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:oldHouse animated:YES];
}

- (void)supermarketTapClick
{
    GrouponClassView *supermarket = [[GrouponClassView alloc] init];
    supermarket.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:supermarket animated:YES];
}

- (void)getADVData
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        //生成获取广告URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:@"1141788149430600" forKey:@"typeId"];
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
    
    [adView setAdTitleArray:titles withShowStyle:AdTitleShowStyleRight];
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
    [self.view addSubview:adView];
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

- (IBAction)repairAction:(id)sender {
    AddRepairView *repairView = [[AddRepairView alloc] init];
    repairView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:repairView animated:YES];
}

- (IBAction)suitAction:(id)sender {
    AddSuitWorkView *addSuitView = [[AddSuitWorkView alloc] init];
    addSuitView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addSuitView animated:YES];
}

- (IBAction)committeeNoticeAction:(id)sender {
    NoticeTableView *noticeView = [[NoticeTableView alloc] init];
    noticeView.hidesBottomBarWhenPushed = YES;
    noticeView.isCommittee = @"1";
    noticeView.title = @"居委会通知";
    [self.navigationController pushViewController:noticeView animated:YES];
}

- (IBAction)payfeeAction:(id)sender {
    PayFeeFrameView *payfee = [[PayFeeFrameView alloc] init];
    payfee.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:payfee animated:YES];
}

- (void)getEstateData
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:@"1" forKey:@"countPerPages"];
        [param setValue:@"1" forKey:@"pageNumbers"];
        NSString *getEstateListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findEstateInfoByPage] params:param];
        
        [[AFOSCClient sharedClient]getPath:getEstateListUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                                           NSError *error;
                                           NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                           
                                           NSDictionary *datas = [json objectForKey:@"data"];
                                           NSArray *array = [datas objectForKey:@"resultsList"];
                                           
                                           NSMutableArray *estateData = [NSMutableArray arrayWithArray:[Tool readJsonToObjArray:array andObjClass:[Estate class]]];
                                           if ([estateData count] > 0) {
                                               Estate *estate = (Estate *)[estateData objectAtIndex:0];
                                               self.newsHouseNameLb.text = estate.estateName;
                                               self.newsHouseContentLb.text = [Tool flattenHTML:estate.content];
                                               [self.newsHouseImg sd_setImageWithURL:[NSURL URLWithString:estate.imgUrlFull] placeholderImage:[UIImage imageNamed:@"placeHoder"]];
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

- (void)getESFData
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:@"1" forKey:@"typeId"];
    [param setValue:@"1" forKey:@"pageNumbers"];
    [param setValue:@"1" forKey:@"countPerPages"];
    [param setValue:@"1" forKey:@"stateId"];
    
    NSString *businessInfoUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findBusinessInfoByPage] params:param];
    [[AFOSCClient sharedClient]getPath:businessInfoUrl parameters:Nil
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   @try {
                                       NSMutableArray *houseNews = [Tool readJsonStrToTradeArray:operation.responseString];
                                       if ([houseNews count] > 0) {
                                           Trade *trade = (Trade *)[houseNews objectAtIndex:0];
                                           self.oldHouseNameLb.text = trade.title;
                                           self.oldHouseContentLb.text = trade.content;
                                           [self.oldHouseImg sd_setImageWithURL:[NSURL URLWithString:trade.imgUrlFull] placeholderImage:[UIImage imageNamed:@"placeHoder"]];
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

//- (void)testAction {
//    //生成登陆URL
//    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
//    [param setValue:@"11111" forKey:@"topic"];
//    [param setValue:@"11111" forKey:@"content"];
//    [param setValue:@"100143615945386700" forKey:@"suserId"];
//    [param setValue:@"100143642578484500" forKey:@"ruserId"];
//    NSString *loginUrl = [Tool serializeURL:@"http://192.168.1.103:8080/jc_api/msg/addMsgInfo.htm" params:param];
//    
//    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:loginUrl]];
//    [request setUseCookiePersistence:NO];
//    [request setTimeOutSeconds:30];
//    [request setDelegate:self];
//    [request setDidFailSelector:@selector(requestFailed:)];
//    [request setDidFinishSelector:@selector(requestLogin:)];
//    [request startAsynchronous];
//    
//    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
//    [Tool showHUD:@"登录中..." andView:self.view andHUD:request.hud];
//}
//
//- (void)requestFailed:(ASIHTTPRequest *)request
//{
//    if (request.hud) {
//        [request.hud hide:NO];
//    }
//    
//}
//- (void)requestLogin:(ASIHTTPRequest *)request
//{
//    if (request.hud) {
//        [request.hud hide:YES];
//    }
//    
//    [request setUseCookiePersistence:YES];
//    NSData *data = [request.responseString dataUsingEncoding:NSUTF8StringEncoding];
//    NSLog(request.responseString);
//}

@end
