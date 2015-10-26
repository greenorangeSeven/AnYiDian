//
//  MarketingView.m
//  AnYiDian
//
//  Created by Seven on 15/7/27.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "MarketingView.h"
#import "Estate.h"
#import "IQKeyboardManager/KeyboardManager.framework/Headers/IQKeyboardManager.h"
#import "NSString+STRegex.h"
#import "AdView.h"
#import "ADInfo.h"
#import "CommDetailView.h"

@interface MarketingView ()
{
    NSMutableArray *estateData;
    NSString *eatateId;
    AdView * adView;
    NSMutableArray *advDatas;
}

@property int pickerSelectRow;
@property (nonatomic, strong) UIPickerView *estatePicker;

@end

@implementation MarketingView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"全民营销";
    
    self.pickerSelectRow = 0;
    
    [self.submitBtn.layer setCornerRadius:5.0f];
    
    self.estateTf.tag = 1;
    self.estateTf.delegate = self;
    
    [self getADVData];
    [self getEstateData];
}

- (void)getADVData
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        UserInfo *userInfo = [[UserModel Instance] getUserInfo];
        //生成获取广告URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:@"1144521933436800" forKey:@"typeId"];
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
    
    adView = [AdView adScrollViewWithFrame:CGRectMake(0, 0, width, 133)  \
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
    [self.adIv addSubview:adView];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.inputAccessoryView == nil)
    {
        textField.inputAccessoryView = [self keyboardToolBar:textField.tag];
    }
    if (textField.tag == 1)
    {
        self.estatePicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
        self.estatePicker.showsSelectionIndicator = YES;
        self.estatePicker.delegate = self;
        self.estatePicker.dataSource = self;
        self.estatePicker.tag = 1;
        textField.inputView = self.estatePicker;
        [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == 1)
    {
        [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
    }
}

- (UIToolbar *)keyboardToolBar:(int)fieldIndex
{
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    [toolBar sizeToFit];
    toolBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] init];
    doneButton.tag = fieldIndex;
    doneButton.title = @"完成";
    doneButton.style = UIBarButtonItemStyleDone;
    doneButton.action = @selector(doneClicked:);
    doneButton.target = self;
    
    
    [toolBar setItems:[NSArray arrayWithObjects:spacer, doneButton, nil]];
    return toolBar;
}

- (void)doneClicked:(UITextField *)sender
{
    if (sender.tag == 1)
    {
        Estate *estate = (Estate *)[estateData objectAtIndex:self.pickerSelectRow];
        self.estateTf.text = estate.estateName;
        eatateId = estate.estateId;
    }
    [self.estateTf resignFirstResponder];
}

#pragma mark -
#pragma mark Picker Data Source Methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == 1)
    {
        return [estateData count];
    }
    else
    {
        return 0;
    }
}

#pragma mark Picker Delegate Methods
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == 1)
    {
        Estate *estate = (Estate *)[estateData objectAtIndex:self.pickerSelectRow];
        return estate.estateName;
    }
    else
    {
        return nil;
    }
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (thePickerView.tag == 1)
    {
        self.pickerSelectRow = row;
    }
}

- (void)getUrl
{
    //生成获取列表URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:@"999" forKey:@"countPerPages"];
    [param setValue:@"1" forKey:@"pageNumbers"];
    NSString *getNoticeListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findEstateInfoByPage] params:param];
}

- (void)getEstateData
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:@"999" forKey:@"countPerPages"];
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
                                               Estate *estate = (Estate *)[estateData objectAtIndex:self.pickerSelectRow];
                                               self.estateTf.text = estate.estateName;
                                               eatateId = estate.estateId;
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

- (IBAction)submitAction:(id)sender {
    NSString *houseNumberStr = self.houseNumberTf.text;
    NSString *marketingNameStr = self.marketingNameTf.text;
    NSString *marketingMobileStr = self.marketingMobileTf.text;
    NSString *marketedNameStr = self.marketedNameTf.text;
    NSString *marketedMobileStr = self.marketedMobileTf.text;
    if (houseNumberStr == nil || [houseNumberStr length] == 0) {
        [Tool showCustomHUD:@"请输入房号" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if (marketingNameStr == nil || [marketingNameStr length] == 0) {
        [Tool showCustomHUD:@"请输入介绍人姓名" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if (![marketingMobileStr isValidPhoneNum]) {
        [Tool showCustomHUD:@"介绍人手机错误" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if (marketedNameStr == nil || [marketedNameStr length] == 0) {
        [Tool showCustomHUD:@"请输入被介绍人姓名" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if (![marketedMobileStr isValidPhoneNum]) {
        [Tool showCustomHUD:@"被介绍人手机错误" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    self.submitBtn.enabled = NO;
    
    UserInfo *userInfo = [[UserModel Instance] getUserInfo];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:eatateId forKey:@"estateId"];
    [param setValue:userInfo.regUserId forKey:@"regUserId"];
    [param setValue:houseNumberStr forKey:@"houseNumber"];
    [param setValue:marketingNameStr forKey:@"marketingName"];
    [param setValue:marketingMobileStr forKey:@"marketingMobile"];
    [param setValue:marketedNameStr forKey:@"marketedName"];
    [param setValue:marketedMobileStr forKey:@"marketedMobile"];
    NSString *addMarketingInfoSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_addMarketingInfo] params:param];
    NSString *addMarketingInfoUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_addMarketingInfo];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:addMarketingInfoUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:Appkey forKey:@"accessId"];
    [request setPostValue:addMarketingInfoSign forKey:@"sign"];
    [request setPostValue:eatateId forKey:@"estateId"];
    [request setPostValue:userInfo.regUserId forKey:@"regUserId"];
    [request setPostValue:houseNumberStr forKey:@"houseNumber"];
    [request setPostValue:marketingNameStr forKey:@"marketingName"];
    [request setPostValue:marketingMobileStr forKey:@"marketingMobile"];
    [request setPostValue:marketedNameStr forKey:@"marketedName"];
    [request setPostValue:marketedMobileStr forKey:@"marketedMobile"];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestAdd:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"推荐中..." andView:self.view andHUD:request.hud];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
        
    }
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
    if(self.submitBtn.enabled == NO)
    {
        self.submitBtn.enabled = YES;
    }
}

- (void)requestAdd:(ASIHTTPRequest *)request
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
        self.submitBtn.enabled = YES;
        return;
    }
    else
    {
        [Tool showCustomHUD:@"已推荐，谢谢您的参与" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        self.houseNumberTf.text = @"";
        self.marketingNameTf.text = @"";
        self.marketingMobileTf.text = @"";
        self.marketedNameTf.text = @"";
        self.marketedMobileTf.text = @"";
        self.submitBtn.enabled = YES;
    }
}

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
