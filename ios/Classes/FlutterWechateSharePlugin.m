#import "FlutterWechateSharePlugin.h"

#import "FlutterWechateSharePlugin+TargetAction.h"
// 注册
static NSString *const METHOD_REGISTERAPP = @"register";
// 是否安装微信
static NSString *const METHOD_ISINSTALLED = @"isWechatInstalled";
// 打开微信
static NSString *const METHOD_OPENWECHAT = @"openWechat";
// 微信登陆
static NSString *const METHOD_LOGINWECHAT = @"login";


// 分享文字
static NSString *const METHOD_SHARETEXT = @"text";
// 分享图片
static NSString *const METHOD_SHAREIMAGE = @"image";
// 分享音乐
static NSString *const METHOD_SHAREMUSIC = @"music";
// 分享网页
static NSString *const METHOD_SHAREWEBPAGE = @"webpage";
// 打开小程序
static NSString *const METHOD_STARTMINIPROGRAM = @"startMiniProgram";



static NSString *const ARGUMENT_KEY_RESULT_ERRORCODE = @"errorCode";
static NSString *const ARGUMENT_KEY_RESULT_ERRORMSG = @"errorMsg";
static NSString *const METHOD_ONSHAREMSGRESP = @"onShareMsgResp";
static NSString *const ARGUMENT_KEY_RESULT_EXTMSG = @"extMsg";
static NSString *const METHOD_ONLAUNCHMINIPROGRAMRESP = @"onLaunchMiniProgramResp";

@interface FlutterWechateSharePlugin ()

@end
@implementation FlutterWechateSharePlugin
{
    FlutterMethodChannel *_channel;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"flutter_wechate_share_plugin" binaryMessenger:[registrar messenger]];
    FlutterWechateSharePlugin* instance = [[FlutterWechateSharePlugin alloc] initWithChannel:channel];
    
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
    self = [super init];
    if (self) {
        
        _channel = channel;
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    // 注册微信
    if ([METHOD_REGISTERAPP isEqualToString:call.method]) {
        
        NSString *appId = call.arguments[@"appid"];
        NSString *universalLink = call.arguments[@"universalLink"];
        [WXApi registerApp:appId universalLink:universalLink];
        result(nil);
        
    }
    // 判断本地是否安装微信
    else if ([METHOD_ISINSTALLED isEqualToString:call.method]) {
        
        result([NSNumber numberWithBool:[WXApi isWXAppInstalled]]);
    }
    // 打开微信
    else if ([METHOD_OPENWECHAT isEqualToString:call.method]) {
        
        result([NSNumber numberWithBool:[WXApi openWXApp]]);
    }
    else if ([METHOD_LOGINWECHAT isEqualToString:call.method]) {
        
        NSString* scope= call.arguments[@"scope"];
        NSString* state= call.arguments[@"state"];
        SendAuthReq *request = [[SendAuthReq alloc] init];
        request.scope = scope;
        request.state = state;
        [WXApi sendReq:request completion:^(BOOL success) {
            
        }];
    }
    // 分享
    else if ([@"share" isEqualToString:call.method]) {
        
        NSDictionary *arguments = [call arguments];
        
        // kind 为分享的类型，text -> 文本, image -> 图片, music -> 音乐, video -> 视频, webpage -> 网页
        NSString *kind = arguments[@"kind"];
        
        // 分享文字内容
        if ([kind isEqualToString:METHOD_SHARETEXT]) {
            
            [self handleShareTextCall:call result:result];
            
        }
        // 分享图片内容
        else if ([kind isEqualToString:METHOD_SHAREIMAGE]) {
                        
            [self handleShareImageCall:call result:result];
        }
        // 分享音乐
        else if ([kind isEqualToString:METHOD_SHAREMUSIC]) {
            
            [self handleShareMusicCall:call result:result];
        }
        // 分享网页
        else if ([kind isEqualToString:METHOD_SHAREWEBPAGE]) {
            
            [self handleShareWebPageCall:call result:result];
        }
        
    }
    // 打开微信小程序
    else if ([METHOD_STARTMINIPROGRAM isEqualToString:call.method]) {
        
        [self handleStartMiniProgramCall:call result:result];
    }
    else {
    
        result(FlutterMethodNotImplemented);
    }
}


