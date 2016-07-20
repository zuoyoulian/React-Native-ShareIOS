#React-Native-ShareIOS

实现了QQ、微信、微博的登录和分享功能。

## 安装
1. 在工程目录下运行命令，安装React-Native-ShareIOS到node_modules目录下：  
`
npm install https://github.com/zuoyoulian/React-Native-ShareIOS.git --save
`
2. 在工程目录下运行命令，链接React-Native-ShareIOS到Xcode中：  
`
rnpm link React-Native-ShareIOS
`
3. 打开Info.plist文件`Open As => Source code`，在文件中添加: 
 
```
<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleURLName</key>
			<string>RNShare</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>wx508e4ac1aebc3477</string>
				<string>tencent1105466267</string>
				<string>tencent1105466267.content</string>
				<string>QQ41E4139B</string>
				<string>wb3196575651</string>
			</array>
		</dict>
	</array>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSApplicationQueriesSchemes</key>
	<array>
		<string>mqqOpensdkSSoLogin</string>
		<string>mqzone</string>
		<string>mqqapi</string>
		<string>mqqwpa</string>
		<string>mqqOpensdkSSoLogin</string>
		<string>weibosdk</string>
		<string>weixin</string>
		<string>wechat</string>
	</array>
	<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSAllowsArbitraryLoads</key>
		<true/>
	</dict>
```

## 注意
1. 在react native中没有Buffer，需要自己安装，运行命令：  
`
npm install buffer --save
`
2. 微博分享时出现`sso package or sign error`错误，需要将微博开放平台上申请的应用的`bundle identifier`改成和你的应用的`bundle identifier`一致

## 文件说明
### 一、ShareIOS.js封装了各平台的登录和分享函数   
1、 分享到微博函数   

```
  shareToWeibo(info) {
    let message = Object.assign({},{'objectID': 'identifier1'}, {description: info.desc, title: info.title, webpageUrl: info.url});
    openShare.shareToWeiboWithInfo(message, info.logo, Weibo_AppKey, (response) => {
      const openUrl = `weibosdk://request?id=${response.uuid}&sdkversion=003013000`
      Linking.openURL(openUrl)
    });
  }
