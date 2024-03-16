import 'dart:io';
import 'package:ezhrm/bottombar_ios.dart/bottombar_ios.dart';
import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:getwidget/types/gf_loader_type.dart';
import 'package:ezhrm/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'applyadvsalary.dart';
import 'constants.dart';
import 'drawer.dart';

class Advance extends StatefulWidget {
  const Advance({Key? key}) : super(key: key);

  @override
  _AdvanceState createState() => _AdvanceState();
}

class _AdvanceState extends State<Advance>
    with SingleTickerProviderStateMixin<Advance> {
  bool visible = false;
  Map? data;
  Map? datanew;
  List? userData;
  List? userDatanew;
  String? username;
  String? email;
  String? ppic;
  String? ppic2;
  String? uid;
  String? cid;
  var internet = 'yes';
 
  @override
  void initState() {
    super.initState();
    // checkinternetconnection();
    getEmail();
    fetchList();
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
      var uri = "$customurl/controller/process/app/extras.php";
      final response = await http.post(Uri.parse(uri), body: {
        'type': 'fetch_advance_history',
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'uid': SharedPreferencesInstance.getString('uid')
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      data = json.decode(response.body);
      setState(() {
        visible = true;
        userData = data!["data"];
        //da = data["data"]["status"];
        visible = true;
      });
      if (userData!.isEmpty) {
        showCupertinoDialog(
          context: context,
          builder: (context) {
            return Theme(
              data: ThemeData.dark(),
              child: CupertinoAlertDialog(
                title: Column(
                  children: const [
                    Icon(
                      Icons.warning,
                      color: Colors.yellow,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'No advance salary taken',
                      style: TextStyle(fontFamily: font1),
                    ),
                  ],
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      }
    } catch (error) {
      userData = [];
    }
  }

  noInternetConnectiondailog2() {
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
                          Navigator.pop(context);
                        } else {
                          Navigator.pop(context);
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
  // String username = "";

  Future logOut(BuildContext context) async {
    SharedPreferencesInstance.instance!.remove('username');
    SharedPreferencesInstance.instance!.remove('email');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Login(),
      ),
    );
  }

  show(String remarks) {
    showCupertinoDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return Theme(
          data: ThemeData.dark(),
          child: CupertinoAlertDialog(
            content: Text(
              remarks,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontFamily: font1),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const bottombar_ios(),

      drawer: CustomDrawer(
          currentScreen: AvailableDrawerScreens.advanceSalary),

      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.blue,
        title: const Text(
          'Advance Salary List',
          style: TextStyle(color: Colors.white),
        ),
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
          : Column(
              children: [
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.black,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Month/Year',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 8, 8, 8),
                        child: Text(
                          'Amount',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 8, 8, 8),
                        child: Text(
                          'Status',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Remarks',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 1.5,
                  child: userData!.isEmpty
                      ? const Center(
                          child: Text(
                            'No any data found',
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
                            return Container(
                              height: 80,
                              color: Colors.transparent,
                              child: Card(
                                elevation: 80,
                                child: ListView(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),

                                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 0, 0, 0),
                                      child: SizedBox(
                                        width: 70,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 20, 8, 8),
                                          child: Text(
                                            '${userData![index]['month']} / ${userData![index]['year']}',
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          45, 10, 0, 0),
                                      child: SizedBox(
                                        width: 70,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 8, 8, 8),
                                          child: Text(
                                            '${userData![index]['amount']}',
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (userData![index]['status'] == '0')
                                      const Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(5, 10, 0, 0),
                                        child: SizedBox(
                                          width: 75,
                                          child: Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 8, 8, 8),
                                            child: Text(
                                              'Pending',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (userData![index]['status'] == '1')
                                      const Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(5, 10, 0, 0),
                                        child: SizedBox(
                                          width: 75,
                                          child: Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 8, 8, 8),
                                            child: Text(
                                              'Approved',
                                              style: TextStyle(
                                                  color: Colors.green),
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (userData![index]['status'] == '2')
                                      const Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(5, 10, 0, 0),
                                        child: SizedBox(
                                          width: 75,
                                          child: Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 8, 8, 8),
                                            child: Text(
                                              'Rejected',
                                              style: TextStyle(
                                                  color:
                                                      Colors.deepPurpleAccent),
                                            ),
                                          ),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 0, 10, 0),
                                      child: SizedBox(
                                        width: 70,
                                        child: IconButton(
                                          icon: const Icon(CupertinoIcons.eye),
                                          onPressed: () {
                                            if (userData![index]['remarks'] ==
                                                '') {
                                              show('No any remarks available');
                                            } else {
                                              show(userData![index]['remarks']);
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                ),
              ],
            ),
      floatingActionButton: userData == null
          ? Container()
          : Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue, Colors.indigo],
                ),
              ),
              width: 120,
              child: TextButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Applyadvsalary())),
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
                      style: TextStyle(color: Colors.white, fontFamily: font1),
                    ),
                  ],
                ),
              ),
            ),
      //bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