/// 分享文字
/// @param call 分享的内容
/// @param result 分享结果
- (void)handleShareTextCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    // to 是分享的渠道, session -> 会话列表, timeline -> 朋友圈, favorite -> 收藏, 默认是 session -> 会话列表
    NSString *to = call.arguments[@"to"];
    // 分享到朋友圈
    if ([@"timeline" isEqualToString:to]) {
        req.scene = WXSceneTimeline;
    }
    // 添加到收藏列表
    else if ([@"favorite" isEqualToString:to]) {
        req.scene = WXSceneFavorite;
    }
    // 分享到好友
    else {
        req.scene = WXSceneSession;
    }
    
    req.bText = YES;
    req.text = call.arguments[@"text"];
    
    // 验证是否分享成功回调
    [WXApi sendReq:req completion:^(BOOL success){
                    
    }];
    result(nil);
}


/// 分享图片
/// @param call 分享的内容
/// @param result 分享结果
- (void)handleShareImageCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    // to 是分享的渠道, session -> 会话列表, timeline -> 朋友圈, favorite -> 收藏, 默认是 session -> 会话列表
    NSString *to = call.arguments[@"to"];
    // 分享到朋友圈
    if ([@"timeline" isEqualToString:to]) {
        req.scene = WXSceneTimeline;
    }
    // 添加到收藏列表
    else if ([@"favorite" isEqualToString:to]) {
        req.scene = WXSceneFavorite;
    }
    // 分享到好友
    else {
        req.scene = WXSceneSession;
    }
    req.bText = NO;
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = call.arguments[@"title"];
    message.description = call.arguments[@"description"];
    
    WXImageObject *mediaObject = [WXImageObject object];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:call.arguments[@"resourceUrl"]]];
    if (imageData != nil) {
        mediaObject.imageData = imageData;
    } else {
        NSString *imageUri = call.arguments[@"url"];
        NSURL *imageUrl = [NSURL URLWithString:imageUri];
        mediaObject.imageData = [NSData dataWithContentsOfFile:imageUrl.path];
    }
    message.mediaObject = mediaObject;
    
    req.message = message;
    [WXApi sendReq:req completion:^(BOOL success){
        
    }];
    result(nil);
}


/// 分享音乐
/// @param call 分享的内容
/// @param result 分享结果
- (void)handleShareMusicCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    // to 是分享的渠道, session -> 会话列表, timeline -> 朋友圈, favorite -> 收藏, 默认是 session -> 会话列表
    NSString *to = call.arguments[@"to"];
    // 分享到朋友圈
    if ([@"timeline" isEqualToString:to]) {
        req.scene = WXSceneTimeline;
    }
    // 添加到收藏列表
    else if ([@"favorite" isEqualToString:to]) {
        req.scene = WXSceneFavorite;
    }
    // 分享到好友
    else {
        req.scene = WXSceneSession;
    }
    req.bText = NO;
    
    // 分享的消息会话模型
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = call.arguments[@"title"];
    message.description = call.arguments[@"description"];
    
    // 音乐的资源路径
    NSString *musicDataUrl = call.arguments[@"resourceUrl"];
    // 音乐的网页链接地址
    NSString *musicUrl = call.arguments[@"url"];
    // 音乐的封面链接地址
    NSString *coverUrl = call.arguments[@"coverUrl"];
    
    // 音乐的数据模型
    WXMusicObject *mediaObject = [WXMusicObject object];
    mediaObject.musicUrl = musicUrl;
    mediaObject.musicDataUrl = musicDataUrl;
    
    
    NSData *coverImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:coverUrl]];
    [message setThumbImage:[UIImage imageWithData:coverImageData]];
    
    message.mediaObject = mediaObject;
    
    req.message = message;
    [WXApi sendReq:req completion:^(BOOL success){
        
    }];
    result(nil);
    
}