``` 
函数参数`info`对象封装的是分享的内容，内容主要有：  
title: 标题  
desc: 描述  
logo: 缩略图  
url: 跳转链接地址  
 例如： 
  
 ```
 info = {title: '测试', 
         desc: 'rn分享', 
         logo: 'http://jijia.tuofeng.cn/plan/images/ins_company/ddhrs.jpg', 
         url: 'http://jijia.tuofeng.cn/#plans'}
 ```
 2、分享到QQ  
 
 ```
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
 ```
 函数参数：  
 info: 作用和格式同分享到微博函数  
 shareTo: 是QQ平台的类型：  
 ```
 0 QQ好友;  
 1 QQ空间;  
 8 QQ收藏;   
 16 QQ数据线，电脑共享
 ```   
 
 3、分享到微信  
 
 ```
  shareToWeixin(info, shareTo) {
    let message = Object.assign({}, WeiXin_dict, {'scene': shareTo}, {description: info.desc, title: info.title, mediaUrl: info.url, objectType: '5'})
    openShare.shareToWeixinWithInfo(message, WeiXin_AppID, info.logo, (respone) => {
	  const openUrl = `weixin://app/${WeiXin_AppID}/sendreq/?`
      Linking.openURL(openUrl)
    });
  }
 ```  
 函数参数：  
 info: 作用和格式同分享到微博函数    
 shareTo: 微信平台类型：  
 ```0 微信好友； 1 微信朋友圈； 3 微信收藏``` 
 
 4、处理openurl回调函数，当分享或登录完成后，在函数中对返回的数据进行回调 
  
  ```
  handleOpenURL(returnedURL, model, callBack) {
  
    // 平台申请的应用的appID，传给oc端，用来处理不同平台的数据；
    var appID = null;
    if(model === 0) {  // 微信
      appID = WeiXin_AppID
    } else if(model === 1){ // 微博
      appID = Weibo_AppID
    } else { // QQ
      appID = QQ_AppID.toString()
    }
	
    openShare.handleOpenURL(returnedURL, appID, (result) => {
      // 将返回的数据回调给调用处
      callBack(result)
    });
  }
  ```
  函数的参数：  
  returnedURL: 回调回来的url地址；  
  model: 登录或分享的平台；  0 微信平台，1 微博平台， 2 QQ平台；   
  callBack: 回调返回数据
 
### 二、OC类 ShareIOS 文件组织数据包并将内容放到剪切板中
1、分享微博方法
```
RCT_EXPORT_METHOD(shareToWeiboWithInfo:(NSDictionary *)info logo:(NSString *)logo appKey:(NSString *)appKey callback:(RCTResponseSenderBlock)callback)
```  
方法参数说明：  

|参数           |类型       |描述              |
|-----------   |:--------:|:---------------  |
| info         |Object    |数据包             |
| logo         |String    |缩略图地址          |
| callback     |Function  |回调函数，将oc数据回调给js |

info参数： 

|参数           |类型       |描述              |
|-----------   |:--------:|:---------------  |
|objectID      |String    |对象ID，链接类型分享值为：identifier1|
|description   |String    |分享的描述|
|title         |String    |分享的标题|
|webpageUrl    |String    |分享的链接|

callback的回调参数：

|参数           |类型       |描述              |
|-----------   |:--------:|:---------------  |
|uuid          |String    |iOS设备的标识符，回调给js拼接openUrl|

2、分享QQ方法
```
RCT_EXPORT_METHOD(shareToQQWithLogo:(NSString *)logo callback:(RCTResponseSenderBlock)callback)
```
函数的参数：   
logo: 缩略图地址  
callback: 回调函数 
 
callback的回调参数：

|参数                  |类型       |描述              |
|-----------          |:--------:|:---------------  |
|thirdAppDisplayName  |String    |应用的名称，回调给js拼接openUrl|

3、分享微信方法
```
RCT_EXPORT_METHOD(shareToWeixinWithInfo:(NSDictionary *)info appid:(NSString *)appid logo:(NSString *)logo callback:(RCTResponseSenderBlock)callback)
```
方法参数说明：  

|参数           |类型       |描述              |
|-----------   |:--------:|:---------------  |
| info         |Object    |数据包             |
| appid        |String    |微信开放平台上申请的应用的appId|
| logo         |String    |缩略图地址          |
| callback     |Function  |回调函数，将oc数据回调给js |

info参数： 

|参数           |类型       |描述              |
|-----------   |:--------:|:---------------  |
|scene       |String    |微信平台的类型，0微信好友，1微信朋友圈，2微信收藏|
|description   |String    |分享的描述|
|title         |String    |分享的标题|
|mediaUrl      |String    |分享的链接|
|objectType    |String    |分享类型，有链接分享值为：5|

callback的回调参数： js不需要oc回调参数，可以回调一个空对象  

4、分享或登录后的回调处理方法
```
RCT_EXPORT_METHOD(handleOpenURL:(NSString *)returnedURL appID:(NSString *)appID callBack:(RCTResponseSenderBlock)callback)
```
方法参数说明：

|参数           |类型       |描述              |
|-----------   |:--------:|:---------------  |
|returnedURL   |String    |登录或分享完成后回调回来的url地址|
|appID         |String    |开放平台上申请的应用的标识符号， 不同平台id不一样，传参时要根据平台类型选择|
|callback      |Function  |将结果回调给js|

## 使用
### AppDelegate.m文件的处理
在AppDelegate.m中的处理主要是用来处理分享或完成后的回调；  
1. 在文件最上面`#import "RCTLinkingManager.h"`；如果出现文件找不到的错误，需要在`Build Setting`->`Header Search Paths`中添加路径`$(SRCROOT)/../node_modules/react-native/Libraries`，并且设置成`recursive`   
2. 在类的实现部分添加方法```-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation```的实现  

```
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
  return [RCTLinkingManager application:application openURL:url
                      sourceApplication:sourceApplication annotation:annotation];
}
```
### 注册Linking回调监听
1. 注册监听事件
```Linking.addEventListener('url', this._handleOpenURL.bind(this));```  
2. 处理监听的回调函数  

```
// 处理监听的回调函数
_handleOpenURL(event) {
  Share.handleOpenURL(event.url, this.mold, (result) => {
    AlertIOS.alert(
      'result',
      JSON.stringify(result)
    );
  });
}
```

### 示例代码

