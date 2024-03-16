import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:circular_countdown/circular_countdown.dart';
import 'package:ezhrm/bottombar_ios.dart/bottombar_ios.dart';
import 'package:ezhrm/drawer.dart';
import 'package:ezhrm/error_api.dart';
import 'package:ezhrm/login.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import 'attendance_records.dart';
import 'main.dart';
import 'constants.dart';
import 'camera_screen.dart';
import 'services/shared_preferences_singleton.dart';

class RequestAttendance extends StatefulWidget {
  const RequestAttendance({Key? key}) : super(key: key);

  @override
  State<RequestAttendance> createState() => _RequestAttendanceState();
}

class _RequestAttendanceState extends State<RequestAttendance> {
  // Keeping default longitude and latitude of 30Days Technology Office
  bool showLoadingSpinnerOnTop = false,
      attendanceloadingOverlay = false,
      showTodaysRecords = false,
      ableToSendRequest = goGreenModel!.canSendRequest!;
  Position? currentPosition;
  final Set<Marker> marker = {};
  final List attendanceRecordsList = [];
  GoogleMapController? _googleMapController;
  StreamSubscription? locationUpdateStream;
  Uint8List? imageBytes;
  String? messageOnScreen, attendanceRecordStatus;
  MapType mapType = MapType.normal;
  BuildContext? scaffoldContext;

  @override
  void initState() {
    fetchAttendanceRecords();
    checkGPSStatus();
    super.initState();
  }

  //-------------------START LOCATION FUNCTIONS---------------------------
  checkGPSStatus() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
    Map<Permission, PermissionStatus> permissions = await [
  Permission.location,
  Permission.storage,
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
    getCurrentLocation();
  }

  getCurrentLocation() async {
    var permission = await Geolocator.checkPermission();
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
    currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {});

