import 'dart:convert';
import 'package:ezhrm/home.dart';
import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:getwidget/types/gf_loader_type.dart';
import 'package:ezhrm/constants.dart';
import 'package:ezhrm/otp.dart';
import 'package:http/http.dart' as http;

import 'login.dart';

class FrgtPwd extends StatefulWidget {
  logout(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  _FrgtPwdState createState() => _FrgtPwdState();
}

class _FrgtPwdState extends State<FrgtPwd> {
  logout(BuildContext context) {
    Navigator.pop(context);
  }

  var data;
  final _formKey = GlobalKey<FormState>();
  var userData;
  var id;
  var db;
  bool visible = false;
  String? btnstate, message = '', name, email, avatar;
  final emailController = TextEditingController(),
      phoneController = TextEditingController();
  @override
  void initState() {
    super.initState();
    getEmails();
  }

  Future getEmails() async {
    setState(() {
      email = SharedPreferencesInstance.getString('email');
      name = SharedPreferencesInstance.getString('username');
      avatar = SharedPreferencesInstance.getString('profile');
    });
    if (debug == 'yes') {
      //print(name);
      //print(email);
    }
  }

  Future Fpwd() async {
    var uri = "$customurl/controller/process/forget_password.php";
    final response = await http.post(Uri.parse(uri), body: {
      'email': emailController.text,
      'phone': phoneController.text,
      'type': 's1'
    }, headers: <String, String>{
      'Accept': 'application/json',
    });
    data = json.decode(response.body);
    setState(() async {
      userData = data["status"];
      if (userData == true) {
        SharedPreferencesInstance.setString('eid', data['data']['id']);
        SharedPreferencesInstance.setString('db', data['data']['db']);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return Otp();
        }));
      } else if (userData == false) {
        Fluttertoast.showToast(
            msg: "Credentials does not matched for the user",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 20,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0);
      }
    });
    if (debug == 'yes') {
      //debugPrint(userData.toString());
      //print(emailController.text);
      //print(phoneController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) =>  HomePage()));
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/fwd.png'), fit: BoxFit.cover)),
          child: Center(
            child: Form(
              key: _formKey,
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
                        'Forgot Password',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3),
                      ))),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 20, 8),
                    child: Card(
                      child: TextFormField(
                        decoration: const InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 5.0),
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide:
                                  BorderSide(color: Colors.white, width: 5.0),
                            ),
                            labelText: 'Enter Your Email',
                            labelStyle: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                        controller: emailController,
                        style: const TextStyle(color: Colors.black),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Email cannot be empty';
                          }
                          return null;
                        },
                      ),
                      color: Colors.blue,
                      elevation: 80,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Card(
                      child: TextFormField(
                        decoration: const InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 5.0),
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide:
                                  BorderSide(color: Colors.white, width: 5.0),
                            ),
                            labelText: 'Enter Your Phone Number',
                            labelStyle: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                        controller: phoneController,
                        style: const TextStyle(color: Colors.black),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Phone number cannot be empty';
                          }
                          return null;
                        },
                      ),
                      color: Colors.blue,
                      elevation: 80,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 20, 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2,
                          child: Card(
                            elevation: 80,
                            color: Colors.transparent,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                                size: 40,
                              ),
                              onPressed: () => showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext context) =>
                                      CupertinoAlertDialog(
                                        title: const Text(
                                          "Back To Login Page?",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        actions: <Widget>[
                                          CupertinoDialogAction(
                                            isDefaultAction: true,
                                            child: const Text('Yes'),
                                            onPressed: () {
                                              logout(BuildContext context) {
                                                Navigator.pop(context);
                                              }

                                              Navigator.pushReplacement(context,
                                                  MaterialPageRoute(
                                                      builder: (context) {
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
                        ),
                        btnstate == 'hide'
                            ? SizedBox(
                                width: MediaQuery.of(context).size.width / 2.25,
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
                            : SizedBox(
                                width: MediaQuery.of(context).size.width / 2.25,
                                child: Card(
                                  color: Colors.transparent,
                                  elevation: 80,
                                  child: MaterialButton(
                                    child: const Text(
                                      'SUBMIT',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () {
                                      logout(BuildContext context) {
                                        Navigator.pop(context);
                                      }

                                      if (_formKey.currentState!.validate()) {
                                        Fpwd();
                                      }
                                      setState(() {
                                        if (emailController.text != '' &&
                                            phoneController.text != '') {
                                          btnstate = 'hide';
                                        }
                                        if (emailController.text != '' &&
                                            phoneController.text != '') {
                                          message = 'please wait....';
                                        }
                                        if (emailController.text != '' &&
                                            phoneController.text != '') {
                                          visible = true;
                                        }
                                      });
                                    },
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                  if (btnstate != 'show')
                    Center(
                        child: Text(
                      message!,
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    )),
                  const Divider(),
                  if (btnstate != 'show')
                    Visibility(
                        visible: visible,
                        child: const GFLoader(
                          type: GFLoaderType.ios,
                          loaderColorOne: Colors.black,
                        )),
                ],
              ),
            ),
          ),
        ),
        // bottomNavigationBar: CustomBottomNavigationBar(),
      ),
    );
  }
}
