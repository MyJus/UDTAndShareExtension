//
//  RequestManager.h
//  UDTAndShareExtension
//
//  Created by peony on 2018/6/7.
//  Copyright © 2018年 peony. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestManager : NSObject
- (void)sendData:(NSData *)sendData ServerIp:(NSString *)server_ip port:(NSString *)port;

@end
