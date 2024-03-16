import 'package:flutter/services.dart';

import 'package:package_info/package_info.dart';

Future<String> verifyAppSignature() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String appSignature = await getPackageSignature(packageInfo.packageName);
  String developerSignature = 'my_sha-1_key';
// storing the sha key in code is not recommended

  if (appSignature != developerSignature) {
    print("appSign: $appSignature");
    // SystemNavigator.pop();
    // throw Exception('Release signature verification failed');
  }
  return appSignature.toString();
}

Future<String> getPackageSignature(String packageName) async {
  try {
    const MethodChannel channel = MethodChannel('app-release');
    final String signature = await channel.invokeMethod('getSignature');
    return signature;
  } on PlatformException catch (e) {
    return e.toString();
  }
}
