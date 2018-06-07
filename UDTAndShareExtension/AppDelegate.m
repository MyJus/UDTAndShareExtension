//
//  AppDelegate.m
//  UDTAndShareExtension
//
//  Created by peony on 2018/6/6.
//  Copyright © 2018年 peony. All rights reserved.
//

#import "AppDelegate.h"
#define LJJ_SHAREUSERDEFAULTSKEY @"LJJ_ShareUserDefaultsKey"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}


- (BOOL)application:(UIApplication *)app openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if ([[url scheme] isKindOfClass:[NSString class]] && [[url scheme] isEqualToString:@"MyShare"]) {//打开当前App
        if ([[options objectForKey:UIApplicationOpenURLOptionsSourceApplicationKey] isEqualToString:@"peony.UDTAndShareExtension.ShareExtension"]) {//分享扩展发送过来的
            //获取分享类型
            NSString *shareTypessssss = [[url.absoluteString componentsSeparatedByString:@"-"] lastObject];
            
            //获取分享数据NSDictionary *shareDic = @{@"shareType" : self.currentType,@"shareData" : self.shareArray,@"detail":@""};
            NSUserDefaults *shareDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.MyShareGroup"];
            NSData *data = [shareDefaults objectForKey:LJJ_SHAREUSERDEFAULTSKEY];
            NSDictionary *shareDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSString *shareType = [shareDic objectForKey:@"shareType"];
            NSArray *shareData = [shareDic objectForKey:@"shareData"];
            NSString *detail = [shareDic objectForKey:@"detail"];
            
            
        }
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
