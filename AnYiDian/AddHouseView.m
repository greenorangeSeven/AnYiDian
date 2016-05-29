//
//  AddHouseView.m
//  JinChang
//
//  Created by Seven on 15/8/31.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "AddHouseView.h"
#import "City.h"
#import "Community.h"
#import "Building.h"
#import "HouseNum.h"
#import "Unit.h"
#import "IQKeyboardManager/KeyboardManager.framework/Headers/IQKeyboardManager.h"

@interface AddHouseView ()
{
    NSString *cellId;
    NSString *houseNumId;
    NSString *identityId;
    UserInfo *userInfo;
    
}

@property int pickerSelectRow;

@property (nonatomic, strong) NSArray *fieldArray;

@property (nonatomic, strong) UIPickerView *cityPicker;
@property (nonatomic, strong) UIPickerView *communityPicker;
@property (nonatomic, strong) UIPickerView *buildingPicker;
@property (nonatomic, strong) UIPickerView *houseNumPicker;
@property (nonatomic, strong) UIPickerView *unitPicker;

@property (nonatomic, strong) NSArray *cityArray;
@property (nonatomic, strong) NSArray *communityArray;
@property (nonatomic, strong) NSArray *buildingArray;
@property (nonatomic, strong) NSArray *houseNumArray;
@property (nonatomic, strong) NSArray *unitArray;

@property (nonatomic, strong) UIPickerView *identityPicker;

@property (nonatomic, strong) NSArray *identityNameArray;
@property (nonatomic, strong) NSArray *identityIdArray;

@end

@implementation AddHouseView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.view.frame.size.height);
    
    self.title = @"添加房间";
    
    userInfo = [[UserModel Instance] getUserInfo];
    
    [self.addHouseBtn.layer setCornerRadius:5.0f];
    
    self.identityNameArray = @[@"业主", @"业主家属", @"租户"];
    self.identityIdArray = @[@"0", @"1", @"2"];
    
    identityId = @"0";
    
    self.fieldArray = @[self.cityTf, self.communityTf, self.buildingTf, self.unitTf, self.houseNumTf,self.identityTf];
    
    self.cityTf.tag = 1;
    self.cityTf.delegate = self;
    
    self.communityTf.tag = 2;
    self.communityTf.delegate = self;
    
    self.buildingTf.tag = 3;
    self.buildingTf.delegate = self;
    
    self.houseNumTf.tag = 4;
    self.houseNumTf.delegate = self;
    //新加单元所以tag在门牌之后
    self.unitTf.tag = 5;
    self.unitTf.delegate = self;
    
    self.identityTf.tag = 10;
    self.identityTf.delegate = self;
    
    self.pickerSelectRow = 0;
    
    [self initCityArrayData];
}

- (void)initCityArrayData
{
    //生成获取城市URL
    NSString *allCityUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findAllCity] params:nil];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:allCityUrl]];
    [request setUseCookiePersistence:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestGetData:)];
    request.tag = 1;
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"数据加载..." andView:self.view andHUD:request.hud];
}

