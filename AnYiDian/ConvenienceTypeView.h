//
//  ConvenienceTypeView.h
//  BBK
//
//  Created by Seven on 14-12-9.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TQImageCache.h"

@interface ConvenienceTypeView : UIViewController<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *types;
    TQImageCache * _iconCache;
    MBProgressHUD *hud;
}

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end
