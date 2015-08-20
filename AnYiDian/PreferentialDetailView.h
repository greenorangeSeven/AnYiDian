//
//  PreferentialDetailView.h
//  AnYiDian
//
//  Created by Seven on 15/8/5.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Activity.h"

@interface PreferentialDetailView : UIViewController<UIWebViewDelegate>

@property (copy, nonatomic) Activity *activity;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *attendBtn;
@property (weak, nonatomic) IBOutlet UIButton *praiseBtn;

- (IBAction)praiseAction:(id)sender;
- (IBAction)attendAction:(id)sender;

@end
