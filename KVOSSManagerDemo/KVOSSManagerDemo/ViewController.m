//
//  ViewController.m
//  KVOSSManagerDemo
//
//  Created by shinho on 2018/2/6.
//  Copyright © 2018年 Kevin. All rights reserved.
//

#import "ViewController.h"
#import "KVOSSManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSData *data = [NSData data];
    [[KVOSSManager shareManager] uploadData:data success:^(NSString *responsData) {
        NSLog(@"success");
    } failed:^(NSError *error) {
        NSLog(@"failed");
    }];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