    locationUpdateStream =
        Geolocator.getPositionStream(locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high
        ))
            .listen(updateLocationOnMap(currentPosition!));
  }

  updateLocationOnMap(Position positon) async {
    if (!mounted) return;
    setState(() {
      showLoadingSpinnerOnTop = true;
    });
    currentPosition = positon;
    setMarkerOnMap();
    await _googleMapController?.animateCamera(CameraUpdate.newCameraPosition(
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
    sendAttendanceRequestAPI();
  }

  //-------------------END IMAGE FUNCTIONS---------------------------

  //------------------ START API FUNCTIONS---------------------------

  sendAttendanceRequestAPI() async {
    if (!ableToSendRequest) return;
    if (currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Location not captured, please enable location",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      attendanceloadingOverlay = true;
    });
    try {
      var apiStartTime = DateTime.now();

      Map<String, String> body = {
        'type': 'mark',
        'uid': SharedPreferencesInstance.getString('uid') ?? "",
        'cid': SharedPreferencesInstance.getString('comp_id') ?? "",
        'device_id': SharedPreferencesInstance.getString('deviceid') ?? "",
        'lat': currentPosition!.latitude.toString(),
        'long': currentPosition!.longitude.toString(),
        'img_data': base64.encode(imageBytes!),
        'send_request': "1"
      };
      final response = await http.post(

        Uri.parse(
        "$customurl/controller/process/app/attendance_mark.php"),
        body: body,
        headers: <String, String>{
          'Accept': 'application/json',
        },
      );
      var apiEndTime = DateTime.now();

      var logBody = {
        'type': 'mark',
        'uid': SharedPreferencesInstance.getString('uid') ?? "",
        'cid': SharedPreferencesInstance.getString('comp_id') ?? "",
        'device_id': SharedPreferencesInstance.getString('deviceid') ?? "",
        'lat': currentPosition!.latitude.toString(),
        'long': currentPosition!.longitude.toString(),
        'img_data': "sent Data (Too Long To display)",
        'send_request': ableToSendRequest ? "1" : "0"
      };
      SharedPreferencesInstance.saveLogs(
        response.request!.url.toString(),
        json.encode(logBody),
        response.body,
        duration: apiEndTime.difference(apiStartTime).inSeconds,
        additionalInfo: "image size is ${imageBytes!.length / 1000}kB",
      );
      log(response.body);
      Map data = json.decode(response.body);
      log(data.toString());
      setState(() {
        attendanceloadingOverlay = false;
      });

      if (!data.containsKey("code")) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Error Occured"),
          backgroundColor: Color(0xAAF44336),
          behavior: SnackBarBehavior.floating,
        ));
        return;
      }

      switch (data["code"].toString()) {
        case "1001":
          return code1001(data);
        case "1002":
          return code1002(data);
        default:
      }

      // logouts if code is not equal to 1001 or 1002
      await SharedPreferencesInstance.logOut();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Invalid Device"), backgroundColor: Colors.red));
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const Login(),
          ),
          (route) => false);
    } catch (e) {
      setState(() {
        attendanceloadingOverlay = false;
      });
      SharedPreferencesInstance.saveError(e.toString());
      ErrorAPI.errorOccuredAPI(
        e.toString(),
        url: "$customurl/controller/process/app/attendance_mark.php",
        body: {
          'type': 'mark',
          'uid': SharedPreferencesInstance.getString('uid') ?? "",
          'cid': SharedPreferencesInstance.getString('comp_id') ?? "",
          'device_id': SharedPreferencesInstance.getString('deviceid') ?? "",
          'lat': currentPosition!.latitude.toString(),
          'long': currentPosition!.longitude.toString(),
          'img_data': "w",
          'send_request': "1"
        }.toString(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Error Occured, Try Again",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Color(0xFFF44336),
        ),
      );
    }
  }

  code1001(data) async {
    if (data["status"].toString() == "true") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Sent Request to Admin",
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
              title: const Text(
                "Error Occured",
                style: TextStyle(color: Colors.red),
              ),
              content: Text(data["msg"]),
              actions: [
                TextButton(
                  child: const Text("Try Again"),
                  onPressed: Navigator.of(context).pop,
                  style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all(const Color(0xff072a99))),
                ),
              ],
            ));
  }

  code1002(data) async {
    if (!ableToSendRequest) return;
    bool sendRequest = await showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: const Text(
                    "Error Occured",
                    style: TextStyle(color: Colors.red),
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
    if (!sendRequest) return;
    sendAttendanceRequestAPI();
  }

  fetchAttendanceRecords() async {
    final response = await http
        .post(
          
          Uri.parse(
          "$customurl/controller/process/app/attendance.php"), body: {
      'type': 'get_att_fetch',
      'cid': SharedPreferencesInstance.getString('comp_id'),
      'uid': SharedPreferencesInstance.getString('uid'),
    }, headers: <String, String>{
      'Accept': 'application/json',
    });
    var data = json.decode(response.body);
    String status = data['status']?.toString() ?? "";
    if (status != "true") {
      checkGPSStatus();
      return;
    }
    attendanceRecordsList.clear();
    attendanceRecordsList.addAll(data["data"]);
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
    if (!clickedOnProceed) return Navigator.pop(context);
  }

  //------------------ END API FUNCTIONS---------------------------

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    scaffoldContext = context;
    return Scaffold(
      bottomNavigationBar: const bottombar_ios(),
      key: scaffoldKey,
      drawer: const CustomDrawer(
        currentScreen: AvailableDrawerScreens.requestAttendance,
      ),
      body: Stack(
        children: [
          ableToSendRequest
              ? currentPosition != null
                  ? GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(currentPosition!.latitude,
                            currentPosition!.longitude),
                        zoom: 18,
                      ),
                      mapType: mapType,
                      markers: marker,
                      onMapCreated: (controller) async {
                        _googleMapController = controller;
                        if (currentPosition != null) {
                          await _googleMapController
                              ?.animateCamera(CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(
                                currentPosition!.latitude,
                                currentPosition!.longitude,
                              ),
                              zoom: 18,
                            ),
                          ));
                        }
                      },
                      mapToolbarEnabled: true,
                      compassEnabled: true,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                    )
                  : Center(
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
              : const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "You are not allowed to send attendance request, please contact Admin",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
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
                        MapButton(Icons.menu,
                            onTap: scaffoldKey.currentState?.openDrawer),
                        const Spacer(),
                        if (showLoadingSpinnerOnTop)
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
                        if (ableToSendRequest)
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
                                    desiredAccuracy: LocationAccuracy.high,
                                  )),
                                ),
                              ],
                            ),
                      ],
                    ),
                  ),
                  if (ableToSendRequest)
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Hero(
                              tag: "The Button",
                              child: currentPosition != null
                                  ? ElevatedButton(
                                      onPressed: () async {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CameraScreen(
                                                callBack: getImage,
                                                imageSizeShouldBeLessThan200kB:
                                                    true),
                                          ),
                                        );
                                      },
                                      child: const Text("Request Attendance"),
                                      style: ButtonStyle(
                                        padding: MaterialStateProperty.all(
                                            const EdgeInsets.all(15)),
                                        shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10))),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                          const Color(0xff072a99),
                                        ),
                                        elevation: MaterialStateProperty.all(8),
                                      ),
                                    )
                                  : const SizedBox(),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          if (attendanceloadingOverlay)
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
    );
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    locationUpdateStream?.cancel();
    super.dispose();
  }
}
