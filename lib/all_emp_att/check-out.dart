import 'dart:convert';
import 'dart:developer';
import 'package:another_flushbar/flushbar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import 'mainscreen.dart';

class MainScrChckOut extends StatefulWidget {
  const MainScrChckOut({Key? key}) : super(key: key);

  @override
  _MainScrChckOutState createState() => _MainScrChckOutState();
}

class _MainScrChckOutState extends State<MainScrChckOut> {
  Geolocator geolocator = Geolocator();
  Position? userLocation;
  String? username;
  String? email;
  String? ppic;
  String? ppic2;
  String? uid;
  String? cid;
  Map? data;
  Map? updata;
  List userData = [];
  List checkinlist = [];
  List? userDatanew;
  String messagefail = '';
  String messagepass = '';
  List enabledbuttonlist = [];
  List enabledbuttonlistsearch = [];

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    getEmail();
  }

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

  Future getEmail() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    SharedPreferences preferencess = await SharedPreferences.getInstance();
    SharedPreferences preferencesimg = await SharedPreferences.getInstance();
    SharedPreferences preferencesimg2 = await SharedPreferences.getInstance();
    SharedPreferences preferencesuid = await SharedPreferences.getInstance();
    SharedPreferences preferencecuid = await SharedPreferences.getInstance();
    setState(() {
      email = preferences.getString('email');
      username = preferencess.getString('username');
      ppic = preferencesimg.getString('profile');
      ppic2 = preferencesimg2.getString('profile2');
      uid = preferencesuid.getString('uid');
      cid = preferencecuid.getString('comp_id');
    });
    fetchEmpList();
  }

  Future fetchEmpList() async {
    setState(() {
      enabledbuttonlist.clear();
      checkinlist.clear();
      items.clear();
      enabledbuttonlist.clear();
    });
    SharedPreferences preferencecuid = await SharedPreferences.getInstance();
    SharedPreferences preferencesuid = await SharedPreferences.getInstance();
    try {
      var uri = "$customurl/controller/process/app/attendance.php";
      final response = await http.post(Uri.parse(uri), body: {
        'type': 'attendance_master',
        'cid': preferencecuid.getString('comp_id'),
        'uid': preferencesuid.getString('uid')
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      data = json.decode(response.body);
      if (data!.containsKey('status')) {
        if (data!['status'] == true) {
          setState(() {
            initScreen = 'screenloaded';
            userData = data!["data"];
            for (var i = 0; i < userData.length; i++) {
              // checkinlist.add(userData[i]);
              if (int.parse(userData[i]['attendance'].toString()).isOdd) {
                checkinlist.add(userData[i]);
                log(checkinlist.toString());
              }
            }
            for (var i = 0; i < checkinlist.length; i++) {
              enabledbuttonlist.add(true);
            }
          });
          //debugPrint(checkinlist.toString());
          if (debug == 'yes') {
            // //debugPrint(data.toString());
          }
        }
        if (data!['status'] == false) {
          setState(() {
            initScreen = 'no found';
          });
        }
      }
    } catch (error) {
      setState(() {
        initScreen = 'error';
      });
    }
  }

  var items = [];
  var indexpostion = [];
  bool isempfound = true;
  var currDt = DateTime.now();
  var mydataatt;
  var lng, lat;
  String initScreen = 'loader';

 Future<bool> _requestPermission(Permission permission) async {
    Map<Permission, PermissionStatus> statuses = await [permission].request();
    if (permission.status.isGranted == true) {
      return true;
    }
    return false;
  }


 Future<bool> requestLocationPermission({Function? onPermissionDenied}) async {
    var granted = await _requestPermission(Permission.location);
    if (granted != true) {
      requestLocationPermission();
    }
    if (debug == 'yes') {
      //debugPrint('requestContactsPermission $granted');
    }
    return granted;
  }

  TextEditingController editingController = TextEditingController();
  void filterSearchResults(String query) {
    indexpostion.clear();
    List dummySearchList = [];
    dummySearchList.addAll(checkinlist);
    if (query.isNotEmpty) {
      List dummyListData = [];
      for (var item in dummySearchList) {
        if (item['u_employee_id']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item['u_full_name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase())) {
          setState(() {
            dummyListData.add(item);
            isempfound = true;
          });
        } else {
          setState(() {
            isempfound = false;
          });
        }
      }
      setState(() {
        items.clear();
        items.addAll(dummyListData);
        indexpostion.clear();
        for (var i = 0; i < items.length; i++) {
          final index = dummySearchList.indexWhere((element) =>
              element['u_employee_id'] == items[i]['u_employee_id'] ||
              element['u_full_name'] == items[i]['u_full_name']);
          indexpostion.add(index);
        }
        //print(indexpostion);
      });
      items.clear();
      enabledbuttonlist.clear();
      for (var i = 0; i < indexpostion.length; i++) {
        items.add(checkinlist[int.parse(indexpostion[i].toString())]);
        enabledbuttonlistsearch.add(true);
        //print(items);
      }
      return;
    } else {
      setState(() {
        isempfound = true;
        items.clear();
        enabledbuttonlist.clear();
        items.addAll(checkinlist);
        for (var i = 0; i < items.length; i++) {
          enabledbuttonlistsearch.add(true);
        }
      });
    }
  }

  Future<Position> _getLocation() async {
    Position? currentLocation;
    try {
      currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        lat = currentLocation!.latitude;
        lng = currentLocation.longitude;
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

  Future MarkAtt(String uid, int index) async {
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
      //debugPrint(mydataatt.toString());
      if (mydataatt.containsKey('status')) {
        Navigator.pop(context);
        if (mydataatt['status'] == false) {
          messagefail = mydataatt['msg'];
          Flushbar(
            title: 'Oops',
            message: mydataatt['msg'].toString(),
            duration: const Duration(seconds: 3),
            icon: const Icon(
              Icons.info,
              color: Colors.blue,
            ),
          ).show(context);
          if (debug == 'yes') {
            //print(messagefail);
          }
        } else if (mydataatt['status'] == true) {
          messagepass = 'Successful';
          if (debug == 'yes') {
            //print(messagepass);
          }
          if (items.isNotEmpty) {
            setState(() {
              items.removeAt(index);
              enabledbuttonlistsearch.removeAt(index);
              checkinlist.removeAt(int.parse(indexpostion[index].toString()));
              enabledbuttonlist
                  .removeAt(int.parse(indexpostion[index].toString()));
            });
          } else {
            setState(() {
              indexpostion.clear();
            });
            checkinlist.removeAt(index);
            enabledbuttonlist.removeAt(index);
          }
          setState(() {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              behavior: SnackBarBehavior.floating,
              elevation: 0,
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.green.withOpacity(0.5),
              content: Text(
                messagepass,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3),
              ),
            ));
            // successfully();
          });
        }
      }
      if (debug == 'yes') {
        //debugPrint(mydataatt.toString());
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.black,
        content: Text(
          error.toString(),
          style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 3),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.black,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                return const MainScr();
              }));
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  initScreen = 'loader';
                  fetchEmpList();
                });
              },
            ),
          ],
          title: const Text('Check Out Screen'),
        ),
        backgroundColor: Colors.white,
        body: initScreen == 'loader'
            ? SizedBox(
                height: MediaQuery.of(context).size.height - 70,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 0.8,
                  ),
                ))
            : initScreen == 'screenloaded'
                ? Container(
                    child: checkinlist.isNotEmpty
                        ? Column(
                            children: [
                              Container(
                                color: Colors.black,
                                height: 60,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    controller: editingController,
                                    onChanged: (v) {
                                      filterSearchResults(v.toString());
                                    },
                                    decoration: const InputDecoration(
                                        labelText: "Search",
                                        labelStyle:
                                            TextStyle(color: Colors.white),
                                        hintText:
                                            "Search using employee id or name",
                                        hintStyle:
                                            TextStyle(color: Colors.white),
                                        fillColor: Colors.white,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.blue, width: 1.0),
                                        ),
                                        prefixIcon: Icon(
                                          Icons.search,
                                          color: Colors.white,
                                        ),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(25.0)))),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              if (items.isEmpty && isempfound == true)
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height - 160,
                                  child: GridView.count(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.6,
                                    children: List<Widget>.generate(
                                        checkinlist.length, (index) {
                                      return GridTile(
                                        child: Card(
                                            elevation: 10,
                                            color: Colors.black,
                                            child: FittedBox(
                                              child: Column(
                                                children: [
                                                  if (checkinlist[index]
                                                          ['p_file'] !=
                                                      '')
                                                    SizedBox(
                                                      height: 400,
                                                      child: Image.network(
                                                        checkinlist[index]
                                                                ['p_file']
                                                            .toString(),
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                      ),
                                                    ),
                                                  if (checkinlist[index]
                                                          ['p_file'] ==
                                                      '')
                                                    SizedBox(
                                                      height: 400,
                                                      child: Image.asset(
                                                        'assets/image_pic.jpg',
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                      ),
                                                    ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Text(
                                                          'Name : ',
                                                          style: TextStyle(
                                                              fontSize: 30,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        Text(
                                                          checkinlist[index][
                                                                  'u_full_name']
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 30,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Text(
                                                          'Emp ID : ',
                                                          style: TextStyle(
                                                              fontSize: 30,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        Text(
                                                          checkinlist[index][
                                                                  'u_employee_id']
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 30,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Container(
                                                      height: 100,
                                                      color: Colors.red,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: MaterialButton(
                                                        color:
                                                            Colors.transparent,
                                                        elevation: 0,
                                                        onPressed:
                                                            enabledbuttonlist[
                                                                        index] ==
                                                                    true
                                                                ? () {
                                                                    setState(
                                                                        () {
                                                                      enabledbuttonlist[
                                                                              index] =
                                                                          false;
                                                                    });
                                                                    showLoaderDialogwithName(
                                                                        context,
                                                                        "Processing...");
                                                                    _getLocation()
                                                                        .then(
                                                                            (position) {
                                                                      userLocation =
                                                                          position;

                                                                      MarkAtt(
                                                                          checkinlist[index]['uid']
                                                                              .toString(),
                                                                          index);
                                                                    });
                                                                  }
                                                                : null,
                                                        child: const Text(
                                                          'Check Out',
                                                          style: TextStyle(
                                                              fontSize: 30,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )),
                                      );
                                    }),
                                  ),
                                ),
                              if (items.isNotEmpty && isempfound == true)
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height - 160,
                                  child: GridView.count(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.6,
                                    children: List<Widget>.generate(
                                        items.length, (index) {
                                      return GridTile(
                                        child: Card(
                                            elevation: 10,
                                            color: Colors.black,
                                            child: FittedBox(
                                              child: Column(
                                                children: [
                                                  if (items[index]['p_file'] !=
                                                      '')
                                                    SizedBox(
                                                      height: 400,
                                                      child: Image.network(
                                                        items[index]['p_file']
                                                            .toString(),
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                      ),
                                                    ),
                                                  if (items[index]['p_file'] ==
                                                      '')
                                                    SizedBox(
                                                      height: 400,
                                                      child: Image.asset(
                                                        'assets/image_pic.jpg',
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                      ),
                                                    ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Text(
                                                          'Name : ',
                                                          style: TextStyle(
                                                              fontSize: 30,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        Text(
                                                          items[index][
                                                                  'u_full_name']
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 30,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Text(
                                                          'Emp ID : ',
                                                          style: TextStyle(
                                                              fontSize: 30,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        Text(
                                                          items[index][
                                                                  'u_employee_id']
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 30,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Container(
                                                      height: 100,
                                                      color: Colors.red,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: MaterialButton(
                                                        color:
                                                            Colors.transparent,
                                                        elevation: 0,
                                                        onPressed:
                                                            enabledbuttonlistsearch[
                                                                        index] ==
                                                                    true
                                                                ? () {
                                                                    setState(
                                                                        () {
                                                                      enabledbuttonlistsearch[
                                                                              index] =
                                                                          false;
                                                                    });
                                                                    _getLocation()
                                                                        .then(
                                                                            (position) {
                                                                      userLocation =
                                                                          position;
                                                                      MarkAtt(
                                                                          items[index]['uid']
                                                                              .toString(),
                                                                          index);
                                                                    });
                                                                  }
                                                                : null,
                                                        child: const Text(
                                                          'Check Out',
                                                          style: TextStyle(
                                                              fontSize: 30,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )),
                                      );
                                    }),
                                  ),
                                ),
                              if (items.isEmpty && isempfound == false)
                                SizedBox(
                                    height: MediaQuery.of(context).size.height -
                                        160,
                                    child: const Center(
                                      child: Text(
                                        'No employee found',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.black),
                                      ),
                                    )),
                              if (items.isNotEmpty && isempfound == false)
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height - 160,
                                  child: GridView.count(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.6,
                                    children: List<Widget>.generate(
                                        items.length, (index) {
                                      return GridTile(
                                        child: Card(
                                            elevation: 10,
                                            color: Colors.black,
                                            child: FittedBox(
                                              child: Column(
                                                children: [
                                                  if (items[index]['p_file'] !=
                                                      '')
                                                    SizedBox(
                                                      height: 400,
                                                      child: Image.network(
                                                        items[index]['p_file']
                                                            .toString(),
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                      ),
                                                    ),
                                                  if (items[index]['p_file'] ==
                                                      '')
                                                    SizedBox(
                                                      height: 400,
                                                      child: Image.asset(
                                                        'assets/image_pic.jpg',
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                      ),
                                                    ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Text(
                                                          'Name : ',
                                                          style: TextStyle(
                                                              fontSize: 30,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        Text(
                                                          items[index][
                                                                  'u_full_name']
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 30,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Text(
                                                          'Emp ID : ',
                                                          style: TextStyle(
                                                              fontSize: 30,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        Text(
                                                          items[index][
                                                                  'u_employee_id']
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 30,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Container(
                                                      height: 100,
                                                      color: Colors.red,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: MaterialButton(
                                                        color:
                                                            Colors.transparent,
                                                        elevation: 0,
                                                        onPressed:
                                                            enabledbuttonlistsearch[
                                                                        index] ==
                                                                    true
                                                                ? () {
                                                                    setState(
                                                                        () {
                                                                      enabledbuttonlistsearch[
                                                                              index] =
                                                                          false;
                                                                    });
                                                                    _getLocation()
                                                                        .then(
                                                                            (position) {
                                                                      userLocation =
                                                                          position;
                                                                      MarkAtt(
                                                                          items[index]['uid']
                                                                              .toString(),
                                                                          index);
                                                                    });
                                                                  }
                                                                : null,
                                                        child: const Text(
                                                          'Check Out',
                                                          style: TextStyle(
                                                              fontSize: 30,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )),
                                      );
                                    }),
                                  ),
                                ),
                            ],
                          )
                        : SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'No employee ',
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              15),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'To',
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              15),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Check-Out',
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              15),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            ),
                          ),
                  )
                : initScreen == 'no found'
                    ? Container(
                        child: const Center(
                          child: Text(
                            'No data',
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                      )
                    : Container(
                        child: const Center(
                          child: Text(
                            'Nothing to show',
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                      ));
  }
}
