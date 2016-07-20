//
//  ShareIOS.m
//  ShareIOS
//
//  Created by 左建军 on 16/7/19.
//  Copyright © 2016年 lanou. All rights reserved.
//

#import "ShareIOS.h"

@implementation ShareIOS

RCT_EXPORT_MODULE();


#pragma mark-分享-

//  分享微博
RCT_EXPORT_METHOD(shareToWeiboWithInfo:(NSDictionary *)info logo:(NSString *)logo appKey:(NSString *)appKey callback:(RCTResponseSenderBlock)callback){
    
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] initWithDictionary:info];
    NSURL *url = [NSURL URLWithString:logo];
    UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]];
    
    CGSize size = CGSizeMake(100, 100);
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *thumbData = UIImageJPEGRepresentation(scaledImage, 1);
    dic[@"thumbnailData"] = thumbData;
    dic[@"__class"] = @"WBWebpageObject";
    NSDictionary *message = @{@"__class" : @"WBMessageObject", @"mediaObject":dic};
    
    NSString *uuid=[[NSUUID UUID] UUIDString];
    NSArray *messageData = @[
                             @{@"transferObject":[NSKeyedArchiver archivedDataWithRootObject:@{@"__class" :@"WBSendMessageToWeiboRequest", @"message":message, @"requestID" :uuid}]},
                             @{@"userInfo":[NSKeyedArchiver archivedDataWithRootObject:@{}]},
                             @{@"app":[NSKeyedArchiver archivedDataWithRootObject:
                                       @{ @"appKey" : appKey,
                                          @"bundleID" : [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]}]}
                             ];
    [UIPasteboard generalPasteboard].items = messageData;
    
    callback(@[@{@"uuid" : uuid}]);
}
//  分享QQ
RCT_EXPORT_METHOD(shareToQQWithLogo:(NSString *)logo callback:(RCTResponseSenderBlock)callback){
    
    NSURL *url = [NSURL URLWithString:logo];
    UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]];
    
    CGSize size = CGSizeMake(100, 100);
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *thumbData = UIImageJPEGRepresentation(scaledImage, 1);
    
    NSDictionary *previewimagedata = @{@"previewimagedata":thumbData};
    
    NSData *data=[NSKeyedArchiver archivedDataWithRootObject:previewimagedata];
    [[UIPasteboard generalPasteboard] setData:data forPasteboardType:@"com.tencent.mqq.api.apiLargeData"];
    
    callback(@[@{@"thirdAppDisplayName" : [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]}]);
}

//  分享微信
RCT_EXPORT_METHOD(shareToWeixinWithInfo:(NSDictionary *)info appid:(NSString *)appid logo:(NSString *)logo callback:(RCTResponseSenderBlock)callback) {
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] initWithDictionary:info];
    NSURL *url = [NSURL URLWithString:logo];
    UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]];
    
    CGSize size=CGSizeMake(100, 100);
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *thumbData=UIImageJPEGRepresentation(scaledImage, 1);
    dic[@"thumbData"]=thumbData;
    
    NSData *output=[NSPropertyListSerialization dataWithPropertyList:@{appid:dic} format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
    [[UIPasteboard generalPasteboard] setData:output forPasteboardType:@"content"];
    
    callback(@[]);
}


#pragma mark-登录-

//  QQ登录
RCT_EXPORT_METHOD(qqLoginAppID:(NSString *)appid callback:(RCTResponseSenderBlock)callback) {
    NSDictionary *authData = @{
                               @"app_id" : appid,
                               @"app_name" : [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"],
                               //@"bundleid":[self CFBundleIdentifier],//或者有，或者正确(和后台配置一致)，建议不填写。
                               @"client_id" : appid,
                               @"response_type" : @"token",
                               @"scope" : @"get_user_info",//@"get_user_info,get_simple_userinfo,add_album,add_idol,add_one_blog,add_pic_t,add_share,add_topic,check_page_fans,del_idol,del_t,get_fanslist,get_idollist,get_info,get_other_info,get_repost_list,list_album,upload_pic,get_vip_info,get_vip_rich_info,get_intimate_friends_weibo,match_nick_tips_weibo",
                               @"sdkp" :@"i",
                               @"sdkv" : @"2.9",
                               @"status_machine" : [[UIDevice currentDevice] model],
                               @"status_os" : [[UIDevice currentDevice] systemVersion],
                               @"status_version" : [[UIDevice currentDevice] systemVersion]};
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:authData];
    [[UIPasteboard generalPasteboard] setData:data forPasteboardType:[@"com.tencent.tencent" stringByAppendingString:appid]];
    
    callback(@[]);
}

