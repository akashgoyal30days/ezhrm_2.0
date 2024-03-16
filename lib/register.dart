import 'dart:convert';
import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:flutter/gestures.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'constants.dart';
import 'package:otp_text_field/otp_field.dart';
import 'custom_text_field.dart';
import 'login.dart';
import 'package:otp_text_field/style.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

Timer? timer;

class RegisterNewCompany extends StatefulWidget {
  const RegisterNewCompany({Key? key}) : super(key: key);

  @override
  _RegisterNewCompanyState createState() => _RegisterNewCompanyState();
}

class _RegisterNewCompanyState extends State<RegisterNewCompany> {
  String _platformVersion = 'Unknown';
  String? btnstate;
  String message = '';
  String messagenew = '';
  String messagenotp = '';
  bool visible = false;
  bool visiblem = false;
  bool visibleotp = false;
  GoogleSignInAccount? _currentUser;
  String? mytoken;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool _initialized = false;
  String? location;

  validateEmail(String value) {
    String pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Enter a valid email address';
    } else {
      return null;
    }
  }

  // Future<void> initPlatformState() async {
  //   String platformVersion;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     platformVersion = await GetMac.macAddress;
  //   } on PlatformException {
  //     platformVersion = 'Failed to get Device MAC Address.';
  //   }

  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;

  //   setState(() {
  //     _platformVersion = platformVersion;
  //   });
  // }

  Future<void> _register() async {
    if (!_initialized) {
      _firebaseMessaging.requestPermission();
      mytoken = await _firebaseMessaging.getToken();
      await SharedPreferencesInstance.setString('fbasetoken', mytoken);
      _initialized = true;
    }
  }

  Future showoncmplete() => showModalBottomSheet(
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(50.0)),
      ),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
                height: 500,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topLeft,
                    colors: [
                      Colors.white,
                      Colors.white,
                      Colors.white,
                      Colors.white,
                    ],
                  ),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.elliptical(50, 50.0)),
                ),
                child: Column(
                  children: [
                    const Center(
                        child: GFLoader(
                      type: GFLoaderType.custom,
                      child: SizedBox(
                        width: 300,
                        height: 300,
                        child: Image(
                          image: AssetImage('assets/success.gif'),
                          height: 300,
                          width: 300,
                        ),
                      ),
                    )),
                    Text(
                      companyController.text,
                      style: const TextStyle(
                          fontFamily: font1,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Registered',
                      style: TextStyle(
                          fontFamily: font1,
                          fontSize: 35,
                          fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Successfully',
                      style: TextStyle(fontFamily: font1, fontSize: 20),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        MaterialButton(
                          height: 50,
                          minWidth: 40,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(180.0),
                              side: const BorderSide(color: Colors.white)),
                          color: const Color.fromRGBO(3, 9, 23, 1),
                          onPressed: () => [
                            {
                              Navigator.pop(context),
                              Navigator.popUntil(
                                  context, (_) => !Navigator.canPop(context)),
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Login(),
                                ),
                              ),
                            }
                          ],
                          child: Row(
                            children: [
                              Text(
                                'Back To Login',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width /
                                            100 *
                                            5.0),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                )),
          );
        });
      });

  show() {
    showModalBottomSheet(
        isDismissible: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(50.0)),
        ),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                height: 210,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topLeft,
                    colors: [
                      Colors.blue.shade800,
                      Colors.blue.shade700,
                      Colors.blue.shade600,
                      Colors.blue.shade400,
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.elliptical(50, 50.0)),
                ),
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 5,
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel),
                      color: Colors.white,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Center(
                        child: Text(
                      'ENTER OTP',
                      style: TextStyle(
                          color: Colors.white, fontFamily: font1, fontSize: 20),
                    )),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Center(
                              child: OTPTextField(
                                length: 6,
                                width: MediaQuery.of(context).size.width,
                                textFieldAlignment:
                                    MainAxisAlignment.spaceAround,
                                fieldWidth: 40,
                                fieldStyle: FieldStyle.box,
                                style: const TextStyle(
                                    fontSize: 17, color: Colors.white),
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
                            otp == null
                                ? Container(
                                    // width: MediaQuery.of(context).size.width/2.25,
                                    child: Card(
                                      color: Colors.transparent,
                                      elevation: 80,
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.grey)),
                                        child: const Text(
                                          'SUBMIT',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        onPressed: null,
                                        //  color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : Container(
                                    // width: MediaQuery.of(context).size.width/2.25,
                                    child: Card(
                                      color: Colors.transparent,
                                      elevation: 80,
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.black)),
                                        child: const Text(
                                          'SUBMIT',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        onPressed: () {
                                          LoaderFull(context);
                                          SendOtp();
                                          setState(() {
                                            btnstate = 'hide';
                                          });
                                        },
                                        // color: Colors.black,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  ScrollController? _scrollController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController();
    _register();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
    });
  }

  String? otp;

  Future SendOtp() async {
    try {
      var uri = "$adminurl/process/controller/create_acc_api.php";
      final response = await http.post(Uri.parse(uri), body: {
        'type': 'hrm_add',
        'cname': companyController.text,
        'uname': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'otp': otp
      }, headers: <String, String>{
        'Accept': 'application/json',
      });

      var mydata = json.decode(response.body);
      if (debug == 'yes') {
        //print(mydata);
      }
      if (mydata.containsKey('status')) {
        if (mydata['status'] == true) {
          Navigator.pop(context);
          Fluttertoast.showToast(
              msg: mydata['message'],
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);
          Navigator.pop(context);
          showoncmplete();
        } else if (mydata['status'] == false) {
          Navigator.pop(context);
          Fluttertoast.showToast(
              msg: mydata['message'],
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);
          Navigator.pop(context);
        }
      }
    } catch (error) {
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg:
              'Network Issues, try again after sometime, please retry after sometime',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 10,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.

  //for loader

  var userData;
  var userDatan;
  var id;
  var db;
  var data;
  var datan;
  String? dbn;
  final emailController = TextEditingController(),
      nameController = TextEditingController(),
      companyController = TextEditingController(),
      totalempController = TextEditingController(),
      phoneController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    companyController.dispose();
    totalempController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  String? btnval;

  Future<void> LoaderFull(BuildContext context) async {
    return await showDialog(
        // barrierDismissible: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return WillPopScope(
              onWillPop: () async => false,
              child: const AlertDialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                content: SizedBox(
                    height: 60,
                    child: Center(
                      child: GFLoader(
                        type: GFLoaderType.custom,
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: Image(
                            image: AssetImage('assets/newlod.gif'),
                            height: 200,
                            width: 200,
                          ),
                        ),
                      ),
                    )),
              ),
            );
          });
        });
  }

  load() {
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

  proceedButton() async {
    if (emailController.text.isEmpty ||
        nameController.text.isEmpty ||
        companyController.text.isEmpty ||
        phoneController.text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Please fill all required fields",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    if (!emailController.text.contains("@")) {
      Fluttertoast.showToast(
          msg: "Please Enter a valid email address",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    LoaderFull(context);
    try {
      var uri = "$adminurl/process/controller/create_acc_api.php";
      final response = await http.post(Uri.parse(uri), body: {
        'type': 'acc_validate',
        'cname': companyController.text,
        'uname': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'acc_type': 'EZHRM'
      }, headers: <String, String>{
        'Accept': 'application/json',
      });

      var mydata = json.decode(response.body);
      if (debug == 'yes') {
        //print(mydata);
      }
      if (mydata.containsKey('status')) {
        if (mydata['status'] == true) {
          Fluttertoast.showToast(
              msg: mydata['response'],
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);
          Navigator.pop(context);
          show();
        } else if (mydata['status'] == false) {
          Fluttertoast.showToast(
              msg: mydata['response'],
              //  msg: "aman soni",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);
          Navigator.pop(context);
        }
      }
    } catch (error) {
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg:
              ' Network Issues, try again after sometime, please retry after sometime',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 10,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  DateTime? _lastPressedAt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff072a99),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 20),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Register Your Company",
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
                  child: Text("All Fields are Mandatory",
                      style: TextStyle(
                        color: Color(0xff072a99),
                      ))),
              CustomTextField(
                hint: "Name",
                controller: nameController,
              ),
              CustomTextField(
                controller: phoneController,
                hint: "Phone",
                textInputType: TextInputType.phone,
              ),
              CustomTextField(
                hint: "Email ID",
                textInputType: TextInputType.emailAddress,
                controller: emailController,
              ),
              CustomTextField(
                hint: "Company Name",
                callBack: proceedButton,
                controller: companyController,
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: proceedButton,
                          child: const Text("Proceed"),
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
                        const SizedBox(height: 6),
                      ])),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            text:
                                "If your company is already registered, please click on ",
                            style: const TextStyle(
                              color: Color(0xff072a99),
                            ),
                            children: [
                              TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Navigator.pop(context),
                                text: "login",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(
                                text: " button below",
                                style: TextStyle(
                                  color: Color(0xff072a99),
                                ),
                              ),
                            ]),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Login"),
                      style: ButtonStyle(
                        padding:
                            MaterialStateProperty.all(const EdgeInsets.all(15)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                        backgroundColor: MaterialStateProperty.all(
                          const Color(0xff072a99),
                        ),
                        elevation: MaterialStateProperty.all(8),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
