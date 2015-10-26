//
//  MarketingView.h
//  AnYiDian
//
//  Created by Seven on 15/7/27.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MarketingView : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UITextField *estateTf;
@property (weak, nonatomic) IBOutlet UITextField *houseNumberTf;
@property (weak, nonatomic) IBOutlet UITextField *marketingNameTf;
@property (weak, nonatomic) IBOutlet UITextField *marketingMobileTf;
@property (weak, nonatomic) IBOutlet UITextField *marketedNameTf;
@property (weak, nonatomic) IBOutlet UITextField *marketedMobileTf;
@property (weak, nonatomic) IBOutlet UIImageView *adIv;

@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
- (IBAction)submitAction:(id)sender;

@end
