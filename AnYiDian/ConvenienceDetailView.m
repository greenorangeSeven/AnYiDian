//
//  ConvenienceDetailView.m
//  BBK
//
//  Created by Seven on 14-12-22.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "ConvenienceDetailView.h"
#import "BMapKit.h"
#import "StoreMapPointView.h"
#import "ShopCommentView.h"

@interface ConvenienceDetailView ()
{
    MBProgressHUD *hud;
    UIWebView *phoneWebView;
}

@end

@implementation ConvenienceDetailView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.titleStr;
    
    //适配iOS7uinavigationbar遮挡的问题
    if(IS_IOS7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在加载" andView:self.view andHUD:hud];
    //WebView的背景颜色去除
    [Tool clearWebViewBackground:self.webView];
    //    [self.webView setScalesPageToFit:YES];
    [self.webView sizeToFit];
    
    if (!self.urlStr) {
        self.urlStr = [NSString stringWithFormat:@"%@%@%@", api_base_url, htm_shopDetail ,self.shopInfo.shopId];
    }
    NSURL *url = [[NSURL alloc]initWithString:self.urlStr];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    self.webView.delegate = self;
    
    [self.praiseBtn setTitle:[NSString stringWithFormat:@"  赞(%d)", self.shopInfo.heartCount]  forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshWebView:) name:Notification_RefreshShopDetailView object:nil];
}

- (void)refreshWebView:(NSNotification *)notification
{
    [Tool showCustomHUD:@"评价成功" andView:self.view andImage:@"37x-Failure.png" andAfterDelay:2];
    [self.webView reload];
}

- (void)webViewDidFinishLoad:(UIWebView *)webViewP
{
    if (hud != nil) {
        [hud hide:YES];
    }
}

#pragma 浏览器链接处理
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString hasSuffix:@"telphone"])
    {
        UserInfo *userInfo = [[UserModel Instance] getUserInfo];
        NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", userInfo.defaultUserHouse.phone]];
        if (!phoneWebView) {
            phoneWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
        }
        [phoneWebView loadRequest:[NSURLRequest requestWithURL:phoneUrl]];
        return NO;
    }
    else if ([request.URL.absoluteString hasSuffix:@"shopMap"])
    {
        CLLocationCoordinate2D coor;
        coor.longitude = self.shopInfo.longitude ;
        coor.latitude = self.shopInfo.latitude;
        StoreMapPointView *pointView = [[StoreMapPointView alloc] init];
        pointView.storeCoor = coor;
        pointView.storeTitle = self.shopInfo.shopName;
        [self.navigationController pushViewController:pointView animated:YES];
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self.webView stopLoading];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)praiseAction:(id)sender{
    self.praiseBtn.enabled = NO;
//    UserInfo *userInfo = [[UserModel Instance] getUserInfo];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:self.shopInfo.shopId forKey:@"shopId"];
//    [param setValue:userInfo.regUserId forKey:@"regUserId"];
    NSString *addShopHeartCountUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_addShopHeartCount] params:param];
    [[AFOSCClient sharedClient]getPath:addShopHeartCountUrl parameters:Nil
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   @try {
                                       NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                                       NSError *error;
                                       NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                       
                                       NSString *state = [[json objectForKey:@"header"] objectForKey:@"state"];
                                       NSString *msg = [[json objectForKey:@"header"] objectForKey:@"msg"];
                                       
                                       if ([state isEqualToString:@"0000"] == YES)
                                       {
//                                           if ([msg isEqualToString:@"点赞成功"]) {
                                               [Tool showCustomHUD:@"点赞成功" andView:self.view andImage:@"37x-Failure.png" andAfterDelay:2];
                                               self.shopInfo.heartCount += 1;
//                                           }
//                                           else
//                                           {
//                                               [Tool showCustomHUD:@"已取消点赞" andView:self.view andImage:@"37x-Failure.png" andAfterDelay:2];
//                                               self.shopInfo.heartCount-= 1;
//                                           }
                                           
                                       }
                                       self.praiseBtn.enabled = YES;
                                       [self.praiseBtn setTitle:[NSString stringWithFormat:@"  赞(%d)", self.shopInfo.heartCount]  forState:UIControlStateNormal];
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
                                       [Tool ToastNotification:@"错误 网络无连接" andView:self.view andLoading:NO andIsBottom:NO];
                                   }
                               }];
}

- (IBAction)commentAction:(id)sender{
    ShopCommentView *commentView = [[ShopCommentView alloc] init];
    commentView.shopId = self.shopInfo.shopId;
    [self.navigationController pushViewController:commentView animated:YES];
}

@end
