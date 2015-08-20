//
//  LoginView.m
//  AnYiDian
//
//  Created by Seven on 15/7/13.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "LoginView.h"
#import "RegisterStep1View.h"
#import "NSString+STRegex.h"
#import "XGPush.h"
#import "AppDelegate.h"

@interface LoginView ()
{
    UIWebView *phoneWebView;
}

@end

@implementation LoginView

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置按钮带圆角
    [self.loginBtn.layer setCornerRadius:5.0f];
    [self.registerBtn.layer setCornerRadius:5.0f];
    [self.visitorBtn.layer setCornerRadius:5.0f];
    
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
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.navigationController.navigationBar.hidden = YES;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
}

- (IBAction)registerAction:(id)sender {
    RegisterStep1View *register1 = [[RegisterStep1View alloc] init];
    [self.navigationController pushViewController:register1 animated:YES];
}

- (IBAction)loginAction:(id)sender {
    NSString *mobileStr = self.mobileNoTf.text;
    NSString *pwdStr = self.passwordTf.text;
    if (![mobileStr isValidPhoneNum]) {
        [Tool showCustomHUD:@"手机号错误" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if (pwdStr == nil || [pwdStr length] == 0) {
        [Tool showCustomHUD:@"请输入密码" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    self.loginBtn.enabled = NO;
    //生成登陆URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:mobileStr forKey:@"mobileNo"];
    [param setValue:pwdStr forKey:@"password"];
    NSString *loginUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_login] params:param];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:loginUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestLogin:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"登录中..." andView:self.view andHUD:request.hud];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
    }
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
    if(self.loginBtn.enabled == NO)
    {
        self.loginBtn.enabled = YES;
    }
    if(self.findPasswordBtn.enabled == NO)
    {
        self.findPasswordBtn.enabled = YES;
    }
}
- (void)requestLogin:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:YES];
    }
    
    [request setUseCookiePersistence:YES];
    NSData *data = [request.responseString dataUsingEncoding:NSUTF8StringEncoding];
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
        self.loginBtn.enabled = YES;
        return;
    }
    else
    {
        UserInfo *userInfo = [Tool readJsonStrToLoginUserInfo:request.responseString];
        //设置登录并保存用户信息
        UserModel *userModel = [UserModel Instance];
        
        userInfo.defaultUserHouse = nil;
        
        [userModel saveAccount:self.mobileNoTf.text andPwd:self.passwordTf.text];
        [userModel saveValue:userInfo.regUserId ForKey:@"regUserId"];
        [userModel saveValue:userInfo.regUserName ForKey:@"regUserName"];
        [userModel saveValue:userInfo.mobileNo ForKey:@"mobileNo"];
        [userModel saveValue:userInfo.nickName ForKey:@"nickName"];
        [userModel saveValue:userInfo.photoFull ForKey:@"photoFull"];
        if([userInfo.rhUserHouseList count] > 0)
        {
            for (int i = 0; i < [userInfo.rhUserHouseList count]; i++) {
                UserHouse *userHouse = (UserHouse *)[userInfo.rhUserHouseList objectAtIndex:i];
                if ([userHouse.userStateId intValue] == 1){
                    //                if (i == 0) {
                    [userModel saveValue:[userHouse.userTypeId stringValue] ForKey:@"userTypeId"];
                    [userModel saveValue:userHouse.userTypeName ForKey:@"userTypeName"];
                    [userModel saveValue:userHouse.numberName ForKey:@"numberName"];
                    [userModel saveValue:userHouse.buildingName ForKey:@"buildingName"];
                    [userModel saveValue:userHouse.cellName ForKey:@"cellName"];
                    [userModel saveValue:userHouse.cellId ForKey:@"cellId"];
                    [userModel saveValue:userHouse.phone ForKey:@"cellPhone"];
                    [userModel saveValue:userHouse.numberId ForKey:@"numberId"];
                    userHouse.isDefault = YES;
                    userInfo.defaultUserHouse = userHouse;
                    [userModel saveIsLogin:YES];
                    [XGPush setTag:userInfo.defaultUserHouse.cellId];
                    break;
                }
                else
                {
                    userHouse.isDefault = NO;
                }
            }
        }
        else
        {
            [userModel saveValue:@"" ForKey:@"userTypeId"];
            [userModel saveValue:@"" ForKey:@"userTypeName"];
            [userModel saveValue:@"" ForKey:@"numberName"];
            [userModel saveValue:@"" ForKey:@"buildingName"];
            [userModel saveValue:@"" ForKey:@"cellName"];
            [userModel saveValue:@"" ForKey:@"cellId"];
            [userModel saveValue:@"" ForKey:@"cellPhone"];
            [userModel saveValue:@"" ForKey:@"numberId"];
        }
        [[UserModel Instance] saveUserInfo:userInfo];
        if (userInfo.defaultUserHouse == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您的账号暂未验证通过，请联系管理员！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"联系管理员", nil];
            alert.tag = 0;
            [alert show];
        }
        else
        {
            [self gotoTabbar];
        }
        self.loginBtn.enabled = YES;
    }
}

- (IBAction)findPasswordAction:(id)sender {
    NSString *mobileStr = self.mobileNoTf.text;
    if (![mobileStr isValidPhoneNum]) {
        [Tool showCustomHUD:@"手机号错误" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    self.findPasswordBtn.enabled = NO;
    //生成登陆URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:mobileStr forKey:@"mobileNo"];
    NSString *findUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findPassword] params:param];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:findUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestFindPassword:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"密码找回中..." andView:self.view andHUD:request.hud];
}

- (void)requestFindPassword:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:YES];
    }
    
    [request setUseCookiePersistence:YES];
    NSData *data = [request.responseString dataUsingEncoding:NSUTF8StringEncoding];
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
        self.findPasswordBtn.enabled = YES;
        return;
    }
    else
    {
        [Tool showCustomHUD:@"新密码已发送至您的手机" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (alertView.tag == 0)
        {
            [self telAction];
        }
    }
}

- (void)telAction
{
    NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", servicephone]];
    if (!phoneWebView) {
        phoneWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    [phoneWebView loadRequest:[NSURLRequest requestWithURL:phoneUrl]];
}

-(void)gotoTabbar
{
    AppDelegate *appdele = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [Tool gotoTabbar:appdele.window];
}

@end
