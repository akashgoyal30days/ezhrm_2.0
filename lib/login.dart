// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:ezhrm/home_bottom_navigation_bar.dart';
import 'package:ezhrm/register.dart';
import 'package:ezhrm/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart' as iosdeviceid;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'main.dart';
import 'constants.dart';
import 'custom_text_field.dart';
import 'api.dart';
import 'services/shared_preferences_singleton.dart';

final _googleSignIn = GoogleSignIn(scopes: ['email']);
String? liveattendancetoken;

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  final currDt = DateTime.now();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final deviceInfo = iosdeviceid.DeviceInfoPlugin();
  final emailController = TextEditingController(),
      passwordController = TextEditingController(),
      emailnewController = TextEditingController(),
      phoneController = TextEditingController();
  bool agreedToDataUsage = false;
  String? _platformVersion = 'Unknown',
      btnstate,
      message = '',
      messagenew = '',
      messagenotp = '',
      mytoken,
      location;
  bool visible = false,
      visiblem = false,
      visibleotp = false,
      hideIcon = false,
      _initialized = false,
      todash = true;
  GoogleSignInAccount? _currentUser;
  StreamSubscription? googleSignInStreamSubscription;

  @override
  void initState() {
    super.initState();
    dontshowbackgroundlocationdailog();
    initPlatformState();
    _register();
    googleSignInStreamSubscription = _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) {
      _currentUser = account;
      _googleLogin();
      _register();
    });
  }

  dontshowbackgroundlocationdailog() async {
    await SharedPreferencesInstance.setString(
        "ShowBackgroundLocationDailog", "false");
  }

  _handleSignIn() async {
    // Warning Dialog
    if (!agreedToDataUsage) {
      bool continueLogin = await showDialog(
              context: context, builder: (_) => DataUsageDialog()) ??
          false;
      if (!continueLogin) return;
    }
    agreedToDataUsage = true;
    await _googleSignIn.signIn();
  }

  String? imeiNumber;
  Future<void> initPlatformState() async {
    try {
      if (Platform.isAndroid) {
        _platformVersion = await PlatformDeviceId.getDeviceId;

        log("Unique ID : " + _platformVersion.toString());
        SharedPreferencesInstance.setString('deviceid', _platformVersion);
      } else if (Platform.isIOS) {
        iosdeviceid.IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        _platformVersion =
            '${iosInfo.utsname.version} + ${iosInfo.systemVersion}';
        SharedPreferencesInstance.setString('deviceid', _platformVersion);
      }
    } catch (e) {
      _platformVersion = 'Failed to get Device id.';
    }
  }

  Future<void> _register() async {
    if (_initialized) return;
    _firebaseMessaging.requestPermission();

    mytoken = await _firebaseMessaging.getToken();
    await SharedPreferencesInstance.instance!.setString('fbasetoken', mytoken!);
    _initialized = true;
  }

  String? otp;
  Future _sendOtp() async {
    var uri = "$customurl/controller/process/forget_password.php";
    final response = await http.post(Uri.parse(uri), body: {
      'id': data['data']['id'],
      'otp': otp,
      'type': 's2',
      'db': data['data']['db'],
    }, headers: <String, String>{
      'Accept': 'application/json',
    });
    datan = json.decode(response.body);
    setState(() {
      userDatan = datan["data"];
      if (datan['status'] == true) {
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: "Your New Password Is Generated Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 20,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0);
        Navigator.pop(context);
      } else if (datan['status'] == false) {
        Navigator.pop(context);
        setState(() {
          btnstate = 'close';
        });
        Fluttertoast.showToast(
            msg: datan['error'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 20000,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0);
      }
    });
  }

  apple_login(String appleloginEmail) async {
    log(appleloginEmail.toString());
    if (appleloginEmail == null) return;
    setState(() {
      message = 'please wait....';
      visible = true;
    });

    var uri = "$customurl/controller/process/app/user_glogin.php";
    final response = await http.post(Uri.parse(uri), body: {
      'type': 'glogin',
      'email': appleloginEmail.toString() ?? "",
      'device_id': _platformVersion ?? "",
      'device_id2': _platformVersion ?? "",
      'version': version ?? "",
      'firebase': mytoken ?? "",
      'platform': 'android',
    }, headers: <String, String>{
      'Accept': 'application/json',
    });
    var mydata = json.decode(response.body);

    if (!mydata.containsKey('status')) {
      setState(() {
        visible = false;
      });
      return;
    }
    setState(() {
      message = mydata['msg'];
      visible = false;
    });
    if (mydata['status'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          data['msg'],
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
      ));
      return;
    }
    await SharedPreferencesInstance.loginDataInitialise(mydata);
    restartApp();
  }

  _googleLogin() async {
    log(_currentUser!.email.toString());
    if (_currentUser == null) return;
    setState(() {
      message = 'please wait....';
      visible = true;
    });

    var uri = "$customurl/controller/process/app/user_glogin.php";
    final response = await http.post(Uri.parse(uri), body: {
      'type': 'glogin',
      'email': _currentUser!.email ?? "",
      'device_id': _platformVersion ?? "",
      'device_id2': _platformVersion ?? "",
      'version': version ?? "",
      'firebase': mytoken ?? "",
      'platform': 'android',
    }, headers: <String, String>{
      'Accept': 'application/json',
    });
    var mydata = json.decode(response.body);

    if (!mydata.containsKey('status')) {
      setState(() {
        visible = false;
      });
      return;
    }
    setState(() {
      message = mydata['msg'];
      visible = false;
    });
    if (mydata['status'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          data['msg'],
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
      ));
      return;
    }
    await SharedPreferencesInstance.loginDataInitialise(mydata);
    restartApp();
  }

  var userData, userDatan, db, data, datan;
  String? dbn;
  Future _frgtpasswrd() async {
    var uri = "$customurl/controller/process/forget_password.php";
    final response = await http.post(Uri.parse(uri), body: {
      'email': emailnewController.text,
      'phone': phoneController.text,
      'type': 's1'
    }, headers: <String, String>{
      'Accept': 'application/json',
    });
    data = json.decode(response.body);
    setState(() async {
      userData = data["status"];
      if (userData == true) {
        Navigator.pop(context);
        Navigator.pop(context);
        emailnewController.clear();
        phoneController.clear();
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              titlePadding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
              backgroundColor: Colors.white,
              elevation: 80,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              title: Center(
                  child: Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.cancel),
                    color: Colors.red,
                    iconSize: 30,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const Text('Enter OTP',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              )),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Center(
                      child: OTPTextField(
                        length: 6,
                        width: MediaQuery.of(context).size.width,
                        textFieldAlignment: MainAxisAlignment.spaceAround,
                        fieldWidth: 40,
                        fieldStyle: FieldStyle.box,
                        style: const TextStyle(fontSize: 17),
                        onCompleted: (pin) => setState(
                          () {
                            otp = pin;
                          },
                        ),
                      ),
                    ),
                    Card(
                      color: Colors.transparent,
                      elevation: 80,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.grey)),
                        child: const Text(
                          'SUBMIT',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          if (otp == null) return;
                          _sendOtp();
                          setState(() {
                            btnstate = 'hide';
                            _load();
                          });
                        },
                        // color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      } else if (userData == false) {
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: "Credentials don't match for the user",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 20,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0);
        setState(() {
          btnstate = 'show';
        });
      }
    });
  }

  @override
  void dispose() {
    googleSignInStreamSubscription?.cancel();
    emailController.dispose();
    passwordController.dispose();
    emailnewController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  String? btnval;

  _load() {
    if (btnstate == 'hide') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
            backgroundColor: Colors.transparent,
            elevation: 80,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            title: Center(
                child: Column(
              children: const [
                GFLoader(
                  type: GFLoaderType.android,
                  size: 50,
                  loaderColorOne: Colors.black,
                )
              ],
            )),
          );
        },
      );
    }
    if (btnstate == 'close') {
      Navigator.pop(context);
    }
  }

  forgotPassword() => showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: EdgeInsets.zero,
            child: ForgotPasswordDialogBox(
              emailnewController,
              phoneController,
              () {
                _frgtpasswrd();
                setState(() {
                  btnstate = 'hide';
                  _load();
                  messagenew = 'please wait....';
                  visiblem = true;
                });
              },
            ),
          );
        },
      );

  login() async {
    log(showupdatedailog.toString());
    String email = emailController.text ?? "",
        password = passwordController.text ?? "";
    if (email.isEmpty || password.isEmpty) return;
    // Warning Dialog
    if (!agreedToDataUsage) {
      bool continueLogin = await showDialog(
              context: context, builder: (_) => DataUsageDialog()) ??
          false;
      if (!continueLogin) return;
    }
    agreedToDataUsage = true;
    // Warning Dialog
    var did = _platformVersion;
    setState(() {
      message = 'please wait....';
      visible = true;
      btnval = 'show';
    });
    var rsp =
        await loginUser(email, password, _platformVersion!, version!, mytoken!);
    log(rsp.toString());
    if (rsp.containsKey('status')) {
      setState(() {
        btnval = 'hide';
        message = rsp['msg'];
        visible = false;
      });
      if (rsp['status'].toString() == "true") {
        await SharedPreferencesInstance.loginDataInitialise(rsp);
        if (rsp['data']['role'].toString().trim() == 'Attendance Manager') {
          setState(() {});
          SharedPreferencesInstance.setString('att_manager', '1');
        } else {
          setState(() {});

          SharedPreferencesInstance.setString('att_manager', '0');
        }
        restartApp();

        if (datak != null) {
          datak['code'] = 1002;
        }
        if (mounted) {
          setState(() {
            btnval = 'hide';
          });
        }
      }
    } else {
      setState(() {
        btnval = 'hide';
        visible = false;
        message = "nothing";
      });
      Navigator.pop(context);
    }
  }

  restartApp() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.locationAlways,
      Permission.camera,
      Permission.photos,
    ].request();

    await SharedPreferencesInstance.instance!
        .setString("showupdatedailog", "true");

    await SharedPreferencesInstance.setString(
        "ShowBackgroundLocationDailog", "true");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const SplashScreen(),
      ),
      (_) => false,
    );
    try {
      var uri = "$customurl/controller/process/app/profile.php";
      final response = await http.post(Uri.parse(uri), body: {
        'type': 'fetch_profile',
        'cid': SharedPreferencesInstance.getString('comp_id') ?? "",
        'uid': SharedPreferencesInstance.getString('uid') ?? ""
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      var data = json.decode(response.body);

      List userData = data["data"];
      log("Profile Data" + userData.toString());
      await SharedPreferencesInstance.saveUserProfileData(userData[0]);
    } catch (e) {
//
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: SizedBox(
                          height: 80,
                          child: Image.asset(
                            'assets/ezlogo.png',
                            colorBlendMode: BlendMode.colorBurn,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Color(0xff072a99),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 26,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Padding(
                                padding: EdgeInsets.only(left: 8.0, bottom: 8),
                                child: Text("Enter your credentials below",
                                    style: TextStyle(
                                      color: Color(0xff072a99),
                                    ))),
                            CustomTextField(
                              enabled: message != "please wait...." ||
                                  message != 'Login Successfully',
                              controller: emailController,
                              hint: "Email ID",
                              textInputType: TextInputType.emailAddress,
                            ),
                            CustomTextField(
                              enabled: message != "please wait...." ||
                                  message != 'Login Successfully',
                              controller: passwordController,
                              callBack: login,
                              isPassword: true,
                              hint: "Password",
                              textInputType: TextInputType.visiblePassword,
                            ),
                            if (message != null &&
                                message != 'Login Successfully' &&
                                message != "please wait...." &&
                                message!.isNotEmpty)
                              Center(
                                  child: Text(
                                message!,
                                style: const TextStyle(
                                  color: Colors.red,
                                ),
                              )),
                            if (message != "please wait...." ||
                                message != 'Login Successfully')
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                        onPressed: forgotPassword,
                                        child: const Text("Forgot Password?"),
                                        style: ButtonStyle(
                                            padding: MaterialStateProperty.all(
                                                EdgeInsets.zero),
                                            foregroundColor:
                                                MaterialStateProperty.all(
                                              const Color(0xff072a99),
                                            ))),
                                  ],
                                ),
                              ),
                            message == "please wait...." ||
                                    message == 'Login Successfully'
                                ? Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Center(
                                      child: LoadingAnimationWidget
                                          .threeRotatingDots(
                                              color: const Color(0x88072a99),
                                              size: 50),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          ElevatedButton(
                                            onPressed: login,
                                            child: const Text(" Login "),
                                            style: ButtonStyle(
                                              padding:
                                                  MaterialStateProperty.all(
                                                      const EdgeInsets.all(15)),
                                              shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    10,
                                                  ),
                                                ),
                                              ),
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                const Color(0xff072a99),
                                              ),
                                              elevation:
                                                  MaterialStateProperty.all(8),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          SignInButton(
                                            Buttons.Google,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            elevation: 8,
                                            onPressed: _handleSignIn,
                                          ),
                                          const SizedBox(height: 10),
                                          Platform.isIOS
                                              ? SignInWithAppleButton(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  height: 35,
                                                  style:
                                                      SignInWithAppleButtonStyle
                                                          .black,
                                                  onPressed: () async {
                                                    final credential =
                                                        await SignInWithApple
                                                            .getAppleIDCredential(
                                                      scopes: [
                                                        AppleIDAuthorizationScopes
                                                            .email,
                                                        AppleIDAuthorizationScopes
                                                            .fullName,
                                                      ],
                                                    );

                                                    log(credential.email
                                                        .toString());
                                                    apple_login(credential.email
                                                        .toString());
                                                  },
                                                )
                                              : const SizedBox(),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: TextButton(
                                                onPressed: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            const RegisterNewCompany())),
                                                child: const Text(
                                                    "Register a New Company"),
                                                style: ButtonStyle(
                                                    padding:
                                                        MaterialStateProperty
                                                            .all(EdgeInsets
                                                                .zero),
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all(
                                                      const Color(0xff072a99),
                                                    ))),
                                          ),
                                        ])),
                          ]),
                    ),
                  ]),
            ),
          ),
          if (message == 'Login Successfully')
            SizedBox.expand(
              child: Container(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LoadingAnimationWidget.fourRotatingDots(
                        size: 40,
                        color: Colors.white,
                      ),
                      const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text("Successfully Logged In",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ]),
                decoration: const BoxDecoration(
                  color: Color(0xdd072a99),
                ),
              ),
            )
        ],
      ),
    );
  }
}

