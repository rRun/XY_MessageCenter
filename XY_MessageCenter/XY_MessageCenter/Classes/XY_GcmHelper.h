//
//  XY_GcmHelper.h
//  XY_MessageCenter
//
//  Created by 何霞雨 on 16/6/17.
//  Copyright © 2016年 何霞雨. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XY_GcmHelper : NSObject
@property (nonatomic,strong)NSString *gcmToken;//推送服务的token
@property (nonatomic,assign)NSInteger badgeNumber;//当前系统badge数字;
//初始化
-(void)setup;
//设置主题，做群推
-(void)setTopic:(NSArray<NSString *> *)topics;


@end

