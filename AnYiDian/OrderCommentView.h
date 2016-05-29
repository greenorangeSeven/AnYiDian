//
//  OrderCommentView.h
//  AnYiDian
//
//  Created by Seven on 16/5/29.
//  Copyright © 2016年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderCommentView : UIViewController<UITextViewDelegate>

@property (copy, nonatomic) MyOrder *order;

@property (weak, nonatomic) IBOutlet UIView *scoreFrameView;
@property (weak, nonatomic) IBOutlet UITextView *resultContentTv;
@property (weak, nonatomic) IBOutlet UIView *resultContentView;
@property (weak, nonatomic) IBOutlet UIButton *submitScoreBtn;

@property (weak, nonatomic) IBOutlet UILabel *resultContentPlaceholder;

- (IBAction)submitScoreAction:(id)sender;


@end
