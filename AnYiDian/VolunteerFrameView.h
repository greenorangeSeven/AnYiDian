//
//  VolunteerFrameView.h
//  AnYiDian
//
//  Created by Seven on 15/7/23.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VolunteerNewsView.h"
#import "AddVolunteerView.h"

@interface VolunteerFrameView : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *item1Btn;
@property (weak, nonatomic) IBOutlet UIButton *item2Btn;
@property (weak, nonatomic) IBOutlet UIButton *item3Btn;
@property (weak, nonatomic) IBOutlet UIView *mainView;

- (IBAction)item1Action:(id)sender;
- (IBAction)item2Action:(id)sender;
- (IBAction)item3Action:(id)sender;

@property (strong, nonatomic) VolunteerNewsView *newsView;
@property (strong, nonatomic) VolunteerNewsView *helpView;
@property (strong, nonatomic) AddVolunteerView *addVolunteer;

@end
