import 'package:ezhrm/bottombar_ios.dart/bottombar_ios.dart';
import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'dart:convert';
import 'applywfh.dart';
import 'constants.dart';
import 'drawer.dart';

class WorkFromHome extends StatefulWidget {
  const WorkFromHome({Key? key}) : super(key: key);

  @override
  _WorkFromHomeState createState() => _WorkFromHomeState();
}

class _WorkFromHomeState extends State<WorkFromHome>
    with SingleTickerProviderStateMixin<WorkFromHome> {
  bool visible = false;
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
  var newdata;
  var internet = 'yes';

  @override
  void initState() {
    super.initState();
    getEmail();
    fetchList();
    fetchCredit();
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
        'type': 'work_home_status'
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      data = json.decode(response.body);
      setState(() {
        visible = true;
        userData = data!["data"];
        print('userData: $userData');
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
        visible = true;
      });
      if (debug == 'yes') {
        //debugPrint(userDatanew.toString());
        //debugPrint(datanew.toString());
      }
    } catch (error) {}
  }

  DateTime selectedDate = DateTime.now();
  DateTime selectedDatenew = DateTime.now();
  var customFormat = DateFormat('yyyy-MM-dd');
  var customFormatnew = DateFormat('yyyy-MM-dd');
  Future<void> showPicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2101));

    if (picked != null && picked != selectedDate && picked != selectedDatenew) {
      setState(() {
        selectedDate = picked;
        selectedDatenew = picked;
      });
    }
  }

  Future<void> showPickernew(BuildContext context) async {
    final DateTime? pickednew = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2101));

    if (pickednew != null && pickednew != selectedDatenew) {
      setState(() {
        selectedDatenew = pickednew;
      });
    }
  }

  // String username = "";

  Future Wfh() async {
    var urii = "$customurl/controller/process/app/leave.php";
    final responseneww = await http.post(Uri.parse(urii), body: {
      'uid': SharedPreferencesInstance.getString('uid'),
      'cid': SharedPreferencesInstance.getString('comp_id'),
      'type': 'apply_work_home',
      'date_from': customFormat.format(selectedDate),
      'reason': reasonController.text
    }, headers: <String, String>{
      'Accept': 'application/json',
    });
    newdata = json.decode(responseneww.body);
    if (newdata.containsKey('status')) {
      setState(() {
        // message =  mydataatt['msg'];
        visible = false;
      });
      if (newdata['status'] == true) {
        setState(() {
          Fluttertoast.showToast(
              msg: "Your Work From Home Is Successfully Applied",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.white,
              textColor: Colors.black,
              fontSize: 16.0);
          _mycredit = null;
          _mylist = null;
          reasonController.clear();
        });
      } else if (newdata['status'] == false) {
        setState(() {
          Fluttertoast.showToast(
              msg: "Already Applied For This Date, Please Check And Try Again",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.white,
              textColor: Colors.black,
              fontSize: 16.0);
          _mycredit = null;
          _mylist = null;
          reasonController.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const bottombar_ios(),
      drawer:
          const CustomDrawer(currentScreen: AvailableDrawerScreens.applyWFH),
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
        elevation: 0,
        title: const Text(
          "Work From Home",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: userData == null
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
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.white],
                ),
              ),
              child: userData!.isEmpty
                  ? const Center(
                      child: Text(
                        'No Data Found',
                        style: TextStyle(
                            fontFamily: font1,
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: Colors.black),
                      ),
                    )
                  : ListView.builder(
                      itemCount: userData == null ? 0 : userData!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child:
                                            Text(userData![index]["date_from"])),
                                    if (userData![index]["status"] == '0')
                                      const Text(
                                        "Pending  ",
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontStyle: FontStyle.italic,
                                          fontFamily: font1,
                                          color: Colors.blue,
                                        ),
                                      )
                                    else if (userData![index]["status"] == '1')
                                      const Text(
                                        "Approved",
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontFamily: font1,
                                            color: Colors.green,
                                            fontWeight: FontWeight.w900),
                                      )
                                    else if (userData![index]["status"] == '2')
                                      const Text(
                                        "Rejected ",
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontFamily: font1,
                                            color: Colors.red,
                                            fontWeight: FontWeight.w900),
                                      )
                                    else if (userData![index]["status"] == '3')
                                      const Text(
                                        "Cancelled",
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontFamily: font1,
                                            color: Colors.red,
                                            fontWeight: FontWeight.w900),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Reason",
                                  style: TextStyle(
                                      color: Color(0xff072a99), fontSize: 13),
                                ),
                                Text(
                                  userData![index]["reason"],
                                  style: const TextStyle(fontSize: 15),
                                )
                              ],
                            ),
                          ),
                        );
                      }),
            ),
      floatingActionButton: userData == null
          ? const SizedBox()
          : Container(
              width: 120,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue, Colors.indigo],
                ),
              ),
              child: TextButton(
                child: Row(
                  children: const [
                    Icon(
                      Icons.add_circle,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Apply New',
                      style: TextStyle(
                          color: Colors.white, fontFamily: font1, fontSize: 15),
                    ),
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ApplyWrkfrmhome()));
                },
              ),
            ),
      //bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
