//
//  AddVolunteerHeaderView.h
//  AnYiDian
//
//  Created by Seven on 15/7/23.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddVolunteerHeaderView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UILabel *faceBg1View;
@property (weak, nonatomic) IBOutlet UILabel *faceBg2View;
@property (weak, nonatomic) IBOutlet UIImageView *faceIv;
@property (weak, nonatomic) IBOutlet UILabel *userInfoLb;
@property (weak, nonatomic) IBOutlet UILabel *mobileNoLb;

@property (weak, nonatomic) IBOutlet UIButton *addVolunteerBtn;
- (IBAction)addVolunteerAction:(id)sender;

@end
