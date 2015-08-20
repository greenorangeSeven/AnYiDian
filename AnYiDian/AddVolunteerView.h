//
//  AddVolunteerView.h
//  AnYiDian
//
//  Created by Seven on 15/7/23.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddVolunteerView : UIViewController<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *volunteers;
    MBProgressHUD *hud;
}

@property (weak, nonatomic) UIView *frameView;

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end
