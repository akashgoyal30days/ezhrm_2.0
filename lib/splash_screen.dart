import 'dart:developer';
import 'dart:io';

import 'package:app_minimizer/app_minimizer.dart';
import 'package:ezhrm/home_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:root_tester/root_tester.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart' as main;
import 'login.dart';
import 'services/shared_preferences_singleton.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkdevicerooted();
  }

  String? appsign;
  checkdevicerooted() async {
    bool isRooted;
    try {
      isRooted = await RootTester.isDeviceRooted;
    } on PlatformException {
      isRooted = false;
    }
    if (isRooted == true) {
      Fluttertoast.showToast(
          msg: "Device is Rooted, You Can't Use this Application",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0);
    } else {
      movetonextscreen();
      // appsign = await verifyAppSignature();

      // setState(() {});
      // if (appsign == "cedf08356571bfa935778c183440b9048ca51dd4") {
      //   movetonextscreen();
      // } else {
      //   Fluttertoast.showToast(
      //       msg: "This App has been tampered With, app will not run",
      //       toastLength: Toast.LENGTH_SHORT,
      //       gravity: ToastGravity.BOTTOM,
      //       timeInSecForIosWeb: 2,
      //       backgroundColor: Colors.white,
      //       textColor: Colors.black,
      //       fontSize: 16.0);
      // }
    }
  }

  // checkinternetconnecttion() async {
  //   log("checking connection...");
  //   if (Platform.isAndroid) {
  //     if (await DataConnectionChecker().hasConnection) {
  //       log("Internet Connected");

  //       movetonextscreen();
  //     } else {
  //       log(" No Internet Connection");
  //       noInternetConnectiondailog();
  //       setState(() {});
  //     }
  //   }
  //   if (Platform.isIOS) {
  //     movetonextscreen();
  //   }
  // }

  noInternetConnectiondailog() {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: AlertDialog(
                titlePadding: const EdgeInsets.only(
                    left: 15, right: 15, top: 15, bottom: 10),
                contentPadding: const EdgeInsets.only(
                    left: 15, right: 15, top: 10, bottom: 10),
                actionsAlignment: MainAxisAlignment.end,
                actions: [
                  TextButton(
                      onPressed: () {
                        if (Platform.isAndroid) {
                          FlutterAppMinimizer.minimize();
                        } else {
                          FlutterAppMinimizer.minimize();
                        }
                      },
                      child: const Text(" Close "))
                ],
                title: const Text(
                  "No Internet Connection",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w500),
                ),
                content: const Text(
                  "Please check your connection status and try again.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                ),
              ),
            ));
  }

  String? savedusername;
  getusername() async {
    SharedPreferences usernameavailable = await SharedPreferences.getInstance();
    savedusername = usernameavailable.getString("username").toString();
    log("Username : " + savedusername!);
  }

  movetonextscreen() async {
    getusername();
    await main.initializeApp();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SharedPreferencesInstance.isUserLoggedIn
            ? const HomeBottomNavigationBar()
            : const Login(),
      ),
    );
  }

  @override
  Widget build(BuildContext contxt) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo,
              Colors.blue.shade600,
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SizedBox.expand(
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset(
                          "assets/ezlogo.png",
                          scale: 4,
                        ),
                        LoadingAnimationWidget.fourRotatingDots(
                          color: Colors.white54,
                          size: 50,
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: ((contet, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return Text(
                              snapshot.data!.version,
                              style: const TextStyle(color: Colors.white54),
                            );
                          }
                          // Place Holder Transparent Text
                          return const Text(
                            "0.0.0",
                            style: TextStyle(color: Colors.transparent),
                          );
                        })),
                  )
                ],
              ),
            ),
          ),
        ),
      );
}
