import 'dart:convert';
import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ezhrm/constants.dart';
import 'package:otp_text_field/style.dart';
import 'package:http/http.dart' as http;
import 'package:otp_text_field/otp_text_field.dart';
import 'login.dart';

class Otp extends StatefulWidget {
  @override
  _OtpState createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  var data;
  List? userData;
  String? dbn;
  String? id;
  String? avatar;
  dynamic emailController = TextEditingController();
  dynamic phoneController = TextEditingController();
  @override
  void initState() {
    super.initState();
    getEmails();
    Fluttertoast.showToast(
        msg: "OTP has been sent to your registered number",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 20,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
  }

  String? btnstate;
  String message = '';
  bool visible = false;

  Future getEmails() async {
    setState(() {
      id = SharedPreferencesInstance.getString('eid');
      dbn = SharedPreferencesInstance.getString('db');
    });
    if (debug == 'yes') {
      //print(id);
      //print(dbn);
    }
  }

  String? otp;
  Future SendOtp() async {
    var uri = "$customurl/controller/process/forget_password.php";
    final response = await http.post(Uri.parse(uri), body: {
      'id': id,
      'otp': otp,
      'type': 's2',
      'db': dbn
    }, headers: <String, String>{
      'Accept': 'application/json',
    });
    data = json.decode(response.body);
    setState(() {
      userData = data["data"];
      if (data['status'] == true) {
        Fluttertoast.showToast(
            msg: "Your New Password Is Generated Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 20,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0);
        Navigator.pop(context);
      } else if (data['status'] == false) {
        setState(() {
          btnstate = 'show';
        });
        Fluttertoast.showToast(
            msg: data['error'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 200,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0);
      }
    });
    if (debug == 'yes') {
      //debugPrint(data['status'].toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/fwd.png'), fit: BoxFit.cover)),
        child: Center(
          child: ListView(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 4,
              ),
              const Card(
                  color: Colors.transparent,
                  elevation: 80,
                  child: Center(
                      child: Text(
                    'Enter Your OTP',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3),
                  ))),
              const SizedBox(height: 15),
              Container(
                child: OTPTextField(
                  length: 6,
                  width: MediaQuery.of(context).size.width,
                  textFieldAlignment: MainAxisAlignment.spaceAround,
                  fieldWidth: 50,
                  fieldStyle: FieldStyle.box,
                  style: const TextStyle(fontSize: 17),
                  onCompleted: (pin) {
                    setState(() {
                      otp = pin;
                    });
                    if (debug == 'yes') {
                      //print("Completed: " + otp);
                    }
                  },
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              otp == null || btnstate == 'hide'
                  ? Container(
                      // width: MediaQuery.of(context).size.width/2.25,
                      child: const Card(
                        color: Colors.transparent,
                        elevation: 80,
                        child: MaterialButton(
                          child: Text(
                            'SUBMIT',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: null,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Container(
                      // width: MediaQuery.of(context).size.width/2.25,
                      child: Card(
                        color: Colors.transparent,
                        elevation: 80,
                        child: MaterialButton(
                          child: const Text(
                            'SUBMIT',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            SendOtp();
                            setState(() {
                              message = 'please wait....';
                              btnstate = 'hide';
                              visible = true;
                            });
                          },
                          color: Colors.black,
                        ),
                      ),
                    ),
              if (btnstate != 'show')
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 5),
                  child: Visibility(
                      visible: visible,
                      child: const LinearProgressIndicator(
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      )),
                ),
              Center(
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 40,
                  ),
                  onPressed: () => showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) => CupertinoAlertDialog(
                            title: const Text(
                              "Back To Login Page?",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            actions: <Widget>[
                              CupertinoDialogAction(
                                isDefaultAction: true,
                                child: const Text('Yes'),
                                onPressed: () {
                                  Navigator.pushReplacement(context,
                                      MaterialPageRoute(builder: (context) {
                                    return const Login();
                                  }));
                                },
                              ),
                              CupertinoDialogAction(
                                child: const Text("No"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          )),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              if (btnstate != 'show')
                Center(
                    child: Text(
                  message,
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                )),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}
