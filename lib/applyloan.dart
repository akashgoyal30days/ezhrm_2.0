import 'package:ezhrm/bottombar_ios.dart/bottombar_ios.dart';
import 'package:ezhrm/loan.dart';
import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart';

class ApplyLoan extends StatefulWidget {
  const ApplyLoan({Key? key}) : super(key: key);

  @override
  _ApplyLoanState createState() => _ApplyLoanState();
}

class _ApplyLoanState extends State<ApplyLoan>
    with SingleTickerProviderStateMixin<ApplyLoan> {
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
  dynamic lamountController = TextEditingController();
  dynamic emiamountController = TextEditingController();
  var difference = "";
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

  Future Loanapp() async {
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
        'type': 'apply_loan',
        'loan_amount': lamountController.text,
        'emi_amount': emiamountController.text
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
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const Loan()));
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
                        'You Already Have An Applied / Pending Loan'),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        isDefaultAction: true,
                        child: const Text('OK! I Understood'),
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
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const bottombar_ios(),
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
        backgroundColor: Colors.blue,
        bottomOpacity: 0,
        elevation: 0,
        title: const Text(
          "Apply Loan",
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
                  height: MediaQuery.of(context).size.height * 0.50,
                  child: Card(
                    color: Colors.transparent,
                    borderOnForeground: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    elevation: 10,
                    shadowColor: Colors.transparent,
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5, 35, 5, 10),
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
                                    'Enter Loan Amount',
                                    style: TextStyle(
                                        fontSize: 17,
                                        color: Colors.white,
                                        fontFamily: font1,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5, 5, 5, 10),
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
                                      labelText: 'Loan Amount Here',
                                      labelStyle: TextStyle(
                                          fontSize: 16,
                                          fontFamily: font1,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                  controller: lamountController,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5, 5, 5, 10),
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
                            // color: Colors.white,
                            height: 30,
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              children: const [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 6, 0, 5),
                                  child: Text(
                                    'Emi Amount',
                                    style: TextStyle(
                                        fontSize: 17,
                                        color: Colors.white,
                                        fontFamily: font1,
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
                                      labelText: 'Emi Amount Here',
                                      labelStyle: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontFamily: font1,
                                          fontWeight: FontWeight.bold)),
                                  controller: emiamountController,
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
                if (lamountController.text == '0' ||
                    emiamountController.text == '0') {
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
                              'Either Loan Amount or Emi Ammount Cannot Be 0?'),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              isDefaultAction: true,
                              child: const Text('OK! I Understood'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else if (lamountController.text == '' ||
                    emiamountController.text == '') {
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
                          content: const Text('Please Fill All Fields'),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              isDefaultAction: true,
                              child: const Text('OK! I Understood'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else if (int.parse(emiamountController.text) >
                    int.parse(lamountController.text)) {
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
                              'Emi amount should not be greater than Loan Amount'),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              isDefaultAction: true,
                              child: const Text('OK! I Understood'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else if (lamountController.text != '' &&
                    emiamountController.text != '' &&
                    emiamountController.text != '0' &&
                    lamountController.text != '0' &&
                    int.parse(emiamountController.text) <
                        int.parse(lamountController.text)) {
                  Loanapp();
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
