//
//  XY_MessageCenter.m
//  XY_MessageCenter
//
//  Created by 何霞雨 on 16/6/17.
//  Copyright © 2016年 何霞雨. All rights reserved.
//

#import "XY_MessageCenter.h"

#import "XY_JpushHelper.h"
#import "XY_GcmHelper.h"

#import <AudioToolbox/AudioToolbox.h>
#import <UIKit/UIKit.h>

@implementation XY_MessageCenter
{
    XY_GcmHelper *gcmHelper;
    XY_JpushHelper *jpushHelper;
    id<XY_MessageCenterDesDelegate> desModel;//解析的model;
    
    SystemSoundID soundId;//播放铃声
    BOOL _isRing;
    BOOL _isVibrate;
}

static XY_MessageCenter *defaultCenter;

+(instancetype)defaultMessageCenter{
    if (!defaultCenter) {
        defaultCenter = [[XY_MessageCenter alloc]init];
        [defaultCenter initRing];
        
        defaultCenter.badgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber;
    }
    return defaultCenter;
}

#pragma mark － 链接，登录，注册
//登录，注册
-(void)setupWithOption:(NSDictionary *)launchOptions andOptionalKey:(NSString *)appkey{
    if (self.pushType == PUSH_VIA_GCM) {
        gcmHelper = [[XY_GcmHelper alloc]init];
        if (gcmHelper) {
            [gcmHelper setup];
        }
    }else if (self.pushType == PUSH_VIA_JPUSH){
        jpushHelper = [[XY_JpushHelper alloc]init];
        if (jpushHelper) {
            jpushHelper.appKey = appkey;
            [jpushHelper setupWithOption:launchOptions];
        }
        
    }
}
//将apns token 向推送服务器注册
-(void)register:(NSData *)deviceToken{
    if (self.pushType == PUSH_VIA_JPUSH && jpushHelper){
        [jpushHelper register:deviceToken];
    }
}

//根据别名登录，如果alias为空，则设置为默认别名
-(void)loginWithAlias:(NSString *)alias{
    if (self.pushType == PUSH_VIA_GCM && gcmHelper) {
        return;
    }else if (self.pushType == PUSH_VIA_JPUSH && jpushHelper){
        [jpushHelper loginWithAlias:alias];
    }
}

//设置推送群组
-(void)setPushGroups:(NSArray *)pushGroups{
    _pushGroups = pushGroups;
    if (self.pushType == PUSH_VIA_GCM && gcmHelper) {
        [gcmHelper setTopic:pushGroups];
        
    }else if (self.pushType == PUSH_VIA_JPUSH && jpushHelper){
        [jpushHelper setWithTags:pushGroups];
    }
}
#pragma mark - 处理消息
//处理消息
-(void)handleMessage:(NSDictionary *)message{
    NSLog(@"收到通知:%@", message);
    NSMutableDictionary *newMessage = [[NSMutableDictionary alloc]initWithDictionary:message];
    
    if (self.pushType == PUSH_VIA_JPUSH && jpushHelper){
        [jpushHelper handleMessage:message];
    }
    
    //前后台，设置铃声或震荡
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        if (_isRing) {
            [self playRing];
        }
        if (_isVibrate) {
            [self playVibrate];
        }
        [newMessage setValue:@1 forKey:@"isActive"];//收到的消息是否在前后台
    }else
        [newMessage setValue:@0 forKey:@"isActive"];//收到的消息是否在前后台
    
    //解析badege number
    if ([[newMessage objectForKey:@"aps"]isKindOfClass:[NSDictionary class]]) {
        NSInteger badege = [[[newMessage objectForKey:@"aps"]objectForKey:@"badge"] integerValue];
        self.badgeNumber = badege;
    }
    
    if (desModel) {
        [desModel des:newMessage];
    }
    
    if ([self.delegate respondsToSelector:@selector(messageCenter:WithMessage:andDesModel:)]) {
        [self.delegate messageCenter:self WithMessage:newMessage andDesModel:desModel];
    }
    
    //发出通知
    [[NSNotificationCenter defaultCenter]postNotificationName:MESSAGE_RECIVE object:self userInfo:newMessage];
    
    
}
-(void)handleError:(NSError *)error{
    if ([self.delegate respondsToSelector:@selector(messageCenter:WithError:)]) {
        [self.delegate messageCenter:self WithError:error];
    }
}
#pragma mark - Badge

-(void)setBadgeNumber:(NSInteger)badgeNumber{
    if (self.pushType == PUSH_VIA_GCM && gcmHelper) {
        gcmHelper.badgeNumber = badgeNumber;
        
    }else if (self.pushType == PUSH_VIA_JPUSH && jpushHelper){
        jpushHelper.badgeNumber = badgeNumber;
    }else{
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
}
-(NSInteger)badgeNumber{
    if (self.pushType == PUSH_VIA_GCM && gcmHelper) {
        return gcmHelper.badgeNumber;
        
    }else if (self.pushType == PUSH_VIA_JPUSH && jpushHelper){
        return jpushHelper.badgeNumber;
    }else
        return 0;
}
#pragma mark - 铃声，震动

-(void)initRing{
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"sound" ofType:@"caf"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundId);
}

-(void)playRing{
    AudioServicesPlaySystemSound(soundId);
}

-(void)playVibrate{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

//设置铃声
-(void)setRingPlay:(BOOL)isRing{
    _isRing = isRing;
}
//设置震动
-(void)setVibratePlay:(BOOL)isVibrate{
    _isVibrate = isVibrate;
}
#pragma mark - Setter and Getter

//传入处理解析model
-(void)handleMessageModel:(id<XY_MessageCenterDesDelegate>) model{
    desModel = model;
}

-(NSString *)serviceToken{
    if (self.pushType == PUSH_VIA_GCM && gcmHelper) {
        return gcmHelper.gcmToken;
    }else if (self.pushType == PUSH_VIA_JPUSH && jpushHelper){
        return jpushHelper.jpushToken;
    }else
        return nil;
}

@end
