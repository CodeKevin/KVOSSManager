//
//  KVOSSManager.h
//  KVOSSManagerDemo
//
//  Created by Kevin on 2018/2/6.
//  Copyright © 2018年 Kevin. All rights reserved.
//
#import "define.h"
#import "AliyunOSSiOS.h"
#import <Foundation/Foundation.h>

typedef void(^SuccessBlockType)(NSString* responsData);
typedef void(^FailedBlockType)(NSError *error);

@interface KVOSSManager : NSObject
+ (instancetype)shareManager;
- (void)uploadData:(NSData*)fileData success:(SuccessBlockType)successBlock failed:(FailedBlockType)failedBlock;
@end
