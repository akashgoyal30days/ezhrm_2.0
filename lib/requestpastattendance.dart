import 'dart:developer';

import 'package:ezhrm/bottombar_ios.dart/bottombar_ios.dart';
import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'constants.dart';

class RequestPastAttendanceScreen extends StatefulWidget {
  const RequestPastAttendanceScreen({Key? key}) : super(key: key);

  @override
  _RequestPastAttendanceScreen createState() => _RequestPastAttendanceScreen();
}

class _RequestPastAttendanceScreen extends State<RequestPastAttendanceScreen>
    with SingleTickerProviderStateMixin<RequestPastAttendanceScreen> {
  bool visible = true;
  Map? data;
  Map? datanew;
  List? userData;
  List? userDatanew;
  String? _mylist;
  String? _mycredit;
  String? username;
  String? email;
  String? ppic;
  String? ppic2;
  String? uid;
  String? cid;
  dynamic reasonController = TextEditingController();
  var difference = "";
  var newdata;

  Future<void> loaderFull(BuildContext context) async {
    return await showDialog(
        // barrierDismissible: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return WillPopScope(
              onWillPop: () async => false,
              child: const AlertDialog(
                backgroundColor: Colors.white,
                elevation: 0,
                content: SizedBox(
                    height: 40,
                    child: Center(
                        child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                    ))),
                title: Center(
                    child: Text(
                  'Processing...',
                  style: TextStyle(color: Colors.blue),
                )),
              ),
            );
          });
        });
  }

  loadProgress() {
    if (visible == true) {
      setState(() {
        visible = false;
      });
    } else {
      setState(() {
        visible = true;
      });
    }
  }

  @override
  void initState() {
    getEmail();
    fetchList();
    fetchCredit();

    super.initState();
  }

  Future getEmail() async {
    setState(() {
      email = SharedPreferencesInstance.getString('email');
      username = SharedPreferencesInstance.getString('username');
      ppic = SharedPreferencesInstance.getString('profile');
      ppic2 = SharedPreferencesInstance.getString('profile2');
      uid = SharedPreferencesInstance.getString('uid');
      cid = SharedPreferencesInstance.getString('comp_id');
    });
  }

  Future fetchList() async {
    try {
      var uri = "$customurl/controller/process/app/leave.php";
      final response = await http.post(Uri.parse(uri), body: {
        'uid': SharedPreferencesInstance.getString('uid'),
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'type': 'fetch_quota'
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      data = json.decode(response.body);
      setState(() {
        visible = true;
        userData = data!["data"];
        visible = true;
      });
      if (debug == 'yes') {
        //debugPrint(userData.toString());
      }
    } catch (error) {}
  }

  Future fetchCredit() async {
    try {
      var urii = "$customurl/controller/process/app/leave.php";
      final responsenew = await http.post(Uri.parse(urii), body: {
        'uid': SharedPreferencesInstance.getString('uid'),
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'type': 'fetch_credit'
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      datanew = json.decode(responsenew.body);
      setState(() {
        visible = true;
        userDatanew = datanew!["data"];
        if (userDatanew == null) {
          setState(() {
            userDatanew = [];
          });
        }
        visible = true;
      });
      if (debug == 'yes') {
        //debugPrint(userDatanew.toString());
        //debugPrint(datanew.toString());
      }
    } catch (error) {}
  }

  String? resulted;
  DateTime selectedDate = DateTime.now().subtract(const Duration(days: 1));
  DateTime selectedDatenew = DateTime.now();
  var customFormat = DateFormat('yyyy-MM-dd');
  var customFormatnew = DateFormat('yyyy-MM-dd');
  Future<void> showPicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate && picked != selectedDatenew) {
      setState(() {
        selectedDate = picked;
        selectedDatenew = picked;
      });
    }
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

  Future requestpastattendance() async {
    showLoaderDialogwithName(context, "Please wait..");
    try {
      var urii = "$customurl/controller/process/app/attendance_mark.php";
      final responseneww = await http.post(Uri.parse(urii), body: {
        'uid': SharedPreferencesInstance.getString('uid'),
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'type': 'req_past_attendance',
        'date': customFormat.format(selectedDate),
        'msg': reasonController.text.toString()
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      log("Data we Sending : " +
          {
            'uid': SharedPreferencesInstance.getString('uid'),
            'cid': SharedPreferencesInstance.getString('comp_id'),
            'type': 'req_past_attendance',
            'date': customFormat.format(selectedDate),
            'msg': reasonController.text
          }.toString());

      newdata = json.decode(responseneww.body);
      log("Request Past Attendance: " + newdata.toString());
      log("Url: " + responseneww.request!.url.toString());

      if (newdata.containsKey('status')) {
        setState(() {
          visible = false;
        });
        if (newdata['status'] == true) {
          Navigator.pop(context);
          btnval = 'hide';
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (_) => const RequestPastAttendanceScreen()));
          setState(() {
            Fluttertoast.showToast(
                msg: "Request Sent Successfully",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 2,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0);
            _mycredit = null;
            _mylist = null;
            reasonController.clear();
          });
        } else if (newdata['status'] == false) {
          Navigator.pop(context);

          setState(() {
            btnval = 'hide';
            Fluttertoast.showToast(
                msg: "Already applied for this date please check and try again",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 2,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
            _mycredit = null;
            _mylist = null;
            reasonController.clear();
          });
        }
      }
      if (debug == 'yes') {
        //debugPrint(newdata.toString());
        //print('from- ${customFormat.format(selectedDate)}');
        //print('To- ${customFormatnew.format(selectedDatenew)}');
      }
    } catch (error) {
      log(error.toString());
      Navigator.pop(context);

      btnval = 'hide';
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Something went wrong, please retry",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.red,
      ));
    }
  }

  String? btnval;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const bottombar_ios(),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        flexibleSpace: Container(
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
        title: const Text(
          "Request Past Attendance",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: userDatanew == null
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
            ))
          : SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  const Divider(),
                  Center(
                    child: Column(
                      children: [
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                  width: 1.0, color: Colors.grey)),
                          margin: const EdgeInsets.all(8),
                          child: InkWell(
                            onTap: () => showPicker(context),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Select Date",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff072a99),
                                      )),
                                  TextButton(
                                      onPressed: () => showPicker(context),
                                      child: Text(DateFormat('dd MMM y')
                                          .format(selectedDate)),
                                      style: ButtonStyle(
                                          padding: MaterialStateProperty.all(
                                              EdgeInsets.zero),
                                          textStyle: MaterialStateProperty.all(
                                              const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          foregroundColor:
                                              MaterialStateProperty.all(
                                            const Color(0xff072a99),
                                          ))),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Reason",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff072a99),
                                )),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            controller: reasonController,
                            cursorColor: const Color(0x33072a99),
                            keyboardType: TextInputType.name,
                            onSubmitted: (_) {},
                            minLines: 10,
                            maxLines: 15,
                            textInputAction: TextInputAction.done,
                            style: const TextStyle(color: Color(0xff072a99)),
                            decoration: InputDecoration(
                              fillColor: const Color(0x33072a99),
                              filled: true,
                              hintText: "State your reason here",
                              contentPadding: const EdgeInsets.all(10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        btnval == 'show'
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (reasonController.text != '') {
                                            btnval = 'show';
                                            requestpastattendance();
                                          } else if (reasonController.text ==
                                              '') {
                                            Fluttertoast.showToast(
                                                msg:
                                                    "Please fill all the fields",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 2,
                                                backgroundColor: Colors.white,
                                                textColor: Colors.black,
                                                fontSize: 16.0);
                                          }
                                        },
                                        child: const Text("Submit"),
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
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      //bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
