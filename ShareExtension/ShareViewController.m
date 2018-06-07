//
//  ShareViewController.m
//  ShareExtension
//
//  Created by peony on 2018/6/6.
//  Copyright © 2018年 peony. All rights reserved.
//

#import "ShareViewController.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    SLComposeSheetConfigurationItem *item = [[SLComposeSheetConfigurationItem alloc] init];
    item.title = @"1111";
    item.value = @"222";
    __weak typeof (self) weakSelf = self;
    item.tapHandler = ^ {
        
        [weakSelf aabb];
    };
    return @[item];
}
- (void)aabb {
    NSLog(@"112233");
}

@end
