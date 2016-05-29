//
//  MyPageView.m
//  AnYiDian
//
//  Created by Seven on 15/7/15.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "MyPageView.h"
#import "SettingModel.h"
#import "PropertyPageCell.h"
#import "UIImageView+WebCache.h"
#import "CallServiceView.h"
#import "IntegralView.h"
#import "ModifyUserInfoView.h"
#import "RepairTableView.h"
#import "MyOrderView.h"
#import "LoginView.h"
#import "AppDelegate.h"
#import "XGPush.h"
#import "CircleOfFriendsView.h"
#import "PayFeeFrameView.h"
#import "InviteView.h"
#import "ChangeHouseView.h"
#import "AddHouseView.h"

#define ORIGINAL_MAX_WIDTH 640.0f

@interface MyPageView ()
{
    UserInfo *userInfo;
    NSArray *mySetings;
    NSString *integral;
    UIImage *userFace;
}

@end

@implementation MyPageView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我";
    
//    UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
//    [rBtn addTarget:self action:@selector(setViewAction:) forControlEvents:UIControlEventTouchUpInside];
//    [rBtn setImage:[UIImage imageNamed:@"head_set"] forState:UIControlStateNormal];
//    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
//    self.navigationItem.rightBarButtonItem = rightBtn;
    
    UIBarButtonItem *rBtn = [[UIBarButtonItem alloc] initWithTitle: @"注销" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutAction:)];
    self.navigationItem.rightBarButtonItem = rBtn;
    
    mySetings = [[NSArray alloc] initWithObjects:
                [[SettingModel alloc] initWith: @"我要邀请家人" andImg:nil andTag:1 andTitle2:@""],
                [[SettingModel alloc] initWith: @"更换住址" andImg:nil andTag:2 andTitle2:@""],
                [[SettingModel alloc] initWith: @"我的订单" andImg:nil andTag:3 andTitle2:@""],
                [[SettingModel alloc] initWith: @"我的缴费" andImg:nil andTag:4 andTitle2:@""],
                [[SettingModel alloc] initWith: @"我的报修" andImg:nil andTag:5 andTitle2:@""],
                [[SettingModel alloc] initWith: @"房间绑定" andImg:nil andTag:6 andTitle2:@""],
                nil];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = [[UIView alloc] init];

    //图片圆形处理
    self.faceBg1View.layer.masksToBounds = YES;
    self.faceBg1View.layer.cornerRadius = self.faceBg1View.frame.size.height / 2;    //最重要的是这个地方要设成imgview高的一半
    
    self.faceBg2View.layer.masksToBounds = YES;
    self.faceBg2View.layer.cornerRadius = self.faceBg2View.frame.size.height / 2;    //最重要的是这个地方要设成imgview高的一半
    
    self.faceIv.layer.masksToBounds = YES;
    self.faceIv.layer.cornerRadius = self.faceIv.frame.size.height / 2;    //最重要的是这个地方要设成imgview高的一半
    [self addTapAction];
    [self findRegUserInfoByUserId];
    [self findTodayTopicCount];
}

- (IBAction)logoutAction:(id)sender {
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

- (void)findTodayTopicCount
{
    NSString *findTodayTopicCount = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findTodayTopicCount] params:nil];
    [[AFOSCClient sharedClient] getPath:findTodayTopicCount parameters:nil
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
                                        NSInteger topicCount = [[json objectForKey:@"data"] integerValue];
                                        self.topicCountLb.text = [NSString stringWithFormat:@"%d条新邻里圈", topicCount];
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

- (void)findRegUserInfoByUserId
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    if (userInfo == nil) {
        userInfo = [[UserModel Instance] getUserInfo];
    }
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
                                        integral = [[json objectForKey:@"data"] objectForKey:@"integral"];
                                        self.integralLabel.text = [NSString stringWithFormat:@"%@分", integral];
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

- (void)setViewAction:(id)sender
{
    
}

- (void)addTapAction
{
    //物业呼叫
    UITapGestureRecognizer *callServiceTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callServiceTapClick)];
    [self.callServiceView addGestureRecognizer:callServiceTap];
    //查看积分
    UITapGestureRecognizer *myIntegralTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myIntegralClick)];
    [self.myIntegralView addGestureRecognizer:myIntegralTap];
    //查看积分
    UITapGestureRecognizer *topicTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topicClick)];
    [self.topicView addGestureRecognizer:topicTap];
}

- (void)callServiceTapClick
{
    CallServiceView *callServiceView = [[CallServiceView alloc] init];
    callServiceView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:callServiceView animated:YES];
}

- (void)myIntegralClick
{
    IntegralView *integralView = [[IntegralView alloc] init];
    integralView.integral = integral;
    integralView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:integralView animated:YES];
}

- (void)topicClick
{
    CircleOfFriendsView *circleOfFriendsView = [[CircleOfFriendsView alloc] init];
    circleOfFriendsView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:circleOfFriendsView animated:YES];
}

