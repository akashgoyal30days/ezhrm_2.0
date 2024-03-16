import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:ezhrm/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:getwidget/types/gf_loader_type.dart';
import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main.dart';
import 'holiday.dart';
import 'constants.dart';
import 'applyleave.dart';
import 'leavestatus.dart';
import 'markattendance_new.dart';
import 'attendance_history_new.dart';
import 'request_attendance_new.dart';
import 'services/shared_preferences_singleton.dart';

class HomePage extends StatefulWidget {
  const HomePage({this.profileViewScreenOpener, Key? key, this.openDrawer})
      : super(key: key);
  final VoidCallback? profileViewScreenOpener, openDrawer;
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List Marketplacedata = [];
  String? username,
      email,
      ppic,
      ppic2,
      uid,
      cid,
      mymgmt,
      locacc,
      freco,
      attreq,
      attlocat;
  showlogoutdailog() {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              actionsAlignment: MainAxisAlignment.end,
              titlePadding: const EdgeInsets.all(20),
              actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              elevation: 10,
              title: const Text(
                "Are you sure you want to logout?",
                style: TextStyle(fontSize: 15),
              ),
              actions: [
                MaterialButton(
                    textColor: Colors.white,
                    color: Colors.red,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("No")),
                MaterialButton(
                    textColor: Colors.white,
                    color: Colors.green,
                    onPressed: () {
                      applogout();
                    },
                    child: const Text("Yes"))
              ],
            ));
  }

  checkGPSStatus() async {
    if (!goGreenModel!.locationEnabled!) return;
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

  applogout() async {
    GoogleSignIn().disconnect();
    SharedPreferencesInstance.logOut();
    SharedPreferencesInstance.instance!.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Login(),
      ),
    );
  }

  Future getspref() async {
    setState(() {
      if (datak != null && datak['status'] == true) {
        setState(() {
          freco = datak['face_recog'];
          attreq = datak['req_attendance'];
          attlocat = datak['attendance_location'];
        });
      } else if (datak == null || datak['status'] == false || datak == '') {
        setState(() {
          freco = SharedPreferencesInstance.getString('freco');
          attreq = SharedPreferencesInstance.getString('reqatt');
          attlocat = SharedPreferencesInstance.getString('ulocat');
        });
      }
    });
  }

  String? emppid;
  var cmplogo = '';
  getEmail() => setState(() {
        email = SharedPreferencesInstance.getString('email');
        username = SharedPreferencesInstance.getString('username');
        ppic = SharedPreferencesInstance.getString('profile');
        ppic2 = SharedPreferencesInstance.getString('profile2');
        uid = SharedPreferencesInstance.getString('uid');
        cid = SharedPreferencesInstance.getString('comp_id');
        emppid = SharedPreferencesInstance.getString('empid');
        mymgmt = SharedPreferencesInstance.getString('appmgmt');
      });

  bool visible = false;
  String myname = '',
      myskills = '',
      myphone = '',
      mygender = '',
      myreporting = '',
      myemail = '',
      mydoj = '',
      shiftname = '',
      shiftstart = '',
      shiftend = '',
      myid = '',
      mydob = '',
      myimg = '',
      mydesig = '';

  Map? data, datanew;
  List? userData, userDatanew;

  Future fetchList() async {
    try {
      var uri = "$customurl/controller/process/app/profile.php";
      final response = await http.post(Uri.parse(uri), body: {
        'type': 'fetch_profile',
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'uid': SharedPreferencesInstance.getString('uid')
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      data = json.decode(response.body);
      log("Fetch Profile : " + data.toString());
      if (data!['status'] == true) {
        setState(() {
          Marketplacedata = data!['apps'];
          visible = true;
          userData = data!["data"];
          myname = userData![0]['uname'];
          mydoj = userData![0]['u_doj'];
          myemail = userData![0]['u_email'];
          mygender = userData![0]['u_gender'];
          myphone = userData![0]['u_phone'];
          myid = userData![0]['uid'];
          myimg = userData![0]['img'];
          mydesig = userData![0]['u_designation'];
          myreporting = userData![0]['reporting_to'];
          mydob = userData![0]['u_dob'];
          myskills = userData![0]['u_skills'];
          shiftname = userData![0]['shift_name'];
          shiftstart = userData![0]['shift_start'];
          shiftend = userData![0]['shift_end'];
          visible = true;
          loader = 'dont show';
        });
      } else {
        setState(() {
          loader = 'error';
        });
      }
    } catch (error) {
      loader = 'error';
    }
  }

  Future openmarketplacelink(String id) async {
    try {
      var uri = "$customurl/controller/process/app/profile.php";
      final response = await http.post(Uri.parse(uri), body: {
        'type': 'get_papp_url',
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'uid': SharedPreferencesInstance.getString('uid'),
        "appid": id,
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      data = json.decode(response.body);
      log("Marketplace Link : " + data.toString());
      if (data!['status'] == true) {
        var url = data!['url'].toString();
        if (Platform.isAndroid) {
          launch(url);
        } else {
          launch(url);
        }
      } else {
        setState(() {
          loader = 'error';
        });
      }
    } catch (error) {
      loader = 'error';
    }
  }

  @override
  void initState() {
    super.initState();
    getspref();
    fetchList();
    getEmail();
    checkmultiplepermissionststaus();
  }

  checkmultiplepermissionststaus() async {
    log("requesting...");
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.locationAlways,
    ].request();
  }

  var loader = 'show';
  @override
  Widget build(BuildContext context) {
    var currentTime = DateTime.now();
    var greeting = currentTime.hour >= 5 && currentTime.hour < 12
        ? "Good Morning"
        : currentTime.hour >= 12 && currentTime.hour < 17
            ? "Good Afternoon"
            : "Good Evening";
    var greetingIcon = currentTime.hour >= 5 && currentTime.hour < 12
        ? const Icon(
            Icons.sunny,
            color: Colors.yellow,
            size: 28,
          )
        : currentTime.hour >= 12 && currentTime.hour < 17
            ? const Icon(
                Icons.wb_sunny,
                color: Colors.orange,
                size: 28,
              )
            : currentTime.hour >= 17 && currentTime.hour < 19
                ? const Icon(
                    Icons.sunny_snowing,
                    color: Colors.red,
                    size: 28,
                  )
                : Icon(
                    Icons.dark_mode,
                    color: Colors.yellow[200],
                    size: 28,
                  );
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Dashboard"),
      //   centerTitle: true,
      //   backgroundColor: Colors.transparent,
      //   elevation: 0
      // ),
      // floatingActionButton: FloatingActionButton.extended(
      //   label: Row(
      //     children: const [Text("Menu")],
      //   ),
      //   icon: const Icon(Icons.menu),
      //   backgroundColor: themecolor,
      //   onPressed: widget.openDrawer,
      // ),
      backgroundColor: const Color.fromRGBO(244, 244, 244, 1),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                ClipPath(
                  clipper: CustomShapeClipper(),
                  child: Container(
                    width: double.infinity,
                    height: 200.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.indigo,
                          Colors.blue.shade600,
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.89,
                      child: Column(children: [
                        // Row(
                        //   children: <Widget>[
                        //     const SizedBox(width: 10),
                        //     IconButton(
                        //       icon: const Icon(Icons.menu, color: Colors.white),
                        //       onPressed: widget.openDrawer,
                        //     ),
                        //     greetingIcon,
                        //     Padding(
                        //       padding: const EdgeInsets.all(10.0),
                        //       child: Text(
                        //         greeting,
                        //         style: const TextStyle(
                        //             color: Colors.white,
                        //             fontFamily: font1,
                        //             fontSize: 30,
                        //             fontWeight: FontWeight.bold),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        AppBar(
                          title: const Text("DASHBOARD"),
                          centerTitle: true,
                          leading: IconButton(
                            tooltip: "Menu",
                            icon: const Icon(
                              Icons.menu,
                              color: Colors.white,
                              size: 40,
                            ),
                            onPressed: widget.openDrawer,
                          ),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          actions: [
                            if (Platform.isAndroid)
                              if (goGreenModel!
                                  .backgroundLocationTrackingEnabled!)
                                IconButton(
                                  icon: const Icon(
                                    Icons.my_location_outlined,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    showLocationTrackingConditions();
                                  },
                                ),
                          ],
                        ),
                        Container(
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(0.0, 3.0),
                                  blurRadius: 5.0,
                                )
                              ]),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 40.0),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 40),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      attlocat == '0' && freco == '0'
                                          ? Column(
                                              children: <Widget>[
                                                Material(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0),
                                                  color: Colors.purple
                                                      .withOpacity(0.1),
                                                  child: IconButton(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15.0),
                                                    icon: const Icon(
                                                        Icons.fingerprint),
                                                    color: Colors.purple,
                                                    iconSize: 30.0,
                                                    onPressed: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (_) =>
                                                                  const MarkAttendanceScreen()));
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Column(
                                                  children: const [
                                                    Text('Mark',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily: font1,
                                                            fontSize: 14)),
                                                    Text('Attendance',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily: font1,
                                                            fontSize: 14)),
                                                  ],
                                                )
                                              ],
                                            )
                                          : attlocat == '1' && freco == '0'
                                              ? Column(
                                                  children: <Widget>[
                                                    Material(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100.0),
                                                      color: Colors.purple
                                                          .withOpacity(0.1),
                                                      child: IconButton(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(15.0),
                                                        icon: const Icon(
                                                            Icons.fingerprint),
                                                        color: Colors.purple,
                                                        iconSize: 30.0,
                                                        onPressed: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (_) =>
                                                                      const MarkAttendanceScreen()));
                                                          return;
                                                          // BlocProvider.of<
                                                          //             NavigationBloc>(
                                                          //         context)
                                                          //     .add(NavigationEvents
                                                          //         .MyAttendanceClickedEvent);
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Column(
                                                      children: const [
                                                        Text('Mark',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black54,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    font1,
                                                                fontSize: 14)),
                                                        Text('Attendance',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black54,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    font1,
                                                                fontSize: 14)),
                                                      ],
                                                    )
                                                  ],
                                                )
                                              : attlocat == '0' && freco == '1'
                                                  ? Column(
                                                      children: <Widget>[
                                                        Material(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100.0),
                                                          color: Colors.purple
                                                              .withOpacity(0.1),
                                                          child: IconButton(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(15.0),
                                                            icon: const Icon(Icons
                                                                .fingerprint),
                                                            color:
                                                                Colors.purple,
                                                            iconSize: 30.0,
                                                            onPressed: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (_) =>
                                                                              const MarkAttendanceScreen()));
                                                              return;
                                                              // set state while we fetch data from API
                                                              // BlocProvider.of<
                                                              //             NavigationBloc>(
                                                              //         context)
                                                              //     .add(NavigationEvents
                                                              //         .Markwithdate);
                                                            },
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 10),
                                                        Column(
                                                          children: const [
                                                            Text('Mark',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        font1,
                                                                    fontSize:
                                                                        14)),
                                                            Text('Attendance',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        font1,
                                                                    fontSize:
                                                                        14)),
                                                          ],
                                                        )
                                                      ],
                                                    )
                                                  : attlocat == '1' &&
                                                          freco == '1'
                                                      ? Column(
                                                          children: <Widget>[
                                                            Material(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100.0),
                                                              color: Colors
                                                                  .purple
                                                                  .withOpacity(
                                                                      0.1),
                                                              child: IconButton(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        15.0),
                                                                icon: const Icon(
                                                                    Icons
                                                                        .fingerprint),
                                                                color: Colors
                                                                    .purple,
                                                                iconSize: 30.0,
                                                                onPressed: () {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (_) =>
                                                                              const MarkAttendanceScreen()));
                                                                  return;
                                                                  // set state while we fetch data from API
                                                                  // BlocProvider.of<
                                                                  //             NavigationBloc>(
                                                                  //         context)
                                                                  //     .add(NavigationEvents
                                                                  //         .MyAttendanceClickedEvent);
                                                                },
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 10),
                                                            Column(
                                                              children: const [
                                                                Text('Mark',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black54,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontFamily:
                                                                            font1,
                                                                        fontSize:
                                                                            14)),
                                                                Text(
                                                                    'Attendance',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black54,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontFamily:
                                                                            font1,
                                                                        fontSize:
                                                                            14)),
                                                              ],
                                                            )
                                                          ],
                                                        )
                                                      : Column(
                                                          children: <Widget>[
                                                            Material(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100.0),
                                                              color: Colors
                                                                  .purple
                                                                  .withOpacity(
                                                                      0.1),
                                                              child: IconButton(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        15.0),
                                                                icon: const Icon(
                                                                    Icons
                                                                        .fingerprint),
                                                                color: Colors
                                                                    .purple,
                                                                iconSize: 30.0,
                                                                onPressed: () {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (_) =>
                                                                              const MarkAttendanceScreen()));
                                                                  return;
                                                                  // set state while we fetch data from API
                                                                  // BlocProvider.of<
                                                                  //             NavigationBloc>(
                                                                  //         context)
                                                                  //     .add(NavigationEvents
                                                                  //         .MyAttendanceClickedEvent);
                                                                },
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 10),
                                                            Column(
                                                              children: const [
                                                                Text('Mark',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black54,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontFamily:
                                                                            font1,
                                                                        fontSize:
                                                                            14)),
                                                                Text(
                                                                    'Attendance',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black54,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontFamily:
                                                                            font1,
                                                                        fontSize:
                                                                            14)),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                      Column(
                                        children: <Widget>[
                                          Material(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            color: Colors.blue.withOpacity(0.1),
                                            child: IconButton(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              icon: const Icon(
                                                  Icons.airline_seat_flat),
                                              color: Colors.blue,
                                              iconSize: 30.0,
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            const ApplyLeave()));
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Column(
                                            children: const [
                                              Text('Apply',
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: font1,
                                                      fontSize: 14)),
                                              Text('Leave',
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: font1,
                                                      fontSize: 14)),
                                            ],
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          Material(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            color:
                                                Colors.orange.withOpacity(0.1),
                                            child: IconButton(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              icon: const Icon(Icons.receipt),
                                              color: Colors.orange,
                                              iconSize: 30.0,
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            const MyHoliday()));
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Column(
                                            children: const [
                                              Text('Holiday',
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: font1,
                                                      fontSize: 14)),
                                              Text('List',
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: font1,
                                                      fontSize: 14)),
                                            ],
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 40.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Column(
                                        children: <Widget>[
                                          Material(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            color: Colors.blue.withOpacity(0.1),
                                            child: IconButton(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              icon: const Icon(
                                                  Icons.analytics_sharp),
                                              color: Colors.blue,
                                              iconSize: 30.0,
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            const LeaveStatus()));
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Column(
                                            children: const [
                                              Text('Leave',
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: font1,
                                                      fontSize: 14)),
                                              Text('Status',
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: font1,
                                                      fontSize: 14)),
                                            ],
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          Material(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            color: Colors.purpleAccent
                                                .withOpacity(0.1),
                                            child: IconButton(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              icon:
                                                  const Icon(Icons.fingerprint),
                                              color: Colors.purpleAccent,
                                              iconSize: 30.0,
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            const RequestAttendance()));
                                                return;
                                                // set state while we fetch data from API
                                                // BlocProvider.of<NavigationBloc>(
                                                //         context)
                                                //     .add(
                                                //   NavigationEvents
                                                //       .MyReqAttendanceClickedEvent,
                                                // );
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Column(
                                            children: const [
                                              Text('Request',
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: font1,
                                                      fontSize: 14)),
                                              Text('Attendance',
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: font1,
                                                      fontSize: 14)),
                                            ],
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          Material(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            color: Colors.deepPurple
                                                .withOpacity(0.1),
                                            child: IconButton(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              icon: const Icon(Icons.list_alt),
                                              color: Colors.deepPurple,
                                              iconSize: 30.0,
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            const AttendanceHistoryScreen()));
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Column(
                                            children: const [
                                              Text('Attendance',
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      fontFamily: font1)),
                                              Text('History',
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      fontFamily: font1)),
                                            ],
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                )
              ],
            ),
            // if (mymgmt == '1')
            // Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            //   const Padding(
            //     padding: EdgeInsets.only(top: 25, right: 30.0, left: 30),
            //     child: Text(
            //       "Manage your team",
            //       style: TextStyle(
            //         fontSize: 16,
            //         fontWeight: FontWeight.bold,
            //         color: Color(0xff072a99),
            //       ),
            //     ),
            //   ),
            //   const SizedBox(height: 10),
            //   SingleChildScrollView(
            //     scrollDirection: Axis.horizontal,
            //     physics: const BouncingScrollPhysics(),
            //     child: Row(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: <Widget>[
            //         const SizedBox(width: 22),
            //         ManageTeamWidgets(
            //           title: "Manage Team's Reimbursment",
            //           onTap: () => Navigator.push(
            //             context,
            //             MaterialPageRoute(builder: (_) => const TrList()),
            //           ),
            //         ),
            //         ManageTeamWidgets(
            //           title: "Manage Team's Leave",
            //           onTap: () => Navigator.push(
            //             context,
            //             MaterialPageRoute(builder: (_) => const LeaveList()),
            //           ),
            //         ),
            //         ManageTeamWidgets(
            //           title: "Manage Team's Attendance",
            //           onTap: () => Navigator.push(
            //             context,
            //             MaterialPageRoute(
            //                 builder: (_) => const TeamAttList()),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            //   const SizedBox(height: 10),
            // ]),
            const SizedBox(height: 5),

            Marketplacedata.isEmpty
                ? Container()
                : Container(
                    margin: const EdgeInsets.all(15),
                    child: CarouselSlider.builder(
                      itemCount: Marketplacedata.length,
                      options: CarouselOptions(
                        enlargeCenterPage: true,
                        height: 200,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 3),
                        reverse: false,
                        aspectRatio: 5.0,
                      ),
                      itemBuilder: (context, i, id) {
                        //for onTap to redirect to another screen
                        return GestureDetector(
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  )),
                              //ClipRRect for image border radius
                              child: Stack(children: [
                                SizedBox(
                                  height: 80,
                                  child: (Marketplacedata[0]['image']
                                              .toString()
                                              .substring(
                                                  Marketplacedata[0]['image']
                                                          .toString()
                                                          .length -
                                                      3,
                                                  Marketplacedata[0]['image']
                                                      .toString()
                                                      .length)) ==
                                          "svg"
                                      ? SvgPicture.network(
                                          Marketplacedata[i]['image'],
                                          semanticsLabel: 'SVG From Network',
                                          placeholderBuilder: (BuildContext
                                                  context) =>
                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.80,
                                                  padding: const EdgeInsets.all(
                                                      30.0),
                                                  child: Center(
                                                      child: CircularProgressIndicator(
                                                          color: Colors.grey
                                                              .shade200))), //placeholder while downloading file.
                                        )
                                      : Image.network(Marketplacedata[i]
                                              ['image']
                                          .toString()),
                                ),
                                // Text(Marketplacedata[i]['name']),
                                Positioned(
                                    top: 65,
                                    width: MediaQuery.of(context).size.width *
                                        0.70,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(Marketplacedata[i]['name'],
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold)),
                                    )),
                                Positioned(
                                    top: 85,
                                    width: MediaQuery.of(context).size.width *
                                        0.70,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        Marketplacedata[i]['description'],
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                    )),

                                Positioned(
                                  bottom: 10,
                                  right: 5,
                                  child: Container(
                                    child: const Center(
                                        child: Icon(Icons.arrow_forward_ios,
                                            color: Colors.white)),
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        shape: BoxShape.circle),
                                  ),
                                )
                              ])),
                          onTap: () {
                            openmarketplacelink(
                                Marketplacedata[i]['id'].toString());
                            log(Marketplacedata[i]['id']);
                          },
                        );
                      },
                    ),
                  ),

            Padding(
              padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
              child: Container(
                height: 255,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.7),
                      offset: const Offset(0.0, 3.0),
                      blurRadius: 8.0,
                    )
                  ],
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  image: const DecorationImage(
                    image: AssetImage("assets/cardb.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: loader == 'show'
                    ? const Center(
                        child: GFLoader(
                          type: GFLoaderType.custom,
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: Image(
                              image: AssetImage('assets/newlod.gif'),
                              height: 100,
                              width: 100,
                            ),
                          ),
                        ),
                      )
                    : loader != 'error'
                        ? GestureDetector(
                            onTap: widget.profileViewScreenOpener,
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 90.0,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10.0),
                                      topRight: Radius.circular(10.0),
                                    ),
                                    color: Colors.white,
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.topRight,
                                      stops: [-0.5, 0.7, 0.8, 0.9],
                                      colors: [
                                        Colors.indigo,
                                        Colors.blue,
                                        Colors.blue,
                                        Colors.blue
                                      ],
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                myname,
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: font1,
                                                    color: Colors.white),
                                              ),
                                              RichText(
                                                text: TextSpan(
                                                  children: [
                                                    const TextSpan(
                                                        text: "ID:",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white54,
                                                            fontSize: 13)),
                                                    TextSpan(
                                                        text: myid,
                                                        style: const TextStyle(
                                                            fontSize: 15)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (myimg != '')
                                          Container(
                                            height: 90,
                                            width: 90,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                image: NetworkImage(myimg),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 8, 10, 0),
                                        child: SizedBox(
                                          height: 60,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      mydesig,
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 20),
                                                    ),
                                                    Text(
                                                      myphone,
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            const Text(
                                              'Virtual ID Card',
                                              style: TextStyle(
                                                color: Color(0x88072a99),
                                                fontSize: 18,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 60,
                                              child: Image.network(
                                                ppic2!,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return const Text("");
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        : const SizedBox(),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ManageTeamWidgets extends StatelessWidget {
  const ManageTeamWidgets({
    Key? key,
    @required this.title,
    @required this.onTap,
  }) : super(key: key);
  final String? title;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2.5,
      child: Card(
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                title!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: font1, fontSize: 14, color: Colors.black),
              ),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                  const Color(0xff072a99),
                )),
                child: const Text(
                  'Open List',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: onTap,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, 390.0 - 200);
    path.quadraticBezierTo(size.width / 2, 280, size.width, 390.0 - 200);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
