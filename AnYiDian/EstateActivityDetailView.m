//
//  EstateActivityDetailView.m
//  AnYiDian
//
//  Created by Seven on 15/7/21.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "EstateActivityDetailView.h"

@interface EstateActivityDetailView ()
{
    MBProgressHUD *hud;
    UIWebView *phoneWebView;
}

@end

@implementation EstateActivityDetailView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"楼盘活动";
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在加载" andView:self.view andHUD:hud];
    
    [self.praiseBtn setTitle:[NSString stringWithFormat:@" 赞(%d)", self.activity.heartCountNew] forState:UIControlStateNormal];
    if ([self.activity.isJoin isEqualToString:@"1"]) {
        [self.attendBtn setTitle:[NSString stringWithFormat:@" 已参与(%d)", self.activity.userCount] forState:UIControlStateNormal];
    }
    else
    {
        [self.attendBtn setTitle:[NSString stringWithFormat:@" 我要参与(%d)", self.activity.userCount] forState:UIControlStateNormal];
    }
    
    //WebView的背景颜色去除
    [Tool clearWebViewBackground:self.webView];
    //    [self.webView setScalesPageToFit:YES];
    [self.webView sizeToFit];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@%@", api_base_url, htm_estateActivityDetail, self.activity.activityId];
    NSURL *url = [[NSURL alloc]initWithString:urlStr];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    self.webView.delegate = self;
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
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self.webView stopLoading];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)praiseAction:(id)sender {
    self.praiseBtn.enabled = NO;
    UserInfo *userInfo = [[UserModel Instance] getUserInfo];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:self.activity.activityId forKey:@"activityId"];
    [param setValue:userInfo.regUserId forKey:@"regUserId"];
    NSString *praiseActivityUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_addCancelInEstateHeart] params:param];
    [[AFOSCClient sharedClient]getPath:praiseActivityUrl parameters:Nil
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   @try {
                                       NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                                       NSError *error;
                                       NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                       
                                       NSString *state = [[json objectForKey:@"header"] objectForKey:@"state"];
                                       NSString *msg = [[json objectForKey:@"header"] objectForKey:@"msg"];
                                       
                                       if ([state isEqualToString:@"0000"] == YES)
                                       {
                                           if ([msg isEqualToString:@"点赞成功"]) {
                                               [Tool showCustomHUD:@"点赞成功" andView:self.view andImage:@"37x-Failure.png" andAfterDelay:2];
                                               self.activity.heartCountNew += 1;
                                           }
                                           else
                                           {
                                               [Tool showCustomHUD:@"已取消点赞" andView:self.view andImage:@"37x-Failure.png" andAfterDelay:2];
                                               self.activity.heartCountNew-= 1;
                                           }
                                           
                                       }
                                       self.praiseBtn.enabled = YES;
                                       [self.praiseBtn setTitle:[NSString stringWithFormat:@" 赞(%d)", self.activity.heartCountNew] forState:UIControlStateNormal];
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

- (IBAction)attendAction:(id)sender {
    self.attendBtn.enabled = NO;
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        UserInfo *userInfo = [[UserModel Instance] getUserInfo];
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:self.activity.activityId forKey:@"activityId"];
        [param setValue:userInfo.regUserId forKey:@"regUserId"];
        NSString *addCancelInActivityUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_addCancelInEstateActivity] params:param];
        [[AFOSCClient sharedClient]getPath:addCancelInActivityUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                                           NSError *error;
                                           NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                           
                                           NSString *state = [[json objectForKey:@"header"] objectForKey:@"state"];
                                           if ([state isEqualToString:@"0000"] == NO) {
                                               UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                                                            message:[[json objectForKey:@"header"] objectForKey:@"msg"]
                                                                                           delegate:nil
                                                                                  cancelButtonTitle:@"确定"
                                                                                  otherButtonTitles:nil];
                                               [av show];
                                           }
                                           else
                                           {
                                               NSString *hudStr = @"";
                                               if([self.activity.isJoin isEqualToString:@"1"] == YES)
                                               {
                                                   self.activity.isJoin = @"0";
                                                   self.activity.userCount -= 1;
                                                   hudStr = @"取消参与";
                                               }
                                               else
                                               {
                                                   self.activity.isJoin = @"1";
                                                   self.activity.userCount += 1;
                                                   hudStr = @"已参与";
                                               }
                                               [Tool showCustomHUD:hudStr andView:self.view andImage:@"37x-Failure.png" andAfterDelay:2];
                                               if ([self.activity.isJoin isEqualToString:@"1"]) {
                                                   [self.attendBtn setTitle:[NSString stringWithFormat:@" 已参与(%d)", self.activity.userCount] forState:UIControlStateNormal];
                                               }
                                               else
                                               {
                                                   [self.attendBtn setTitle:[NSString stringWithFormat:@" 我要参与(%d)", self.activity.userCount] forState:UIControlStateNormal];
                                               }
                                           }
                                           self.attendBtn.enabled = YES;
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
}
@end
