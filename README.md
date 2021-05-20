# flutter_wechat_share_plugin

微信平台，flutter版本插件，该插件的主要功能有:
1.配置工程在微信开放平台注册的appId参数，直接在flutter层进行统一配置，不需要，再在ios和android原生端进行单独配置
2.分享文字，图片，音乐，网页，登录，打开小程序等功能统一在flutter层进行处理

## 关于微信功能插件的引入方式方式

### 方式一:在yaml文件中通过git地址引入
```yaml

flutter_wechat_share_plugin:
    git:
      url: 'https://github.com/clearCoro/flutter_wechat_share_plugin.git'
      ref: 'main'

```

## 关于微信插件的初始化配置方式
```dart
import 'package:flutter_wechat_plugin/flutter_wechat_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  void initState() {
      super.initState();
      if(Platform.isAndroid) {
        FlutterWechatPlugin.register('xxx');
      }else {
        // ios 除了传 appId 以外还需要传递 universalLink
        FlutterWechatPlugin.register('xxx',universalLink: 'xxx');
      }
  }
}

```


## 微信分享相关使用示例

<img src="http://gitlab.sinoiov.com/LHJH/flutter/plugin/wechat_flutter/uploads/7cb3d55a7394c95c0748e614ae327eca/Simulator_Screen_Shot_-_iPhone_12_Pro_-_2021-03-18_at_09.29.29.png" width = "321" height = "694" alt="默认主题，银行卡列表界面" align=center />


```dart
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_wechat_plugin/flutter_wechat_plugin.dart';

// 和原生端进行通讯
void _share (arguments) async {
    try {
      var result = await FlutterWechatPlugin.share(arguments);
      print(result);
    } catch (e) {
      print(e);
    }

}

// 分享文字
void _shareText ([String to = 'session']) async {
    var arguments = {
      'to': to,
      'text': '欢迎使用微信分享Flutter组件'
    };
    _share(arguments);
}

// 分享图片
void _shareImage ([String to = 'session']) async {
    _share({
      'kind': 'image',
      'to': to,
      'resourceUrl': 'https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=3659917810,2399103574&fm=15&gp=0.jpg',
      'url': 'https://ss0.bdstatic.com',
      'title': '美图',
      'description': '分享一张图片'
    });
}

// 分享音乐
void _shareMusic ([String to = 'session']) async {
    _share({
      'kind': 'music',
      'to': to,
      'resourceUrl': 'http://music.163.com/song?id=1417781787&userid=93491438',
      'url': 'http://music.163.com',
      'coverUrl': 'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fpic.51yuansu.com%2Fpic3%2Fcover%2F03%2F54%2F69%2F5bc6e948642f1_610.jpg&refer=http%3A%2F%2Fpic.51yuansu.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1618379001&t=46661a82b5e101857739eb836bf71df1',
      'title': '奔跑',
      'description': '励志翻唱羽泉歌曲'
    });
}

// 分享网页
void _shareWebpage ([String to = 'session']) async {
    _share({
      'kind': 'webpage',
      'to': to,
      'url': 'https://www.baidu.com/',
      'coverUrl': 'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fpic.51yuansu.com%2Fpic3%2Fcover%2F03%2F54%2F69%2F5bc6e948642f1_610.jpg&refer=http%3A%2F%2Fpic.51yuansu.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1618379001&t=46661a82b5e101857739eb836bf71df1',
      'title': 'Search',
      'description': '搜索页'
    });
}

// 微信登陆
void _login () async {
    var result = await FlutterWechatPlugin.login({
      'scope': 'snsapi_userinfo',
      'state': 'customstate'
    });
    print(result);
}

// 打开微信
void _openWechat () async {
    var result = await FlutterWechatPlugin.openWechat();
    print(result);
}

// 打开微信小程序
void _startMiniProgram () async {
    var result = await FlutterWechatPlugin.startMiniProgram("xxx", "xxx", "0");
    print(result);
}

@override
Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('微信功能组件'),
        ),
        body: ListView(
          children: <Widget>[
    
            ListTile(
              leading: Icon(Icons.text_format),
              title: Text('分享文字'),
              onTap: () {
                _shareText();
              },
            ),
            ListTile(
              leading: Icon(Icons.text_format),
              title: Text('分享文字到好友圈'),
              onTap: () {
                _shareText('timeline');
              },
            ),
            ListTile(
              leading: Icon(Icons.image),
              title: Text('分享图片'),
              onTap: () {
                _shareImage();
              },
            ),
            ListTile(
              leading: Icon(Icons.music_note),
              title: Text('分享音乐'),
              onTap: () {
                _shareMusic();
              },
            ),
            ListTile(
              leading: Icon(Icons.web),
              title: Text('分享网页'),
              onTap: () {
                _shareWebpage();
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('微信登陆'),
              onTap: () {
                _login();
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('打开微信'),
              onTap: () {
                _openWechat();
              },
            ),
            ListTile(
              leading: Icon(Icons.web),
              title: Text('打开小程序'),
              onTap: () {
                _startMiniProgram();
              },
            ),
          ],
        ),
      ),
    );
}

```

