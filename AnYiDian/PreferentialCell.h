//
//  PreferentialCell.h
//  AnYiDian
//
//  Created by Seven on 15/8/5.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreferentialCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageIv;
@property (strong, nonatomic) IBOutlet UIView *bg;
@property (strong, nonatomic) IBOutlet UILabel *titleLb;
@property (strong, nonatomic) IBOutlet UILabel *dateLb;
@property (strong, nonatomic) IBOutlet UITextView *contentLb;
@property (strong, nonatomic) IBOutlet UILabel *telephoneLb;
@property (strong, nonatomic) IBOutlet UILabel *qqLb;

@property (strong, nonatomic) IBOutlet UIButton *praiseBtn;
@property (strong, nonatomic) IBOutlet UIButton *attendBtn;
@property (weak, nonatomic) IBOutlet UIButton *checkDetailBtn;

@end
