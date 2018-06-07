//
//  CoustomShareViewController.m
//  ShareExtension
//
//  Created by peony on 2018/6/6.
//  Copyright © 2018年 peony. All rights reserved.
//

#import "CoustomShareViewController.h"
#import "CycleScrollView.h"

#define LJJ_SHAREUSERDEFAULTSKEY @"LJJ_ShareUserDefaultsKey"

@interface CoustomShareViewController ()

//只允许分享同类型，目前可分享图片、视频、链接
@property (nonatomic, copy) NSString *currentType;
@property (strong,nonatomic) NSMutableArray *shareArray;

@property (weak,nonatomic) UIView *containerView;
@property (weak,nonatomic) UIView *navView;

@property (weak,nonatomic) UIWebView *webView;

@property (weak,nonatomic) CycleScrollView *cycleScrollView;
@end

@implementation CoustomShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initWebView];
    self.shareArray = [NSMutableArray array];
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds), CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds))];
    container.backgroundColor = [UIColor whiteColor];
    container.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.containerView = container];

    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(container.frame), 64)];
    navView.backgroundColor = [UIColor colorWithRed:249 / 255.0 green:249 / 255.0 blue:249 / 255.0 alpha:1.0];
    [container addSubview:self.navView = navView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(navView.frame) - 1, CGRectGetWidth(navView.frame), 1)];
    lineView.backgroundColor = [UIColor colorWithRed:174 / 255.0 green:174 / 255.0 blue:174 / 255.0 alpha:1.0];
    [navView addSubview:lineView];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(8, CGRectGetHeight(navView.frame) - 8 - 25, 40, 25);
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [cancelButton addTarget:self action:@selector(cancelBtnClickHandler:) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:cancelButton];
    
    UIButton *sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sureButton.frame = CGRectMake(CGRectGetWidth(navView.frame) - 40 -8, CGRectGetHeight(navView.frame) - 8 - 25, 40, 25);
    [sureButton setTitle:@"确定" forState:UIControlStateNormal];
    [sureButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    sureButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [sureButton addTarget:self action:@selector(postBtnClickHandler:) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:sureButton];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(cancelButton.frame), CGRectGetMinY(cancelButton.frame), CGRectGetWidth(navView.frame) - CGRectGetMaxX(cancelButton.frame) * 2, CGRectGetHeight(cancelButton.frame))];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:17.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"测试分享";
    [navView addSubview:titleLabel];
    
    
    NSLog(@"%@",self.extensionContext.inputItems);
    //获取分享链接
    __weak typeof(self) weakself= self;
    [self.extensionContext.inputItems enumerateObjectsUsingBlock:^(NSExtensionItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.attachments enumerateObjectsUsingBlock:^(NSItemProvider *  _Nonnull itemProvider, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([itemProvider hasItemConformingToTypeIdentifier:@"public.url"]) {//分享网址
                [itemProvider loadItemForTypeIdentifier:@"public.url" options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                    NSString *errorMessage = [weakself getErrorMessageWithType:@"public.url"];
                    if (errorMessage != nil) {//结束，展示错误信息
                        [weakself creatUIWithMessage:errorMessage];
                        *stop = YES;
                    }else {//可以分享
                        
                    }
                    [weakself.shareArray addObject:item];
                    [weakself creatUIWithMessage:nil];
                }];
            }else if ([itemProvider hasItemConformingToTypeIdentifier:@"public.jpeg"] || [itemProvider hasItemConformingToTypeIdentifier:@"public.png"] || [itemProvider hasItemConformingToTypeIdentifier:@"com.compuserve.gif"]) {//分享图片
                NSString *errorMessage = [weakself getErrorMessageWithType:@"public.jpeg"];
                if (errorMessage != nil) {//结束，展示错误信息
                    [weakself creatUIWithMessage:errorMessage];
                    *stop = YES;
                }else {//可以分享
                    [itemProvider loadItemForTypeIdentifier:itemProvider.registeredTypeIdentifiers.lastObject options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
//                        NSData *data = [NSData dataWithContentsOfURL:(NSURL *)item];
//                        UIImage *image = [UIImage imageWithData:data];
                        if ([(NSURL *)item respondsToSelector:@selector(absoluteString)]) {
                            [weakself.shareArray addObject:[(NSURL *)item absoluteString]];
                            [weakself creatUIWithMessage:nil];
                        }
                    }];
                }
                
            }else if ([itemProvider hasItemConformingToTypeIdentifier:@"com.apple.quicktime-movie"]) {//分享视频
                
                NSString *errorMessage = [weakself getErrorMessageWithType:@"com.apple.quicktime-movie"];
                if (errorMessage != nil) {//结束，展示错误信息
                    [weakself creatUIWithMessage:errorMessage];
                    *stop = YES;
                }else {//可以分享
                    [itemProvider loadItemForTypeIdentifier:@"com.apple.quicktime-movie" options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
//                        NSData *data = [NSData dataWithContentsOfURL:(NSURL *)item];
                        if ([(NSURL *)item respondsToSelector:@selector(absoluteString)]) {
                            [weakself.shareArray addObject:[(NSURL *)item absoluteString]];
                            [weakself creatUIWithMessage:nil];
                        }
                        
                        
                        
                    }];
                }
            }else {
                [weakself creatUIWithMessage:@"目前只支持分享图片、视频、链接"];
                *stop = YES;
            }
            NSLog(@"进入");
            
        }];
        *stop = YES;
    }];
    
    
    NSLog(@"结束");
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.25 animations:^{
        self.containerView.frame = [UIScreen mainScreen].bounds;
    }];
}


