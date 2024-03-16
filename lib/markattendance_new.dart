import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:circular_countdown/circular_countdown.dart';
import 'package:ezhrm/bottombar_ios.dart/bottombar_ios.dart';
import 'package:ezhrm/error_api.dart';
import 'package:ezhrm/login.dart';
import 'package:ezhrm/drawer.dart';
import 'package:ezhrm/main.dart';
import 'package:flutter/material.dart';
import 'package:ezhrm/uploadimg_new.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'camera_screen.dart';
import 'attendance_records.dart';
import 'services/shared_preferences_singleton.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({Key? key}) : super(key: key);
  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  bool? showLoadingSpinnerOnTop = false,
      attendanceloadingOverlay = false,
      checkInButtonLoading = false,
      showTodaysRecords = false,
      showOutOfRangeButton = false,
      imageRequired = goGreenModel!.faceRecognitionEnabled,
      locationRequired = goGreenModel!.locationEnabled,
      ableToSendRequest = goGreenModel!.canSendRequest;
  Position? currentPosition;
  final Set<Marker> marker = {};
  final List attendanceRecordsList = [];
  GoogleMapController? _googleMapController;
  StreamSubscription? locationUpdateStream;
  Uint8List? imageBytes;
  String? messageOnScreen, attendanceRecordStatus;
  MapType mapType = MapType.normal;
  BuildContext? scaffoldContext;
  String attendancerequestreason = "No Reason in Starting";
  StreamSubscription? locationStream;
  final int? intervalInMiliSeconds = goGreenModel!.backgroundLocationInterval;
  Timer? backgroundTrackingTimer;
  Timer? stopTrackingTimer;
  Timer? timer;

  @override
  void initState() {
    checkGPSStatus();
    checklocationpermission();

    // startlocationstream();
    attendancerequestreason = "No Reason in Starting";
    super.initState();
  }

  checklocationpermission() async {
    log("check permission");
    var permission = await Geolocator.checkPermission();
    log("Permission Status : " + permission.toString());
    if (permission != LocationPermission.always) {
      permission = await Geolocator.requestPermission();
    }
  }

  startlocationstream() async {
    log("start location stream");
    if (goGreenModel!.locationEnabled! ||
        goGreenModel!.backgroundLocationTrackingEnabled!) {
      log("getting location");
      currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      log(currentPosition.toString());
      log(currentPosition!.accuracy.toString());
      locationStream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      ).listen((data) {
        currentPosition = data;
      });

      timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
        if (currentPosition != null) {
          if (timer.isActive) {
            timer.cancel();
          }
          fetchAttendanceRecords();
        }
      });
    }
  }

  startlocationstream2() async {
    await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      // forceAndroidLocationManager: true
    );

    locationStream = Geolocator.getPositionStream(
            locationSettings: LocationSettings(accuracy: LocationAccuracy.high)
            // forceAndroidLocationManager: true
            )
        .listen((data) {
      currentPosition = data;
    });
  }

  // checkinternet() async {
  //   if (await DataConnectionChecker().hasConnection) {
  //     log("Has Internet Connection");
  //   } else {
  //     log("No Internet Connection");
  //     NotificationDetails platformChannelSpecifics = NotificationDetails(
  //         android: NotificationService().androidPlatformChannelSpecifics);

  //     await NotificationService().flutterLocalNotificationsPlugin.show(
  //         1234,
  //         "No Internet Connection",
  //         "Please enable your internet connection for location tracking.",
  //         platformChannelSpecifics);
  //   }
  // }

  Future<bool> backgroundServicesStartAndroid() async =>
      await FlutterBackground.initialize(
        androidConfig: const FlutterBackgroundAndroidConfig(
          notificationTitle: "Running in Background",
          notificationImportance: AndroidNotificationImportance.Max,
          notificationText: "Your Location is being updated in background.",
        ),
      );

  startBackgroundTrackingAndroid() async {
    var shiftendtime = await SharedPreferencesInstance.getString("shiftend");
    shiftendtime = shiftendtime.replaceAll(":", "");

    log("Checking background location...");
    var shiftendingtime = int.parse(shiftendtime.toString());
    var currenttime =
        int.parse(DateFormat('HHmm').format(DateTime.now()).toString());
    log("Current Time : " + currenttime.toString());
    log("Flutter Background Enabled : " +
        FlutterBackground.isBackgroundExecutionEnabled.toString());
    log("Shift End Time : " + shiftendingtime.toString());

    log("Current Position : " + currentPosition.toString());
    if (currenttime < shiftendingtime) {
      await backgroundServicesStartAndroid();
      await FlutterBackground.enableBackgroundExecution();
    } else {}

    if (currenttime < shiftendingtime) {
      await sendBackgroundLocation();
    } else {}

    startlocationstream2();

    backgroundTrackingTimer = Timer.periodic(
        Duration(milliseconds: intervalInMiliSeconds!), (_) async {
      if (currenttime < shiftendingtime) {
        await sendBackgroundLocation();
      } else {}
    });

    // checkInternetTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
    //   if (currenttime < shiftendingtime) {
    //     await checkinternet();
    //   } else {}
    // });

    stopTrackingTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) async {
        stopbackgroundlocationONcheckoutAndroid();
      },
    );
  }

  startBackgroundTrackingIOS() async {}

  stopbackgroundlocationONcheckoutAndroid() async {
    var shiftendtime = await SharedPreferencesInstance.getString("shiftend");
    shiftendtime = shiftendtime.replaceAll(":", "");

    log("Checking background location...");
    var shiftendingtime = int.parse(shiftendtime.toString());
    var currenttime =
        int.parse(DateFormat('HHmm').format(DateTime.now()).toString());
    log("Current Time : " + currenttime.toString());
    log("Flutter Background Enabled : " +
        FlutterBackground.isBackgroundExecutionEnabled.toString());
    log("Shift End Time : " + shiftendingtime.toString());

    if (FlutterBackground.isBackgroundExecutionEnabled.toString() == "true") {
      if (currenttime >= shiftendingtime) {
        sendBackgroundLocation();
        NotificationDetails platformChannelSpecifics = NotificationDetails(
            android: NotificationService().androidPlatformChannelSpecifics);

        await NotificationService().flutterLocalNotificationsPlugin.show(
            1234,
            "Location Tracking..",
            "Your tracking has been stopped for the day.",
            platformChannelSpecifics);

        log("Disabling Background Execution...");
        log("Flutter Background Enabled : " +
            FlutterBackground.isBackgroundExecutionEnabled.toString());
        if (backgroundTrackingTimer!.isActive) {
          backgroundTrackingTimer!.cancel();
          log("Timer 1 " + backgroundTrackingTimer!.isActive.toString());
        }

        if (stopTrackingTimer!.isActive) {
          stopTrackingTimer!.cancel();
          log("Timer 3 " + stopTrackingTimer!.isActive.toString());
        }
        // backgroundTrackingTimer.cancel();
        // checkInternetTimer.cancel();
        // stopTrackingTimer.cancel();
        await FlutterBackground.disableBackgroundExecution();
      }
    }
  }

  sendBackgroundLocation() async {
    var response = await http.post(
        Uri.parse("$customurl/controller/process/app/location_track.php"),
        body: {
          'uid': SharedPreferencesInstance.getString('uid') ?? "",
          'cid': SharedPreferencesInstance.getString('comp_id') ?? "",
          'type': 'add_loc',
          'lat': currentPosition!.latitude.toString() ?? "",
          'long': currentPosition!.longitude.toString() ?? "",
        },
        headers: <String, String>{
          'Accept': 'application/json',
        });
    log("Location Updating in Background : " +
        response.body +
        DateTime.now().toString());
  }

  casesWorkflows() async {
    if (!locationRequired! && imageRequired!) {
      return Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(
            callBack: getImage,
            imageSizeShouldBeLessThan200kB: true,
          ),
        ),
      );
    }
  }

  //-------------------START LOCATION FUNCTIONS---------------------------
  checkGPSStatus() async {
    if (!locationRequired! &&
        !goGreenModel!.backgroundLocationTrackingEnabled!) {
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      Map<Permission, PermissionStatus> permissions = await [
        Permission.location,
        Permission.locationWhenInUse,
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
        Navigator.pop(context);
        return;
      }
    }
    if (!(permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always)) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Please Goto Settings and give Location Permission",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
      ));
      Navigator.pop(context);
      return;
    }
    var locationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Please Turn your GPS ON",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ));
      }
      Navigator.pop(context);
      return;
    }
    startlocationstream();
    startLocationStreaming();
  }

  startLocationStreaming() async {
    updateLocationOnMap(await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      // forceAndroidLocationManager: true
    ));
    locationUpdateStream = Geolocator.getPositionStream(
            locationSettings: LocationSettings(accuracy: LocationAccuracy.high)
            // forceAndroidLocationManager: true
            )
        .listen(updateLocationOnMap(currentPosition!));
    await Future.delayed(const Duration(seconds: 10));
    if (mounted && currentPosition == null) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const MarkAttendanceScreen()));
    }
  }

  markattendancedirect() async {
    SharedPreferences preferencecuid = await SharedPreferences.getInstance();
    try {
      var uri = "$customurl/controller/process/app/attendance.php";
      final response = await http.post(Uri.parse(uri), body: {
        'type': '_mark',
        'cid': preferencecuid.getString('comp_id'),
        'uid': preferencecuid.getString('uid'),
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      var data = json.decode(response.body);
      log("Mark Attendance Direct : " + data.toString());
      fetchAttendanceRecords();

      if (data['status'] == true) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "${data['msg']}",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.green,
        ));
      } else if (data['status'] == false) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "${data['msg']}",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.red,
        ));
      } else if (data['status'] != false || data['status'] != true) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Problem in marking your attendance please contact to admin",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.red,
        ));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Unable to process your request at this time",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<bool> checkUserLocationValidity() async {
    showCheckInButtonLoading(true);
    try {
      var response = await http.post(
          Uri.parse("$customurl/controller/process/app/attendance_mark.php"),
          body: {
            'type': 'verify_location',
            'uid': SharedPreferencesInstance.getString('uid') ?? "",
            'cid': SharedPreferencesInstance.getString('comp_id') ?? "",
            'lat':
                locationRequired! ? currentPosition!.latitude.toString() : "",
            'long':
                locationRequired! ? currentPosition!.longitude.toString() : "",
          });
      log("Data we sending in Verify Location : " +
          {
            'type': 'verify_location',
            'uid': SharedPreferencesInstance.getString('uid') ?? "",
            'cid': SharedPreferencesInstance.getString('comp_id') ?? "",
            'lat':
                locationRequired! ? currentPosition!.latitude.toString() : "",
            'long':
                locationRequired! ? currentPosition!.longitude.toString() : "",
          }.toString());
      var responseBody = json.decode(response.body);
      log("Location Response :" + responseBody.toString());
      showOutOfRangeButton = responseBody['status'].toString() != "true";
      showCheckInButtonLoading(false);
      if (showOutOfRangeButton!) {
        attendancerequestreason = "Out of Range";
        locationOutOfRangeDialog();
      }
      return !showOutOfRangeButton!;
    } catch (e) {
      log(e.toString());
      showCheckInButtonLoading(false);
    }
    return false;
  }

  updateLocationOnMap(Position positon) async {
    currentPosition = positon;
    if (!mounted) return;

    setState(() {
      showLoadingSpinnerOnTop = true;
    });
    setMarkerOnMap();

    await _googleMapController!.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(currentPosition!.latitude, currentPosition!.longitude),
        zoom: 18,
      ),
    ));
  }

  setMarkerOnMap() => setState(
        () {
          marker.clear();
          marker.add(Marker(
            markerId: MarkerId("User Location"),
            infoWindow: const InfoWindow(
                title: "This Location will be used for attendance"),
            visible: true,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            position:
                LatLng(currentPosition!.latitude, currentPosition!.longitude),
          ));
          showLoadingSpinnerOnTop = false;
        },
      );

  changeMapType() => setState(() {
        mapType =
            mapType == MapType.normal ? MapType.satellite : MapType.normal;
      });

  shareLocation() => Share.share(
        'Hello Sir!\n'
        '${SharedPreferencesInstance.getString('username')} this side.\n'
        'I am sharing my current working location. Please add it in HRM software, so that i can Mark my Attendance from Here.\nEmployee ID: ${SharedPreferencesInstance.getString('empid')}\nLatitude: ${currentPosition!.latitude}\nLongitude: ${currentPosition!.longitude} ',
      );

  //-------------------END LOCATION FUNCTIONS---------------------------

  //------------------ START IMAGE FUNCTIONS---------------------------

  getImage(Uint8List imageBytes) {
    this.imageBytes = imageBytes;
    // log('length of png image bytes ${imageBytes.length / 1000}kB');
    // log('length of base64 bytes ${base64.encode(imageBytes).length / 1000}kB');
    // log('length of jpeg bytes ${image.encodeJpg(image.decodeImage(imageBytes), quality: 50).length / 1000}kB');
    faceRecogAPI();
  }

  //-------------------END IMAGE FUNCTIONS---------------------------

  //------------------ START API FUNCTIONS---------------------------

  faceRecogAPI() async {
    var apiStart = DateTime.now();
    showProcessingOverlay(true);
    try {
      final tokenResponse = await http.post(
        Uri.parse("$customurl/controller/process/app/attendance_mark.php"),
        body: {
          'type': 'face_token',
          'uid': SharedPreferencesInstance.getString('uid') ?? "",
          'cid': SharedPreferencesInstance.getString('comp_id') ?? "",
        },
        headers: <String, String>{
          'Accept': 'application/json',
        },
      );
      var token = json.decode(tokenResponse.body)['token'];
      log("Token : " + token.toString());
      // FACE RECOG REQUEST
      var request = http.MultipartRequest(
        "POST",
        Uri.parse(
            "http://164.52.223.146/verify?model_name=Facenet&distance_metric=cosine"),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.fields.addAll({
        'employee_id': SharedPreferencesInstance.getString('uid') ?? "",
        'company_id': SharedPreferencesInstance.getString('comp_id') ?? "",
      });
      Directory cacheDirectory = await getTemporaryDirectory();
      File file = await File(cacheDirectory.path +
              "/${DateTime.now().millisecondsSinceEpoch}.png")
          .writeAsBytes(imageBytes!);
      request.files
          .add(await http.MultipartFile.fromPath('image_file', file.path));
      var response = await http.Response.fromStream(await request.send());
      var apiEnd = DateTime.now();
      SharedPreferencesInstance.saveLogs(
          "both token + face recog", json.encode(request.fields), response.body,
          duration: apiEnd.difference(apiStart).inSeconds,
          additionalInfo:
              "image bytes in kb is ${imageBytes!.length / 1000}kB");
      log("Face distance : " +
          json.decode(response.body)["distance"].toString());
      await markAttendanceAPI(
          faceDistance: json.decode(response.body)["distance"].toString());
    } catch (e) {
      log("Error : " + e.toString());
      showProcessingOverlay(false);
      SharedPreferencesInstance.saveError(e.toString());
      ErrorAPI.errorOccuredAPI(
        e.toString(),
        url: "$customurl/controller/process/app/attendance_mark.php",
        body: {
          'type': 'face_token',
          'uid': SharedPreferencesInstance.getString('uid') ?? "",
          'cid': SharedPreferencesInstance.getString('comp_id') ?? "",
        }.toString(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Error Occured, Try Again",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  markAttendanceAPI(
      {bool sendRequest = false, String faceDistance = ""}) async {
    if (sendRequest && !ableToSendRequest!) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Cannot Send Request",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
      showProcessingOverlay(false);
      return;
    }
    if (currentPosition == null && locationRequired!) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Location not captured, please try again",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
      SharedPreferencesInstance.saveError(
          "location Enabled: ${await Geolocator.isLocationServiceEnabled()} location Not captured");
      showProcessingOverlay(false);
      return;
    }
    showProcessingOverlay(true);

    try {
      var apiStartTime = DateTime.now();
      Map body = {
        'type': 'mark_attendance',
        'uid': SharedPreferencesInstance.getString('uid') ?? "",
        'cid': SharedPreferencesInstance.getString('comp_id') ?? "",
        'device_id': SharedPreferencesInstance.getString('deviceid') ?? "",
        'lat': locationRequired! ? currentPosition!.latitude.toString() : "",
        'long': locationRequired! ? currentPosition!.longitude.toString() : "",
        'face_distance': faceDistance ?? "0",
        'img_data': sendRequest ? base64.encode(imageBytes!) : "",
        'send_request': ableToSendRequest! && sendRequest ? "1" : "0",
        'message':
            ableToSendRequest! && sendRequest ? attendancerequestreason : "",
      };
      final response = await http.post(
        Uri.parse("$customurl/controller/process/app/attendance_mark.php"),
        body: body,
        headers: <String, String>{
          'Accept': 'application/json',
        },
      );
      var apiEndTime = DateTime.now();
      var logBody = {
        'type': 'mark_attendance',
        'uid': SharedPreferencesInstance.getString('uid') ?? "",
        'cid': SharedPreferencesInstance.getString('comp_id') ?? "",
        'device_id': SharedPreferencesInstance.getString('deviceid') ?? "",
        'lat': locationRequired! ? currentPosition!.latitude.toString() : "",
        'long': locationRequired! ? currentPosition!.longitude.toString() : "",
        'face_distance': faceDistance,
        'img_data': imageRequired! ? "sent Data (Too Long To display)" : "",
        'send_request': ableToSendRequest! && sendRequest ? "1" : "0",
        'message':
            ableToSendRequest! && sendRequest ? attendancerequestreason : "",
      };
      SharedPreferencesInstance.saveLogs(
        response.request!.url.toString(),
        json.encode(logBody),
        response.body,
        duration: apiEndTime.difference(apiStartTime).inSeconds,
      );
      Map data = json.decode(response.body);
      log("Mark attendance Response : " + data.toString());
      showProcessingOverlay(false);

      if (!data.containsKey("code")) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Error Occured"),
          backgroundColor: Colors.red,
        ));
        return;
      }

      switch (data["code"].toString()) {
        case "1001":
          return code1001(data, sendRequest);
        case "1002":
          return code1002(data);
        case "1003":
          return code1003(data);
      }

      // logouts if code is not equal to 1001 or 1002 or 1003
      await SharedPreferencesInstance.logOut();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Invalid Device"),
        backgroundColor: Color(0xAAF44336),
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const Login(),
          ),
          (route) => false);
    } catch (e) {
      log(e.toString());
      showProcessingOverlay(false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Error Occured, Try Again",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  code1001(data, bool sendRequestType) async {
    if (data["status"].toString() == "true") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: sendRequestType
            ? const Text(
                "Request Sent successfully",
                textAlign: TextAlign.center,
              )
            : const Text(
                "Attendance Marked successfully",
                textAlign: TextAlign.center,
              ),
        backgroundColor: Colors.green,
      ));
      fetchAttendanceRecords();
      return;
    }
    await showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(
                data["msg"].toString() == "Face not matched, Please try again"
                    ? "Face not matched"
                    : "Out of range",
                style: const TextStyle(color: Colors.red),
              ),
              content: Text(data["msg"]),
              actions: [
                TextButton(
                  child: const Text("Try Again"),
                  onPressed: Navigator.of(context).pop,
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(
                      const Color(0xff072a99),
                    ),
                  ),
                ),
              ],
            ));
  }

  code1002(data) async {
    attendancerequestreason = "Face Not Matched";

    if (!ableToSendRequest!) return;
    bool selectedSendRequest = await showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: Text(
                    data["msg"].toString() ==
                            "Face not matched, Do you want to send attendance request"
                        ? "Face not matched"
                        : "Out of Range",
                    style: const TextStyle(color: Colors.red),
                  ),
                  content: Text(data['msg']),
                  actions: [
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: Navigator.of(context).pop,
                      style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(
                              const Color(0xff072a99))),
                    ),
                    TextButton(
                      child: const Text("Send Request"),
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(
                              const Color(0xff072a99))),
                    ),
                  ],
                )) ??
        false;
    if (!selectedSendRequest) return;
    markAttendanceAPI(sendRequest: true);
  }

  code1003(data) async {
    attendancerequestreason = "Face Images Not Uploaded";
    bool selectedSendRequest = await showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: const Text(
                    "Face Images Not Uploaded",
                    style: TextStyle(color: Colors.red),
                  ),
                  content: Text(data["msg"]),
                  actions: [
                    TextButton(
                      child: const Text("Send Request"),
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(
                          const Color(0xff072a99),
                        ),
                      ),
                    ),
                    TextButton(
                      child: const Text("Upload Images"),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const UploadImg()),
                            (route) => route.isFirst);
                      },
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(
                          const Color(0xff072a99),
                        ),
                      ),
                    ),
                  ],
                )) ??
        false;
    if (!selectedSendRequest) return;
    markAttendanceAPI(sendRequest: true);
  }

  fetchAttendanceRecords() async {
    final response = await http.post(
        Uri.parse("$customurl/controller/process/app/attendance.php"),
        body: {
          'type': 'get_att_fetch',
          'cid': SharedPreferencesInstance.getString('comp_id'),
          'uid': SharedPreferencesInstance.getString('uid'),
        },
        headers: <String, String>{
          'Accept': 'application/json',
        });
    var data = json.decode(response.body);
    log("Attendance Records :" + data.toString());

    String status = data['status']?.toString() ?? "";
    if (status != "true") {
      casesWorkflows();
      return;
    }
    attendanceRecordsList.clear();
    attendanceRecordsList.addAll(data["data"]);
    log("Attendance Record List :" + attendanceRecordsList.toString());
    if (attendanceRecordsList.isNotEmpty) {
      if (goGreenModel!.backgroundLocationTrackingEnabled!) {
        if (Platform.isAndroid) {
          if (FlutterBackground.isBackgroundExecutionEnabled) {
            log("Background Location already Enabled...");
          } else {
            log("Starting background service...");

            var shiftendtime =
                await SharedPreferencesInstance.getString("shiftend");
            shiftendtime = shiftendtime.replaceAll(":", "");

            log("Checking background location...");
            var shiftendingtime = int.parse(shiftendtime.toString());
            var currenttime =
                int.parse(DateFormat('HHmm').format(DateTime.now()).toString());
            log("Current Time : " + currenttime.toString());
            log("Flutter Background Enabled : " +
                FlutterBackground.isBackgroundExecutionEnabled.toString());
            log("Shift End Time : " + shiftendingtime.toString());

            log("Current Position : " + currentPosition.toString());
            if (currenttime < shiftendingtime) {
              startBackgroundTrackingAndroid();
            } else {
              log("Dont initialize Tracking in background");
            }
          }
        } else {
          startBackgroundTrackingIOS();
        }
      }
      log("Attendance Records Present");
    }
    String creditStatus = data["credit"].toString();
    attendanceRecordStatus = creditStatus == "3"
        ? "Full Day"
        : creditStatus == "4"
            ? "Half Day"
            : creditStatus == "7"
                ? "Submitted"
                : "Pending";
    setState(() {});
    if (attendanceRecordsList.isEmpty) {
      casesWorkflows();
      return;
    }
    bool clickedOnProceed = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
                builder: (_) => AttendanceRecordScreen(
                      attendanceRecordsList,
                      attendanceRecordStatus!,
                      openedDirectly: true,
                    ))) ??
        false;
    log("Click on proceed : " + clickedOnProceed.toString());

    if (!clickedOnProceed) return Navigator.pop(context);
    casesWorkflows();
  }

  //------------------ END API FUNCTIONS---------------------------

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  showProcessingOverlay(bool value) {
    setState(() {
      attendanceloadingOverlay = value;
    });
  }

  showCheckInButtonLoading(bool value) {
    setState(() {
      checkInButtonLoading = value;
    });
  }

  locationOutOfRangeDialog() async {
    bool sendRequestSelected = await showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: const Text(
                    "Out of Range",
                    style: TextStyle(color: Colors.red),
                  ),
                  content: RichText(
                      text: const TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 16),
                          children: [
                        TextSpan(
                            text: "Sorry! Out of Range\n",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: "Do you want to send request to admin?")
                      ])),
                  actions: [
                    TextButton(
                      child: const Text("Try Again"),
                      onPressed: () async {
                        Navigator.pop(context);
                        if (locationRequired!) {
                          if (currentPosition == null) {
                            toast("please wait..");

                            // currentPosition =
                            //     await Geolocator.getLastKnownPosition(
                            //         forceAndroidLocationManager: true);
                            setState(() {});
                          } else {
                            if (locationRequired!) {
                              var value = await checkUserLocationValidity();
                              if (!value) return;
                            }

                            if (imageRequired!) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CameraScreen(
                                    callBack: getImage,
                                    imageSizeShouldBeLessThan200kB: true,
                                  ),
                                ),
                              );
                            } else {
                              markAttendanceAPI();
                            }
                          }
                        } else {
                          if (imageRequired!) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CameraScreen(
                                  callBack: getImage,
                                  imageSizeShouldBeLessThan200kB: true,
                                ),
                              ),
                            );
                          }
                        }
                      },
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(
                          const Color(0xff072a99),
                        ),
                      ),
                    ),
                    TextButton(
                      child: const Text("Send Request"),
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(
                          const Color(0xff072a99),
                        ),
                      ),
                    ),
                  ],
                )) ??
        false;
    if (sendRequestSelected) {
      imageBytes = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CameraScreen(
            imageSizeShouldBeLessThan200kB: true,
          ),
        ),
      );
      if (imageBytes == null) return;
      markAttendanceAPI(sendRequest: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    scaffoldContext = context;
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: const bottombar_ios(),
        key: scaffoldKey,
        drawer: const CustomDrawer(
            currentScreen: AvailableDrawerScreens.markAttendance),
        body: Stack(
          children: [
            if (locationRequired!)
              currentPosition == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TimeCircularCountdown(
                            textStyle: const TextStyle(
                                color: themecolor,
                                fontWeight: FontWeight.w500,
                                fontSize: 15),
                            repeat: true,
                            diameter: 100.0,
                            countdownTotalColor: themecolor,
                            countdownRemainingColor:
                                themecolor.withOpacity(0.20),
                            unit: CountdownUnit.second,
                            countdownTotal: 10,
                            onUpdated: (unit, remainingTime) =>
                                log('Countdown '),
                            onFinished: () => log('Countdown finished'),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Fetching Location",
                            style: TextStyle(
                              color: Color(0xff072a99),
                            ),
                          ),
                        ],
                      ),
                    )
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          currentPosition!.latitude,
                          currentPosition!.longitude,
                        ),
                        zoom: 18,
                      ),
                      mapType: mapType,
                      markers: marker,
                      onMapCreated: (controller) async {
                        _googleMapController = controller;
                        if (!locationRequired!) return;
                        await _googleMapController!
                            .animateCamera(CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(
                              currentPosition!.latitude,
                              currentPosition!.longitude,
                            ),
                            zoom: 18,
                          ),
                        ));
                      },
                      mapToolbarEnabled: true,
                      compassEnabled: true,
                      myLocationEnabled: locationRequired!,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: false,
                    ),
            if (!locationRequired!)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "To submit your attendance, please click on the button below",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            SafeArea(
              child: SizedBox.expand(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          MapButton(
                            Icons.menu,
                            onTap: scaffoldKey.currentState?.openDrawer,
                          ),
                          const Spacer(),
                          if (showLoadingSpinnerOnTop!)
                            Container(
                              width: 34,
                              height: 34,
                              padding: const EdgeInsets.all(4),
                              margin: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                  color: Color(0xff072a99),
                                  shape: BoxShape.circle),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          if (attendanceRecordsList.isNotEmpty)
                            if (currentPosition != null)
                              MapButton(
                                Icons.how_to_reg,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AttendanceRecordScreen(
                                        attendanceRecordsList,
                                        attendanceRecordStatus!,
                                      ),
                                    ),
                                  );
                                },
                              ),
                          if (locationRequired!)
                            if (currentPosition != null)
                              Row(
                                children: [
                                  MapButton(
                                    Icons.share,
                                    onTap: shareLocation,
                                  ),
                                  MapButton(
                                    mapType == MapType.satellite
                                        ? Icons.apartment
                                        : Icons.map,
                                    onTap: changeMapType,
                                  ),
                                  MapButton(
                                    Icons.my_location_sharp,
                                    onTap: () async => updateLocationOnMap(
                                        await Geolocator.getCurrentPosition(
                                      // forceAndroidLocationManager: true,
                                      desiredAccuracy: LocationAccuracy.high,
                                    )),
                                  ),
                                ],
                              ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: checkInButtonLoading!
                                ? CircleAvatar(
                                    radius: 22,
                                    backgroundColor: const Color(0xff072a99),
                                    child: LoadingAnimationWidget
                                        .threeRotatingDots(
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  )
                                : showOutOfRangeButton!
                                    ? IntrinsicHeight(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Hero(
                                                tag: "The Button",
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    locationOutOfRangeDialog();
                                                  },
                                                  child: const Text(
                                                      "Location is out of Range"),
                                                  style: ButtonStyle(
                                                    padding:
                                                        MaterialStateProperty
                                                            .all(
                                                                const EdgeInsets
                                                                    .all(15)),
                                                    shape: MaterialStateProperty
                                                        .all(RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10))),
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(
                                                      Colors.red,
                                                    ),
                                                    elevation:
                                                        MaterialStateProperty
                                                            .all(8),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // const SizedBox(width: 8),
                                            // Container(
                                            //   decoration: BoxDecoration(
                                            //     borderRadius:
                                            //         BorderRadius.circular(8),
                                            //     color: Colors.white,
                                            //   ),
                                            //   width: MediaQuery.of(context)
                                            //           .size
                                            //           .width *
                                            //       0.2,
                                            //   child: Column(
                                            //     mainAxisAlignment:
                                            //         MainAxisAlignment.center,
                                            //     children: [
                                            //       GestureDetector(
                                            //         onTap:
                                            //             checkUserLocationValidity,
                                            //         child: const Icon(
                                            //           Icons.refresh,
                                            //           size: 26,
                                            //           color: Color(0xff072a99),
                                            //         ),
                                            //       ),
                                            //     ],
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      )
                                    : Hero(
                                        tag: "The Button",
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            if (locationRequired!) {
                                              if (currentPosition == null) {
                                                toast("please wait..");

                                                // currentPosition = await Geolocator
                                                //     .getLastKnownPosition(
                                                //         forceAndroidLocationManager:
                                                //             true);

                                                setState(() {});
                                              } else {
                                                if (locationRequired!) {
                                                  var value =
                                                      await checkUserLocationValidity();
                                                  if (!value) return;
                                                }

                                                if (imageRequired!) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          CameraScreen(
                                                        callBack: getImage,
                                                        imageSizeShouldBeLessThan200kB:
                                                            true,
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  markAttendanceAPI();
                                                }
                                              }
                                            } else {
                                              if (imageRequired!) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        CameraScreen(
                                                      callBack: getImage,
                                                      imageSizeShouldBeLessThan200kB:
                                                          true,
                                                    ),
                                                  ),
                                                );
                                              }
                                            }

                                            if (!locationRequired! &&
                                                !imageRequired!) {
                                              markattendancedirect();
                                            }
                                          },
                                          child: attendanceRecordStatus ==
                                                  "Submitted"
                                              ? const Text("Check Out")
                                              : const Text("Check In"),
                                          style: ButtonStyle(
                                            padding: MaterialStateProperty.all(
                                                const EdgeInsets.all(15)),
                                            shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10))),
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                              const Color(0xff072a99),
                                            ),
                                            elevation:
                                                MaterialStateProperty.all(8),
                                          ),
                                        )),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (attendanceloadingOverlay!)
              SizedBox.expand(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LoadingAnimationWidget.threeRotatingDots(
                        color: Colors.white70,
                        size: 60,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(messageOnScreen ?? "Processing",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            )),
                      )
                    ],
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xcc072a99),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