//  微博登录
RCT_EXPORT_METHOD(weiboLoginAppKey:(NSString *)appKey callBack:(RCTResponseSenderBlock)callback) {
    NSString *uuid=[[NSUUID UUID] UUIDString];
    NSArray *authData=@[
                        @{@"transferObject" : [NSKeyedArchiver archivedDataWithRootObject:
                                               @{@"__class" :@"WBAuthorizeRequest",
                                                 @"redirectURI":@"http://sina.com",
                                                 @"requestID" :uuid,
                                                 @"scope": @"all"}]},
                        @{@"userInfo":[NSKeyedArchiver archivedDataWithRootObject:
                                       @{ @"mykey":@"as you like",
                                          @"SSO_From" : @"SendMessageToWeiboViewController"}]},
                        @{@"app":[NSKeyedArchiver archivedDataWithRootObject:
                                  @{@"appKey" : appKey,
                                    @"bundleID" : [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"],
                                    @"name" :[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]}]}];
    [UIPasteboard generalPasteboard].items=authData;
    
    callback(@[@{@"uuid" : uuid}]);
}


#pragma mark-回调处理-

RCT_EXPORT_METHOD(handleOpenURL:(NSString *)returnedURL appID:(NSString *)appID callBack:(RCTResponseSenderBlock)callback){
    
    NSURL* url=[NSURL URLWithString:returnedURL];
    NSDictionary *result = nil;
    if ([url.scheme hasPrefix:@"wx"]) {
        result = [self Weixin_handleOpenURL:url andAppID:appID];
    } else if ([url.scheme hasPrefix:@"wb"]) {
        result = [self Weibo_handleOpenURL:url];
    } else if ([url.scheme hasPrefix:@"QQ"]) {
        result = [self QQShare_handleOpenURL:url];
    } else if([url.scheme hasPrefix:@"tencent"]) {
        result = [self QQAuth_handleOpenURL:url andAppID:appID];
        
    } else {
        
    }
    callback(@[result]);
}

//  微信回调处理
-(NSDictionary *)Weixin_handleOpenURL:(NSURL *)url andAppID:(NSString *)appID {
    
    NSDictionary *retDic=[NSPropertyListSerialization propertyListWithData:[[UIPasteboard generalPasteboard] dataForPasteboardType:@"content"]?:[[NSData alloc] init] options:0 format:0 error:nil][appID];
    
    if ([url.absoluteString rangeOfString:@"://oauth"].location != NSNotFound) {
        // 登录成功
        return @{@"title" : @"微信登录成功", @"res" : [self parseUrl:url]};
    } else {
        if (retDic[@"state"] && [retDic[@"state"] isEqualToString:@"Weixinauth"] && [retDic[@"result"] intValue] != 0) {
            // 登录失败
            return @{@"title" : @"微信登录失败", @"res" : retDic};
        }else if([retDic[@"result"] intValue] == 0){
            // 分享成功
            return @{@"title" : @"微信分享成功", @"res" : retDic};
        }else{
            // 分享失败
            return @{@"title" : @"微信分享失败", @"res" : retDic};
        }
    }
}

//  微博回调处理
-(NSDictionary *)Weibo_handleOpenURL:(NSURL *)url {
    NSArray *items = [UIPasteboard generalPasteboard].items;
    NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithCapacity:items.count];
    for (NSDictionary *item in items) {
        for (NSString *k in item) {
            ret[k]=[k isEqualToString:@"sdkVersion"]?item[k]:[NSKeyedUnarchiver unarchiveObjectWithData:item[k]];
        }
    }
    NSDictionary *transferObject = ret[@"transferObject"];
    if ([transferObject[@"__class"] isEqualToString:@"WBAuthorizeResponse"]) {
        //auth
        if ([transferObject[@"statusCode"] intValue] == 0) {
            return @{@"title" : @"微博登录成功", @"res" : transferObject};
        }else{
            return @{@"title" : @"微博登录失败", @"res" : transferObject};
        }
    }else if ([transferObject[@"__class"] isEqualToString:@"WBSendMessageToWeiboResponse"]) {
        //分享回调
        if ([transferObject[@"statusCode"] intValue] == 0) {
            return @{@"title" : @"微博分享成功", @"res" : transferObject};
        }else{
            return @{@"title" : @"微博分享失败", @"res" : transferObject};
        }
    } else {
        return @{};
    }
}

//  QQ auth回调处理
- (NSDictionary *)QQAuth_handleOpenURL:(NSURL *)url andAppID:(NSString *)appID {
    NSData *data = [[UIPasteboard generalPasteboard] dataForPasteboardType:[@"com.tencent.tencent" stringByAppendingString:appID]];
    NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
    
    if (ret[@"ret"] && [ret[@"ret"] intValue] == 0) {
        return @{@"title": @"QQ登录成功", @"res": ret};
    }else{
        return @{@"title": @"QQ登录失败", @"res": ret};
    }
}
//  QQ 分享回调处理
- (NSDictionary *)QQShare_handleOpenURL:(NSURL *)url {
    NSDictionary *dic = [self parseUrl:url];
    if (dic[@"error_description"]) {
        [dic setValue:[self base64Decode:dic[@"error_description"]] forKey:@"error_description"];
    }
    if ([dic[@"error"] intValue] != 0) {
        return @{@"title" : @"QQ分享失败", @"res" : dic};
    }else {
        return @{@"title" : @"QQ分享成功", @"res" : dic};
    }
}

//  解析url信息
- (NSMutableDictionary *)parseUrl:(NSURL*)url{
    NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
    NSArray *urlComponents = [[url query] componentsSeparatedByString:@"&"];
    
    for (NSString *keyValuePair in urlComponents)
    {
        NSRange range=[keyValuePair rangeOfString:@"="];
        [queryStringDictionary setObject:range.length>0?[keyValuePair substringFromIndex:range.location+1]:@"" forKey:(range.length?[keyValuePair substringToIndex:range.location]:keyValuePair)];
    }
    return queryStringDictionary;
}

//  base64解码
-(NSString*)base64Decode:(NSString *)input{
    return [[NSString alloc ] initWithData:[[NSData alloc] initWithBase64EncodedString:input options:0] encoding:NSUTF8StringEncoding];
}

@end
