// MobPushModule.m

#import "MobPushModule.h"

#import <React/RCTLog.h>
#import <React/RCTConvert.h>
#import <MobPush/MobPush.h>
#import <MobPush/MobPush+Test.h>
#import <MobFoundation/MobFoundation.h>

static BOOL isPro = NO;
static BOOL enableDebug = NO;
static NSString *MPush_Configure_Cache_Domain = @"MOBPUSH_RN_PLUGIN";
static NSString *MPush_Configure_Cache_Key = @"MPushNotificationConfiguration";

#define PushRNDebugLog(info, ...) if (enableDebug) { NSLog((@"\n********** Push RN Plugin Debug **********\n" info "\n********** Push RN Plugin Debug **********\n"), ##__VA_ARGS__); }

@interface RCTConvert (MobPushEnums)

@end

@implementation MobPushModule

/// 定义JS中访问的模块名，未设置则默认使用类名，如果类名有RCT，则自动移除这个前缀
RCT_EXPORT_MODULE(MobPushModule)

#pragma mark ----
#pragma mark SDK Function

RCT_EXPORT_METHOD(setDebugLog:(BOOL)enable) {
    enableDebug = enable;
}

/// 根据参数发送消息
/// @param params 发送消息参数
/// @param callback 主线程回调，可选
RCT_EXPORT_METHOD(send:(NSDictionary *)params completion:(RCTResponseSenderBlock)callback) {
    MPushMessageType msgType = MPushMessageTypeAPNs;
    if ([[params allKeys] containsObject:@"type"]
        && [[params objectForKey:@"type"] respondsToSelector:@selector(integerValue)]) {
        msgType = [[params objectForKey:@"type"] integerValue];
    }
    
    NSString *content = @"";
    if (![MobPushModule is_empty_str:[params objectForKey:@"content"]]) {
        content = [params objectForKey:@"content"];
    }
    NSNumber *space = [NSNumber numberWithInt:0];
    if ([[params allKeys] containsObject:@"space"]
        && [[params objectForKey:@"space"] isKindOfClass:[NSNumber class]]) {
        space = [params objectForKey:@"space"];
    }
    NSDictionary *extras = @{};
    if ([[params allKeys] containsObject:@"extrasMap"]
        && [[params objectForKey:@"extrasMap"] isKindOfClass:[NSDictionary class]]) {
        extras = [params objectForKey:@"extrasMap"];
    }
    NSString *sound = @"";
    if (![MobPushModule is_empty_str:[params objectForKey:@"sound"]]) {
        sound = [params objectForKey:@"sound"];
    }
    NSString *coverId = @"";
    if (![MobPushModule is_empty_str:[params objectForKey:@"coverId"]]) {
        coverId = [params objectForKey:@"coverId"];
    }
    
    [MobPush sendMessageWithMessageType:msgType
                                content:content
                                  space:space
                                  sound:sound
                isProductionEnvironment:isPro
                                 extras:extras
                             linkScheme:nil
                               linkData:nil
                                coverId:coverId
                                 result:^(NSString *workId, NSError *error) {
        [MobPushModule main_async_callback:^{
            if (callback)
                callback(@[
                    @{
                        @"success": @(error ? NO:YES),
                        @"res": (workId ? :@""),
                        @"error": (error ? :[NSNull null])
                    }
                ]);
        }];
    }];
}

