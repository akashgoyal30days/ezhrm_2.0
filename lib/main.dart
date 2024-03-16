import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'goGreen_Global.dart';
import 'splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/shared_preferences_singleton.dart';

GoGreenModel? goGreenModel;
var datak;
final PageController pageController = PageController(initialPage: 0);
int currentIndex = 0;
String? location, token, version, packagename, val, buildNumber;
final List<CameraDescription> cameras = [];
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
String _message = '';

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  debugPrint("On Background  : " + message.toString());

  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }
  // Or do other work.
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const OverlaySupport.global(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {},
        home: SplashScreen(),
      ),
    );
  }
}

initializeApp() async {
  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  cameras.addAll(await availableCameras());
  await SharedPreferencesInstance.initialize();
  SharedPreferencesInstance.instance!.remove('reqatt');

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  version = packageInfo.version;
  packagename = packageInfo.packageName;
  buildNumber = packageInfo.buildNumber;
  await SharedPreferencesInstance.instance!
      .setString("showupdatedailog", "true");
  await SharedPreferencesInstance.setString(
      "Showbackgroundnotification", "true");

  if (!SharedPreferencesInstance.isUserLoggedIn) return;
  await GoGreenGlobal.initialize();
  if (!SharedPreferencesInstance.isUserLoggedIn) return;
  goGreenModel = GoGreenModel(
    backgroundLocationInterval: int.parse(datak['time'].toString()),
    canSendRequest: datak["req_attendance"].toString() == "1",
    locationEnabled: datak["attendance_location"].toString() == "1",
    faceRecognitionEnabled: datak["face_recog"].toString() == "1",
    showattendancetime: datak["attendance_time"].toString() == "1",
    backgroundLocationTrackingEnabled: datak["loc_track"].toString() == "1",
    companyLogo: datak["comp_logo"],
    companyName: datak["comp_name"],
    debugEnable: datak["debug_enable"].toString() == "true",
    showUpdateAvailableDialog: datak['code'].toString() == "1009",
  );
}

class NotificationService {
  AndroidNotificationDetails androidPlatformChannelSpecifics =
      const AndroidNotificationDetails("Android", "Flutter_Notification",
          channelDescription: "Flutter_notification",
          importance: Importance.high,
          playSound: true);
  static final NotificationService _notificationService =
      NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  void init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid, macOS: null);
    Future selectNotification(String payload) async {}

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
