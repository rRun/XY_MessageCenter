//
//  XY_JpushHelper.m
//  XY_MessageCenter
//
//  Created by 何霞雨 on 16/6/17.
//  Copyright © 2016年 何霞雨. All rights reserved.
//

#import "XY_JpushHelper.h"

#import <UIKit/UIKit.h>
#import "JPUSHService.h"
#import <AdSupport/AdSupport.h>

#import "XY_MessageCenter.h"

static NSString *channel = @"Publish channel";
@implementation XY_JpushHelper
#pragma mark - 注册/登录
-(void)setupWithOption:(NSDictionary *)launchOptions{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    } else {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                          UIRemoteNotificationTypeSound |
                                                          UIRemoteNotificationTypeAlert)
                                              categories:nil];
    }
    
    //如不需要使用IDFA，advertisingIdentifier 可为nil
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    [JPUSHService setupWithOption:launchOptions appKey:self.appKey
                          channel:channel
                 apsForProduction:self.isProduction
            advertisingIdentifier:advertisingId];
    
}

-(void)register:(NSData *)deviceToken{
    NSLog(@"%@", [NSString stringWithFormat:@"Device Token: %@", deviceToken]);
    [JPUSHService registerDeviceToken:deviceToken];
}

//根据别名登录
-(void)loginWithAlias:(NSString *)alias{
    
    [JPUSHService setAlias:alias
          callbackSelector:@selector(tagsAliasCallback:tags:alias:)
                    object:self];
}

//根据别名登录，如果alias为空，则设置为默认别名
-(void)setWithTags:(NSArray *)tags{
    NSSet *set = [NSSet setWithArray:tags];
    [JPUSHService setTags:set callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:nil];
}

static int setAliasCount = 0;//如果设置alias超过20次，就停止设置
//设置别名,组别的回调
- (void)tagsAliasCallback:(int)iResCode
                     tags:(NSSet *)tags
                    alias:(NSString *)alias {
    setAliasCount ++;//设置标志
    
    NSString *callbackString =
    [NSString stringWithFormat:@"%d, \ntags: %@, \nalias: %@\n", iResCode,
     tags, alias];
    
    NSLog(@"TagsAlias回调:%@", callbackString);
    
    if (iResCode == 0) {
        if ([tags count]!=0) {
            NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];
            NSArray *sortSetArray = [tags sortedArrayUsingDescriptors:sortDesc];
            self.currentTags = sortSetArray;
        }else
            self.currentAlias= alias;
        
        setAliasCount = 0;//设置标志
        
    }else{//延时处理，重新登录
        
        if (setAliasCount >= 20) {//设置标志
            setAliasCount = 0 ;
            return;
        }
        
        dispatch_queue_t queue = dispatch_queue_create("sc", DISPATCH_QUEUE_CONCURRENT);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), queue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([tags count]!=0) {
                    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];
                    NSArray *sortSetArray = [tags sortedArrayUsingDescriptors:sortDesc];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setWithTags:sortSetArray];
                    });
                    
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self loginWithAlias:alias];
                    });
                    
                }
                
            });
        });
    }
    
    
}
#pragma mark - Handle Message
-(void)handleMessage:(NSDictionary *)message{
    //告知jpush收到消息
    [JPUSHService handleRemoteNotification:message];
}

#pragma mark - Notifation
-(void)addNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkDidRegister:)
                                                 name:kJPFNetworkDidRegisterNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkDidLogin:)
                                                 name:kJPFNetworkDidLoginNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkDidReceiveMessage:)
                                                 name:kJPFNetworkDidReceiveMessageNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(serviceError:)
                                                 name:kJPFServiceErrorNotification
                                               object:nil];
}

//登录／注册
- (void)networkDidRegister:(NSNotification *)notification {
    NSLog(@"已注册%@", [notification userInfo]);
    
}

- (void)networkDidLogin:(NSNotification *)notification {
    NSLog(@"已登录");
    
    if ([JPUSHService registrationID]) {
        NSLog(@"get RegistrationID");
    }
}

- (void)serviceError:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString *errorStr = [userInfo valueForKey:@"error"];
    NSLog(@"%@", errorStr);
    NSDictionary *userInfoDic = [NSDictionary dictionaryWithObject:errorStr forKey:NSLocalizedDescriptionKey];
    NSError *error = [[NSError alloc]initWithDomain:@"MessageDomin" code:-99 userInfo:userInfoDic];
    [[XY_MessageCenter defaultMessageCenter] handleError:error];
}

//获取消息
- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSLog(@"接受到非APNS的消息：%@", userInfo);
    //处理消息
    [[XY_MessageCenter defaultMessageCenter]handleMessage:userInfo];
}

#pragma mark - Badge

-(void)setBadgeNumber:(NSInteger)badgeNumber{
    _badgeNumber = badgeNumber;
    
    if (badgeNumber == 0) {
        [JPUSHService resetBadge];
    }else
        [JPUSHService setBadge:badgeNumber];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = badgeNumber;
}

#pragma mark - getter and setter
-(NSString *)jpushToken{
    return self.currentAlias;
}
@end
