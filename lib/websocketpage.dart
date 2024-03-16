import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:ezhrm/constants.dart';
import 'package:ezhrm/login.dart';
import 'package:ezhrm/main.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class websocketpage extends StatefulWidget {
  final WebSocketChannel channel = WebSocketChannel.connect(Uri.parse(
      "ws://164.52.223.146:5001/recognise?token=$liveattendancetoken"));

  websocketpage({
    Key? key,
  }) : super(key: key);

  @override
  websocketpageState createState() {
    return websocketpageState();
  }
}

class websocketpageState extends State<websocketpage> {
  showLoaderDialogwithName(BuildContext context, String message) {
    AlertDialog alert = AlertDialog(
      contentPadding: const EdgeInsets.all(15),
      content: Row(
        children: [
          const CircularProgressIndicator(
            color: Colors.black,
          ),
          Container(
              margin: const EdgeInsets.only(left: 25),
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              )),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  getlivetoken() async {
    SharedPreferences gettokendetails = await SharedPreferences.getInstance();

    liveattendancetoken = gettokendetails.getString("liveattendancetoken");
    frame_numbers = int.parse(gettokendetails.getString("framenumbers").toString());
    face_time_miliseconds = int.parse(gettokendetails.getString("frametime").toString());
    face_percentage = double.parse(gettokendetails.getString("facedistance").toString());

    log("Live attendance token : " + liveattendancetoken.toString());
    log("Frame numbers : " + frame_numbers.toString());
    log("Face Distance : " + face_percentage.toString());
    log("Frame time : " + face_time_miliseconds.toString());
  }

  Geolocator geolocator = Geolocator();
  Position? userLocation;
  var lng, lat;
  var currDt = DateTime.now();
  var mydataatt;
  bool check1 = false;
  bool check2 = false;
  bool check3 = false;
  bool check4 = false;
  bool check5 = false;
  bool showpleasewait = false;
  bool showStartbutton = true;
  double? face_percentage;
  int? frame_numbers;
  int? face_time_miliseconds;
  int localUID = 0;
  int localfrequency = 0;

  List errorlistlength = [];

  void showcustomDailog(
    BuildContext context,
    String title,
    String bodymessage,
  ) {
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      title: Text(
        title,
      ),
      content: Text(
        bodymessage,
        style: const TextStyle(
            color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      actions: const <Widget>[
        // new MaterialButton(
        //   color: Colors.blue,
        //   child: new Text(
        //     "Okay",
        //     style: TextStyle(color: Colors.white),
        //   ),
        //   onPressed: () {
        //     // Navigator.of(context).pop();
        //   },
        // ),
      ],
    );

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future MarkAtt(String uid) async {
    SharedPreferences preferencecuid = await SharedPreferences.getInstance();
    SharedPreferences preferencesuid = await SharedPreferences.getInstance();
    try {
      var uri = "$customurl/controller/process/app/attendance.php";
      final response = await http.post(Uri.parse(uri), body: {
        'type': 'manager_mark',
        'cid': preferencecuid.getString('comp_id'),
        'uid': uid,
        'lat': userLocation!.latitude.toString(),
        'lng': userLocation!.longitude.toString(),
        'device_id': '',
        'time':
            '${currDt.hour.toString()}:${currDt.minute.toString()}:${currDt.second.toString()}.',
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      mydataatt = json.decode(response.body);
      log(mydataatt.toString());
      log({
        'type': 'manager_mark',
        'cid': preferencecuid.getString('comp_id'),
        'uid': uid,
        'lat': userLocation!.latitude.toString(),
        'lng': userLocation!.longitude.toString(),
        'device_id': '',
        'time':
            '${currDt.hour.toString()}:${currDt.minute.toString()}:${currDt.second.toString()}.',
      }.toString());

      if (mydataatt.containsKey('status')) {
        if (mydataatt['status'] == false) {
          localUID = 0;
          localfrequency = 0;
          setState(() {
            check1 = false;
            check2 = false;
            check3 = false;
            check4 = false;
            check5 = false;
            showpleasewait = false;
          });
          var username = mydataatt["name"];
          Future.delayed(const Duration(seconds: 0), () {
            showcustomDailog(this.context, "Sorry ${username ?? "User"}",
                "Your attendance is not marked, please try again.");
          });
        } else if (mydataatt['status'] == true) {
          localUID = 0;
          localfrequency = 0;
          setState(() {
            check1 = false;
            check2 = false;
            check3 = false;
            check4 = false;
            check5 = false;
            showpleasewait = false;
          });
          var username = mydataatt["name"];

          // ScaffoldMessenger.of(this.context).showSnackBar(

          //     SnackBar(content: Text("Attendance Marked successsfully"),
          //     backgroundColor: Colors.green,
          //     behavior: SnackBarBehavior.floating,

          //     ),

          //     );

          Future.delayed(const Duration(seconds: 0), () {
            showcustomDailog(this.context, "Thank you! $username",
                "Your attendance is marked successfully.");
          });

          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pop(this.context);
            uidList.clear();
            streamphotodata();
          });
        }
      }
      if (debug == 'yes') {
        //debugPrint(mydataatt.toString());
      }
    } catch (error) {
      // Scaffold.of(context).showSnackBar(SnackBar(
      //   behavior: SnackBarBehavior.floating,
      //   elevation: 0,
      //   duration: Duration(seconds: 3),
      //   backgroundColor: Colors.black,
      //   content: Text(
      //     error.toString(),
      //     style: TextStyle(
      //         color: Colors.white,
      //         fontSize: 18,
      //         fontWeight: FontWeight.bold,
      //         letterSpacing: 3),
      //   ),
      // ));
    }
  }

  Future<Position> _getLocation() async {
    Position? currentLocation;
    try {
      currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        lat = currentLocation!.latitude;
        lng = currentLocation!.longitude;
        if (debug == 'yes') {
          //print(currentLocation);
          //print(lat);
        }
      });
    } catch (e) {
      if (debug == 'yes') {
        //print('l');
      }
    }
    return currentLocation!;
  }

  CameraController? _cameraController;
  Timer? timer;
  var _savedimage;

  @override
  void initState() {
    super.initState();
    initializeCamera();
    getlivetoken();
  }

  initializeCamera() async {
    _cameraController = CameraController(
      cameras[1],
      // widget.cameratype == CameraType.frontCamera ? cameras[1] : cameras[1],
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _cameraController!.initialize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Live Attendance"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 430,
            width: MediaQuery.of(context).size.width,
            child: Container(
                decoration: const BoxDecoration(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CameraPreview(_cameraController!)),
                )),
          ),
          showpleasewait
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                      child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          height: 13,
                          width: 13,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "   Please wait...",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  )),
                  color: Colors.blue,
                  height: 30)
              : Container(),
          Container(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: check1 ? Colors.green : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(5)),
                    height: 25,
                    width: 25,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: check2 ? Colors.green : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(5)),
                    height: 25,
                    width: 25,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: check3 ? Colors.green : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(5)),
                    height: 25,
                    width: 25,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: check4 ? Colors.green : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(5)),
                    height: 25,
                    width: 25,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: check5 ? Colors.green : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(5)),
                    height: 25,
                    width: 25,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              showStartbutton
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MaterialButton(
                          minWidth: MediaQuery.of(context).size.width * 0.80,
                          textColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          height: 50,
                          color: Colors.green,
                          onPressed: () {
                            streamphotodata();

                            showStartbutton = false;
                            setState(() {});
                          },
                          child: const Text("Start")),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MaterialButton(
                          minWidth: MediaQuery.of(context).size.width * 0.80,
                          textColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          height: 50,
                          color: Colors.red,
                          onPressed: () {
                            showStartbutton = true;
                            timer!.cancel();
                            setState(() {
                              localUID = 0;
                              localfrequency = 0;
                              check1 = false;
                              check2 = false;
                              check3 = false;
                              check4 = false;
                              check5 = false;

                              showpleasewait = false;

                              uidList.clear();
                            });
                          },
                          child: const Text("Stop")),
                    ),
            ],
          )
        ],
      ),
    );
  }

  streamphotodata() {
    timer = Timer.periodic(Duration(milliseconds: face_time_miliseconds!),
        (Timer t) => capturePhoto());
  }

  List<int> uidList = [];

  capturePhoto() async {
    var tempPath = join(
      (await getTemporaryDirectory()).path,
      '${DateTime.now()}.png',
    );
    await _cameraController!.takePicture();
    // log(tempPath.toString());
    _savedimage = File(tempPath).readAsBytesSync();
    // log(_savedimage.toString());
    setState(() {});

    widget.channel.sink.add(_savedimage);

    widget.channel.stream.listen((data) {
      var response = jsonDecode(data);
      // log("Response :" + response.toString());
      log("Verified value :" + response["verified"].toString());
      if (response['verified'].toString() == "false") {
        log("Error Occured");
        errorlistlength.add("error");
        log("Error list length : " + errorlistlength.length.toString());
        if (errorlistlength.length > 9) {
          localfrequency = 0;

          showpleasewait = false;
          errorlistlength.clear();
          check1 = false;
          check2 = false;
          check3 = false;
          check4 = false;
          check5 = false;
          setState(() {});
        }
      }

      double distance =
          double.parse(response["distance"].toString().substring(0, 4));
      log("Distance :" + distance.toString());

      if (response.containsKey("verified") &&
          response.containsKey("distance") &&
          response.containsKey("matched_empid")) {
        if (response['verified'].toString() == "true") {
          //while (localfrequency <= frame_numbers) {
          log("Local Frequency : " + localfrequency.toString());
          log("Local UID : " + localUID.toString());

          if (double.parse(response['distance'].toString().substring(0, 4)) <=
              face_percentage!) {
            if (localUID == 0) {
              localfrequency = 1;
              localUID = int.parse(response["matched_empid"].toString());
            } else if (localUID ==
                int.parse(response["matched_empid"].toString())) {
              localfrequency++;
              localUID = int.parse(response["matched_empid"].toString());
            } else {
              localUID = 0;
              localfrequency = 0;
            }
          }
          //}
          if (localfrequency == 1) {
            showpleasewait = true;

            check1 = true;
          }
          if (localfrequency == 2) {
            check2 = true;
          }
          if (localfrequency == 3) {
            check3 = true;
          }
          if (localfrequency == 4) {
            check4 = true;
          }
          if (localfrequency == frame_numbers) {
            check5 = true;
            timer
            !.cancel();

            log("Mark attendace call..");
            _getLocation().then((position) {
              userLocation = position;

              MarkAtt(localUID.toString());
            });
          }

          // if (double.parse(response['distance'].toString().substring(0, 4)) <=
          //     face_percentage) {
          //   // log("id adding");
          //   // int uid = int.parse(response["matched_empid"].toString());
          //   // log(uid.toString());
          //   // uidList.add(uid);
          //   // log(uidList.toString());
          //   // log("Length of List" + uidList.length.toString());

          //   // for (var i = 1; i <= 5; i++) {
          //   //   if (uidList.length == 1) {
          //   //     setState(() {
          //   //         check1 = true;
          //   //         showpleasewait = true;
          //   //     });
          //   //   }
          //   // }
          //   if (uidList.length == 1) {
          //     setState(() {
          //       check1 = true;
          //       showpleasewait = true;
          //     });
          //   }
          //   if (uidList.length == 2) {
          //     setState(() {
          //       check2 = true;
          //     });
          //   }
          //   if (uidList.length == 3) {
          //     setState(() {
          //       check3 = true;
          //     });
          //   }
          //   if (uidList.length == 4) {
          //     setState(() {
          //       check4 = true;
          //     });
          //   }
          //   if (uidList.length == frame_numbers) {
          //     setState(() {
          //       check5 = true;
          //       timer.cancel();
          //     });
          //   }

          //   if (uidList.length >= frame_numbers) {
          //     timer.cancel();
          //     uidList.sort();
          //     log(uidList.toString());

          //     var popularNumbers = [];
          //     List<Map<dynamic, dynamic>> data = [];
          //     var maxOccurrence = 0;

          //     var i = 0;
          //     while (i < uidList.length) {
          //       var number = uidList[i];
          //       var occurrence = 1;
          //       for (int j = 0; j < uidList.length; j++) {
          //         if (j == i) {
          //           continue;
          //         } else if (number == uidList[j]) {
          //           occurrence++;
          //         }
          //       }
          //       uidList.removeWhere((it) => it == number);
          //       data.add({number: occurrence});
          //       if (maxOccurrence < occurrence) {
          //         maxOccurrence = occurrence;
          //       }
          //     }

          //     data.forEach((map) {
          //       if (map[map.keys.toList()[0]] == maxOccurrence) {
          //         popularNumbers.add(map.keys.toList()[0]);
          //       }
          //     });

          //     log("Popular Number " + popularNumbers.toString());
          //

          //   }
          // }
        } else {}
      } else {}
    }, onError: (error) {
      log(error.toString());
    });
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
    timer!.cancel();
    _cameraController!.dispose();
  }
}
