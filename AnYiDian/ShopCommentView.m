//
//  ShopCommentView.m
//  AnYiDian
//
//  Created by Seven on 15/8/7.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "ShopCommentView.h"
#import "AMRatingControl.h"

@interface ShopCommentView ()
{
    NSInteger score;
    UserInfo *userInfo;
}

@end

@implementation ShopCommentView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我要点评";
    
    userInfo = [[UserModel Instance] getUserInfo];
    
    [self.commentBtn.layer setCornerRadius:5.0f];
    
    self.contentTv.delegate = self;
    
    UIImage *dot, *star;
    dot = [UIImage imageNamed:@"star_gray.png"];
    star = [UIImage imageNamed:@"star_orange.png"];
    //星级评价
    AMRatingControl *scoreControl = [[AMRatingControl alloc] initWithLocation:CGPointMake(0, 0) emptyImage:dot solidImage:star andMaxRating:5];
    scoreControl.update = @selector(updateScoreRating:);
    [scoreControl sizeToFit];
    scoreControl.starSpacing = 5;
    scoreControl.targer = self;
    scoreControl.enabled = YES;
    [scoreControl setRating:4];
    score = 4;
    
    [self.sorceView addSubview:scoreControl];

    
}

- (void)updateScoreRating:(id)sender
{
    AMRatingControl *scoreControl = (AMRatingControl *)sender;
    score = [scoreControl rating];
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSInteger textLength = [textView.text length];
    if (textLength == 0) {
        [self.placeholderLb setHidden:NO];
    }else{
        [self.placeholderLb setHidden:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)commentAction:(id)sender {
    self.commentBtn.enabled = NO;
    NSString *contentStr = self.contentTv.text;
    if (contentStr == nil || [contentStr length] == 0) {
        [Tool showCustomHUD:@"请输入您的评价" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    
    //生成提交报修评价URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:[NSString stringWithFormat: @"%d", score] forKey:@"sorce"];
    [param setValue:contentStr forKey:@"content"];
    [param setValue:self.shopId forKey:@"shopId"];
    [param setValue:userInfo.regUserId forKey:@"regUserId"];
    NSString *addShopCommentSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_addShopComment] params:param];
    NSString *addShopCommentUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_addShopComment];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:addShopCommentUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:Appkey forKey:@"accessId"];
    [request setPostValue:addShopCommentSign forKey:@"sign"];
    [request setPostValue:[NSString stringWithFormat: @"%d", score] forKey:@"sorce"];
    [request setPostValue:contentStr forKey:@"content"];
    [request setPostValue:self.shopId forKey:@"shopId"];
    [request setPostValue:userInfo.regUserId forKey:@"regUserId"];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestAddShopComment:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"提交评价..." andView:self.view andHUD:request.hud];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
    }
}

- (void)requestAddShopComment:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:YES];
    }
    
    [request setUseCookiePersistence:YES];
    NSData *data = [request.responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSString *state = [[json objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == NO) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                     message:[[json objectForKey:@"header"] objectForKey:@"msg"]
                                                    delegate:nil
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil];
        [av show];
        self.commentBtn.enabled = YES;
        return;
    }
    else
    {
        self.contentTv.text = @"";
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_RefreshShopDetailView object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
