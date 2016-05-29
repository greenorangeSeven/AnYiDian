//
//  RegisterStep3View.m
//  BBK
//
//  Created by Seven on 14-11-27.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "RegisterStep3View.h"
#import "NSString+STRegex.h"
#import "EGOCache.h"
#import "AppDelegate.h"
#import "XGPush.h"
#import "LoginView.h"

@interface RegisterStep3View ()
{
    NSTimer *_timer;
    int countDownTime;
    UIWebView *phoneWebView;
}

@end

@implementation RegisterStep3View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.view.frame.size.height);

    self.title = @"注册";
    
    UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [rBtn addTarget:self action:@selector(telAction:) forControlEvents:UIControlEventTouchUpInside];
    [rBtn setImage:[UIImage imageNamed:@"head_tel"] forState:UIControlStateNormal];
    UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = btnTel;
    
    [self.finishBtn.layer  setCornerRadius:5.0f];
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

- (IBAction)getValidateCodeAction:(id)sender {
    
    NSString *mobileStr = self.mobileNoTf.text;
    if (![mobileStr isValidPhoneNum]) {
        [Tool showCustomHUD:@"手机号错误" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    self.getValidataCodeBtn.enabled = NO;
    //生成验证码URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:mobileStr forKey:@"mobileNo"];
    NSString *createRegCodeListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_createRegCode] params:param];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:createRegCodeListUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestCreateRegCode:)];
    request.tag = 3;
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"验证码发送中" andView:self.view andHUD:request.hud];
}

- (void)requestCreateRegCode:(ASIHTTPRequest *)request
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
        self.finishBtn.enabled = YES;
        return;
    }
    else
    {
        [Tool showCustomHUD:@"验证码发送成功" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        [self startValidateCodeCountDown];
    }
}

- (IBAction)telAction:(id)sender
{
    NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", servicephone]];
    if (!phoneWebView) {
        phoneWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    [phoneWebView loadRequest:[NSURLRequest requestWithURL:phoneUrl]];
}

- (void)startValidateCodeCountDown
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerFunc) userInfo:nil repeats:YES];
    countDownTime = 60;
}

