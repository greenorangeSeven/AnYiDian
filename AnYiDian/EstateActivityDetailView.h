//
//  EstateActivityDetailView.h
//  AnYiDian
//
//  Created by Seven on 15/7/21.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EstateActivity.h"

@interface EstateActivityDetailView : UIViewController<UIWebViewDelegate>

@property (copy, nonatomic) EstateActivity *activity;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *attendBtn;
@property (weak, nonatomic) IBOutlet UIButton *praiseBtn;

- (IBAction)praiseAction:(id)sender;
- (IBAction)attendAction:(id)sender;

@end
