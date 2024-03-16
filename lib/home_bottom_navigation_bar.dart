import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:app_minimizer/app_minimizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';

import 'home.dart';
import 'main.dart';
import 'drawer.dart';
import 'myprofile.dart';
import 'constants.dart';
import 'notification.dart';
import 'services/shared_preferences_singleton.dart';

String? showupdatedailog =
    SharedPreferencesInstance.instance!.getString("showupdatedailog");

String? showbackgroundlocationdailog = SharedPreferencesInstance.instance!
    .getString("ShowBackgroundLocationDailog");

class HomeBottomNavigationBar extends StatefulWidget {
  const HomeBottomNavigationBar({Key? key}) : super(key: key);

  @override
  State<HomeBottomNavigationBar> createState() =>
      _HomeBottomNavigationBarState();
}

class _HomeBottomNavigationBarState extends State<HomeBottomNavigationBar> {
  final _pageController = PageController(initialPage: 0);
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final Map<String, List> fetchedNotifications = {};
  final int intervalInMicroSeconds = goGreenModel!.backgroundLocationInterval!;
  Timer? backgroundTrackingTimer;
  StreamSubscription? locationStream;
  Position? currentPosition;
  int _currentPageIndex = 0;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService().init();

      if (goGreenModel!.backgroundLocationTrackingEnabled!) {
        var show =
            SharedPreferencesInstance.getString("ShowBackgroundLocationDailog");
        if (show.toString() == "true") {
          Future.delayed(const Duration(seconds: 1), () {
            if (Platform.isAndroid) {
              showLocationTrackingDialog();
            }
          });
        }
      } else {}

