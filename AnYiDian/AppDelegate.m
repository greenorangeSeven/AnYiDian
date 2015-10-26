//
//  AppDelegate.m
//  AnYiDian
//
//  Created by Seven on 15/7/8.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "AppDelegate.h"
#import "CheckNetwork.h"
#import "LoginView.h"
#import "CommDetailView.h"

#import "XGPush.h"
#import "XGSetting.h"

#define _IPHONE80_ 80000

BMKMapManager* _mapManager;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)registerPushForIOS8{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
    
    //Types
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    //Actions
    UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
    
    acceptAction.identifier = @"ACCEPT_IDENTIFIER";
    acceptAction.title = @"Accept";
    
    acceptAction.activationMode = UIUserNotificationActivationModeForeground;
    acceptAction.destructive = NO;
    acceptAction.authenticationRequired = NO;
    
    //Categories
    UIMutableUserNotificationCategory *inviteCategory = [[UIMutableUserNotificationCategory alloc] init];
    
    inviteCategory.identifier = @"INVITE_CATEGORY";
    
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextDefault];
    
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextMinimal];
    
    NSSet *categories = [NSSet setWithObjects:inviteCategory, nil];
    
    
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
#endif
}

- (void)registerPush{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //检查网络是否存在 如果不存在 则弹出提示
    [UserModel Instance].isNetworkRunning = [CheckNetwork isExistenceNetwork];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //设置UINavigationController背景
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"top_bg"]  forBarMetrics:UIBarMetricsDefault];
    
    self.pushInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    //启动判断登陆
    [self userLogin];
    
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    BOOL ret = [_mapManager start:@"PC5KvBArsoRTLzrO8PEHi3XH" generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    //设置目录不进行IOS自动同步！否则审核不能通过
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [NSString stringWithFormat:@"%@/cfg", [paths objectAtIndex:0]];
    NSURL *dbURLPath = [NSURL fileURLWithPath:directory];
    [self addSkipBackupAttributeToItemAtURL:dbURLPath];
    
    //集成信鸽start
    [XGPush startApp:2200152378 appKey:@"IGTA36EN683M"];
    
    //注销之后需要再次注册前的准备
    void (^successCallback)(void) = ^(void){
        //如果变成需要注册状态
        if(![XGPush isUnRegisterStatus])
        {
            //iOS8注册push方法
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
            
            float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
            if(sysVer < 8){
                [self registerPush];
            }
            else{
                [self registerPushForIOS8];
            }
#else
            //iOS8之前注册push方法
            //注册Push服务，注册后才能收到推送
            [self registerPush];
#endif
        }
    };
    [XGPush initForReregister:successCallback];
    
    //推送反馈(app不在前台运行时，点击推送激活时)
    [XGPush handleLaunching:launchOptions];
    
    //推送反馈回调版本示例
    void (^successBlock)(void) = ^(void){
        //成功之后的处理
        NSLog(@"[XGPush]handleLaunching's successBlock");
        [self pushNotificationHandle];
    };
    
    void (^errorBlock)(void) = ^(void){
        //失败之后的处理
        //        NSLog(@"[XGPush]handleLaunching's errorBlock");
    };
    //清除所有通知(包含本地通知)
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    [XGPush handleLaunching:launchOptions successCallback:successBlock errorCallback:errorBlock];
    //信鸽END
    
    return YES;
}

- (void)userLogin
{
    UserModel *user = [UserModel Instance];
    if (user.isLogin == YES)
    {
//        //如果登录过就先启动过渡界面，否则异步登陆会有一瞬间黑屏
//        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//        TransitionView *transitionView = [[TransitionView alloc] initWithNibName:@"TransitionView" bundle:nil];
//        self.window.rootViewController = transitionView;
//        [self.window makeKeyAndVisible];
//        
        NSString *mobileStr = [user getUserValueForKey:@"Account"];
        NSString *pwdStr = [user getPwd];
        //生成登陆URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:mobileStr forKey:@"mobileNo"];
        [param setValue:pwdStr forKey:@"password"];
        NSString *loginUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_login] params:param];
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:loginUrl]];
        [request setUseCookiePersistence:NO];
        [request setDelegate:self];
        [request setDidFailSelector:@selector(requestFailed:)];
        [request setDidFinishSelector:@selector(requestLogin:)];
        [request startAsynchronous];
    }
    else
