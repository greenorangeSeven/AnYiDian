//
//  CallServiceView.h
//  BBK
//
//  Created by Seven on 14-12-3.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallServiceView : UIViewController<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *services;
    MBProgressHUD *hud;
    
    NSMutableArray *advDatas;
}

@property (strong, nonatomic) UIImageView *advIv;

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end
