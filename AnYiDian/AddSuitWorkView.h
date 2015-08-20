//
//  AddSuitWorkView.h
//  BBK
//
//  Created by Seven on 14-12-14.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddSuitWorkView : UIViewController<UITextViewDelegate, UIActionSheetDelegate, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *faceBg1View;
@property (weak, nonatomic) IBOutlet UILabel *faceBg2View;
@property (weak, nonatomic) IBOutlet UIImageView *faceIv;

@property (weak, nonatomic) IBOutlet UILabel *userInfoLb;
@property (weak, nonatomic) IBOutlet UILabel *mobileNoLb;

@property (weak, nonatomic) IBOutlet UILabel *suitContentPlaceholder;
@property (weak, nonatomic) IBOutlet UITextView *suitContentTv;
@property (weak, nonatomic) IBOutlet UILabel *suitTypeNameLb;
@property (weak, nonatomic) IBOutlet UIButton *submitSuitBtn;
@property (weak, nonatomic) IBOutlet UIButton *telServiceBtn;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (IBAction)selectSuitTypeAction:(id)sender;
- (IBAction)telServiceAction:(id)sender;
- (IBAction)submitSuitAction:(id)sender;

@end