//    {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        LoginView *loginView = [[LoginView alloc] initWithNibName:@"LoginView" bundle:nil];
        UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginView];
        self.window.rootViewController = loginNav;
        [self.window makeKeyAndVisible];
//    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    LoginView *loginView = [[LoginView alloc] initWithNibName:@"LoginView" bundle:nil];
    UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginView];
    self.window.rootViewController = loginNav;
    [self.window makeKeyAndVisible];
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
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        LoginView *loginView = [[LoginView alloc] initWithNibName:@"LoginView" bundle:nil];
        UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginView];
        self.window.rootViewController = loginNav;
        [self.window makeKeyAndVisible];
    }
    else
    {
        UserInfo *userInfo = [Tool readJsonStrToLoginUserInfo:request.responseString];
        //设置登录并保存用户信息
        UserModel *userModel = [UserModel Instance];
        
        userInfo.defaultUserHouse = nil;
        
        if([userInfo.rhUserHouseList count] > 0)
        {
            for (int i = 0; i < [userInfo.rhUserHouseList count]; i++) {
                UserHouse *userHouse = (UserHouse *)[userInfo.rhUserHouseList objectAtIndex:i];
                if ([userHouse.userStateId intValue] == 1){
                    userHouse.isDefault = YES;
                    userInfo.defaultUserHouse = userHouse;
                    [userModel saveIsLogin:YES];
                    break;
                }
                else
                {
                    userHouse.isDefault = NO;
                }
            }
        }
        if (userInfo.defaultUserHouse == nil) {
            [userModel saveIsLogin:NO];
            self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            LoginView *loginView = [[LoginView alloc] initWithNibName:@"LoginView" bundle:nil];
            UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginView];
            self.window.rootViewController = loginNav;
            [self.window makeKeyAndVisible];
        }
        else
        {
            [userModel saveUserInfo:userInfo];
            [Tool gotoTabbar:self.window];
        }
    }
}

//信鸽
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    //notification是发送推送时传入的字典信息
    [XGPush localNotificationAtFrontEnd:notification userInfoKey:@"clockID" userInfoValue:@"myid"];
    
    //删除推送列表中的这一条
    [XGPush delLocalNotification:notification];
    //[XGPush delLocalNotification:@"clockID" userInfoValue:@"myid"];
    
    //清空推送列表
    //[XGPush clearLocalNotifications];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_

//注册UserNotification成功的回调
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //用户已经允许接收以下类型的推送
    //UIUserNotificationType allowedTypes = [notificationSettings types];
    
}

//按钮点击事件回调
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler{
    if([identifier isEqualToString:@"ACCEPT_IDENTIFIER"]){
        NSLog(@"ACCEPT_IDENTIFIER is clicked");
    }
    
    completionHandler();
}

#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString * deviceTokenStr = [XGPush registerDevice:deviceToken];
    
    void (^successBlock)(void) = ^(void){
        //成功之后的处理
        NSLog(@"[XGPush]register successBlock ,deviceToken: %@",deviceTokenStr);
    };
    
    void (^errorBlock)(void) = ^(void){
        //失败之后的处理
        NSLog(@"[XGPush]register errorBlock");
    };
    
    UserInfo *userInfo = [[UserModel Instance] getUserInfo];
    
    if (userInfo.mobileNo != nil && [userInfo.mobileNo length] > 0) {
        [XGPush setAccount:userInfo.mobileNo];
    }
    
    //注册设备
    [[XGSetting getInstance] setChannel:@"appstore"];
    //    [[XGSetting getInstance] setGameServer:@"巨神峰"];
    [XGPush registerDevice:deviceToken successCallback:successBlock errorCallback:errorBlock];
    //    [XGPush setTag:@"0"];
    //如果不需要回调
    //[XGPush registerDevice:deviceToken];
    
    //打印获取的deviceToken的字符串
    NSLog(@"deviceTokenStr is %@",deviceTokenStr);
}