```
import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  TouchableOpacity,
  AlertIOS,
  Linking,
  View
} from 'react-native';

import Share from 'React-Native-ShareIOS'

class Share_ios extends Component {

  componentDidMount() {
    // 注册Linking回调监听
    Linking.addEventListener('url', this._handleOpenURL.bind(this));
  }
  
  // 处理监听的回调函数
  _handleOpenURL(event) {
    Share.handleOpenURL(event.url, this.mold, (result) => {
	    AlertIOS.alert(
          'result',
          JSON.stringify(result)
        );
    });
  }
  
  constructor(props) {
    super(props);
    
    // 测试分享数据
    this.info = {title: '测试', desc: 'rn分享', logo: 'http://jijia.tuofeng.cn/plan/images/ins_company/ddhrs.jpg', url: 'http://jijia.tuofeng.cn/#plans'};
    
    this.model = 0;  // 
  }
  
// 登录授权
  _weixinLogin() {
    Share.IsWeixinInstalled().then(result => {
	  if(result) {
	    this.mold = 0
	    Share.weixinLogin()
      } else {
	    AlertIOS.alert(
          'result',
          '您没有安装微信，无法进行授权登录'
        );
      }
    })
  }
   _qqLogin() {
     Share.IsQQInstalled().then(result => {
	   if(result) {
	     this.mold = 2
	     Share.qqLogin()
	    } else {
		    AlertIOS.alert(
              'result',
              '您没有安装QQ，无法进行授权登录'
           );
	    }
	  }) 
   }
   _weiboLogin() {
     Share.IsWeiboInstalled().then(result => {
	   if(result) {
	     this.mold = 1
		 Share.weiboLogin()
	   } else {
		   AlertIOS.alert(
              'result',
              '您没有安装微博，无法进行授权登录'
           );
	   }
     })
   }
  
// 分享到微博
    _shareToWeibo(){
      Share.IsWeiboInstalled().then(result => {
	      if(result) {
	        this.mold = 1
	        Share.shareToWeibo(this.info)
	      } else {
		    AlertIOS.alert(
              'result',
              '您没有安装微博，无法分享'
           );
	      }
      })
    }
 // 分享到QQ好友
    _shareToQQFriends(){
      Share.IsQQInstalled().then(result => {
	    if(result) {
	      this.mold = 2
	      Share.shareToQQ(this.info, 0)
	    } else {
		    AlertIOS.alert(
		      'reslut',
		      '您没有安装QQ，无法分享'
		    )
	    }
      })
    }
// 分享到QQ空间
    _shareToQQZone(){
	  Share.IsQQInstalled().then(result => {
	    if(result) {
	      this.mold = 2
	      Share.shareToQQ(this.info, 1)
	    } else {
		    AlertIOS.alert(
		      'reslut',
		      '您没有安装QQ，无法分享'
		    )
	    }
      })
    }
//  分享到QQ收藏   
    _shareToQQFavorites(){
	  Share.IsQQInstalled().then(result => {
	    if(result) {
	      this.mold = 2
	      Share.shareToQQ(this.info, 8)
	    } else {
		    AlertIOS.alert(
		      'reslut',
		      '您没有安装QQ，无法分享'
		    )
	    }
      })
    }
 // 分享到QQ数据线 电脑共享
    _shareToQQDataline(){
	  Share.IsQQInstalled().then(result => {
	    if(result) {
	      this.mold = 2
	      Share.shareToQQ(this.info, 16)
	    } else {
		    AlertIOS.alert(
		      'reslut',
		      '您没有安装QQ，无法分享'
		    )
	    }
      })
    }
    
//  分享微信
    _shareToWeixinSession() {
	   Share.IsWeixinInstalled().then(result => {
	    if(result) {
	      this.mold = 0
		  Share.shareToWeixin(this.info, 0);
	    } else {
		    AlertIOS.alert(
		      'reslut',
		      '您没有安装微信，无法分享'
		    )
	    }
      }) 
    }
    _shareToWeixinTimeline() {
	    Share.IsWeixinInstalled().then(result => {
	    if(result) {
	      this.mold = 0
		  Share.shareToWeixin(this.info, 1);
	    } else {
		    AlertIOS.alert(
		      'reslut',
		      '您没有安装微信，无法分享'
		    )
	    }
      }) 
    }
    _shareToWeixinFavorite() {
	    Share.IsWeixinInstalled().then(result => {
	    if(result) {
	      this.mold = 0
		  Share.shareToWeixin(this.info, 2);
	    } else {
		    AlertIOS.alert(
		      'reslut',
		      '您没有安装微信，无法分享'
		    )
	    }
      })
    }


  render() {
    return (
      <View style={styles.container}>
        <Text style={{backgroundColor:'red'}}>登录</Text>
        <TouchableOpacity onPress={this._weixinLogin.bind(this)}>
          <Text style={{height:30}}>WeChat Login</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={this._qqLogin.bind(this)}>
          <Text style={{height:30}}>QQ Login</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={Share.weiboLogin}>
          <Text style={{height:30}}>weibo Login</Text>
        </TouchableOpacity>
        
        <Text style={{backgroundColor:'red'}}>分享</Text>
        <Text>QQ分享</Text>
        <TouchableOpacity onPress={this._shareToQQFriends.bind(this)}>
          <Text style={{height:30}}>QQFriends share</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={this._shareToQQZone.bind(this)}>
          <Text style={{height:30}}>QQZone share</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={this._shareToQQFavorites.bind(this)}>
          <Text style={{height:30}}>QQFavorites share</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={this._shareToQQDataline.bind(this)}>
          <Text style={{height:30}}>QQDataline share</Text>
        </TouchableOpacity>
        <Text>微博分享</Text>
        <TouchableOpacity onPress={this._shareToWeibo.bind(this)}>
          <Text style={{height:30}}>weibo share</Text>
        </TouchableOpacity>
        <Text>微信分享</Text>
        <TouchableOpacity onPress={this._shareToWeixinSession.bind(this)}>
          <Text style={{height:30}}>weixinSession share</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={this._shareToWeixinTimeline.bind(this)}>
          <Text style={{height:30}}>weixinTimeline share</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={this._shareToWeixinFavorite.bind(this)}>
          <Text style={{height:30}}>weixinFavorite share</Text>
        </TouchableOpacity>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});

AppRegistry.registerComponent('Share_ios', () => Share_ios);

```