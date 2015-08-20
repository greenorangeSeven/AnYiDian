//
//  ConvenienceCell.h
//  BBK
//
//  Created by Seven on 14-12-10.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConvenienceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *shopNameLb;
@property (weak, nonatomic) IBOutlet UILabel *shopAddressLb;
@property (weak, nonatomic) IBOutlet UILabel *shopPhoneLb;
@property (weak, nonatomic) IBOutlet UIImageView *imageIv;
@property (weak, nonatomic) IBOutlet UIButton *locationBtn;

@end
