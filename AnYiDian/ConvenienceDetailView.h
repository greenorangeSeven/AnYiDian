//
//  ConvenienceDetailView.h
//  BBK
//
//  Created by Seven on 14-12-22.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConvenienceDetailView : UIViewController<UIWebViewDelegate>

@property (weak, nonatomic) NSString *titleStr;
@property (weak, nonatomic) NSString *urlStr;
@property (weak, nonatomic) ShopInfo *shopInfo;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (weak, nonatomic) IBOutlet UIButton *praiseBtn;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;

- (IBAction)praiseAction:(id)sender;
- (IBAction)commentAction:(id)sender;

@end
