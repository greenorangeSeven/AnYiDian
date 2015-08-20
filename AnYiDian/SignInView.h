//
//  SignInView.h
//  AnYiDian
//
//  Created by Seven on 15/7/23.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignInView : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *signInBtn;
@property (weak, nonatomic) IBOutlet UIButton *luckyDrawBtn;

- (IBAction)signInAction:(id)sender;
- (IBAction)luckyDrawAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *integralLb;

@end