- (void)getCommunityArrayData:(NSString *)cityId
{
    //生成获取城市下小区URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:cityId forKey:@"cityId"];
    NSString *cellListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findCellListByCity] params:param];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:cellListUrl]];
    [request setUseCookiePersistence:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestGetData:)];
    request.tag = 2;
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"数据加载..." andView:self.view andHUD:request.hud];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
    }
}
- (void)requestGetData:(ASIHTTPRequest *)request
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
        return;
    }
    else
    {
        if(request.tag == 1)
        {
            self.cityArray = [Tool readJsonStrToCityArray:request.responseString];
        }
        else if(request.tag == 2)
        {
            self.communityArray = [Tool readJsonStrToCommunityArray:request.responseString];
            [self.communityPicker reloadAllComponents];
            if ([self.communityArray count] > 0) {
                self.communityTf.enabled = YES;
            }
            else
            {
                self.communityTf.enabled = NO;
                self.communityTf.text = @"暂无社区";
            }
        }
    }
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
        return [self.cityArray count];
    }
    else if (pickerView.tag == 2)
    {
        return [self.communityArray count];
    }
    else if (pickerView.tag == 3)
    {
        return [self.buildingArray count];
    }
    else if (pickerView.tag == 4)
    {
        return [self.houseNumArray count];
    }
    else if (pickerView.tag == 5)
    {
        return [self.unitArray count];
    }
    else if (pickerView.tag == 10)
    {
        return [self.identityNameArray count];
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
        City *city = (City *)[self.cityArray objectAtIndex:row];
        return city.cityName;
    }
    else if (pickerView.tag == 2)
    {
        Community *community = (Community *)[self.communityArray objectAtIndex:row];
        return community.cellName;
    }
    else if (pickerView.tag == 3)
    {
        Building *building = (Building *)[self.buildingArray objectAtIndex:row];
        return building.buildingName;
    }
    else if (pickerView.tag == 4)
    {
        HouseNum *houseNum = (HouseNum *)[self.houseNumArray objectAtIndex:row];
        return houseNum.numberName;
    }
    else if (pickerView.tag == 5)
    {
        Unit *unit = (Unit *)[self.unitArray objectAtIndex:row];
        return unit.unitName;
    }
    else if (pickerView.tag == 10)
    {
        return [self.identityNameArray objectAtIndex:row];
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
    else if (thePickerView.tag == 2)
    {
        self.pickerSelectRow = row;
    }
    else if (thePickerView.tag == 3)
    {
        self.pickerSelectRow = row;
    }
    else if (thePickerView.tag == 4)
    {
        self.pickerSelectRow = row;
    }
    else if (thePickerView.tag == 5)
    {
        self.pickerSelectRow = row;
    }
    else if (thePickerView.tag == 10)
    {
        self.identityTf.text = [self.identityNameArray objectAtIndex:row];
        identityId = [self.identityIdArray objectAtIndex:row];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.inputAccessoryView == nil)
    {
        textField.inputAccessoryView = [self keyboardToolBar:textField.tag];
    }
    if (textField.tag == 1)
    {
        self.cityPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
        self.cityPicker.showsSelectionIndicator = YES;
        self.cityPicker.delegate = self;
        self.cityPicker.dataSource = self;
        self.cityPicker.tag = 1;
        textField.inputView = self.cityPicker;
        
        City *city = (City *)[self.cityArray objectAtIndex:0];
        self.cityTf.text = city.cityName;
        self.communityTf.enabled = NO;
        self.buildingTf.enabled = NO;
        self.houseNumTf.enabled = NO;
        self.communityTf.text = @"社区";
        self.buildingTf.text = @"楼栋";
        self.unitTf.text = @"单元";
        self.houseNumTf.text = @"门牌号";
    }
    else if (textField.tag == 2)
    {
        self.communityPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
        self.communityPicker.showsSelectionIndicator = YES;
        self.communityPicker.delegate = self;
        self.communityPicker.dataSource = self;
        self.communityPicker.tag = 2;
        textField.inputView = self.communityPicker;
        
        Community *community = (Community *)[self.communityArray objectAtIndex:0];
        self.communityTf.text = community.cellName;
    }
    else if (textField.tag == 3)
    {
        self.buildingPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
        self.buildingPicker.showsSelectionIndicator = YES;
        self.buildingPicker.delegate = self;
        self.buildingPicker.dataSource = self;
        self.buildingPicker.tag = 3;
        textField.inputView = self.buildingPicker;
        
        Building *building = (Building *)[self.buildingArray objectAtIndex:0];
        self.buildingTf.text = building.buildingName;
    }
    else if (textField.tag == 4)
    {
        self.houseNumPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
        self.houseNumPicker.showsSelectionIndicator = YES;
        self.houseNumPicker.delegate = self;
        self.houseNumPicker.dataSource = self;
        self.houseNumPicker.tag = 4;
        textField.inputView = self.houseNumPicker;
        
        HouseNum *houseNum = (HouseNum *)[self.houseNumArray objectAtIndex:0];
        self.houseNumTf.text = houseNum.numberName;
    }
    else if (textField.tag == 5)
    {
        self.unitPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
        self.unitPicker.showsSelectionIndicator = YES;
        self.unitPicker.delegate = self;
        self.unitPicker.dataSource = self;
        self.unitPicker.tag = 5;
        textField.inputView = self.unitPicker;
        
        Unit *unit = (Unit *)[self.unitArray objectAtIndex:0];
        self.unitTf.text = unit.unitName;
    }
    else if (textField.tag == 10)
    {
        self.identityPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
        self.identityPicker.showsSelectionIndicator = YES;
        self.identityPicker.delegate = self;
        self.identityPicker.dataSource = self;
        self.identityPicker.tag = 10;
        textField.inputView = self.identityPicker;
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

//用户不滑动UIPickerView控件及滑动操作过快解决方法，不滑动默认选定数组第一个，滑动过快由于先处理doneClicked事件才会触发UIPickerView选定事件，所有还判断了当前选定全局变量是否大于控件数组长度处理
- (void)doneClicked:(UITextField *)sender
{
    houseNumId = @"";
    if (sender.tag == 1)
    {
        City *city = (City *)[self.cityArray objectAtIndex:self.pickerSelectRow];
        self.cityTf.text = city.cityName;
        [self getCommunityArrayData:city.cityId];
        
    }
    else if (sender.tag == 2)
    {
        if([self.communityArray count] - 1 < self.pickerSelectRow)
        {
            self.pickerSelectRow = 0;
        }
        Community *community = (Community *)[self.communityArray objectAtIndex:self.pickerSelectRow];
        self.communityTf.text = community.cellName;
        self.buildingArray = community.buildingList;
        [self.buildingPicker reloadAllComponents];
        cellId = community.cellId;
        
        if ([self.buildingArray count] > 0) {
            self.buildingTf.enabled = YES;
            self.buildingTf.text = @"楼栋";
        }
        else
        {
            self.buildingTf.enabled = NO;
            self.buildingTf.text = @"暂无楼栋";
        }
    }
    else if (sender.tag == 3)
    {
        if([self.buildingArray count] - 1 < self.pickerSelectRow)
        {
            self.pickerSelectRow = 0;
        }
        Building *building = [self.buildingArray objectAtIndex:self.pickerSelectRow];
        self.buildingTf.text = building.buildingName;
        self.unitArray = building.unitList;
        [self.unitPicker reloadAllComponents];
        
        if ([self.unitArray count] > 0) {
            self.unitTf.enabled = YES;
            self.unitTf.text = @"单元";
        }
        else
        {
            self.unitTf.enabled = NO;
            self.unitTf.text = @"暂无单元";
        }
    }
    else if (sender.tag == 5)
    {
        if([self.unitArray count] - 1 < self.pickerSelectRow)
        {
            self.pickerSelectRow = 0;
        }
        Unit *unit = [self.unitArray objectAtIndex:self.pickerSelectRow];
        self.unitTf.text = unit.unitName;
        self.houseNumArray = unit.houseNumList;
        [self.houseNumPicker reloadAllComponents];
        
        if ([self.houseNumArray count] > 0) {
            self.houseNumTf.enabled = YES;
            self.houseNumTf.text = @"门牌号";
        }
        else
        {
            self.houseNumTf.enabled = NO;
            self.houseNumTf.text = @"暂无门牌";
        }
    }
    else if (sender.tag == 4)
    {
        if([self.houseNumArray count] - 1 < self.pickerSelectRow)
        {
            self.pickerSelectRow = 0;
        }
        HouseNum *houseNum = (HouseNum *)[self.houseNumArray objectAtIndex:self.pickerSelectRow];
        self.houseNumTf.text = houseNum.numberName;
        houseNumId = houseNum.numberId;
    }
    self.pickerSelectRow = 0;
    for (UITextField *field in self.fieldArray)
    {
        [field resignFirstResponder];
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

- (IBAction)addHouseAction:(id)sender {
    if (houseNumId == nil || [houseNumId length] == 0) {
        [Tool showCustomHUD:@"请正确选择您的房间" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    //    if ([self.ownerNameTf.text length] == 0) {
    //        [Tool showCustomHUD:@"请输入业主姓名" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
    //        return;
    //    }
    //    if ([self.idCardTf.text length] != 4) {
    //        [Tool showCustomHUD:@"请输入正确的身份证后四位" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
    //        return;
    //    }
    self.addHouseBtn.enabled = NO;
    //生成注册URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    //    [param setValue:self.ownerNameTf.text forKey:@"rUserName"];
    //    [param setValue:self.idCardTf.text forKey:@"idCardLast4"];
    [param setValue:identityId forKey:@"userTypeId"];
    [param setValue:houseNumId forKey:@"numberId"];
    [param setValue:userInfo.regUserId forKey:@"regUserId"];
    
    NSString *bindOtherHouseSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_bindOtherHouse] params:param];
    NSString *bindOtherHouseUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_bindOtherHouse];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:bindOtherHouseUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:Appkey forKey:@"accessId"];
    //    [request setPostValue:self.ownerNameTf.text forKey:@"rUserName"];
    //    [request setPostValue:self.idCardTf.text forKey:@"idCardLast4"];
    [request setPostValue:identityId forKey:@"userTypeId"];
    [request setPostValue:houseNumId forKey:@"numberId"];
    [request setPostValue:userInfo.regUserId forKey:@"regUserId"];
    
    [request setPostValue:bindOtherHouseSign forKey:@"sign"];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestRegUser:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"添加中..." andView:self.view andHUD:request.hud];
}

- (void)requestRegUser:(ASIHTTPRequest *)request
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
        self.addHouseBtn.enabled = YES;
        return;
    }
    else
    {
        UserHouse *userHouse = [[UserHouse alloc] init];
        userHouse.userTypeId = [identityId intValue];
        userHouse.userTypeName = self.identityTf.text;
        userHouse.cellId = cellId;
        userHouse.cellName = self.communityTf.text;
        userHouse.buildingName = self.buildingTf.text;
        userHouse.unitName= self.unitTf.text;
        userHouse.numberId = houseNumId;
        userHouse.numberName = self.houseNumTf.text;
        userHouse.isDefault = NO;
        [userInfo.rhUserHouseList addObject:userHouse];
        [[UserModel Instance] saveUserInfo:userInfo];
        [Tool showCustomHUD:@"添加成功" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        [self performSelector:@selector(back) withObject:self afterDelay:1.2f];
    }
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
