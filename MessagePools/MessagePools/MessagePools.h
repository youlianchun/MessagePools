//
//  MessagePools.h
//  MessagePools
//
//  Created by YLCHUN on 2017/11/7.
//  Copyright © 2017年 lrlz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessagePools : NSObject

-(instancetype)init NS_UNAVAILABLE;

@property (nonatomic, assign) BOOL handlerLock;


-(instancetype)initWithThreshold:(NSUInteger)threshold priorityKeys:(NSArray<NSString*>*)keys handler:(void(^)(id msg))handler;

+(instancetype)poolsWithThreshold:(NSUInteger)threshold priorityKeys:(NSArray<NSString*>*)keys handler:(void(^)(id msg))handler;

-(void)pushMsg:(id)msg priorityKey:(NSString*)key;

-(void)handlerMsg;

@end