/// 添加本地通知
/// @param params 发送消息参数
/// @{
///   @"delay": 5(默认分钟)
/// }
/// @param callback 主线程回调，可选
RCT_EXPORT_METHOD(addLocalNotification:(NSDictionary *)params completion:(RCTResponseSenderBlock)callback) {
    MPushNotificationRequest *request = [[MPushNotificationRequest alloc] init];
    
    /// 配置推送通知唯一标识
    if (![MobPushModule is_empty_str:[params objectForKey:@"messageId"]]) {
        request.requestIdentifier = [params objectForKey:@"messageId"];
    }
    
    /// 推送消息Content
    MPushNotification *content = [[MPushNotification alloc] init];
    /// title
    if (![MobPushModule is_empty_str:[params objectForKey:@"title"]]) {
        content.title = [params objectForKey:@"title"];
    }
    /// subtitle
    if (![MobPushModule is_empty_str:[params objectForKey:@"subTitle"]]) {
        content.subTitle = [params objectForKey:@"subTitle"];
    }
    /// badge
    if ([[params allKeys] containsObject:@"badge"]
        && [[params objectForKey:@"badge"] respondsToSelector:@selector(integerValue)]) {
        content.badge = [[params objectForKey:@"badge"] integerValue];
    }
    /// body
    if (![MobPushModule is_empty_str:[params objectForKey:@"content"]]) {
        content.body = [params objectForKey:@"content"];
    }
    /// sound
    if (![MobPushModule is_empty_str:[params objectForKey:@"sound"]]) {
        content.sound = [params objectForKey:@"sound"];
    }
    /// userInfo
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] init];
    if ([[params allKeys] containsObject:@"extrasMap"]
        && [[params objectForKey:@"extrasMap"] isKindOfClass:[NSDictionary class]]) {
        [mDict addEntriesFromDictionary:[params objectForKey:@"extrasMap"]];
    }
    if (![MobPushModule is_empty_str:[params objectForKey:@"messageId"]]) {
        mDict[@"messageId"] = [params objectForKey:@"messageId"];
    }
    content.userInfo = [mDict copy];
    content.action = @"action";
    request.content = content;
    
    /// 推送通知触发条件
    MPushNotificationTrigger *trigger = [[MPushNotificationTrigger alloc] init];
    request.trigger = trigger;
    if ([[params allKeys] containsObject:@"delay"]
        && [[params objectForKey:@"delay"] respondsToSelector:@selector(integerValue)]) {
        if ([MOBFDevice versionCompare:@"10.0"] >= 0) {
            trigger.timeInterval = [[params objectForKey:@"delay"] integerValue] * 60.0;
        } else {
            NSDate *currentDate = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval nowtime = [currentDate timeIntervalSince1970] * 1000;
            NSTimeInterval delayTime = [[params objectForKey:@"delay"] integerValue] * 60.0;
            trigger.fireDate = [NSDate dateWithTimeIntervalSince1970:(nowtime + delayTime)];
        }
    }
    
    [MobPush addLocalNotification:request result:^(id result, NSError *error) {
        RCTLogInfo(@"AddLocalNotification Result: %@ Err: %@", result, error);
        [MobPushModule main_async_callback:^{
            if (callback)
                callback(@[
                    @{
                        @"success": @(error ? NO:YES),
                        @"error": (error ? :[NSNull null])
                    }
                ]);
        }];
    }];
}

/// 设置应用在前台有 Badge、Sound、Alert 三种类型，默认3个选项都有，iOS 10 以后设置有效。
/// 如果不想前台有 Badge、Sound、Alert，设置 MPushAuthorizationOptionsNone
/// @param type 前台通知类型
RCT_EXPORT_METHOD(setAPNsShowForegroundType:(MPushAuthorizationOptions)type) {
    [MobPush setAPNsShowForegroundType:type];
}

/// 设置推送配置
/// @param types 通知类型集合
RCT_EXPORT_METHOD(setupNotification:(NSInteger)types) {
    MPushNotificationConfiguration *configuration = [[MPushNotificationConfiguration alloc] init];
    configuration.types = types;
    
    [[MOBFDataService sharedInstance] setCacheData:configuration
                                            forKey:MPush_Configure_Cache_Key
                                            domain:MPush_Configure_Cache_Domain];
    [MobPush setupNotification:configuration];
}

#pragma mark ----
#pragma mark 手机号

