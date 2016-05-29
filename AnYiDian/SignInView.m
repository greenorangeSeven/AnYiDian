//
//  SignInView.m
//  AnYiDian
//
//  Created by Seven on 15/7/23.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "SignInView.h"
#import "CommDetailView.h"

@interface SignInView ()
{
    int remainingIntegral;
    UserInfo *userInfo;
}

@end

@implementation SignInView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"签到有奖";
    
    userInfo = [[UserModel Instance] getUserInfo];
}

- (void)findRegUserInfoByUserId
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:userInfo.regUserId forKey:@"userId"];
    
    NSString *findRegUserInfoUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findRegUserInfoByUserId] params:param];
    [[AFOSCClient sharedClient] getPath:findRegUserInfoUrl parameters:nil
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
                                        remainingIntegral = [[[json objectForKey:@"data"] objectForKey:@"integral"] intValue];
                                        self.integralLb.text = [NSString stringWithFormat:@"您目前有%d积分", remainingIntegral];
                                    }
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    NSLog(@"列表获取出错");
                                    self.signInBtn.enabled = YES;
                                    if ([UserModel Instance].isNetworkRunning == NO) {
                                        return;
                                    }
                                    if ([UserModel Instance].isNetworkRunning) {
                                        [Tool showCustomHUD:@"网络不给力" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
                                    }
                                }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signInAction:(id)sender {
    //用户签到
    self.signInBtn.enabled = NO;
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:userInfo.regUserId forKey:@"userId"];
    
    NSString *signInUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_signin] params:param];
    [[AFOSCClient sharedClient] getPath:signInUrl parameters:nil
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                                    NSError *error;
                                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                    
                                    NSString *state = [[json objectForKey:@"header"] objectForKey:@"state"];
                                    if ([state isEqualToString:@"0000"] == NO) {
                                        [Tool showCustomHUD:[[json objectForKey:@"header"] objectForKey:@"msg"] andView:self.view andImage:@"37x-Failure.png" andAfterDelay:2];
                                        
                                    }
                                    else
                                    {
                                        [Tool showCustomHUD:@"签到成功" andView:self.view andImage:@"37x-Failure.png" andAfterDelay:2];
//                                        remainingIntegral += 1;
//                                        self.integralLb.text = [NSString stringWithFormat:@"您目前有%d积分", remainingIntegral];
                                        [self findRegUserInfoByUserId];
                                    }
                                    self.signInBtn.enabled = YES;
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    NSLog(@"列表获取出错");
                                    self.signInBtn.enabled = YES;
                                    if ([UserModel Instance].isNetworkRunning == NO) {
                                        return;
                                    }
                                    if ([UserModel Instance].isNetworkRunning) {
                                        [Tool showCustomHUD:@"网络不给力" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
                                    }
                                }];
}

- (IBAction)luckyDrawAction:(id)sender {
    NSString *lotteryHtm = [NSString stringWithFormat:@"%@%@accessId=%@&userId=%@", api_base_url, htm_lottery, Appkey, userInfo.regUserId];
    CommDetailView *detailView = [[CommDetailView alloc] init];
    detailView.titleStr = @"抽奖";
    detailView.urlStr = lotteryHtm;
    detailView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailView animated:YES];
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
    [self findRegUserInfoByUserId];
    
    self.navigationController.navigationBar.hidden = NO;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
}

@end
