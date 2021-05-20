
import 'dart:async';

import 'package:flutter/services.dart';

class FlutterWechateSharePlugin {
  static const MethodChannel _channel =
      const MethodChannel('flutter_wechate_share_plugin');

  /// 通过 微信 appid 注册应用，universalLink 为 ios 平台的必传参数
  static Future<dynamic> register(String appid, {String universalLink = ''}) async {
    if(appid.length == 0 || appid == null) return;
    var result = await _channel.invokeMethod(
        'register',
        {
          'appid': appid,
          'universalLink' : universalLink
        }
    );
    return result;
  }

  /// 检测本地是否安装了微信
  static Future<dynamic> isWechatInstalled() async {
    var result = await _channel.invokeMethod(
        'isWechatInstalled'
    );
    return result == 'true' ? true : false;
  }

  /// 获取微信的版本.
  static Future<dynamic> getApiVersion() async {
    var result = await _channel.invokeMethod(
        'getApiVersion'
    );
    return result;
  }

  /// 打开微信app.
  static Future<dynamic> openWechat() async {
    var result = await _channel.invokeMethod(
        'openWechat'
    );
    return result;
  }

  ///打开小程序
  /*
  * originalId: 组织id,必传参数
  * path 小程序页面的路径 不填默认拉起小程序首页
  * type 分享小程序的版本 （0-正式，1-开发，2-体验）
  * */
  static Future<dynamic> startMiniProgram(String originalId, {String path, String type = "0"}) async {
    if(originalId.length == 0 || originalId == null) {
      return;
    }
    var result = await _channel.invokeMethod(
        'startMiniProgram',
        {
          'originalId': originalId,
          'path': path,
          'type': type
        }
    );
    return result;
  }

  /// 分享方法的调用入口
  /// 参数
  /// {
  ///   "kind": "text",
  ///   "to": "session", timeline - 分享到朋友圈，favorite - 收藏，session - 分享到好友（默认）
  ///   "title": "the title of message",
  ///   "description": "short description of message.",
  ///   "coverUrl": "https://example.com/path/to/cover/image.jpg",
  ///   "resourceUrl": "https://example.com/path/to/resource.mp4"
  /// }
  static Future<dynamic> share(Map<String, dynamic> arguments) async {
    arguments['kind'] = arguments['kind'] ?? 'text';
    arguments['to'] = arguments['to'] ?? 'session';

    var result = await _channel.invokeMethod(
        'share',
        arguments
    );

    return result;
  }

  /// 登陆
  /// {
  ///   "scope": "snsapi_userinfo",
  ///   "state": "customestate"
  /// }
  static Future<dynamic> login(Map<String, String> arguments) async {
    arguments['scope'] = arguments['scope'] ?? 'snsapi_userinfo';

    var result = await _channel.invokeMethod(
        'login',
        arguments
    );
    return result;
  }

}