/// 绑定手机号，如果字符串为空则为解除绑定
/// @param phone 待绑定手机号 or 空字符串
/// @param callback 主线程回调，可选
RCT_EXPORT_METHOD(bindPhoneNum:(NSString *)phone completion:(RCTResponseSenderBlock)callback) {
    if ([MobPushModule is_empty_str:phone]) phone = @"";
    [MobPush bindPhoneNum:phone
                   result:^(NSError *error) {
        [MobPushModule main_async_callback:^{
            if (callback)
                callback(@[
                    @{
                        @"success": @(error ? NO:YES),
                        @"res": phone,
                        @"error": (error ? :[NSNull null])
                    }
                ]);
        }];
    }];
}

/// 获取绑定的手机号
/// @param callback 主线各回调，可选
RCT_EXPORT_METHOD(getPhoneNum:(RCTResponseSenderBlock)callback) {
    [MobPush getPhoneNumWithResult:^(NSString *phoneNum, NSError *error) {
        BOOL isErr = [MobPushModule is_empty_str:phoneNum] || error;
        [MobPushModule main_async_callback:^{
            if (callback)
                callback(@[
                    @{
                        @"success": @(!isErr),
                        @"res": (phoneNum ? :@""),
                        @"error": (error ? :error)
                    }
                ]);
        }];
    }];
}

#pragma mark ----
#pragma mark 其他

/// 上传隐私协议状态，建议在App启动时调用
/// @param result 是否同意隐私
RCT_EXPORT_METHOD(submitPolicyGrantResult:(BOOL)result) {
    [MobSDK uploadPrivacyPermissionStatus:result
                                 onResult:^(BOOL success) {
        PushRNDebugLog(@"Upload PolicyGrant Result: %@", @(success));
    }];
}

/// 注册AppKey和APpSecret
/// @param appkey 非空字符串
/// @param secret 非空字符串
RCT_EXPORT_METHOD(registerAppKey:(NSString *)appkey appSecret:(NSString *)secret) {
    if ([MobPushModule is_empty_str:appkey]
        || [MobPushModule is_empty_str:secret]) {
        return;
    }
    
    [MobSDK registerAppKey:appkey
                 appSecret:secret];
}

/// 设置推送环境
/// @param pro 是否是正式环境
RCT_EXPORT_METHOD(setAPNsForProduction:(BOOL)pro) {
    isPro = pro;
    [MobPush setAPNsForProduction:pro];
    RCTLogInfo(@"SetAPNsForProduction: %@", @(pro));
}

/// 获取RegID
/// @param callback 主线程回调block
RCT_EXPORT_METHOD(getRegistrationID:(RCTResponseSenderBlock)callback) {
    [MobPush getRegistrationID:^(NSString *registrationID, NSError *error) {
        RCTLogInfo(@"Get RegistrationID Result:%@ Error: %@", registrationID, error);
        NSString *rgID = registrationID;
        if ([MobPushModule is_empty_str:rgID]) rgID = @"";
        [MobPushModule main_async_callback:^{
            NSDictionary *ret = @{
                                    @"success": @(error ? NO:YES),
                                    @"res": rgID,
                                    @"error": (error ? :[NSNull null])
                                };
            PushRNDebugLog(@"Method: getRegistrationID, Result: %@", [MOBFJson jsonStringFromObject:ret]);
            if (callback)
                callback(@[ret]);
        }];
    }];
}

/// 设置国家区号
/// @param regionID 默认 0 国内，1 国外
RCT_EXPORT_METHOD(setRegionID:(int)regionID) {
    [MobPush setRegionID:regionID];
}

/// 获取SDK Version
/// @param callback 主线程回调block
RCT_EXPORT_METHOD(getSDKVersion:(RCTResponseSenderBlock)callback) {
    [MobPushModule main_async_callback:^{
        PushRNDebugLog(@"Method: getShowBadge, Result: %@", [MobPush sdkVersion]);
        if (callback)
            callback(@[@{@"success": @(YES), @"res": [MobPush sdkVersion]}]);
    }];
}