class DataUsageDialog extends StatelessWidget {
  const DataUsageDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 15),
      title: const Text(
        "Attention",
        style: TextStyle(
            color: Color(0xff072a99),
            fontWeight: FontWeight.bold,
            fontSize: 20),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("By continuing to the app, you agree that:",
              style: TextStyle(
                fontSize: 18,
              )),
          const SizedBox(height: 10),
          RichText(
              textAlign: TextAlign.justify,
              text: const TextSpan(
                  style: TextStyle(fontSize: 18, color: Colors.black),
                  children: [
                    TextSpan(text: "Your "),
                    TextSpan(
                        text: "location ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "may be tracked in "),
                    TextSpan(
                        text: "background ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "for "),
                    TextSpan(
                        text: "marking your attendance ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "and "),
                    TextSpan(
                        text: "tracking your customer visits ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "during your working hours, only "),
                    TextSpan(
                        text: "when the app is running, ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "as "),
                    TextSpan(
                        text: "Agreed between you and your employer. ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text:
                            "To stop your location tracking, please exit or logout from the app."),
                  ])),
        ],
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text("Cancel"),
          style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(Colors.red)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: const Text("Continue"),
          style: ButtonStyle(
              foregroundColor:
                  MaterialStateProperty.all(const Color(0xff072a99))),
        ),
      ],
    );
  }
}