- (NSString *)getErrorMessageWithType:(NSString *)type {//判断当前类型是否可以进行分享
    NSString *typeN = [self getTypeNameWithType:type];
    if (typeN == nil) {
        return @"目前只支持分享图片、视频、链接";
    }
    if (self.currentType != nil) {
        if (![type isEqualToString:self.currentType]) {
            NSString *typeName = [self getTypeNameWithType:self.currentType];
            return [NSString stringWithFormat:@"%@和%@不能同时分享",typeName,typeN];
        }
    }else {
        self.currentType = type;
    }
    
    return nil;
    
//    if (types.count > 1) {
//        NSString *type = [types firstObject];
//        NSString *typeName = [self getTypeName:type];
//        if (typeName == nil) {
//            return @"目前只支持分享图片、视频、链接";
//        }
//        for (int i = 1; i < types.count; i ++) {
//            if (![type isEqualToString:[types objectAtIndex:i]]) {
//                NSString *typeN = [self getTypeName:[types objectAtIndex:i]];
//                if (typeN == nil) {
//                    return @"目前只支持分享图片、视频、链接";
//                }else {
//                    return [NSString stringWithFormat:@"%@和%@不能同时分享",typeName,typeN];
//                }
//            }
//        }
//
//        return nil;
//    }else {
//        return nil;
//    }
    
}
- (NSString *)getTypeNameWithType:(NSString *)type {
    if ([type isEqualToString:@"public.url"]) {//分享网址
        return @"网址";
    }else if ([type isEqualToString:@"public.jpeg"] || [type isEqualToString:@"public.png"] || [type isEqualToString:@"com.compuserve.gif"]) {//分享图片([itemProvider hasItemConformingToTypeIdentifier:@"public.jpeg"] || [itemProvider hasItemConformingToTypeIdentifier:@"public.png"] || [itemProvider hasItemConformingToTypeIdentifier:@"com.compuserve.gif"])
        return @"图片";
    }else if ([type isEqualToString:@"com.apple.quicktime-movie"]) {//分享视频
        
        return @"视频";
    }else {
        return nil;
    }
}

- (void)creatUIWithMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (message == nil) {
            if ([self.currentType isEqualToString:@"public.url"]) {//分享网址
//                return @"网址";
            }else if (([self.currentType isEqualToString:@"public.jpeg"] || [self.currentType isEqualToString:@"public.png"] || [self.currentType isEqualToString:@"com.compuserve.gif"])) {//分享图片
//                return @"图片";
                @synchronized(self) {
                    if (self.cycleScrollView == nil) {
                        CycleScrollView *scrollView = [[CycleScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navView.frame) + 4, CGRectGetWidth(self.containerView.frame), CGRectGetWidth(self.containerView.frame) / 2) cycleDirection:CycleDirectionLandscape pictures:self.shareArray delegate:nil];
                        [self.containerView addSubview:self.cycleScrollView = scrollView];
                    }else {
                        [self.cycleScrollView resetScrollViewImages:self.shareArray];
                    }
                }
                
                
            }else if ([self.currentType isEqualToString:@"com.apple.quicktime-movie"]) {//分享视频
                
//                return @"视频";
            }else {
//                return nil;
            }
        }else {
            //定义一个分享链接标签
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8,
                                                                       self.navView.frame.origin.y + self.navView.frame.size.height + 8,
                                                                       self.navView.frame.size.width - 16,
                                                                       self.containerView.frame.size.height - 16 - self.navView.frame.origin.y - self.navView.frame.size.height)];
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            label.text = message;
            [self.containerView addSubview:label];
        }
    });
    
}

- (void)initWebView {
    UIWebView *webView = [[UIWebView alloc] init];
    [self.view addSubview:self.webView = webView];
}
- (void)openAppWithURL:(NSString*)urlString text:(NSString*)text {
    UIResponder* responder = self;
    while ((responder = [responder nextResponder]) != nil) {
        if ([responder respondsToSelector:@selector(openURL:)] == YES) {
            [responder performSelector:@selector(openURL:) withObject:[NSURL URLWithString:[NSString stringWithFormat:@"MyShare://%@", [self urlStringForShareExtension:urlString text:text]]]];
        }
    }
}
- (NSString*)urlStringForShareExtension:(NSString*)urlString text:(NSString*)text {
    NSString* finalUrl=[NSString stringWithFormat:@"%@-%@", urlString, text];
    finalUrl =  (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                      NULL,
                                                                                      (CFStringRef)finalUrl,
                                                                                      NULL,
                                                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                      kCFStringEncodingUTF8 ));
    return finalUrl;
}

- (void)cancelBtnClickHandler:(id)sender {
    //取消分享
    [self.extensionContext cancelRequestWithError:[NSError errorWithDomain:@"CustomShareError" code:NSUserCancelledError userInfo:nil]];
}

- (void)postBtnClickHandler:(id)sender {
    //执行分享内容处理
    NSUserDefaults *shareDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.MyShareGroup"];
    NSDictionary *shareDic = @{@"shareType" : self.currentType,@"shareData" : self.shareArray,@"detail":@""};
    NSData *data= [NSJSONSerialization dataWithJSONObject:shareDic options:NSJSONWritingPrettyPrinted error:nil];
    [shareDefaults setObject:data forKey:LJJ_SHAREUSERDEFAULTSKEY];
    
    [self openAppWithURL:@"myshare" text:self.currentType];
    
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