#pragma mark ----
#pragma mark 角标

/// 设置角标到Mob服务器
/// 本地先调用setApplicationIconBadgeNumber函数来显示角标
/// 再将该角标值同步到Mob服务器
/// @param badgeCount 新的角标值(会覆盖服务器上保存的值)
RCT_EXPORT_METHOD(setShowBadgeCount:(NSInteger)badgeCount) {
    [MobPush setBadge:badgeCount];
}

/// 获取服务器上的角标
/// @param callback 主线程上的回调
RCT_EXPORT_METHOD(getShowBadge:(RCTResponseSenderBlock)callback) {
    [MobPush getBadgeWithhandler:^(NSInteger badge, NSError *error) {
        RCTLogInfo(@"Get Badge Result: %@, Err: %@", @(badge), error);
        [MobPushModule main_async_callback:^{
            NSDictionary *ret = @{
                                    @"success": @(error ? NO:YES),
                                    @"res": @(badge),
                                    @"error": (error ? :[NSNull null])
                                };
            PushRNDebugLog(@"Method: getShowBadge, Result: %@", [MOBFJson jsonStringFromObject:ret]);
            if (callback)
                callback(@[ret]);
        }];
    }];
}

RCT_EXPORT_METHOD(clearBadge) {
    [MobPush clearBadge];
    PushRNDebugLog(@"MobPush ClearBadge Success");
}

#pragma mark ----
#pragma mark 推送服务

/// 推送服务是否停止
/// @param callback 主线程回调block
RCT_EXPORT_METHOD(isPushStopped:(RCTResponseSenderBlock)callback) {
    [MobPushModule main_async_callback:^{
        BOOL stoped = [MobPush isPushStopped];
        PushRNDebugLog(@"Current SDK Whether Stoped Push Service: %@", @(stoped));
        if (callback) callback(@[@{@"success": @(YES), @"res": @(stoped)}]);
    }];
}

/// 停止推送服务
/// @param callback 主线程回调block, 可选
RCT_EXPORT_METHOD(stopPush) {
    [MobPushModule main_async_callback:^{
        [MobPush stopPush];
    }];
    PushRNDebugLog(@"Have Stoped The SDK Push Services.");
}

/// 重启推送服务
/// @param callback 主线程回调block, 可选
RCT_EXPORT_METHOD(restartPush) {
    [MobPushModule main_async_callback:^{
        [MobPush restartPush];
    }];
    PushRNDebugLog(@"Have Restart The SDK Push Services.");
}

#pragma mark ----
#pragma mark Alias & Tags Manage