- (void)timerFunc
{
    if (countDownTime > 0) {
        self.getValidataCodeBtn.enabled = NO;
        [self.getValidataCodeBtn setTitle:[NSString stringWithFormat:@"获取验证码(%d)" ,countDownTime] forState:UIControlStateDisabled];
        [self.getValidataCodeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    }
    else
    {
        self.getValidataCodeBtn.enabled = YES;
        [self.getValidataCodeBtn setTitle:@"重新获取验证码" forState:UIControlStateNormal];
        [self.getValidataCodeBtn setTitleColor:[UIColor colorWithRed:251/255.0 green:67/255.0 blue:79/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_timer invalidate];
    }
    countDownTime --;
}

- (IBAction)finishAction:(id)sender {
    NSString *mobileStr = self.mobileNoTf.text;
    NSString *validateCodeStr = self.validateCodeTf.text;
    NSString *nickNameStr = self.nickNameTf.text;
    NSString *pwdStr = self.passwordTf.text;
    NSString *pwdAgainStr = self.passwordAgainTf.text;
    if (![mobileStr isValidPhoneNum]) {
        [Tool showCustomHUD:@"手机号错误" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if (validateCodeStr == nil || [validateCodeStr length] == 0) {
        [Tool showCustomHUD:@"请输入验证码" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if (nickNameStr == nil || [nickNameStr length] == 0) {
        [Tool showCustomHUD:@"请输入昵称" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if (pwdStr == nil || [pwdStr length] == 0) {
        [Tool showCustomHUD:@"请输入密码" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if ([pwdStr isEqualToString:pwdAgainStr] == NO) {
        [Tool showCustomHUD:@"两次密码输入不一致" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    self.finishBtn.enabled = NO;
    //生成注册URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:self.ownerNameStr forKey:@"regUserName"];
    [param setValue:self.idCardStr forKey:@"idCardLast4"];
//    [param setValue:self.identityIdStr forKey:@"userTypeId"];
    [param setValue:self.houseNumId forKey:@"numberId"];
    [param setValue:validateCodeStr forKey:@"validateCode"];
    [param setValue:mobileStr forKey:@"mobileNo"];
    [param setValue:nickNameStr forKey:@"nickName"];
    [param setValue:pwdStr forKey:@"password"];
    NSString *regUserSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_regUser] params:param];
    NSString *regUserUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_regUser];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:regUserUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:Appkey forKey:@"accessId"];
    [request setPostValue:self.ownerNameStr forKey:@"regUserName"];
    [request setPostValue:self.idCardStr forKey:@"idCardLast4"];
//    [request setPostValue:self.identityIdStr forKey:@"userTypeId"];
    [request setPostValue:self.houseNumId forKey:@"numberId"];
    [request setPostValue:validateCodeStr forKey:@"validateCode"];
    [request setPostValue:mobileStr forKey:@"mobileNo"];
    [request setPostValue:nickNameStr forKey:@"nickName"];
    [request setPostValue:pwdStr forKey:@"password"];
    [request setPostValue:regUserSign forKey:@"sign"];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestRegUser:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"注册中..." andView:self.view andHUD:request.hud];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
        
    }
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
    if(self.getValidataCodeBtn.enabled == NO)
    {
        self.getValidataCodeBtn.enabled = YES;
    }
    if(self.finishBtn.enabled == NO)
    {
        self.finishBtn.enabled = YES;
    }
}
- (void)requestRegUser:(ASIHTTPRequest *)request
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
        self.finishBtn.enabled = YES;
        return;
    }
    else
    {
        UserInfo *userInfo = [Tool readJsonStrToLoginUserInfo:request.responseString];
        //设置登录并保存用户信息
        UserModel *userModel = [UserModel Instance];
        [userModel saveIsLogin:YES];
        [userModel saveAccount:self.mobileNoTf.text andPwd:self.passwordTf.text];
        [userModel saveValue:userInfo.regUserId ForKey:@"regUserId"];
        [userModel saveValue:userInfo.regUserName ForKey:@"regUserName"];
        [userModel saveValue:userInfo.mobileNo ForKey:@"mobileNo"];
        [userModel saveValue:userInfo.nickName ForKey:@"nickName"];
        [userModel saveValue:userInfo.photoFull ForKey:@"photoFull"];
        
        if([userInfo.rhUserHouseList count] > 0)
        {
            for (int i = 0; i < [userInfo.rhUserHouseList count]; i++) {
                UserHouse *userHouse = (UserHouse *)[userInfo.rhUserHouseList objectAtIndex:0];
                if (i == 0) {
                    [userModel saveValue:[NSString stringWithFormat:@"%d",userHouse.userTypeId] ForKey:@"userTypeId"];
                    [userModel saveValue:userHouse.userTypeName ForKey:@"userTypeName"];
                    [userModel saveValue:userHouse.numberName ForKey:@"numberName"];
                    [userModel saveValue:userHouse.buildingName ForKey:@"buildingName"];
                    [userModel saveValue:userHouse.cellName ForKey:@"cellName"];
                    [userModel saveValue:userHouse.cellId ForKey:@"cellId"];
                    [userModel saveValue:userHouse.phone ForKey:@"cellPhone"];
                    [userModel saveValue:userHouse.numberId ForKey:@"numberId"];
                    userHouse.isDefault = YES;
                    userInfo.defaultUserHouse = userHouse;
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
//        [[EGOCache globalCache] setObject:userInfo forKey:UserInfoCache withTimeoutInterval:3600 * 24 * 356];
        [[UserModel Instance] saveUserInfo:userInfo];
        [XGPush setTag:userInfo.defaultUserHouse.cellId];
        [self gotoTabbar];
    }
}

-(void)gotoTabbar
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"注册账号成功，请等待管理员审核！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    alert.tag = 0;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if (alertView.tag == 0)
        {
            //设置登录并保存用户信息
            UserModel *userModel = [UserModel Instance];
            [userModel saveIsLogin:NO];
            [userModel logoutUser];
            [userModel saveAccount:@"" andPwd:@""];
            
            UserHouse *defaultHouse = [userModel getUserInfo].defaultUserHouse;
            
            [XGPush delTag:defaultHouse.cellId];
            
            LoginView *loginView = [[LoginView alloc] initWithNibName:@"LoginView" bundle:nil];
            UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginView];
            AppDelegate *appdele = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            appdele.window.rootViewController = loginNav;
        }
    }
}

@end
