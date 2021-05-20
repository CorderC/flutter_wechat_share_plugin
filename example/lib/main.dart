import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_wechate_share_plugin/flutter_wechate_share_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {

    super.initState();
    if(Platform.isAndroid) {
      FlutterWechateSharePlugin.register('xxx');
    }else {
      // ios 除了传 appId 以外还需要传递 universalLink
      FlutterWechateSharePlugin.register('xxx',universalLink: 'xxx');
    }

  }


  // 和原生端进行通讯
  void _share (arguments) async {
    try {
      var result = await FlutterWechateSharePlugin.share(arguments);
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
    var result = await FlutterWechateSharePlugin.login({
      'scope': 'snsapi_userinfo',
      'state': 'customstate'
    });
    print(result);
  }

  // 打开微信
  void _openWechat () async {
    var result = await FlutterWechateSharePlugin.openWechat();
    print(result);
  }

  // 打开微信小程序
  void _startMiniProgram () async {
    var result = await FlutterWechateSharePlugin.startMiniProgram("xxx", path: "xxx", type: "0");
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
}

