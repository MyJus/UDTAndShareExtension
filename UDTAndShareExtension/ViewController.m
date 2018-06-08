//
//  ViewController.m
//  UDTAndShareExtension
//
//  Created by peony on 2018/6/6.
//  Copyright © 2018年 peony. All rights reserved.
//

#import "ViewController.h"
#import "RequestManager.h"



@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[[RequestManager alloc] init] sendData:[@"/ecm/ecm.service.RsaKey.html?method=getRsaPub" dataUsingEncoding:NSUTF8StringEncoding] ServerIp:@"user.sdecpay.com" port:@"80"];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
