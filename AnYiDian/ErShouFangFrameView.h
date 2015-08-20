//
//  ErShouFangFrameView.h
//  AnYiDian
//
//  Created by Seven on 15/8/4.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OldHouseView.h"

@interface ErShouFangFrameView : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *item1Btn;
@property (weak, nonatomic) IBOutlet UIButton *item2Btn;

@property (weak, nonatomic) IBOutlet UIView *mainView;

- (IBAction)item1Action:(id)sender;
- (IBAction)item2Action:(id)sender;

@property (strong, nonatomic) OldHouseView *chushouView;
@property (strong, nonatomic) OldHouseView *chuzuView;

@end