/// 设置别名
/// @param alias 别名，字符串类型
/// @param callback 主线程回调block, 可选
RCT_EXPORT_METHOD(setAlias:(NSString *)alias) {
    if ([MobPushModule is_empty_str:alias]) {
        RCTLogInfo(@"SetAlias Required Alias Mustn't Empty.");
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [MobPush setAlias:alias result:^(NSError *error) {
        if (error) {
            RCTLogInfo(@"SetAlias Failed, Error: %@", error);
        } else {
            RCTLogInfo(@"SetAlias: %@ Success", alias);
        }
        [MobPushModule main_async_callback:^{
            NSDictionary *ret = @{
                @"success": @(error ? NO:YES),
                @"res": (alias ? :@""),
                @"error": (error ? :[NSNull null]),
                @"opeartion": @(1)
            };
            PushRNDebugLog(@"Method: setAlias, Result: %@", [MOBFJson jsonStringFromObject:ret]);
            [weakSelf sendCustomEventWith:@"onAliasCallback" body:ret];
        }];
    }];
}

/// 获取别名
/// @param callback 主线程回调block, 可选
RCT_EXPORT_METHOD(getAlias) {
    __weak typeof(self) weakSelf = self;
    [MobPush getAliasWithResult:^(NSString *alias, NSError *error) {
        alias = [MobPushModule is_empty_str:alias] ? @"" : alias;
        RCTLogInfo(@"GetAlias Error:%@, Alias:%@", error, alias);
        [MobPushModule main_async_callback:^{
            NSDictionary *ret = @{
                @"success": @(error ? NO:YES),
                @"res": (alias ? :@""),
                @"error": (error ? :[NSNull null]),
                @"opeartion": @(0)
            };
            PushRNDebugLog(@"Method: getAlias, Result: %@", [MOBFJson jsonStringFromObject:ret]);
            [weakSelf sendCustomEventWith:@"onAliasCallback" body:ret];
        }];
    }];
}

/// 删除别名
RCT_EXPORT_METHOD(deleteAlias) {
    __weak typeof(self) weakSelf = self;
    [MobPush deleteAlias:^(NSError *error) {
        RCTLogInfo(@"Delete Alias Result: %@", error);
        [MobPushModule main_async_callback:^{
            NSDictionary *ret = @{
                @"success": @(error ? NO:YES),
                @"error": (error ? :[NSNull null]),
                @"opeartion": @(2)
            };
            PushRNDebugLog(@"Method: deleteAlias, Result: %@", [MOBFJson jsonStringFromObject:ret]);
            [weakSelf sendCustomEventWith:@"onAliasCallback" body:ret];
        }];
    }];
}

/// 获取所有标签组
RCT_EXPORT_METHOD(getAllTags) {
    __weak typeof(self) weakSelf = self;
    [MobPush getTagsWithResult:^(NSArray *tags, NSError *error) {
        BOOL success = [tags isKindOfClass:[NSArray class]] && !error;
        NSDictionary *ret = @{
            @"success": @(success),
            @"res": (success ? tags:@[]),
            @"error": (error ? :[NSNull null]),
            @"operation": @(0)
        };
        PushRNDebugLog(@"Method: getAllTags, Result: %@", [MOBFJson jsonStringFromObject:ret]);
        [weakSelf sendCustomEventWith:@"onTagsCallback" body:ret];
    }];
}

/// 添加标签组
/// @param tags 字符串类型数组
/// @param completion 结果回调，可选
RCT_EXPORT_METHOD(addTags:(NSDictionary *)params) {
    if (![params isKindOfClass:[NSDictionary class]]
        || ![[params allKeys] containsObject:@"tags"]) return;
    if (![[params objectForKey:@"tags"] isKindOfClass:[NSArray class]]) return;
    
    NSArray *tags = [RCTConvert NSStringArray:[params objectForKey:@"tags"]];
    NSMutableArray *tmpTags = [NSMutableArray arrayWithCapacity:[tags count]];
    for (id content in tags) {
        if ([MobPushModule is_empty_str:content]) continue;
        [tmpTags addObject:content];
    }
    if (![tmpTags count]) return;
    
    __weak typeof(self) weakSelf = self;
    [MobPush addTags:tmpTags result:^(NSError *error) {
        RCTLogInfo(@"AddTags Result:%@", error);
        [MobPushModule main_async_callback:^{
            NSDictionary *ret = @{
                @"success": @(error ? NO:YES),
                @"res": tmpTags,
                @"error": (error ? :[NSNull null]),
                @"operation": @(1)
            };
            PushRNDebugLog(@"Method: addTags, Result: %@", [MOBFJson jsonStringFromObject:ret]);
            [weakSelf sendCustomEventWith:@"onTagsCallback" body:ret];
        }];
    }];
}

/// 替换标签组
/// @param tags 字符串类型数组
/// @param completion 结果回调，可选
RCT_EXPORT_METHOD(replaceTags:(NSDictionary *)params) {
    if (![params isKindOfClass:[NSDictionary class]]
        || ![[params allKeys] containsObject:@"tags"]) return;
    if (![[params objectForKey:@"tags"] isKindOfClass:[NSArray class]]) return;
    
    NSArray *tags = [RCTConvert NSStringArray:[params objectForKey:@"tags"]];
    NSMutableArray *tmpTags = [NSMutableArray arrayWithCapacity:[tags count]];
    for (id content in tags) {
        if ([MobPushModule is_empty_str:content]) continue;
        [tmpTags addObject:content];
    }
    if (![tmpTags count]) return;
    
    __weak typeof(self) weakSelf = self;
    [MobPush replaceTags:tmpTags result:^(NSError *error) {
        RCTLogInfo(@"AddTags Result:%@", error);
        [MobPushModule main_async_callback:^{
            NSDictionary *ret = @{
                @"success": @(error ? NO:YES),
                @"res": tmpTags,
                @"error": (error ? :[NSNull null]),
                @"operation": @(1)
            };
            PushRNDebugLog(@"Method: replaceTags, Result: %@", [MOBFJson jsonStringFromObject:ret]);
            [weakSelf sendCustomEventWith:@"onTagsCallback" body:ret];
        }];
    }];
}

/// 删除标签
/// @param tags 待删除标签组
/// @param callback 回调, 可选
RCT_EXPORT_METHOD(deleteTags:(NSDictionary *)params) {
    if (![params isKindOfClass:[NSDictionary class]]
        || ![[params allKeys] containsObject:@"tags"]) return;
    if (![[params objectForKey:@"tags"] isKindOfClass:[NSArray class]]) return;
    
    NSArray *tags = [RCTConvert NSStringArray:[params objectForKey:@"tags"]];
    
    tags = [RCTConvert NSStringArray:tags];
    NSMutableArray *tmpTags = [NSMutableArray arrayWithCapacity:[tags count]];
    for (id content in tags) {
        if ([MobPushModule is_empty_str:content]) continue;
        [tmpTags addObject:content];
    }
    if (![tmpTags count]) return;
    
    __weak typeof(self) weakSelf = self;
    [MobPush deleteTags:tmpTags result:^(NSError *error) {
        RCTLogInfo(@"DeleteTags Result:%@", error);
        [MobPushModule main_async_callback:^{
            NSDictionary *ret = @{
                @"success": @(error ? NO:YES),
                @"res": tmpTags,
                @"error": (error ? :[NSNull null]),
                @"operation": @(2)
            };
            PushRNDebugLog(@"Method: DeleteTags, Result: %@", [MOBFJson jsonStringFromObject:ret]);
            [weakSelf sendCustomEventWith:@"onTagsCallback" body:ret];
        }];
    }];
}

/// 清空所有标签
RCT_EXPORT_METHOD(cleanAllTags) {
    __weak typeof(self) weakSelf = self;
    [MobPush cleanAllTags:^(NSError *error) {
        RCTLogInfo(@"CleanAllTags Result:%@", error);
        [MobPushModule main_async_callback:^{
            NSDictionary *ret = @{
                @"success": @(error ? NO:YES),
                @"error": (error ? :[NSNull null]),
                @"operation": @(3)
            };
            PushRNDebugLog(@"Method: CleanAllTags, Result: %@", [MOBFJson jsonStringFromObject:ret]);
            [weakSelf sendCustomEventWith:@"onTagsCallback" body:ret];
        }];
    }];
}

#pragma mark ----
#pragma mark Observer

- (NSArray<NSString *> *)supportedEvents {
    return @[
        @"onCustomMessageReceive",
        @"onNotifyMessageReceive",
        @"onLocalMessageReceive",
        @"onNotifyMessageOpenedReceive",
        @"onTagsCallback",
        @"onAliasCallback"
    ];
}

- (void)startObserving {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mobpushEventReminderReceived:)
                                                 name:MobPushDidReceiveMessageNotification object:nil];
}

