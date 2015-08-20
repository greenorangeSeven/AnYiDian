//
//  PayFeeFrameView.m
//  AnYiDian
//
//  Created by Seven on 15/8/13.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "PayFeeFrameView.h"

@interface PayFeeFrameView ()

@end

@implementation PayFeeFrameView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"物业缴费";
    
    //下属控件初始化
    self.wuyeFeeView = [[PayFeeTableView alloc] init];
    self.wuyeFeeView.typeId = @"0";
    self.wuyeFeeView.frameView = self.mainView;
    [self addChildViewController:self.wuyeFeeView];
    [self.mainView addSubview:self.wuyeFeeView.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)item1Action:(id)sender {
    [self.item1Btn setTitleColor:[Tool getColorForMain] forState:UIControlStateNormal];
    [self.item2Btn setTitleColor:[UIColor colorWithRed:131.0/255 green:132.0/255 blue:133.0/255 alpha:1.0] forState:UIControlStateNormal];
    [self.item3Btn setTitleColor:[UIColor colorWithRed:131.0/255 green:132.0/255 blue:133.0/255 alpha:1.0] forState:UIControlStateNormal];
    self.wuyeFeeView.view.hidden = NO;
    self.dianFeeView.view.hidden = YES;
    self.tingcheFeeView.view.hidden = YES;
}

- (IBAction)item2Action:(id)sender {
    [self.item1Btn setTitleColor:[UIColor colorWithRed:131.0/255 green:132.0/255 blue:133.0/255 alpha:1.0] forState:UIControlStateNormal];
    [self.item2Btn setTitleColor:[Tool getColorForMain] forState:UIControlStateNormal];
    [self.item3Btn setTitleColor:[UIColor colorWithRed:131.0/255 green:132.0/255 blue:133.0/255 alpha:1.0] forState:UIControlStateNormal];
    if (self.dianFeeView == nil) {
        self.dianFeeView = [[PayFeeTableView alloc] init];
        self.dianFeeView.typeId = @"1";
        self.dianFeeView.frameView = self.mainView;
        [self addChildViewController:self.dianFeeView];
        [self.mainView addSubview:self.dianFeeView.view];
    }
    self.wuyeFeeView.view.hidden = YES;
    self.dianFeeView.view.hidden = NO;
    self.tingcheFeeView.view.hidden = YES;
}

- (IBAction)item3Action:(id)sender {
    [self.item1Btn setTitleColor:[UIColor colorWithRed:131.0/255 green:132.0/255 blue:133.0/255 alpha:1.0] forState:UIControlStateNormal];
    [self.item2Btn setTitleColor:[UIColor colorWithRed:131.0/255 green:132.0/255 blue:133.0/255 alpha:1.0] forState:UIControlStateNormal];
    [self.item3Btn setTitleColor:[Tool getColorForMain] forState:UIControlStateNormal];
    if (self.tingcheFeeView == nil) {
        self.tingcheFeeView = [[PayFeeTableView alloc] init];
        self.tingcheFeeView.typeId = @"2";
        self.tingcheFeeView.frameView = self.mainView;
        [self addChildViewController:self.tingcheFeeView];
        [self.mainView addSubview:self.tingcheFeeView.view];
    }
    self.wuyeFeeView.view.hidden = YES;
    self.dianFeeView.view.hidden = YES;
    self.tingcheFeeView.view.hidden = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    self.navigationController.navigationBar.hidden = NO;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
}

@end
