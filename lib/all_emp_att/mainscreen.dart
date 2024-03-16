import 'dart:developer';

import 'package:ezhrm/all_emp_att/check-out.dart';
import 'package:ezhrm/all_emp_att/check_in.dart';
import 'package:ezhrm/websocketpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login.dart';

class MainScr extends StatefulWidget {
  const MainScr({Key? key}) : super(key: key);

  @override
  _MainScrState createState() => _MainScrState();
}

class _MainScrState extends State<MainScr> {
  void showDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: ThemeData.dark(),
          child: CupertinoAlertDialog(
            title: Text('Log Out'),
            content: Text('Are You Sure You Want To Log Out?'),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text('Yes'),
                onPressed: () {
                  // Navigator.of(context).pop();
                  logOut(context);
                },
              ),
              CupertinoDialogAction(
                child: Text("No"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );
      },
    );
  }

  Future logOut(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    SharedPreferences preferenceslocat = await SharedPreferences.getInstance();
    SharedPreferences preferencestime = await SharedPreferences.getInstance();
    SharedPreferences preferencestart = await SharedPreferences.getInstance();
    SharedPreferences preferencesend = await SharedPreferences.getInstance();
    SharedPreferences preferencemylocation =
        await SharedPreferences.getInstance();
    SharedPreferences preferenceattmanager =
        await SharedPreferences.getInstance();
    preferencemylocation.setString('locatstatus', '2');
    preferences.remove('username');
    preferencestart.remove('offcstart');
    preferencesend.remove('offcend');
    preferences.remove('email');
    preferencestime.remove('timing');
    preferenceslocat.remove('locate');
    preferenceattmanager.remove('att_manager');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Login(),
      ),
    );
  }

  String? companylogo;
  getcompanylogo() async {
    SharedPreferences getlogo = await SharedPreferences.getInstance();
    setState(() {
      companylogo = getlogo.getString("profile2");
    });
    log(companylogo.toString());
  }

  @override
  void initState() {
    super.initState();
    getcompanylogo();
    getlocationaccess();
  }

  getlocationaccess() {
    Geolocator geolocator = Geolocator();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(),
              companylogo != null
                  ? Container(width: 300, child: Image.network(companylogo!))
                  : Container(
                      child: CircularProgressIndicator(),
                    ),
              SizedBox(height: 50),
              // Center(
              //     child: Text(
              //   'Welcome',
              //   style: TextStyle(
              //       fontSize: MediaQuery.of(context).size.width / 10,
              //       fontWeight: FontWeight.w600),
              // )),
              // Center(
              //     child: Text(
              //   'to',
              //   style: TextStyle(
              //       fontSize: MediaQuery.of(context).size.width / 10,
              //       fontWeight: FontWeight.w600),
              // )),
              Text(
                'Attendance'.toUpperCase(),
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 5),
              ),
              SizedBox(height: 10),
              Text(
                'Management'.toUpperCase(),
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 5),
              ),
              SizedBox(height: 10),
              Text(
                'System'.toUpperCase(),
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 5),
              ),
              SizedBox(
                height: 70,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10)),
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: MaterialButton(
                      elevation: 0,
                      color: Colors.transparent,
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return websocketpage();
                        }));
                      },
                      child: Text(
                        "Live Attendance",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.04),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10)),
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: MaterialButton(
                      elevation: 0,
                      color: Colors.transparent,
                      onPressed: () {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) {
                          return MainScrChckIn();
                        }));
                      },
                      child: Text(
                        "Check In Sheet",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.04),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10)),
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: MaterialButton(
                      elevation: 0,
                      color: Colors.transparent,
                      onPressed: () {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) {
                          return MainScrChckOut();
                        }));
                      },
                      child: Text(
                        "Check Out Sheet",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.04),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10)),
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.40,
                    child: MaterialButton(
                      elevation: 0,
                      color: Colors.transparent,
                      onPressed: () {
                        showDialog();
                      },
                      child: Text(
                        "Log Out",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width / 20),
                      ),
                    ),
                  ),
                ],
              ),
              Spacer()
            ],
          ),
        ));
  }
}