/// 分享网页
/// @param call 分享的内容
/// @param result 分享结果
- (void)handleShareWebPageCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    // to 是分享的渠道, session -> 会话列表, timeline -> 朋友圈, favorite -> 收藏, 默认是 session -> 会话列表
    NSString *to = call.arguments[@"to"];
    // 分享到朋友圈
    if ([@"timeline" isEqualToString:to]) {
        req.scene = WXSceneTimeline;
    }
    // 添加到收藏列表
    else if ([@"favorite" isEqualToString:to]) {
        req.scene = WXSceneFavorite;
    }
    // 分享到好友
    else {
        req.scene = WXSceneSession;
    }
    req.bText = NO;
    // 分享的消息会话模型
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = call.arguments[@"title"];
    message.description = call.arguments[@"description"];
    
    WXWebpageObject *mediaObject = [WXWebpageObject object];
    mediaObject.webpageUrl = call.arguments[@"url"];
    
    [message setThumbImage:[UIImage imageWithData:call.arguments[@"coverUrl"]]];
    message.mediaObject = mediaObject;
    
    req.message = message;
    [WXApi sendReq:req completion:^(BOOL success){
        
    }];
    result(nil);
    
}


/// 打开微信小程序
/// @param call 参数内容
/// @param result 返回结果结果
- (void)handleStartMiniProgramCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    
    WXLaunchMiniProgramReq *req = [[WXLaunchMiniProgramReq alloc] init];
    req.userName = call.arguments[@"originalId"];
    req.path = call.arguments[@"path"];
    // 默认打开正式版本的小程序
    req.miniProgramType = WXMiniProgramTypeRelease;
    NSString *miniProgramType = call.arguments[@"type"];
    if (miniProgramType.length != 0 && miniProgramType != nil) {
        
        NSInteger type = [call.arguments[@"type"] integerValue];
        switch (type) {
            case 0:
            {
                req.miniProgramType = WXMiniProgramTypeRelease;
            }
                break;
                
            case 1:
            {
                req.miniProgramType = WXMiniProgramTypeTest;
            }
                break;
                
            case 2:
            {
                req.miniProgramType = WXMiniProgramTypePreview;
            }
                break;
                
            default:
                break;
        }
        
    }
    [WXApi sendReq:req completion:^(BOOL success){
        
    }];
    result(nil);
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp*)resp {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:[NSNumber numberWithInt:resp.errCode] forKey:ARGUMENT_KEY_RESULT_ERRORCODE];
    if (resp.errStr != nil) {
        [dictionary setValue:resp.errStr forKey:ARGUMENT_KEY_RESULT_ERRORMSG];
    }
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        // 分享
        [_channel invokeMethod:METHOD_ONSHAREMSGRESP arguments:dictionary];
    } else if ([resp isKindOfClass:[WXLaunchMiniProgramResp class]]) {
        // 打开小程序
        if (resp.errCode == WXSuccess) {
            WXLaunchMiniProgramResp *launchMiniProgramResp =
                (WXLaunchMiniProgramResp *)resp;
            [dictionary setValue:launchMiniProgramResp.extMsg
                          forKey:ARGUMENT_KEY_RESULT_EXTMSG];
        }
        [_channel invokeMethod:METHOD_ONLAUNCHMINIPROGRAMRESP arguments:dictionary];
    }
}

#pragma mark - AppDelegate - Hook 实现
- (BOOL)flutter_application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    [FlutterWechateSharePlugin performAppDelegateTarget:[self class] action:_cmd params:application,url, nil];
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)flutter_application:(UIApplication *)application
              openURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication
           annotation:(id)annotation {
    
    [FlutterWechateSharePlugin performAppDelegateTarget:[self class] action:_cmd params:application,url,sourceApplication,annotation, nil];
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)flutter_application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    
    [FlutterWechateSharePlugin performAppDelegateTarget:[self class] action:_cmd params:application,url,options, nil];
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)flutter_application:(UIApplication *)application
    continueUserActivity:(NSUserActivity *)userActivity
      restorationHandler:(void (^)(NSArray *_Nonnull))restorationHandler {
    
    [FlutterWechateSharePlugin performAppDelegateTarget:[self class] action:_cmd params:application,userActivity,restorationHandler, nil];
    return [WXApi handleOpenUniversalLink:userActivity delegate:self];
}

@end