#pragma TableView的处理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SettingModel *action = [mySetings objectAtIndex:[indexPath row]];
    //开始处理
    switch (action.tag) {
        case 1:
        {
            InviteView *inviteView = [[InviteView alloc] init];
            inviteView.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:inviteView animated:YES];
        }
            break;
        case 2:
        {
            ChangeHouseView *changeView = [[ChangeHouseView alloc] init];
            changeView.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:changeView animated:YES];
        }
            break;
            
        case 3:
        {
            MyOrderView *orderView = [[MyOrderView alloc] init];
            orderView.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:orderView animated:YES];
        }
            break;
        case 4:
        {
            PayFeeFrameView *payfee = [[PayFeeFrameView alloc] init];
            payfee.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:payfee animated:YES];
        }
            break;
        case 5:
        {
            RepairTableView *repairTableView = [[RepairTableView alloc] init];
            repairTableView.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:repairTableView animated:YES];
        }
            break;
        case 6:
        {
            AddHouseView *addHouseView = [[AddHouseView alloc] init];
            addHouseView.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:addHouseView animated:YES];
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
    return [mySetings count];
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
    SettingModel *model = [mySetings objectAtIndex:row];
    cell.titleLb.text = model.title;
    cell.detailLb.text = model.title2;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
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
    
    self.navigationController.navigationBar.hidden = NO;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    
    userInfo = [[UserModel Instance] getUserInfo];
    [self.faceIv sd_setImageWithURL:[NSURL URLWithString:userInfo.photoFull] placeholderImage:[UIImage imageNamed:@"default_head.png"]];
    
    self.mobileNoLb.text = [NSString stringWithFormat:@"手机号码：%@", userInfo.mobileNo];
    self.userInfoLb.text = [NSString stringWithFormat:@"%@%@%@    %@", userInfo.defaultUserHouse.cellName, userInfo.defaultUserHouse.buildingName, userInfo.defaultUserHouse.numberName, userInfo.regUserName];
    
}

- (IBAction)modifyUserInfoAction:(id)sender {
    ModifyUserInfoView *modifyView = [[ModifyUserInfoView alloc] init];
    [self.navigationController pushViewController:modifyView animated:YES];
}

- (IBAction)uploadFaceAction:(id)sender {
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:self.view];
}

#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    self.faceIv.image = editedImage;
    userFace = editedImage;
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        UserInfo *userInfo = [[UserModel Instance] getUserInfo];
        //生成更换头像URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:userInfo.regUserId forKey:@"regUserId"];
        NSString *changePhotoSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_changeUserPhoto] params:param];
        
        NSString *changePhotoUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_changeUserPhoto] params:param];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:changePhotoUrl]];
        [request setUseCookiePersistence:[[UserModel Instance] isLogin]];
        [request setTimeOutSeconds:30];
        [request setPostValue:Appkey forKey:@"accessId"];
        [request setPostValue:changePhotoSign forKey:@"sign"];
        [request setPostValue:userInfo.regUserId forKey:@"regUserId"];
        if (userFace != nil) {
            [request addData:UIImageJPEGRepresentation(userFace, 0.8f) withFileName:@"img.jpg" andContentType:@"image/jpeg" forKey:@"pic"];
        }
        [request setDelegate:self];
        [request setDidFailSelector:@selector(requestFailed:)];
        [request setDidFinishSelector:@selector(requestChangeUserPhoto:)];
        [request startAsynchronous];
        
        request.hud = [[MBProgressHUD alloc] initWithView:self.view];
        [Tool showHUD:@"头像更新..." andView:self.view andHUD:request.hud];
    }];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
    }
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
}

- (void)requestChangeUserPhoto:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:YES];
    }
    
    [request setUseCookiePersistence:YES];
    NSLog(@"%@", request.responseString);
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
        return;
    }
    else
    {
        userFace = nil;
        NSString *userPhoto = [json objectForKey:@"data"];
        [self.faceIv setImageWithURL:[NSURL URLWithString:userPhoto] placeholderImage:[UIImage imageNamed:@"default_head.png"]];
        //        [[UserModel Instance] saveValue:userPhoto ForKey:@"photoFull"];
        userInfo.photoFull = userPhoto;
        UserModel *userModel = [UserModel Instance];
        [userModel saveUserInfo:userInfo];
    }
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 0) {
        if (buttonIndex == 0) {
            // 拍照
            if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                //使用前置摄像头
                //                if ([self isFrontCameraAvailable]) {
                //                    controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                //                }
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
            
        } else if (buttonIndex == 1) {
            // 从相册中选取
            if ([self isPhotoLibraryAvailable]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        // 裁剪
        VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgEditorVC.delegate = self;
        [self presentViewController:imgEditorVC animated:YES completion:^{
            // TO DO
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}

#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

@end