- (void)stopObserving {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)mobpushEventReminderReceived:(NSNotification *)notification {
    if (![[notification object] isKindOfClass:[MPushMessage class]]) return;
    
    MPushMessage *message = [notification object];
    NSString *eventName = @"";
    NSMutableDictionary *content = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    
    switch ([message messageType]) {
        case MPushMessageTypeCustom: {
            eventName = @"onCustomMessageReceive";
        }
            break;
        case MPushMessageTypeAPNs: {
            eventName = @"onNotifyMessageReceive";
        }
            break;
        case MPushMessageTypeLocal: {
            eventName = @"onLocalMessageReceive";
        }
            break;
        case MPushMessageTypeClicked: {
            eventName = @"onNotifyMessageOpenedReceive";
        }
            break;
        default:
            break;
    }
    
    if (message.notification.userInfo) {
        [content setObject:message.notification.userInfo forKey:@"extrasMap"];
    }
    if (message.notification.body) {
        [content setObject:message.notification.body forKey:@"content"];
    }
    if (message.messageID) {
        [content setObject:message.messageID forKey:@"messageId"];
    }
    [content addEntriesFromDictionary:message.notification.convertDictionary];
    
    if ([content count]) {
        [resultDict setObject:content forKey:@"result"];
    }
    NSString *result_json_str = [MOBFJson jsonStringFromObject:resultDict];
    NSDictionary *ret = @{
        @"success": @(YES),
        @"res": result_json_str,
        @"error": [NSNull null]
    };
    [self sendEventWithName:eventName body:ret];
}

