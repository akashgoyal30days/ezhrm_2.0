import 'dart:io';
import 'package:camera/camera.dart';
import 'package:ezhrm/bottombar_ios.dart/bottombar_ios.dart';
import 'package:ezhrm/reimbursment.dart';
import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ezhrm/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path1;
import 'dart:math' as Math;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'constants.dart';
import 'main.dart';

class ReimBursement extends StatefulWidget {
  const ReimBursement({Key? key}) : super(key: key);

  @override
  _ReimBursementState createState() => _ReimBursementState();
}

class _ReimBursementState extends State<ReimBursement>
    with SingleTickerProviderStateMixin<ReimBursement> {
  bool visible = false;
  Map? data;
  Map? datanew;
  Map? expnew;
  List? expnewdata;
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
  String? img64;
  File? _image;
  File? imageResized;
  final picker = ImagePicker();
  dynamic amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _value1;
  String? _value2;

  String? imgpath;
  final GlobalKey _globalKey = GlobalKey();
  CameraController? _controllercam;
  Future<void>? _initializeControllerFuture;
  bool iscameraExcute = false;
  bool forImageShow = false;
  String? imgnew;

  // Core Camera
  void executecam() async {
    Navigator.pop(context);
    // To display the current output from the Camera,
    // create a CameraController.
    _controllercam = CameraController(
      cameras[0],
      // Define the resolution to use.
      ResolutionPreset.medium,
    );
    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controllercam!.initialize();
    getImage();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controllercam!.dispose();
    super.dispose();
  }

  void afterimagecatch() async {
    //print("amansoni afterimageCatch");
    try {
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;
      // Construct the path where the image should be saved using the
      // pattern package.
      imgpath = path1.join(
        // Store the picture in the temp directory.
        // Find the temp directory using the `path_provider` plugin.
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.png',
      );

      var image = await _controllercam!.takePicture();
      final bytes = File(imgpath!).readAsBytesSync();
      imgnew = base64Encode(bytes);
      //print(imgpath.toString());
      //print(Math.pi.toString());
      if (imgpath != null) {
        setState(() {});
      }
      // if(facereco=='1'){
      //   MarkAttImg();
      // }else{
      //    ReqAttwithImg();
      //  }
    } catch (e) {
      // If an error occurs, log the error to the console.
      //print("aman");
      //print(e);
    }
  }

  Future getImage() async {
    // final pickedFile = await picker.getImage(source: ImageSource.camera,
    //     imageQuality: 20);
    // final bytes = await File(pickedFile.path).readAsBytesSync();
    final bytes = File(imgpath!).readAsBytesSync();
    img64 = base64Encode(bytes);
    //  //print(img64.substring(0, img64.length));
    setState(() {
      _image = File(imgpath!);
    });
    if (_image != null) {
      Fluttertoast.showToast(
          msg: "Item Selected",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0);
    }
  }

  Future getImagegallery() async {
    final pickedFilenew =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 30);
    final bytesnew = File(pickedFilenew!.path).readAsBytesSync();
    img64 = base64Encode(bytesnew);
    //  //print(img64.substring(0, img64.length));
    setState(() {
      _image = File(
        pickedFilenew.path,
      );
    });
  }

  final List<String> leaveList = <String>[
    "Company",
    "Client",
  ];
  final List<String> leaveListval = <String>[
    "1",
    "2",
  ];
  @override
  void initState() {
    getEmail();
    fetchExp();
    fetchCredit();
    super.initState();
    _value1 = leaveListval[0];
    _value2 = leaveListval[1];
  }

  Clear() {
    reasonController.clear();
    amountController.clear();
    _image = null;
    // Navigator.of(context).pop();
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

  Future Reim() async {
    var urii = "$customurl/controller/process/app/extras.php";
    final responseneww = await http.post(Uri.parse(urii), body: {
      'uid': SharedPreferencesInstance.getString('uid'),
      'amount': '${amountController.text}',
      'exp_against': _mycredit,
      if (_mycredit != '1') 'client_id': '' else 'client_id': _mylist,
      'cid': SharedPreferencesInstance.getString('comp_id'),
      'type': 'apply_reimbursement',
      'date': customFormat.format(selectedDate),
      'desc': '${reasonController.text}',
      if (img64 == null)
        'img_bill': ''
      else if (img64 != null)
        'img_bill': img64,
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
          Fluttertoast.showToast(
              msg: "Your reimbursement is applied",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.white,
              textColor: Colors.black,
              fontSize: 16.0);
          _mycredit = null;
          _mylist = null;
          reasonController.clear();
          amountController.clear();
          _image = null;
        });
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ApplyReim()));
      } else if (newdata['status'] == false) {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ApplyReim()));
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.fixed,
            elevation: 0,
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.blue.shade50.withOpacity(0.5),
            content: Center(
                child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 2.5,
                ),
                const Icon(
                  Icons.close,
                  size: 60,
                  color: Colors.red,
                ),
                Text(
                  '${newdata['error']}',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3),
                ),
              ],
            )),
          ));
          _mycredit = null;
          _mylist = null;
          reasonController.clear();
        });
      }
      if (img64 == null && newdata['status'] == true) {
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
                  color: Colors.red,
                ),
                const Text(
                  'Reimbursement Applied',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3),
                ),
                const Text(
                  'Applied Without Bill',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3),
                ),
              ],
            )),
          ));
          _mycredit = null;
          _mylist = null;
          reasonController.clear();
        });
      }
    }
    //  //debugPrint(newdata.toString());
    // //print('from- ${customFormat.format(selectedDate)}');
    // //print('To- ${customFormatnew.format(selectedDatenew)}');
  }

  Future fetchCredit() async {
    try {
      var urii = "$customurl/controller/process/app/extras.php";
      final responsenew = await http.post(Uri.parse(urii), body: {
        'uid': SharedPreferencesInstance.getString('uid'),
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'type': 'fetch_active_client'
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
    } catch (error) {
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

  Future fetchExp() async {
    try {
      var urii = "$customurl/controller/process/app/extras.php";
      final responseexp = await http.post(Uri.parse(urii), body: {
        'uid': SharedPreferencesInstance.getString('uid'),
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'type': 'fetch_active_expense'
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      expnew = json.decode(responseexp.body);
      setState(() {
        visible = true;
        expnewdata = expnew!["data"];
        visible = true;
      });
      if (debug == 'yes') {
        //debugPrint('expnew- ${expnew.toString()}');
        //debugPrint('expnewdata- ${expnewdata.toString()}');
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
        lastDate: DateTime.now());

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const bottombar_ios(),
      appBar: AppBar(
        elevation: 0,
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
        bottomOpacity: 0,
        centerTitle: true,
        title: const Text(
          "Apply Reimbursement",
          style: TextStyle(color: Colors.white, fontFamily: font1),
        ),
      ),
      body: iscameraExcute == true
          ? Stack(children: <Widget>[
              if (iscameraExcute == true)
                FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      // If the Future is complete, display the preview.
                      return CameraPreview(_controllercam!);
                    } else {
                      // Otherwise, display a loading indicator.
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              if (forImageShow == true)
                RepaintBoundary(
                  key: _globalKey,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(Math.pi),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(File(imgpath!)),
                            fit: BoxFit.cover,
                          ),
                        ),
                        height: MediaQuery.of(context).size.height,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ),
              Column(
                children: <Widget>[
                  const Spacer(),
                  Row(
                    children: [
                      if (forImageShow == false)
                        Padding(
                          padding: const EdgeInsets.only(left: 60, bottom: 20),
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
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: TextButton(
                                //amanhere
                                onPressed: () {
                                  forImageShow = true;
                                  afterimagecatch();
                                },
                                child: Row(
                                  children: const [
                                    Text(
                                      "Capture",
                                      style: TextStyle(
                                          fontSize: 14,
                                          letterSpacing: 2.2,
                                          color: Colors.white,
                                          fontFamily: font1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (forImageShow == true)
                        Padding(
                          padding: const EdgeInsets.only(left: 70, bottom: 20),
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
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: TextButton(
                                //aman here
                                onPressed: () {
                                  _controllercam!.dispose();
                                  getImage();

                                  iscameraExcute = false;
                                },
                                child: Row(
                                  children: const [
                                    Text(
                                      "Ok",
                                      style: TextStyle(
                                          fontSize: 14,
                                          letterSpacing: 2.2,
                                          color: Colors.white,
                                          fontFamily: font1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(left: 60, bottom: 20),
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            // gradient: LinearGradient(
                            //   begin: Alignment.topCenter,
                            //   end: Alignment.bottomCenter,
                            //   colors: [Colors.black,Colors.indigo],
                            // ),
                            color: Colors.black,
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: TextButton(
                              onPressed: () {
                                _controllercam!.dispose();
                                setState(() {
                                  iscameraExcute = false;
                                  imgpath = "";
                                  img64 = "";
                                  _image = null;
                                });
                              },
                              child: Row(
                                children: const [
                                  Text(
                                    "Cancel",
                                    style: TextStyle(
                                        fontSize: 14,
                                        letterSpacing: 2.2,
                                        color: Colors.white,
                                        fontFamily: font1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ])
          : datanew == null
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
              : Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Card(
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 9, 10, 0),
                            child: Container(
                              padding: const EdgeInsets.only(
                                  left: 15, right: 15, top: 0),
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    child: DropdownButtonHideUnderline(
                                      child: ButtonTheme(
                                        alignedDropdown: true,
                                        child: DropdownButton<String>(
                                          value: _mycredit,
                                          iconSize: 30,
                                          icon: (null),
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 16,
                                          ),
                                          hint: const Text('Select Type *'),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _mycredit = newValue;
                                              if (debug == 'yes') {
                                                //print(_mycredit);
                                              }
                                            });
                                          },
                                          items: expnewdata?.map((item) {
                                                return DropdownMenuItem(
                                                  child: Text(item['label']),
                                                  value: item['id'].toString(),
                                                );
                                              }).toList() ??
                                              [],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      _mycredit != '1'
                          ? const Center(child: SizedBox())
                          : Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Card(
                                elevation: 5,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 9, 10, 0),
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        left: 15, right: 15, top: 0),
                                    color: Colors.white,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Expanded(
                                          child: DropdownButtonHideUnderline(
                                            child: ButtonTheme(
                                              alignedDropdown: true,
                                              child: DropdownButton<String>(
                                                value: _mylist,
                                                iconSize: 30,
                                                icon: (null),
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 16,
                                                ),
                                                hint: userDatanew == null
                                                    ? const Center(
                                                        child: Text(
                                                            'No Clent Available'),
                                                      )
                                                    : const Text(
                                                        'Select Client *'),
                                                onChanged: (String? newValue) {
                                                  setState(() {
                                                    _mylist = newValue;
                                                    //  //print(_mylist);
                                                  });
                                                },
                                                items: userDatanew?.map((item) {
                                                      return DropdownMenuItem(
                                                        child: Text(item[
                                                            'company_name']),
                                                        value: item['id']
                                                            .toString(),
                                                      );
                                                    }).toList() ??
                                                    [],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width / 2 - 18,
                              color: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(5, 5, 0, 0),
                                child: Container(
                                  color: Colors.transparent,
                                  height: 65,
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                    elevation: 10,
                                    shadowColor: Colors.white,
                                    color: Colors.white,
                                    child: Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            showPicker(
                                                context); // Call Function that has showDatePicker()
                                          },
                                          child: IgnorePointer(
                                            child: TextFormField(
                                              cursorColor: Colors.blueAccent,
                                              decoration: InputDecoration(
                                                  enabledBorder:
                                                      const OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(1)),
                                                    borderSide: BorderSide(
                                                        color: Colors.white,
                                                        width: 2.0),
                                                  ),
                                                  border:
                                                      const OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                  ),
                                                  //icon: Icon(Icons.calendar_today_sharp, color: Colors.blueAccent,),
                                                  hintText: customFormat
                                                      .format(selectedDate)),
                                              onSaved: (String? val) {
                                                customFormat
                                                    .format(selectedDate);
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                              child: Container(
                                height: 70,
                                width:
                                    MediaQuery.of(context).size.width / 2 - 30,
                                color: Colors.transparent,
                                child: Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0.0),
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                    child: TextFormField(
                                      cursorColor: Colors.blueAccent,
                                      decoration: const InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(0)),
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(0),
                                            ),
                                          ),
                                          labelText: 'Amount (In ₹)',
                                          labelStyle: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black,
                                              fontFamily: font1)),
                                      controller: amountController,
                                      keyboardType: TextInputType.number,
                                      style:
                                          const TextStyle(color: Colors.black),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Amount Cannot Be Empty';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: Container(
                          color: Colors.transparent,
                          child: Card(
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                              child: TextFormField(
                                cursorColor: Colors.blueAccent,
                                decoration: const InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(0)),
                                      borderSide: BorderSide(
                                          color: Colors.white, width: 1.0),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(0),
                                      ),
                                    ),
                                    labelText: 'Description',
                                    labelStyle: TextStyle(
                                        fontSize: 18,
                                        fontFamily: font1,
                                        color: Colors.black)),
                                controller: reasonController,
                                style: const TextStyle(color: Colors.black),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Description Cannot Be Empty';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                        child: Container(
                          color: Colors.transparent,
                          width: MediaQuery.of(context).size.width,
                          child: Card(
                            elevation: 0,
                            color: Colors.transparent,
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 6, 0, 5),
                                  child: Stack(
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 190,
                                        child: GestureDetector(
                                          onTap: () => showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  backgroundColor: Colors.white,
                                                  elevation: 100,
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      10.0))),
                                                  title: const Text(
                                                      'Upload Image',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  content:
                                                      SingleChildScrollView(
                                                    child: ListBody(
                                                      children: const <Widget>[
                                                        Text(
                                                            "Choose The Method You Want To Use For Image"),
                                                      ],
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    ElevatedButton(
                                                      style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all<Color>(
                                                                      Colors
                                                                          .amber)),
                                                      onPressed: () {
                                                        executecam();
                                                        setState(() {
                                                          iscameraExcute = true;
                                                        });
                                                      },
                                                      //  color: Colors.amber,
                                                      // elevation: 20,
                                                      child: Row(
                                                        children: const [
                                                          Icon(
                                                            Icons.camera_alt,
                                                            color: Colors.white,
                                                          ),
                                                          Text(
                                                            "Camera",
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                letterSpacing:
                                                                    2.2,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all<Color>(
                                                                      Colors
                                                                          .blue)),
                                                      onPressed: () {
                                                        getImagegallery();
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Row(
                                                        children: const [
                                                          Icon(Icons.image),
                                                          Text(
                                                            "Gallery",
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                letterSpacing:
                                                                    2.2,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all<Color>(
                                                                      Colors
                                                                          .red)),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Row(
                                                        children: const [
                                                          Icon(Icons.cancel),
                                                          Text(
                                                            "Cancel",
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                letterSpacing:
                                                                    2.2,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }),
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(0.0),
                                            ),
                                            color: Colors.white,
                                            elevation: 10,
                                            child: Container(
                                              child: _image != null
                                                  ? const Text('')
                                                  : Column(
                                                      children: [
                                                        const SizedBox(
                                                          height: 50,
                                                        ),
                                                        Center(
                                                          child:
                                                              FloatingActionButton(
                                                            onPressed: () {},
                                                            heroTag: null,
                                                            child: Image.asset(
                                                              'assets/uploaddd.png',
                                                              height: 100,
                                                              width: 100,
                                                            ),
                                                            elevation: 0,
                                                            backgroundColor:
                                                                Colors.white,
                                                          ),
                                                        ),
                                                        const Text(
                                                            'Upload Bill Image')
                                                      ],
                                                    ),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.85,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                    width: 0,
                                                    color: Colors.transparent,
                                                  ),
                                                  shape: BoxShape.rectangle,
                                                  image: DecorationImage(
                                                      image:
                                                          FileImage(_image!))),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: _mycredit == null
          ? const SizedBox()
          : Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue, Colors.indigo],
                ),
              ),
              child: FloatingActionButton(
                backgroundColor: Colors.transparent,
                child: const Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: Colors.white,
                ),
                elevation: 10,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      behavior: SnackBarBehavior.fixed,
                      elevation: 0,
                      duration: const Duration(hours: 1),
                      backgroundColor: Colors.blue.shade50.withOpacity(0.5),
                      content: Center(
                          child: Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 2.5,
                          ),
                          const LinearProgressIndicator(
                            backgroundColor: Colors.transparent,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            'Uploading',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3),
                          ),
                        ],
                      )),
                    ));
                    Reim();
                    setState(() {
                      userData = null;
                      fetchExp();
                    });
                  }
                },
              ),
            ),
    );
  }
}
