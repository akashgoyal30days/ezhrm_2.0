import 'package:ezhrm/advance.dart';
import 'package:ezhrm/bottombar_ios.dart/bottombar_ios.dart';
import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart';

class Applyadvsalary extends StatefulWidget {
  const Applyadvsalary({Key? key}) : super(key: key);

  @override
  _ApplyadvsalaryState createState() => _ApplyadvsalaryState();
}

class _ApplyadvsalaryState extends State<Applyadvsalary>
    with SingleTickerProviderStateMixin<Applyadvsalary> {
  bool visible = true;
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
  dynamic reasonController = TextEditingController();
  dynamic advsalaryController = TextEditingController();
  dynamic remarksController = TextEditingController();
  var difference = "";
  // ignore: prefer_typing_uninitialized_variables
  var newdata;

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

  // String username = "";

  Future advapp() async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.fixed,
      elevation: 0,
      duration: const Duration(hours: 1),
      backgroundColor: Colors.black.withOpacity(0.5),
      content: Center(
          child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 2.5,
          ),
          const Text(
            'Please Wait!! Processing',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 3),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(120, 10, 120, 0),
            child: LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        ],
      )),
    ));
    try {
      var urii = "$customurl/controller/process/app/extras.php";
      final responseneww = await http.post(Uri.parse(urii), body: {
        'uid': SharedPreferencesInstance.getString('uid'),
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'type': 'apply_advance',
        'amount': advsalaryController.text,
        'remarks': remarksController.text
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
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          setState(() {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              behavior: SnackBarBehavior.fixed,
              elevation: 0,
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green.withOpacity(0.5),
              content: Center(
                  child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 2.5,
                  ),
                  const Icon(
                    Icons.check,
                    size: 60,
                    color: Colors.blue,
                  ),
                  const Text(
                    'Successfully Applied',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3),
                  ),
                ],
              )),
            ));
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Advance()));
          });
        } else if (newdata['status'] == false) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          setState(() {
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
                      ],
                    ),
                    content: const Text(
                      'You Already Have An Applied / Pending Loan',
                      style: TextStyle(fontFamily: font1),
                    ),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        isDefaultAction: true,
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          });
        }
      }
      if (debug == 'yes') {
        //debugPrint(newdata.toString());
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Unable to complete your request, please retry after sometime",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottombar_ios(),
      appBar: AppBar(
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
        bottomOpacity: 0,
        elevation: 0,
        title: const Text(
          "Apply Advance Salary",
          style: TextStyle(color: Colors.white, fontFamily: font1),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.40,
                  child: Card(
                    color: Colors.transparent,
                    borderOnForeground: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    elevation: 90,
                    shadowColor: Colors.transparent,
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5, 35, 5, 0),
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.blue, Colors.indigo],
                              ),
                            ),
                            height: 30,
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              children: const [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 6, 0, 5),
                                  child: Text(
                                    'Enter Advance Salary Amount',
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontFamily: font1,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                          child: Container(
                            color: Colors.transparent,
                            child: Card(
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  cursorColor: Colors.blueAccent,
                                  decoration: const InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(0)),
                                        borderSide: BorderSide(
                                            color: Colors.white, width: 1.0),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                      ),
                                      labelText: 'Amount',
                                      labelStyle: TextStyle(
                                          fontSize: 16,
                                          fontFamily: font1,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                  controller: advsalaryController,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.blue, Colors.indigo],
                              ),
                            ),
                            height: 30,
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              children: const [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 6, 0, 5),
                                  child: Text(
                                    'Remarks',
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontFamily: font1,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                          child: Container(
                            color: Colors.transparent,
                            child: Card(
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                child: TextFormField(
                                  cursorColor: Colors.blueAccent,
                                  decoration: const InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(0)),
                                        borderSide: BorderSide(
                                            color: Colors.white, width: 1.0),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                      ),
                                      labelText: 'Remarks Here',
                                      labelStyle: TextStyle(
                                          fontSize: 16,
                                          fontFamily: font1,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                  controller: remarksController,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
            child: ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.black)),
              child: const Text(
                'SUBMIT',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                if (advsalaryController.text == '0') {
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
                            ],
                          ),
                          content: const Text(
                            'Advance Salary Amount Cannot Be Or Less Than 0 ',
                            style: TextStyle(fontFamily: font1),
                          ),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              isDefaultAction: true,
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else if (advsalaryController.text == '' ||
                    remarksController.text == '') {
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
                            ],
                          ),
                          content: const Text(
                            'Please Fill All Fields',
                            style: TextStyle(fontFamily: font1),
                          ),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              isDefaultAction: true,
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else if (advsalaryController.text != '' &&
                    remarksController.text != '' &&
                    int.parse(advsalaryController.text) > 0) {
                  advapp();
                }
              },
            ),
          )
        ],
      ),
      //bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
