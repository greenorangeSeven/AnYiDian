//
//  LifeReferView.h
//  BBK
//
//  Created by Seven on 14-12-9.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LifeReferView : UIViewController<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *refers;
    MBProgressHUD *hud;
}

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end
