//
//  AppDelegate.h
//  AnYiDian
//
//  Created by Seven on 15/7/8.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,BMKGeneralDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property BOOL isForeground;
@property (copy, nonatomic) NSDictionary *pushInfo;


@end

