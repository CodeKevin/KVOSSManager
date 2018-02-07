//
//  KVOSSManager.m
//  KVOSSManagerDemo
//
//  Created by Kevin on 2018/2/6.
//  Copyright © 2018年 Kevin. All rights reserved.
//

#import "KVOSSManager.h"
typedef void(^STSTokenSuccessBlockType)(NSDictionary* responsData);
typedef void(^STSTokenFailedBlockType)(NSError *error);
@implementation KVOSSManager
+ (id)shareManager {
    static KVOSSManager *s_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[KVOSSManager alloc] init];
    });
    return s_manager;
}

//服务器配置好阿里OSS好以后，生成一个请求凭证的接口，客户端请求服务器获取阿里上传凭证
- (void)getSTSTokenFromSeverSuccess:(STSTokenSuccessBlockType)successBlock failed:(STSTokenFailedBlockType)failedBlock {
    NSString *url = [NSString stringWithFormat:@"%@",AppSever_url];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask * sessionTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            failedBlock(error);
            return;
        }
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        //判断返回数据中的状态字段（StatusCode）是否是200（获取凭证成功）
        if ([dic[@"StatusCode"] integerValue] == 200) {
            successBlock(dic);
        }else {
            //NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"status = -500"                                                                      forKey:NSLocalizedDescriptionKey];
            //NSError *error = [NSError errorWithDomain:nil code:nil userInfo:userInfo];
            failedBlock(error);
        }
    }];
    [sessionTask resume];
}

//这里演示上传一张png图片
- (void)uploadData:(NSData*)fileData success:(SuccessBlockType)successBlock failed:(FailedBlockType)failedBlock {
    [self getSTSTokenFromSeverSuccess:^(NSDictionary *responsData) {
        NSString *endpoint = AliyunEndpoint;
        //配置AccessKeyId AccessKeySecret SecurityToken 三个参数
        id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:responsData[@"AccessKeyId"] secretKeyId:responsData[@"AccessKeySecret"] securityToken:responsData[@"SecurityToken"]];
        OSSClient *client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential];
        NSString *picName = [NSUUID UUID].UUIDString;
        OSSPutObjectRequest *put = [OSSPutObjectRequest new];
        //配置 bucketName
        put.bucketName = AliyunBucketName;
        //配置 objectKey
        put.objectKey = [NSString stringWithFormat:@"%@%@.png",AliyunObjectKey,picName];
        put.uploadingData = fileData;
        OSSTask * putTask = [client putObject:put];
        [putTask continueWithBlock:^id(OSSTask *task) {
            if (!task.error) {
                //服务没有回调的话，需要自己拼接路径
                NSString *imageUrl = [NSString stringWithFormat:@"%@%@%@.png",AppImageHeadUrl,AliyunObjectKey,picName];
                successBlock(imageUrl);
            } else {
                failedBlock(task.error);
            }
            return nil;
        }];
        [putTask waitUntilFinished];
    } failed:^(NSError *error) {
        failedBlock(error);
    }];
}
@end