#pragma mark ----
#pragma mark 常量

- (NSDictionary *)constantsToExport {
    return @{
        @"MPushAuthorizationOptionsNone": @(MPushAuthorizationOptionsNone),
        @"MPushAuthorizationOptionsBadge": @(MPushAuthorizationOptionsBadge),
        @"MPushAuthorizationOptionsSound": @(MPushAuthorizationOptionsSound),
        @"MPushAuthorizationOptionsAlert": @(MPushAuthorizationOptionsAlert),
        @"MSendMessageTypeAPNs": @(MSendMessageTypeAPNs),
        @"MSendMessageTypeCustom": @(MSendMessageTypeCustom),
        @"MSendMessageTypeTimed": @(MSendMessageTypeTimed)
    };
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

#pragma mark ----
#pragma mark Private Method
+ (BOOL)is_empty_str:(NSString *)str {
    if (![str isKindOfClass:[NSString class]]) return YES;
    
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    str = [str stringByTrimmingCharactersInSet:set];
    
    return ([str length] ? NO : YES);
}

+ (void)main_async_callback:(dispatch_block_t)block {
    if ([[NSThread currentThread] isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

- (void)sendCustomEventWith:(NSString *)eventName body:(id)body {
    if ([MobPushModule is_empty_str:eventName]) return;
    
    [self sendEventWithName:eventName body:body];
}

@end

@implementation RCTConvert (MobPushEnums)

RCT_ENUM_CONVERTER(MPushAuthorizationOptions,
                   (@{
                    @"MPushAuthorizationOptionsNone": @(MPushAuthorizationOptionsNone),
                    @"MPushAuthorizationOptionsBadge": @(MPushAuthorizationOptionsBadge),
                    @"MPushAuthorizationOptionsSound": @(MPushAuthorizationOptionsSound),
                    @"MPushAuthorizationOptionsAlert": @(MPushAuthorizationOptionsAlert)
                   }),
                   MPushAuthorizationOptionsNone,
                   integerValue);

RCT_ENUM_CONVERTER(MSendMessageType,
                   (@{
                    @"MSendMessageTypeAPNs": @(MSendMessageTypeAPNs),
                    @"MSendMessageTypeCustom": @(MSendMessageTypeCustom),
                    @"MSendMessageTypeTimed": @(MSendMessageTypeTimed)
                   }),
                   MSendMessageTypeAPNs,
                   integerValue);

@end
