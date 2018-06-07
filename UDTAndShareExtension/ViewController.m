//
//  ViewController.m
//  UDTAndShareExtension
//
//  Created by peony on 2018/6/6.
//  Copyright © 2018年 peony. All rights reserved.
//

#import "ViewController.h"

#define LJJ_SHAREUSERDEFAULTSKEY @"LJJ_ShareUserDefaultsKey"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //获取分享数据
    NSUserDefaults *shareDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.MyShareGroup"];
    NSData *shareData = [shareDefaults objectForKey:LJJ_SHAREUSERDEFAULTSKEY];
    NSDictionary *shareDic = [NSJSONSerialization JSONObjectWithData:shareData options:NSJSONReadingMutableLeaves error:nil];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[shareDic objectForKey:@"shareData"] lastObject]]];
    
    [[[UIAlertView alloc] initWithTitle:@"收到分享" message:[NSString stringWithFormat:@"%@,%ld",data.length > 0 ? @"可以读取到图片" : @"不能读取图片",data.length] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
