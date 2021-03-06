//
//  XY_GcmHelper.m
//  XY_MessageCenter
//
//  Created by 何霞雨 on 16/6/17.
//  Copyright © 2016年 何霞雨. All rights reserved.
//

#import "XY_GcmHelper.h"

@import Firebase;
@import FirebaseInstanceID;
@import FirebaseMessaging;


#import "XY_MessageCenter.h"

@implementation XY_GcmHelper{
    NSArray *topicsArr;
}
-(void)setup{
    // Register for remote notifications
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        // iOS 7.1 or earlier
        UIRemoteNotificationType allNotificationTypes =
        (UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:allNotificationTypes];
    } else {
        // iOS 8 or later
        // [END_EXCLUDE]
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    
    // [START configure_firebase]
    [FIRApp configure];
    // [END configure_firebase]
    
    // Add observer for InstanceID token refresh callback.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenRefreshNotification:)
                                                 name:kFIRInstanceIDTokenRefreshNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
}

//设置主题
-(void)setTopic:(NSArray<NSString *> *)topics{
    topicsArr = topics;
    if (self.gcmToken ==nil) {
        return;
    }
    dispatch_queue_t queue =dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        [topics enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *topic = [NSString stringWithFormat:@"/topics/%@",obj];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1ull *NSEC_PER_SEC), queue, ^{
                [[FIRMessaging messaging] subscribeToTopic:topic];
            });
            
        }];
    });

}

//注册成功
- (void)tokenRefreshNotification:(NSNotification *)notification {
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    NSLog(@"InstanceID token: %@", refreshedToken);
    self.gcmToken = refreshedToken;
    
    if ([[XY_MessageCenter defaultMessageCenter].delegate respondsToSelector:@selector(messageCenter:didLoginWIthInfo:)]) {
        [[XY_MessageCenter defaultMessageCenter].delegate messageCenter:[XY_MessageCenter defaultMessageCenter] didLoginWIthInfo:nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:MESSAGE_LOGIN object:nil];
    }
    
    
    [self connectToFcm];
}

- (void)connectToFcm {
    [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Unable to connect to FCM. %@", error);
            [[XY_MessageCenter defaultMessageCenter]handleError:error];
        } else {
            NSLog(@"Connected to FCM.");
//            if ([topicsArr count]>0) {
//                [self setTopic:topicsArr];
//            }
        }
    }];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self connectToFcm];
}

// [START disconnect_from_fcm]
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[FIRMessaging messaging] disconnect];
    NSLog(@"Disconnected from FCM");
}

#pragma mark -Getter and Setter
-(NSString *)gcmToken{
    NSString *token = [[FIRInstanceID instanceID] token];
    return token;
}

-(void)setBadgeNumber:(NSInteger)badgeNumber{
    if (badgeNumber>=1) {
        _badgeNumber =badgeNumber;
         [UIApplication sharedApplication].applicationIconBadgeNumber = badgeNumber;
    }else{
        _badgeNumber=0;
         [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
}
@end