      if (goGreenModel!.showUpdateAvailableDialog!) {
        log("Show update Dailog Status : " + showupdatedailog.toString());
        if (showupdatedailog.toString() == "true") {
          showUpdate();
        }
      }
    });
  }

  void showUpdate() => showCupertinoDialog(
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async {
              Navigator.pop(context);
              return false;
            },
            child: Theme(
              data: ThemeData.light(),
              child: CupertinoAlertDialog(
                title: Column(
                  children: [
                    const SizedBox(height: 10),
                    Image.asset(
                      'assets/ezlogo.png',
                      width: 200,
                      height: 100,
                    ),
                    const Text(
                      'EZHRM',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
                content: Column(
                  children: const [
                    SizedBox(height: 20),
                    Text(
                      ' New Update available',
                      style: TextStyle(
                          fontFamily: font1,
                          fontWeight: FontWeight.w500,
                          fontSize: 25),
                    ),
                  ],
                ),
                actions: <Widget>[
                  Column(
                    children: [
                      CupertinoDialogAction(
                        isDefaultAction: true,
                        child: const Text('Update Now'),
                        onPressed: () async {
                          showupdatedailog = "false";
                          await SharedPreferencesInstance.instance!
                              .setString("showupdatedailog", "false");
                          if (Platform.isAndroid) {
                            launch(
                                "https://play.google.com/store/apps/details?id=com.in30days.ezhrm");
                          } else {
                            launch(
                                "https://apps.apple.com/us/app/ezhrm/id1551548072");
                          }
                        },
                      ),
                      const Divider(),
                      CupertinoDialogAction(
                        isDefaultAction: true,
                        child: const Text('Not Now'),
                        onPressed: () async {
                          showupdatedailog = "false";
                          await SharedPreferencesInstance.instance!
                              .setString("showupdatedailog", "false");
                          setState(() {});
                          Navigator.pop(context);
                          log("Show Update Dailog : " +
                              showupdatedailog.toString());
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );

  showLocationTrackingDialog() async {
    await showCupertinoDialog(
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: CupertinoAlertDialog(
              title: const Text("This app collects location data to enable"),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("- Location Based Attendance Marking"),
                  const Text(
                    "- Employer/Company can track your live location",
                    textAlign: TextAlign.left,
                  ),
                  const Text(
                    "- To Check and approve your travel allowances even when the app is closed or not in use",
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Do you want to allow?",
                    textAlign: TextAlign.left,
                  ),
                  RichText(
                      text: TextSpan(
                          style: const TextStyle(color: Colors.black),
                          children: [
                        const TextSpan(text: "Click "),
                        TextSpan(
                            text: "here ",
                            style: const TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launch("https://ezhrm.in/locationpolicy");
                              }),
                        const TextSpan(text: "for details"),
                      ])),
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  child: const Text("Allow"),
                  onPressed: () async {
                    await SharedPreferencesInstance.setString(
                        "ShowBackgroundLocationDailog", "false");
                    Navigator.pop(context);

                    log("Background Location Dailog : " +
                        SharedPreferencesInstance.getString(
                            "ShowBackgroundLocationDailog"));
                    await showLocationTrackingConditions();
                  },
                ),
                const CupertinoDialogAction(
                  child: Text("Exit"),
                  onPressed: SystemNavigator.pop,
                ),
              ],
            ),
          );
        });
  }

  showLocationTrackingConditions() async {
    await showDialog(
        context: context,
        builder: (context) {
          return WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: AlertDialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 15),
                title: Row(
                  children: const [
                    SizedBox(width: 10),
                    Text(
                      "Attention",
                      style: TextStyle(
                          color: Color(0xff072a99),
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        SizedBox(width: 10),
                        Text("For Background Location Tracking : ",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          height: 15,
                          width: 15,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: themecolor),
                        ),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Text(
                              "Please, Keep your battery Save Mode Disable",
                              style: TextStyle(
                                fontSize: 15,
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          height: 15,
                          width: 15,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: themecolor),
                        ),
                        const SizedBox(width: 15),
                        const Expanded(
                          child:
                              Text("Please Allow the app to Run in Background",
                                  style: TextStyle(
                                    fontSize: 15,
                                  )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          height: 15,
                          width: 15,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: themecolor),
                        ),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Text(
                              "Do not Remove your app from Recent Activity",
                              style: TextStyle(
                                fontSize: 15,
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          height: 15,
                          width: 15,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: themecolor),
                        ),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Text("Keep Your Phone GPS Enabled ",
                              style: TextStyle(
                                fontSize: 15,
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          height: 15,
                          width: 15,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: themecolor),
                        ),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Text(
                              "Please, Make sure your Internet Connection is active ",
                              style: TextStyle(
                                fontSize: 15,
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      checkGPSStatus();
                    },
                    child: const Text("OKAY"),
                    style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all(const Color(0xff072a99))),
                  ),
                ],
              ));
        });
  }

  checkGPSStatus() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.ignoreBatteryOptimizations,
    ].request();
    ;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      Map<Permission, PermissionStatus> permissions = await [
        Permission.locationWhenInUse,
        Permission.location,
        Permission.ignoreBatteryOptimizations
      ].request();

      if (permissions[Permission.locationWhenInUse] ==
              PermissionStatus.denied &&
          permissions[Permission.location] == PermissionStatus.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              "Location permission is denied",
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
          ));
        }
        return;
      }
    }
    var servicestatus = await Geolocator.isLocationServiceEnabled();
    if (!servicestatus) {
      try {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Please Turn your GPS ON",
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 10),
          backgroundColor: Colors.red,
        ));
      } catch (e) {
        //
      }
      return;
    }
    if (await Geolocator.checkPermission() == LocationPermission.denied ||
        await Geolocator.checkPermission() ==
            LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Please enable location permission from settings",
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 10),
        backgroundColor: Colors.red,
      ));
      return;
    }
  }

  saveFetchedNotifications(fetchedNotifications) {
    this.fetchedNotifications.clear();
    this.fetchedNotifications.addAll(fetchedNotifications);
  }

  openDrawer() => scaffoldKey.currentState?.openDrawer();

  openUserProfileScreen() => _pageController
      .animateToPage(2,
          duration: const Duration(milliseconds: 150), curve: Curves.easeInQuad)
      .then((_) => setState(() => _currentPageIndex = 2));

  DateTime _lastPressedAt = DateTime.now();
  GlobalKey<HomePageState> homeKey = GlobalKey<HomePageState>();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentPageIndex != 0) {
          await _pageController.animateToPage(0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInQuad);
          setState(() => _currentPageIndex = 0);
          return false;
        }
        if (DateTime.now().difference(_lastPressedAt) >
            const Duration(seconds: 2)) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              "Press Back Again To Exit The App",
              textAlign: TextAlign.center,
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.black54,
          ));
          _lastPressedAt = DateTime.now();
          return false;
        }
        await FlutterAppMinimizer.minimize();
        return false;
      },
      child: Scaffold(
          key: scaffoldKey,
          drawer: CustomDrawer(
              openUserProfileScreen: openUserProfileScreen,
              currentScreen: AvailableDrawerScreens.dashboard),
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              HomePage(
                  key: homeKey,
                  openDrawer: openDrawer,
                  profileViewScreenOpener: openUserProfileScreen),
              NotificationsScreen(
                showlogoutpopup: false,
                openDrawer: openDrawer,
                saveFetchedNotifications: saveFetchedNotifications,
                fetchedNotifications: fetchedNotifications,
              ),
              UserProfile(
                openDrawer: openDrawer,
              ),
              NotificationsScreen(
                showlogoutpopup: true,
                openDrawer: openDrawer,
                saveFetchedNotifications: saveFetchedNotifications,
                fetchedNotifications: fetchedNotifications,
              ),
            ],
          ),
          bottomNavigationBar: SnakeNavigationBar.color(
            backgroundColor: const Color(0xff072a99),
            snakeShape: SnakeShape.indicator,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white,
            snakeViewColor: Colors.blueAccent,
            showSelectedLabels: true,
            currentIndex: _currentPageIndex,
            showUnselectedLabels: true,
            onTap: (index) => _pageController
                .animateToPage(index,
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeInQuad)
                .then((_) => setState(
                    () => _currentPageIndex = _pageController.page!.toInt())),
            items: [
              BottomNavigationBarItem(
                icon: _currentPageIndex == 0
                    ? const Icon(Icons.cottage)
                    : const Icon(Icons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                  icon: _currentPageIndex == 1
                      ? const Icon(Icons.notifications_active)
                      : const Icon(Icons.notifications),
                  label: "Notifications"),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: "Profile"),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.logout), label: "Logout"),
            ],
          )),
    );
  }

  @override
  dispose() {
    backgroundTrackingTimer?.cancel();
    locationStream?.cancel();
    FlutterBackground.disableBackgroundExecution();
    super.dispose();
  }
}
