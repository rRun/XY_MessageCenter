//
//  XY_MessageCenter.h
//  XY_MessageCenter
//
//  Created by 何霞雨 on 16/6/17.
//  Copyright © 2016年 何霞雨. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,XY_PushType) {
    PUSH_VIA_GCM=1,//谷歌推送
    PUSH_VIA_JPUSH=0//极光推送
};

@protocol XY_MessageCenterDelegate;
@protocol XY_MessageCenterDesDelegate;

static NSString *MESSAGE_RECIVE= @"messageSuccess";

@interface XY_MessageCenter : NSObject

@property (nonatomic,weak)id<XY_MessageCenterDelegate>delegate;

@property (nonatomic,assign)XY_PushType pushType;//当前使用的推送服务,默认为jpush
@property (nonatomic,strong)NSString *serviceToken;//推送服务的token
@property (nonatomic,assign)NSInteger badgeNumber;//当前系统badge数字;
@property (nonatomic,strong)NSString *currentAlias;//推送的别名
@property (nonatomic,strong)NSArray *pushGroups;//设置群推，jpush将设置tags，gcm将设置topics


//单例
+(instancetype)defaultMessageCenter;

//登录，注册；如果是gcm可不输入key
-(void)setupWithOption:(NSDictionary *)launchOptions andOptionalKey:(NSString *)appkey;
//［jpush必须实现］将apns token 向推送服务器注册
-(void)register:(NSData *)deviceToken;
//［jpush必须实现］根据别名登录，如果alias为空，则设置为默认别名
-(void)loginWithAlias:(NSString *)alias;
//设置推送群组
-(void)setPushGroups:(NSArray *)pushGroups;

//处理消息,需要在appdlegate收到通知的回调里，实现
-(void)handleMessage:(NSDictionary *)message;
-(void)handleError:(NSError *)error;

//传入处理解析model
-(void)handleMessageModel:(id<XY_MessageCenterDesDelegate>) model;

//铃声或震动
-(void)setRingPlay:(BOOL)isRing;
-(void)setVibratePlay:(BOOL)isVibrate;

@end

@protocol XY_MessageCenterDelegate <NSObject>

//接收到消息
-(void)messageCenter:(XY_MessageCenter *)center WithMessage:(NSDictionary *)message andDesModel:(id<XY_MessageCenterDesDelegate>) respondeModel;

//错误
-(void)messageCenter:(XY_MessageCenter *)center WithError:(NSError *)error;

@end


@protocol XY_MessageCenterDesDelegate <NSObject>

-(void)des:(NSDictionary *)responde;

@end