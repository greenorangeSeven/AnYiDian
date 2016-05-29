//
//  AddHouseView.h
//  JinChang
//
//  Created by Seven on 15/8/31.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddHouseView : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *cityTf;
@property (weak, nonatomic) IBOutlet UITextField *communityTf;
@property (weak, nonatomic) IBOutlet UITextField *buildingTf;
@property (weak, nonatomic) IBOutlet UITextField *unitTf;
@property (weak, nonatomic) IBOutlet UITextField *houseNumTf;

//@property (weak, nonatomic) IBOutlet UITextField *ownerNameTf;
//@property (weak, nonatomic) IBOutlet UITextField *idCardTf;
@property (weak, nonatomic) IBOutlet UITextField *identityTf;

@property (weak, nonatomic) IBOutlet UIButton *addHouseBtn;
- (IBAction)addHouseAction:(id)sender;

@end
