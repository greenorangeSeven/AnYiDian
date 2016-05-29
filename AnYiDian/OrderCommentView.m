//
//  OrderCommentView.m
//  AnYiDian
//
//  Created by Seven on 16/5/29.
//  Copyright © 2016年 Seven. All rights reserved.
//

#import "OrderCommentView.h"
#import "AMRatingControl.h"

@interface OrderCommentView ()
{
    NSArray *orderSorce;
}

@end

@implementation OrderCommentView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"订单评价";
    
    [self.submitScoreBtn.layer setCornerRadius:5.0f];
    
    self.resultContentTv.delegate = self;
    
    if (self.order.stateId == 6) {
        self.resultContentTv.editable = NO;
        self.submitScoreBtn.hidden = YES;
        self.resultContentTv.text = self.order.userRecontent;
    }
    
    [self getOrderInfo];
}

- (void)getOrderInfo
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:self.order.orderId forKey:@"orderId"];
        NSString *updateOrderCloseUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findOrderInfoById] params:param];
        [[AFOSCClient sharedClient]getPath:updateOrderCloseUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
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
                                               return;
                                           }
                                           else
                                           {
                                               NSDictionary *datas = [json objectForKey:@"data"];
                                               NSArray *array = [datas objectForKey:@"orderResult"];
                                               
                                               orderSorce = [NSMutableArray arrayWithArray:[Tool readJsonToObjArray:array andObjClass:[RepairResuleItem class]]];
                                               if ([orderSorce count] > 0) {
                                                   [self initOrderSorceView];
                                               }
                                           }
                                       }
                                       @catch (NSException *exception) {
                                           [NdUncaughtExceptionHandler TakeException:exception];
                                       }
                                       @finally {
                                           
                                       }
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       if ([UserModel Instance].isNetworkRunning == NO) {
                                           return;
                                       }
                                       if ([UserModel Instance].isNetworkRunning) {
                                           [Tool ToastNotification:@"错误 网络无连接" andView:self.view andLoading:NO andIsBottom:NO];
                                       }
                                   }];
    }
}

- (void)initOrderSorceView
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    UIImage *dot, *star;
    dot = [UIImage imageNamed:@"star_gray.png"];
    star = [UIImage imageNamed:@"star_orange.png"];
    
    
    for (int i = 0; i < [orderSorce count]; i++) {
        RepairResuleItem *item = [orderSorce objectAtIndex:i];
        UIView *itemView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 39.0 * i, width, 39.0)];
        
        UILabel *itemNameLb = [[UILabel alloc]initWithFrame:CGRectMake(8.0, 9.0, 87.0, 21.0)];
        itemNameLb.font = [UIFont systemFontOfSize:14];
        itemNameLb.text = item.dimensionName;
        itemNameLb.textColor = [UIColor colorWithRed:137.0/255.0 green:137.0/255.0 blue:137.0/255.0 alpha:1.0];
        [itemView addSubview:itemNameLb];
        
        UILabel *bottomLb = [[UILabel alloc]initWithFrame:CGRectMake(0.0, 38.0, width, 1.0)];
        bottomLb.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
        [itemView addSubview:bottomLb];
        
        //星级评价
        AMRatingControl *scoreControl = [[AMRatingControl alloc] initWithLocation:CGPointMake(width - 120, 10) emptyImage:dot solidImage:star andMaxRating:5];
        scoreControl.tag = i;
        scoreControl.update = @selector(updateScoreRating:);
        scoreControl.targer = self;
        [scoreControl setRating:item.score];
        
        [itemView addSubview:scoreControl];
        
        if (self.order.stateId == 6) {
            scoreControl.enabled = NO;
        }
        else
        {
            scoreControl.enabled = YES;
        }
        
        [self.scoreFrameView addSubview:itemView];
    }
    
    CGRect scoreViewFrame = self.scoreFrameView.frame;
    scoreViewFrame.size.height += ([orderSorce count] - 1) * 39.0;
    self.scoreFrameView.frame = scoreViewFrame;
    
    CGRect resultContentFrame = self.resultContentView.frame;
    resultContentFrame.origin.y += ([orderSorce count] - 1) * 39.0;
    self.resultContentView.frame = resultContentFrame;
}

- (void)updateScoreRating:(id)sender
{
    AMRatingControl *scoreControl = (AMRatingControl *)sender;
    RepairResuleItem *item = [orderSorce objectAtIndex:scoreControl.tag];
    item.score = [scoreControl rating];
}

- (IBAction)submitScoreAction:(id)sender
{
    
    NSMutableString *scoreMutable = [[NSMutableString alloc] init];
    for (RepairResuleItem *item in orderSorce) {
        NSString *scoreItem = [NSString stringWithFormat:@"%d,%d;", item.dimensionId, item.score];
        [scoreMutable appendString:scoreItem];
    }
    NSString *sorce = [[NSString stringWithString:scoreMutable] substringToIndex:[scoreMutable length] -1];
    NSString *userRecontent = self.resultContentTv.text;
    if (userRecontent.length == 0) {
        [Tool showCustomHUD:@"请输入评论内容" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    self.submitScoreBtn.enabled = NO;
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:sorce forKey:@"sorce"];
    [param setValue:self.order.orderId forKey:@"orderId"];
    if ([userRecontent length] > 0) {
        [param setValue:userRecontent forKey:@"userRecontent"];
    }
    NSString *submitOrderSorceSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_submitOrderSorce] params:param];
    NSString *submitOrderSorcerUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_submitOrderSorce];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:submitOrderSorcerUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:Appkey forKey:@"accessId"];
    [request setPostValue:sorce forKey:@"sorce"];
    [request setPostValue:self.order.orderId forKey:@"orderId"];
    if ([userRecontent length] > 0) {
        [request setPostValue:userRecontent forKey:@"userRecontent"];
    }
    [request setPostValue:submitOrderSorceSign forKey:@"sign"];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestsubmitOrderSorce:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"提交评价..." andView:self.view andHUD:request.hud];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
        
    }
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
    self.submitScoreBtn.enabled = YES;
}
- (void)requestsubmitOrderSorce:(ASIHTTPRequest *)request
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
        self.submitScoreBtn.enabled = YES;
        return;
    }
    else
    {
        [Tool showCustomHUD:@"谢谢您的对我们的评价！" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        self.submitScoreBtn.hidden = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_ReloadMyOrder object:nil];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    int textLength = [textView.text length];
    if (textLength == 0)
    {
        [self.resultContentPlaceholder setHidden:NO];
    }
    else
    {
        [self.resultContentPlaceholder setHidden:YES];
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

@end
