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

@interface MarketingView ()
{
    NSMutableArray *estateData;
    NSString *eatateId;
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
    
    [self getEstateData];
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

@end