class ForgotPasswordDialogBox extends StatelessWidget {
  const ForgotPasswordDialogBox(this.email, this.phone, this.submit, {Key? key})
      : super(key: key);
  final TextEditingController? email, phone;
  final VoidCallback? submit;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Card(
          margin: const EdgeInsets.all(12.0),
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Reset Password",
                      style: TextStyle(
                        color: Color(0xff072a99),
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      ),
                    ),
                  ),
                ),
                const Padding(
                    padding: EdgeInsets.only(left: 8.0, bottom: 8),
                    child: Text("Enter your Email & Phone Number",
                        style: TextStyle(
                          color: Color(0xff072a99),
                        ))),
                CustomTextField(
                  hint: "Email",
                  controller: email,
                  textInputType: TextInputType.emailAddress,
                ),
                CustomTextField(
                  hint: "Phone Number",
                  controller: phone,
                  callBack: submit,
                  textInputType: TextInputType.phone,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (email!.text.isEmpty || phone!.text.isEmpty)
                            return;
                          submit!();
                        },
                        child: const Text("Get OTP"),
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.all(15)),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          backgroundColor: MaterialStateProperty.all(
                            const Color(0xff072a99),
                          ),
                          elevation: MaterialStateProperty.all(8),
                        ),
                      ),
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Close"),
                          style: ButtonStyle(
                              padding:
                                  MaterialStateProperty.all(EdgeInsets.zero),
                              foregroundColor: MaterialStateProperty.all(
                                const Color(0xff072a99),
                              ))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