//如果deviceToken获取不到会进入此事件
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
    NSString *str = [NSString stringWithFormat: @"Error: %@",err];
    
    NSLog(@"%@",str);
    
}

//点击通知出发事件
- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    //推送反馈(app运行时)
    [XGPush handleReceiveNotification:userInfo];
    self.pushInfo = userInfo;
    
    //回调版本示例
    /**/
    void (^successBlock)(void) = ^(void){
        //成功之后的处理
        NSLog(@"[XGPush]handleReceiveNotification successBlock");
        if (_isForeground == YES) {
            [self pushNotificationHandle];
        }
        else
        {
            NSString *alertStr = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
            UIAlertView *notificationAlert = [[UIAlertView alloc] initWithTitle:@"推送消息" message:alertStr delegate:self cancelButtonTitle:@"忽略" otherButtonTitles:@"查看", nil];
            notificationAlert.tag = 1;
            [notificationAlert show];
        }
        
    };
    
    void (^errorBlock)(void) = ^(void){
        //失败之后的处理
        NSLog(@"[XGPush]handleReceiveNotification errorBlock");
    };
    
    void (^completion)(void) = ^(void){
        //失败之后的处理
        NSLog(@"[xg push completion]userInfo is %@",userInfo);
    };
    
    [XGPush handleReceiveNotification:userInfo successCallback:successBlock errorCallback:errorBlock completion:completion];
}

//推送通知处理
- (void)pushNotificationHandle
{
    //角标清0
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    //清除所有通知(包含本地通知)
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    NSString *type = [self.pushInfo  objectForKey:@"type"];
    if ([type isEqualToString:@"notice"] == YES) {
        NSString *pushDetailHtm = [NSString stringWithFormat:@"%@%@", api_base_url, [self.pushInfo  objectForKey:@"url"]];
        CommDetailView *detailView = [[CommDetailView alloc] initWithNibName:@"CommDetailView" bundle:nil];
        detailView.present = @"present";
        detailView.titleStr = @"物业通知";
        detailView.urlStr = pushDetailHtm;
        UINavigationController *detailViewNav = [[UINavigationController alloc] initWithRootViewController:detailView];
        [self.window.rootViewController presentViewController:detailViewNav animated:YES completion:^{
            _isForeground = NO;
        }];
    }
//    else if ([type isEqualToString:@"express"] == YES)
//    {
//        ExpressView *expressView = [[ExpressView alloc] initWithNibName:@"ExpressView" bundle:nil];
//        expressView.present = @"present";
//        UINavigationController *noticeViewNav = [[UINavigationController alloc] initWithRootViewController:expressView];
//        [self.window.rootViewController presentViewController:noticeViewNav animated:YES completion:^{
//            _isForeground = NO;
//        }];
//    }
//    else if ([type isEqualToString:@"repair"] == YES)
//    {
//        RepairDetailView *repairDetail = [[RepairDetailView alloc] initWithNibName:@"RepairDetailView" bundle:nil];
//        repairDetail.present = @"present";
//        repairDetail.repairWorkId = [self.pushInfo objectForKey:@"id"];
//        UINavigationController *repairDetailNav = [[UINavigationController alloc] initWithRootViewController:repairDetail];
//        [self.window.rootViewController presentViewController:repairDetailNav animated:YES completion:^{
//            _isForeground = NO;
//        }];
//    }
//    else if ([type isEqualToString:@"suit"] == YES)
//    {
//        SuitDetailView *suitDetail = [[SuitDetailView alloc] initWithNibName:@"SuitDetailView" bundle:nil];
//        suitDetail.present = @"present";
//        suitDetail.suitWorkId = [self.pushInfo objectForKey:@"id"];
//        UINavigationController *suitDetailNav = [[UINavigationController alloc] initWithRootViewController:suitDetail];
//        [self.window.rootViewController presentViewController:suitDetailNav animated:YES completion:^{
//            _isForeground = NO;
//        }];
//    }
}

//信鸽

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //角标清0
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    //清除所有通知(包含本地通知)
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    _isForeground = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (alertView.tag == 1) {
            [self pushNotificationHandle];
        }
    }
}

@end
