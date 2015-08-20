//
//  MyPageView.h
//  AnYiDian
//
//  Created by Seven on 15/7/15.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPImageCropperViewController.h"

@interface MyPageView : UIViewController<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, VPImageCropperDelegate, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *faceBg1View;
@property (weak, nonatomic) IBOutlet UILabel *faceBg2View;
@property (weak, nonatomic) IBOutlet UIImageView *faceIv;
@property (weak, nonatomic) IBOutlet UILabel *topicCountLb;

@property (weak, nonatomic) IBOutlet UILabel *userInfoLb;
@property (weak, nonatomic) IBOutlet UILabel *mobileNoLb;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *callServiceView;
@property (weak, nonatomic) IBOutlet UIView *myIntegralView;
@property (weak, nonatomic) IBOutlet UILabel *integralLabel;
@property (weak, nonatomic) IBOutlet UIView *topicView;

- (IBAction)modifyUserInfoAction:(id)sender;
- (IBAction)uploadFaceAction:(id)sender;

@end
