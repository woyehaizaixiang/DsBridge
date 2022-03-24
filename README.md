# ds_bridge

A new Flutter package project.

## 说明
此包是(flutter_webview_plugin)[https://pub.flutter-io.cn/packages/flutter_webview_plugin]webview与网页交互的工具包


## 配置依赖包
```
dependencies:
  ds_bridge: ^1.0.0
```

## 例子
在webview页面添加JavascriptChannel
webview.dart
```
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:yundk_app/routes/application.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import '../../utils/JsBridgeUtil.dart';

class WebviewPage extends StatefulWidget {
  final String url;
  final VoidCallback backCallback;

  WebviewPage({
    Key key,
    @required this.url,
    this.backCallback,
  }) : super(key: key);

  @override
  _WebviewPageState createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  String _title = '';
  final flutterWebViewPlugin = FlutterWebviewPlugin();
  final Set<JavascriptChannel> jsChannels = [
    JavascriptChannel(
        name: 'DsBridgeApp',
        onMessageReceived: (JavascriptMessage msg) {
          String jsonStr = msg.message;
          JsBridgeUtil.executeMethod(FlutterWebviewPlugin(), jsonStr);
        }),
  ].toSet();

  StreamSubscription<String> _onUrlChanged;

  @override
  void initState() {
    super.initState();
    flutterWebViewPlugin.close();

    // 监听 url changed
    _onUrlChanged =
    flutterWebViewPlugin.onUrlChanged.listen((String url) async {

    });

    // 监听页面onload
    flutterWebViewPlugin.onStateChanged.listen((viewState) async {
      if (viewState.type == WebViewState.finishLoad) {
        flutterWebViewPlugin.evalJavascript('document.title').then((result) => {
          setState(() {
            _title = result;
          })
        });
      }
    });

  }

  @override
  void dispose() {
    _onUrlChanged.cancel();
    flutterWebViewPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebviewScaffold(
        appBar: new AppBar(
          leading: IconButton(
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            icon: Icon(const IconData(0xe61b, fontFamily: 'IconFont'), color: Color(0xff333333), size: 18),
            onPressed: (){
              flutterWebViewPlugin.close();
              Application.router.pop(context);
            },
          ),
          title: new Text(
            _title,
            style: TextStyle(color: Color(0xff333333), fontSize: 17),
          ),
          actions: [
            new IconButton(
              icon: new Icon(
                Icons.refresh_outlined,
                color: Color(0xff333333),
                size: 20
              ),
              onPressed: () {
                flutterWebViewPlugin.reload();
              }
            ),
          ],
          centerTitle: true,
          elevation: 0,
        ),
        url: widget.url,
        javascriptChannels: jsChannels,
        mediaPlaybackRequiresUserGesture: false,
        withZoom: true,
        withLocalStorage: true,
        hidden: true,
      )
    );
  }
}
```

在JsBridgeUtil类中
utils/JsBridgeUtil.dart
```
import 'package:ds_bridge/ds_bridge.dart';
class JsBridgeUtil {
  // 向H5调用接口
  static executeMethod(flutterWebViewPlugin, String jsonStr) async{
    DsBridge dsBridge = DsBridge(flutterWebViewPlugin);
    Result result = dsBridge.dispatch(jsonStr);
    if(result.method == 'share'){
      result.callBack('收到网页端share事件，内容为${result.data}并返回此文本给网页');
    }
    if(result.method == 'share1'){
      result.callBack('收到网页端share1事件');
    }
  }
}
```

## 其他
网页端对应使用(dsbridge_flutter)[https://github.com/woyehaizaixiang/dsbridge_flutter]