//
//  ShopCommentView.h
//  AnYiDian
//
//  Created by Seven on 15/8/7.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopCommentView : UIViewController<UITextViewDelegate>

@property (weak, nonatomic) NSString *shopId;

@property (weak, nonatomic) IBOutlet UILabel *sorceView;
@property (weak, nonatomic) IBOutlet UITextView *contentTv;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLb;

@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
- (IBAction)commentAction:(id)sender;

@end
