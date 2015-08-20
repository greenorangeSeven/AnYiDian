//
//  BuildingPageView.m
//  AnYiDian
//
//  Created by Seven on 15/7/14.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "BuildingPageView.h"
#import "BuildingPageCell.h"
#import "AdView.h"
#import "EstateActivity.h"
#import "EstateActivityDetailView.h"
#import "MyPageView.h"
#import "SignInView.h"
#import "MarketingView.h"
#import "PropertyNews.h"
#import "UIImageView+WebCache.h"
#import "CommDetailView.h"
#import "Estate.h"
#import "PreferentialView.h"

@interface BuildingPageView ()
{
    AdView *adView;
    UserInfo *userInfo;
    NSMutableArray *activityNews;
    NSMutableArray *newsData;
    NSMutableArray *estateData;
}

@end

@implementation BuildingPageView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"房产频道";
    self.tabBarItem.title = @"房产";
    
    userInfo = [[UserModel Instance] getUserInfo];
    
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithTitle: @"签到" style:UIBarButtonItemStyleBordered target:self action:@selector(signInAction:)];
    self.navigationItem.leftBarButtonItem = leftBtn;
    
    UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [rBtn addTarget:self action:@selector(myViewAction:) forControlEvents:UIControlEventTouchUpInside];
    [rBtn setImage:[UIImage imageNamed:@"head_my"] forState:UIControlStateNormal];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self getEstateData];
    [self initNewsTable];
    [self addTapAction];
}

- (void)addTapAction
{
    //全民营销
    UITapGestureRecognizer *marketingTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(marketingTapClick)];
    [self.marketingView addGestureRecognizer:marketingTap];
    //优惠政策
    UITapGestureRecognizer *preferentialTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(preferentialTapClick)];
    [self.preferentialView addGestureRecognizer:preferentialTap];
}

- (void)marketingTapClick
{
    MarketingView *marketingView = [[MarketingView alloc] init];
    marketingView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:marketingView animated:YES];
}

- (void)preferentialTapClick
{
    PreferentialView *preferentialView = [[PreferentialView alloc] init];
    preferentialView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:preferentialView animated:YES];
}

- (void)getUrl
{
    //生成获取列表URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:@"5" forKey:@"countPerPages"];
    [param setValue:@"1" forKey:@"pageNumbers"];
    NSString *getNoticeListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findRecentInfoByPage] params:param];
}

- (void)getEstateData
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:@"5" forKey:@"countPerPages"];
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
                                           
                                           estateData = [NSMutableArray arrayWithArray:[Tool readJsonToObjArray:array andObjClass:[Estate class]]];
                                           if ([estateData count] > 0) {
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

//获取楼盘活动
- (void)initEstateActivity
{
    //生成获取列表URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:userInfo.regUserId forKey:@"userId"];
    NSString *getActivityListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findEstateActivityOnTime] params:param];
    
    [[AFOSCClient sharedClient]getPath:getActivityListUrl parameters:Nil
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   
                                   NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                                   NSError *error;
                                   NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                   
                                   //                                   NSDictionary *datas = [json objectForKey:@"data"];
                                   NSArray *array = [json objectForKey:@"data"];
                                   
                                   activityNews = [NSMutableArray arrayWithArray:[Tool readJsonToObjArray:array andObjClass:[EstateActivity class]]];
                                   if ([activityNews count] > 0) {
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

- (void)initNewsTable
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:@"5" forKey:@"countPerPages"];
    [param setValue:@"1" forKey:@"pageNumbers"];
    NSString *getNewsListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findRecentInfoByPage] params:param];
    
    [[AFOSCClient sharedClient]getPath:getNewsListUrl parameters:Nil
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                                   NSError *error;
                                   NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                   
                                   NSDictionary *datas = [json objectForKey:@"data"];
                                   NSArray *array = [datas objectForKey:@"resultsList"];
                                   
                                   newsData = [NSMutableArray arrayWithArray:[Tool readJsonToObjArray:array andObjClass:[PropertyNews class]]];
                                   
                                   [self.tableView reloadData];
                                   
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

- (void)initAdView
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    NSMutableArray *imagesURL = [[NSMutableArray alloc] init];
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    if ([estateData count] > 0) {
        for (Estate *estate in estateData) {
            [imagesURL addObject:estate.imgUrlFull];
            [titles addObject:estate.estateName];
        }
    }
    
    //如果你的这个广告视图是添加到导航控制器子控制器的View上,请添加此句,否则可忽略此句
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    adView = [AdView adScrollViewWithFrame:CGRectMake(0, 0, width, 230)  \
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
        Estate *estate = [estateData objectAtIndex:index];
        NSString *estateDetailHtm = [NSString stringWithFormat:@"%@%@%@", api_base_url, htm_estateInfoDetail ,estate.estateId];
        CommDetailView *detailView = [[CommDetailView alloc] init];
        detailView.titleStr = @"楼盘详情";
        detailView.urlStr = estateDetailHtm;
        [self.navigationController pushViewController:detailView animated:YES];
    };
    [self.headerView addSubview:adView];
}

#pragma TableView的处理

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 83;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return newsData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
    
    NSUInteger row = [indexPath row];
    PropertyNews *news = [newsData objectAtIndex:row];
    cell.titleLb.text = news.title;
    cell.descLb.text = news.desc;
    [cell.photoIv sd_setImageWithURL:[NSURL URLWithString:news.imgFull] placeholderImage:[UIImage imageNamed:@"placeHoder"]];
    [Tool roundTextView:cell.photoIv andBorderWidth:0.0 andCornerRadius:3.0];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger row = [indexPath row];
    PropertyNews *news = [newsData objectAtIndex:row];
    NSString *recentDetailHtm = [NSString stringWithFormat:@"%@%@%@", api_base_url, htm_recentDetail ,news.newsId];
    CommDetailView *detailView = [[CommDetailView alloc] init];
    detailView.titleStr = @"详情";
    detailView.urlStr = recentDetailHtm;
    detailView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailView animated:YES];
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

@end
