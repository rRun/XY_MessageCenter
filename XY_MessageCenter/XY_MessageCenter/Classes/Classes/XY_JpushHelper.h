//
//  XY_JpushHelper.h
//  XY_MessageCenter
//
//  Created by 何霞雨 on 16/6/17.
//  Copyright © 2016年 何霞雨. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XY_JpushHelper : NSObject

@property (nonatomic,strong)NSString *appKey;//APP Key
@property (nonatomic,assign)BOOL isProduction;//推送环境
@property (nonatomic,strong)NSString *jpushToken;//推送服务的token，其实就是我们设置的alias
@property (nonatomic,strong)NSString *currentAlias;//推送的别名
@property (nonatomic,strong)NSArray *currentTags;//推送的群组
@property (nonatomic,assign)NSInteger badgeNumber;//当前系统badge数字;

//登录，注册
-(void)setupWithOption:(NSDictionary *)launchOptions;//注册
-(void)register:(NSData *)deviceToken;

//根据别名登录，如果alias为空，则设置为默认别名
-(void)loginWithAlias:(NSString *)alias;
//根据别名登录，如果alias为空，则设置为默认别名
-(void)setWithTags:(NSArray *)tags;

//处理消息
-(void)handleMessage:(NSDictionary *)message;


@end

