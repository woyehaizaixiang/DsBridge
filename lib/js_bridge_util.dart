library ds_bridge;

import 'dart:convert';

class DsBridge {
  final flutterWebViewPlugin;
  String callBackCode = '';
  DsBridge(this.flutterWebViewPlugin);

  Result dispatch (String jsonStr) {
    Map jsonData = jsonDecode(jsonStr);
    String method = jsonData['method'];
    String data = jsonData['data'];
    callBackCode = jsonData['callBack'];
    final result = Result();
    result.method = method;
    result.data = data;
    result.callBack = callBack;
    return result;
  }

  void callBack (String params) {
    String code = '$callBackCode("$params")';
    flutterWebViewPlugin.evalJavascript('$code');
  }

}

class Result {
  String method = '';
  String data = '';
  Function? callBack;
}
