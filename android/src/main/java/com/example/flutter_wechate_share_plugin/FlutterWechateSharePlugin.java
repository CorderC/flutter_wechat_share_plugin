package com.example.flutter_wechate_share_plugin;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterWechateSharePlugin */
public class FlutterWechateSharePlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private static int code;//返回错误吗
  private static String loginCode;//获取access_code
  private static IWXAPI api;
  private static Result result;
  private Context context;
  private String appid;
  private Bitmap bitmap;
  private WXMediaMessage message;
  private String kind = "session";
  private BroadcastReceiver sendRespReceiver;
  private MethodChannel channel;
  public static final String WX_PLATFORM_APP_ID = "xxx";

  public static final String WX_PLATFORM_APP_SECRET = "xxx";

  public static final String WX_APP_KEY = "xxx";

  public static int getCode() {
    return code;
  }

  public static void setCode(int value) {
    code = value;
  }

  public static String getLoginCode() {
    return loginCode;
  }

  public static void setLoginCode(String value) {
    loginCode = value;
  }

  private Handler handler = new Handler(new Handler.Callback() {
    @Override
    public boolean handleMessage(Message osMessage) {
      SendMessageToWX.Req request = new SendMessageToWX.Req();
      request.scene = kind.equals("timeline")
              ? SendMessageToWX.Req.WXSceneTimeline
              : kind.equals("favorite")
              ? SendMessageToWX.Req.WXSceneFavorite
              : SendMessageToWX.Req.WXSceneSession;

      if (bitmap != null) {
        Bitmap thumbBitmap = Bitmap.createScaledBitmap(bitmap, 100, 100, true);
        message.thumbData = convertBitmapToByteArray(thumbBitmap, true);
      }
      switch (osMessage.what) {
        case 0:
        case 2:
        case 3:
          request.transaction = String.valueOf(System.currentTimeMillis());
          request.message = message;
          api.sendReq(request);
          break;
        case 1:
          if (bitmap == null) {
            Toast.makeText(context, "图片路径错误", Toast.LENGTH_SHORT).show();
            break;
          }
          WXImageObject imageObject = new WXImageObject(bitmap);
          message.mediaObject = imageObject;
          request.transaction = String.valueOf(System.currentTimeMillis());
          request.message = message;
          api.sendReq(request);
          break;
        default:
          break;
      }
      return false;
    }
  });

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_wechat_share_plugin");
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.getApplicationContext();
    IntentFilter intentFilter = new IntentFilter();
    intentFilter.addAction("sendResp");
    flutterPluginBinding.getApplicationContext().registerReceiver(createReceiver(), intentFilter);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("register")) {
      appid = call.argument("appid");
      api = WXAPIFactory.createWXAPI(context, appid, true);
      result.success(api.registerApp(appid));
    }
    // Check if wechat app installed
    else if (call.method.equals("isWechatInstalled")) {
      if (api == null) {
        result.success(false);
      } else {
        result.success(api.isWXAppInstalled());
      }
    } else if (call.method.equals("getApiVersion")) {
      result.success(api.getWXAppSupportAPI());
    } else if (call.method.equals("openWechat")) {
      result.success(api.openWXApp());
    } else if (call.method.equals("startMiniProgram")) {
      String originalId = call.argument("originalId");
      String path = call.argument("path");
      String type = call.argument("type");//0 release版本，1测试版本 ，2体验版
      IWXAPI api = WXAPIFactory.createWXAPI(context, appid);
      WXLaunchMiniProgram.Req req = new WXLaunchMiniProgram.Req();
      req.userName = originalId; // 填小程序原始id
      req.path = path; //拉起小程序页面的可带参路径，不填默认拉起小程序首页
      int miniprogramType = WXLaunchMiniProgram.Req.MINIPTOGRAM_TYPE_RELEASE;
      if (!TextUtils.isEmpty(type)) {
        miniprogramType = Integer.parseInt(type);
      }
      req.miniprogramType = miniprogramType;// 可选打开 开发版，体验版和正式版
      api.sendReq(req);
    } else if (call.method.equals("share")) {
      final String kind = call.argument("kind");
      final String to = call.argument("to");
      final String coverUrl = call.argument("coverUrl");
      SendMessageToWX.Req request = new SendMessageToWX.Req();
      message = new WXMediaMessage();
      request.scene = to.equals("timeline")
              ? SendMessageToWX.Req.WXSceneTimeline
              : to.equals("favorite")
              ? SendMessageToWX.Req.WXSceneFavorite
              : SendMessageToWX.Req.WXSceneSession;
      switch (kind) {
        case "text":
          WXTextObject textObject = new WXTextObject();
          final String text = call.argument("text");
          textObject.text = text;
          message.mediaObject = textObject;
          message.description = text;
          request.transaction = String.valueOf(System.currentTimeMillis());
          request.message = message;
          api.sendReq(request);
          break;
        case "music":
          WXMusicObject musicObject = new WXMusicObject();
          musicObject.musicUrl = call.argument("resourceUrl").toString();
          musicObject.musicDataUrl = call.argument("resourceUrl").toString();
          musicObject.musicLowBandDataUrl = call.argument("resourceUrl").toString();
          musicObject.musicLowBandUrl = call.argument("resourceUrl").toString();
          message = new WXMediaMessage();
          message.mediaObject = musicObject;
          message.title = call.argument("title").toString();
          message.description = call.argument("description").toString();
          //网络图片或者本地图片
          new Thread() {
            public void run() {
              Message osMessage = new Message();
              bitmap = GetBitmap(coverUrl);
              osMessage.what = 2;
              handler.sendMessage(osMessage);
            }
          }.start();
          break;
        case "video":
          WXVideoObject videoObject = new WXVideoObject();
          videoObject.videoUrl = call.argument("resourceUrl").toString();
          videoObject.videoLowBandUrl = call.argument("resourceUrl").toString();
          message = new WXMediaMessage();
          message.mediaObject = videoObject;
          message.title = call.argument("title").toString();
          message.description = call.argument("description").toString();
          //网络图片或者本地图片
          new Thread() {
            public void run() {
              Message osMessage = new Message();
              bitmap = GetBitmap(coverUrl);
              osMessage.what = 3;
              handler.sendMessage(osMessage);
            }
          }.start();
          break;
        case "image":
          message = new WXMediaMessage();
          message.title = call.argument("title").toString();
          message.description = call.argument("description").toString();
          final String imageResourceUrl = call.argument("resourceUrl");
          //网络图片或者本地图片
          new Thread() {
            public void run() {
              Message osMessage = new Message();
              bitmap = GetBitmap(imageResourceUrl);
              osMessage.what = 1;
              handler.sendMessage(osMessage);
            }
          }.start();
          break;
        case "webpage":
          WXWebpageObject webpageObject = new WXWebpageObject();
          webpageObject.webpageUrl = call.argument("url").toString();
          message = new WXMediaMessage();
          message.mediaObject = webpageObject;
          message.title = call.argument("title").toString();
          message.description = call.argument("description").toString();
          //网络图片或者本地图片
          new Thread() {
            public void run() {
              Message osMessage = new Message();
              bitmap = GetBitmap(coverUrl);
              osMessage.what = 0;
              handler.sendMessage(osMessage);
            }
          }.start();
          break;
      }
    } else if (call.method.equals("login")) {
      final String scope = call.argument("scope").toString();
      final String state = call.argument("state").toString();
      SendAuth.Req authRequest = new SendAuth.Req();
      authRequest.scope = scope;
      authRequest.state = state;
      api.sendReq(authRequest);
    } else if (call.method.equals("pay")) {
      final String appId = call.argument("appId").toString();
      final String partnerId = call.argument("partnerId").toString();
      final String prepayId = call.argument("prepayId").toString();
      final String nonceStr = call.argument("nonceStr").toString();
      final String timestamp = call.argument("timestamp").toString();
      final String sign = call.argument("sign").toString();
      final String packageValue = call.argument("package").toString();
      PayReq payRequest = new PayReq();
      payRequest.partnerId = partnerId;
      payRequest.prepayId = prepayId;
      payRequest.nonceStr = nonceStr;
      payRequest.timeStamp = timestamp;
      payRequest.sign = sign;
      payRequest.packageValue = packageValue;
      payRequest.appId = appId;
      api.sendReq(payRequest);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  public Bitmap GetBitmap(String url) {
    Bitmap bitmap = null;
    InputStream in = null;
    BufferedOutputStream out = null;
    try {
      in = new BufferedInputStream(new URL(url).openStream(), 1024);
      final ByteArrayOutputStream dataStream = new ByteArrayOutputStream();
      out = new BufferedOutputStream(dataStream, 1024);
      copy(in, out);
      out.flush();
      byte[] data = dataStream.toByteArray();
      bitmap = BitmapFactory.decodeByteArray(data, 0, data.length);
      return bitmap;
    } catch (IOException e) {
      e.printStackTrace();
      return null;
    }
  }

  public byte[] convertBitmapToByteArray(final Bitmap bitmap, final boolean needRecycle) {
    ByteArrayOutputStream output = new ByteArrayOutputStream();
    bitmap.compress(Bitmap.CompressFormat.PNG, 100, output);
    if (needRecycle) {
      bitmap.recycle();
    }

    byte[] result = output.toByteArray();
    try {
      output.close();
    } catch (Exception e) {
      e.printStackTrace();
    }

    return result;
  }

  private static void copy(InputStream in, OutputStream out) throws IOException {
    byte[] b = new byte[1024];
    int read;
    while ((read = in.read(b)) != -1) {
      out.write(b, 0, read);
    }
  }

  private static BroadcastReceiver createReceiver() {
    return new BroadcastReceiver() {
      @Override
      public void onReceive(Context context, Intent intent) {
        System.out.println(intent.getStringExtra("type"));
        if (intent.getStringExtra("type").equals("SendAuthResp")) {
          result.success(intent.getStringExtra("code"));
        } else if (intent.getStringExtra("type").equals("PayResp")) {
          result.success(intent.getStringExtra("code"));
        } else if (intent.getStringExtra("type").equals("ShareResp")) {
          System.out.println(intent.getStringExtra("code"));
          result.success(intent.getStringExtra("code"));
        }
      }
    };
  }
}
