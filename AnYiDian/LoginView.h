//
//  LoginView.h
//  AnYiDian
//
//  Created by Seven on 15/7/13.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginView : UIViewController<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *mobileNoTf;
@property (weak, nonatomic) IBOutlet UITextField *passwordTf;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *visitorBtn;
@property (weak, nonatomic) IBOutlet UIButton *findPasswordBtn;

- (IBAction)registerAction:(id)sender;
- (IBAction)loginAction:(id)sender;
- (IBAction)findPasswordAction:(id)sender;

@end
