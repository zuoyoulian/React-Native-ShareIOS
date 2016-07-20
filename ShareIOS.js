'use strict'
import {
  Linking,
  plist,
  AlertIOS,
  NativeModules
} from 'react-native';

var Buffer = require('buffer/').Buffer

var openShare = NativeModules.ShareIOS

// 微信
const WeiXin_AppID = 'wx508e4ac1aebc3477'
const WeiXin_AppSecret = 'ab15ba53168f8760115d413fb0342e06'
const WeiXin_dict = {'result': '1', 'sdkver': '1.5', 'command': '1010', 'returnFromApp': '0'}
// 微博
const Weibo_AppID = '12344544'
const Weibo_AppKey = '3196575651'
// QQ
const QQ_AppID = 1105466267
const QQ_AppKey = 'KHZnREw7p78ZgCD6'

export default class Share {
  
  // 判断是否安装
  IsQQInstalled() {
    return new Promise(function(resolve, reject){
      Linking.canOpenURL('mqqapi://').then(function(ret){
        resolve(ret)
      })
    })
  }
  
  IsWeiboInstalled() {
    return new Promise(function(resolve, reject){
      Linking.canOpenURL('weibosdk://request').then(function(ret){
        resolve(ret)
      })
    })
  }
  
  IsWeixinInstalled() {
    return new Promise(function(resolve, reject){
      Linking.canOpenURL('weixin://').then(function(ret){
        resolve(ret)
      })
    })
  }
	
// 授权登录
  weixinLogin() {
    const openUrl = `weixin://app/${WeiXin_AppID}/auth/?scope=snsapi_userinfo&state=Weixinauth`
    Linking.openURL(openUrl)
  }
  
  qqLogin() {
    openShare.qqLoginAppID(QQ_AppID.toString(), (response) => {
	  const openUrl = `mqqOpensdkSSoLogin://SSoLogin/tencent${QQ_AppID.toString()}/com.tencent.tencent${QQ_AppID.toString()}?generalpastboard=1`
	  Linking.openURL(openUrl)
    });
  }  
  
  weiboLogin() {
	openShare.weiboLoginAppKey(Weibo_AppKey, (response) => {
      const openUrl = `weibosdk://request?id=${response.uuid}&sdkversion=003013000`
	  Linking.openURL(openUrl)
	});
  }
  
  
// 分享  标题、描述、图片、链接

// 分享到微博
/**
  参数：
  info  分享的内容  例如：{title: '测试', desc: 'rn分享', logo: 'http://jijia.tuofeng.cn/plan/images/ins_company/ddhrs.jpg', url: 'http://jijia.tuofeng.cn/#plans'}
**/ 
  shareToWeibo(info) {
    let message = Object.assign({},{'objectID': 'identifier1'}, {description: info.desc, title: info.title, webpageUrl: info.url});
    
    openShare.shareToWeiboWithInfo(message, info.logo, Weibo_AppKey, (response) => {
      const openUrl = `weibosdk://request?id=${response.uuid}&sdkversion=003013000`
      Linking.openURL(openUrl)
    });
  }
  
  
// 分享到QQ
/**
  参数：
  info  分享的内容  例如：{title: '测试', desc: 'rn分享', logo: 'http://jijia.tuofeng.cn/plan/images/ins_company/ddhrs.jpg', url: 'http://jijia.tuofeng.cn/#plans'}
  shareTo  类型  0 QQ好友  1 QQ空间  8 QQ收藏   16 QQ数据线 电脑共享
**/ 
  shareToQQ(info, shareTo) {
    // callback_name 是 'QQ' 拼接 QQ_AppID的16进制
    let callback_name = 'QQ'+(QQ_AppID).toString(16)
    let title = encodeURI(new Buffer(info.title).toString('base64'))
    let url = encodeURI(new Buffer(info.url).toString('base64'))
    let description = encodeURI(new Buffer(info.desc).toString('base64'))
    
    openShare.shareToQQWithLogo(info.logo, (response) => {
	  let thirdAppDisplayName = new Buffer(response.thirdAppDisplayName).toString('base64')
	  const openUrl = `mqqapi://share/to_fri?thirdAppDisplayName=${thirdAppDisplayName}&version=1&cflag=${shareTo}&callback_type=scheme&generalpastboard=1&callback_name=${callback_name}&src_type=app&shareType=0&file_type=news&title=${title}&url=${url}&description=${description}&objectlocation=pasteboard`
	  Linking.openURL(openUrl)
    });
  }
  
// 分享到微信
/**
  参数：
  info 分享的内容  例如：{title: '测试', desc: 'rn分享', logo: 'http://jijia.tuofeng.cn/plan/images/ins_company/ddhrs.jpg', url: 'http://jijia.tuofeng.cn/#plans'}
  shareTo  分享的类型   0 微信好友  1 微信朋友圈   2 微信收藏
**/
  shareToWeixin(info, shareTo) {
    let message = Object.assign({}, WeiXin_dict, {'scene': shareTo}, {description: info.desc, title: info.title, mediaUrl: info.url, objectType: '5'})
    openShare.shareToWeixinWithInfo(message, WeiXin_AppID, info.logo, (respone) => {
	  const openUrl = `weixin://app/${WeiXin_AppID}/sendreq/?`
      Linking.openURL(openUrl)
    });
  }
}

module.exports = new Share();


