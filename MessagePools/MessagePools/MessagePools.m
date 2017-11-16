//
//  MessagePools.m
//  MessagePools
//
//  Created by YLCHUN on 2017/11/7.
//  Copyright © 2017年 lrlz. All rights reserved.
//

#import "MessagePools.h"
#import <pthread.h>

static NSString* const kDefaultKey =  @"__kDefaultKey__";

@implementation MessagePools
{
    NSUInteger _threshold;
    BOOL _startLock;
    NSMutableArray *_priorityKeys;
    NSMutableDictionary<NSString*, NSMutableArray*> *_priorityPools;
    void(^_handler)(id msg);
    pthread_mutex_t _mutex;
}

+(instancetype)poolsWithThreshold:(NSUInteger)threshold priorityKeys:(NSArray<NSString*>*)keys handler:(void(^)(id msg))handler
{
    return [[self alloc] initWithThreshold:threshold priorityKeys:keys handler:handler];
}

-(instancetype)initWithThreshold:(NSUInteger)threshold priorityKeys:(NSArray*)keys handler:(void(^)(id msg))handler
{
    self = [super init];
    if (self)
    {
        pthread_mutex_init(&_mutex, NULL);
        
        _priorityKeys = [NSMutableArray arrayWithArray:keys.count>0?keys:@[kDefaultKey]];
        _priorityPools = [NSMutableDictionary dictionary];
        for (NSString* key in _priorityKeys) {
            _priorityPools[key] = [NSMutableArray array];
        }
        
        _threshold = threshold?:1;
        _startLock = NO;
        _handlerLock = NO;
        _handler = handler;
    }
    return self;
}

-(void)dealloc
{
    pthread_mutex_destroy(&_mutex);
}

-(void)pushMsg:(id)msg priorityKey:(NSString*)key
{
    if (msg == nil) {
        return;
    }
    key = key?:kDefaultKey;

    NSMutableArray *pools = _priorityPools[key];
    if (pools == nil) {
        return;
    }
    
    pthread_mutex_lock(&_mutex);
    
    if (pools.count > _threshold)
    {
        [pools removeObjectAtIndex:0];
    }
    [pools addObject:msg];
    pthread_mutex_unlock(&_mutex);
    
    if (_startLock == NO)
    {
        [self handlerMsg];
    }
}

-(void)handlerMsg
{
    if (_handlerLock == YES) {
        return;
    }
    pthread_mutex_lock(&_mutex);
    NSMutableArray *pools = nil;
    for (int i = 0; i<_priorityKeys.count; i++)
    {
        NSString *key = _priorityKeys[i];
        pools = _priorityPools[key];
        if (pools.count > 0)
        {
            break;
        }
    }
    
    if (pools.count > 0)
    {
        _startLock = YES;
        id top = [pools objectAtIndex:0];
        [pools removeObjectAtIndex:0];
        pthread_mutex_unlock(&_mutex);
        _handler(top);
    }
    else
    {
        _startLock = NO;
        pthread_mutex_unlock(&_mutex);
    }
}

-(void)setHandlerLock:(BOOL)handlerLock {
    if (_handlerLock == handlerLock) {
        return;
    }
    _handlerLock = handlerLock;
    if (_handlerLock == NO) {
        [self handlerMsg];
    }
}

@end
