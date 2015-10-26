//
//  PayFeeDetailView.m
//  AnYiDian
//
//  Created by Seven on 15/8/13.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "PayFeeDetailView.h"
#import <AlipaySDK/AlipaySDK.h>

@interface PayFeeDetailView ()

@end

@implementation PayFeeDetailView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"缴费清单";
    
    self.monthLb.text = [NSString stringWithFormat:@"%@账单", self.bill.monthStr];
    NSString *moneyStr = @"";
    if (self.bill.typeId == 0) {
        moneyStr = [NSString stringWithFormat:@"物业费：%0.2f元", self.bill.totalMoney];
    }
    else if (self.bill.typeId == 1)
    {
        moneyStr = [NSString stringWithFormat:@"电费：%0.2f元", self.bill.totalMoney];
    }
    else if (self.bill.typeId == 2)
    {
        moneyStr = [NSString stringWithFormat:@"停车费：%0.2f元", self.bill.totalMoney];
    }
    self.moneyLb.text = moneyStr;
    self.totalLb.text = [NSString stringWithFormat:@"%0.2f元", self.bill.totalMoney];
    
    [self.payBtn.layer setCornerRadius:5.0f];
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

- (IBAction)doPayAction:(id)sender {
    //生成支付宝订单URL
    NSString *createOrderUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_createAlipayParams];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:createOrderUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:self.bill.detailsId forKey:@"billDetailsId"];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestCreate:)];
    [request startAsynchronous];
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在支付..." andView:self.view andHUD:request.hud];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:NO];
    }
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
}

- (void)requestCreate:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:YES];
    }
    
    [request setUseCookiePersistence:YES];
    NSData *data = [request.responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSString *state = [json objectForKey:@"state"];
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
        NSString *orderStr = [json objectForKey:@"msg"];
        [[AlipaySDK defaultService] payOrder:orderStr fromScheme:@"AnYiDianAlipay" callback:^(NSDictionary *resultDic)
         {
             NSString *resultState = resultDic[@"resultStatus"];
             if([resultState isEqualToString:ORDER_PAY_OK])
             {
                 [self updatePayedTable];
             }
         }];
    }
}

#pragma mark 刷新列表(当程序支付时在后台被kill掉时供appdelegate调用)
- (void)updatePayedTable
{
    [Tool showCustomHUD:@"支付成功" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:2];
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_RefreshPayFeeTableView object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
