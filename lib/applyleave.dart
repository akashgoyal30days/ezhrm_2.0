import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:ezhrm/bottombar_ios.dart/bottombar_ios.dart';
import 'package:ezhrm/camera_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';

import 'constants.dart';
import 'drawer.dart';
import 'services/shared_preferences_singleton.dart';

class ApplyLeave extends StatefulWidget {
  const ApplyLeave({Key? key}) : super(key: key);

  @override
  _ApplyLeaveState createState() => _ApplyLeaveState();
}

class _ApplyLeaveState extends State<ApplyLeave>
    with SingleTickerProviderStateMixin<ApplyLeave> {
  bool visible = true;
  Map? data, leaveQuota;
  Map? datanew;
  List userData = [];
  List userDatanew = [];
  String? _mylist;
  String? _mycredit;
  String? username;
  String? email;
  String? ppic;
  String? ppic2;
  String? uid;
  String? cid;
  TextEditingController reasonController = TextEditingController();
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
    fetchList();
    fetchCredit();
    fetchQuota();
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

  Future fetchList() async {
    try {
      var uri = "$customurl/controller/process/app/leave.php";
      final response = await http.post(Uri.parse(uri), body: {
        'uid': SharedPreferencesInstance.getString('uid'),
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'type': 'fetch_quota'
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      data = json.decode(response.body);
      log("Quota Data :" + data.toString());
      setState(() {
        visible = true;
        userData = data!["data"];
        visible = true;
      });
      if (debug == 'yes') {
        //debugPrint(userData.toString());
      }
    } catch (error) {
      log("ERROR : " + error.toString());
    }
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
      log("Credit Data :" + datanew.toString());

      setState(() {
        visible = true;
        userDatanew = datanew!["data"];
        if (userDatanew.isEmpty) {
          setState(() {
            userDatanew = [];
          });
        }
        visible = true;
      });
      if (debug == 'yes') {
        //debugPrint(userDatanew.toString());
        //debugPrint(datanew.toString());
      }
    } catch (error) {
      log("ERROR : " + error.toString());
    }
  }

  String? resulted;
  DateTime selectedDate = DateTime.now();
  DateTime selectedDatenew = DateTime.now();
  var customFormat = DateFormat('yyyy-MM-dd');
  var customFormatnew = DateFormat('yyyy-MM-dd');
  Future<void> showPicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0XFF072A99), // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Color(0XFF072A99),

              /// body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0XFF072A99), //text color
              ),
            ),
          ),
          child: child!,
        );
      },
      initialDate: selectedDate,
      firstDate: DateTime(2021),
      lastDate: DateTime(2050),
    );
    if (picked != selectedDate) {
      setState(() {
        selectedDate = picked!;
        selectedDatenew = selectedDate;
      });
    }
  }

  Future<void> showPickernew(BuildContext context) async {
    final DateTime? pickednew = await showDatePicker(
        context: context,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0XFF072A99), // header background color
                onPrimary: Colors.white, // header text color
                onSurface: Color(0XFF072A99),

                /// body text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0XFF072A99), //text color
                ),
              ),
            ),
            child: child!,
          );
        },
        initialDate: selectedDatenew,
        firstDate: DateTime(2021),
        lastDate: DateTime(2050));

    if (pickednew != selectedDatenew) {
      setState(() {
        var difference = pickednew!.difference(selectedDate).inDays;

        if (0 > difference) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              '"To Date" Should Not Be Earlier Than "From Date"',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
          ));
        } else {
          resulted = "Good Day.";
          selectedDatenew = pickednew;
        }
      });
    }
  }

  var imageBytes;
  openGallery() async {
    var file =
        await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    imageBytes = await file.readAsBytes();

    filepath = file.path.toString().substring(file.path.toString().length - 1);
    filename = file.path.split('/').last.toString();
    filetypename =
        file.path.split('/').last.toString().split('.').last.toString();
    mimetype = lookupMimeType(filetypename).toString();
    log("Filepathlast : " + filepath.toString());

    log("Filetype : " + filetypename.toString());
    log("Mimetype : " + mimetype.toString());
    imagefile = File(file.path);
    isfileselected = true;

    setState(() {});
  }

  selectdocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf'],
    );
    File file = File(result!.files.single.path.toString());

    filepath = file.path.toString().substring(file.path.toString().length - 1);
    filename = file.path.split('/').last.toString();
    filetypename =
        file.path.split('/').last.toString().split('.').last.toString();
    mimetype = lookupMimeType(filetypename).toString();
    log("Filepathlast : " + filepath.toString());

    log("Filetype : " + filetypename.toString());
    log("Mimetype : " + mimetype.toString());

    setState(() {});

    if (file == null) return;
    imageBytes = await file.readAsBytes();
    if (filepath.toString() == 'f') {
      pdffile = file;
      isfileselected = true;
      log("PDF Path : " + pdffile!.path.toString());
    } else {
      imagefile = file;
      isfileselected = true;
    }
    setState(() {});
  }

  openCamera() async {
    imageBytes = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const CameraScreen(cameraType: CameraType.rearCamera),
          ),
        ) ??
        imageBytes;

    final tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/image.png').create();
    file.writeAsBytesSync(imageBytes);

    imagefile = File(file.path);
    filename = "image.png";
    isfileselected = true;
    setState(() {});
  }

  showoptionsheet() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
            height: 200,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(children: [
                const SizedBox(
                  height: 10,
                ),
                MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    textColor: Colors.white,
                    color: themecolor,
                    elevation: 5,
                    onPressed: () {
                      Navigator.pop(context);

                      selectdocument();
                    },
                    child: const Text("Select Document")),
                const SizedBox(
                  height: 10,
                ),
                MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    textColor: Colors.white,
                    color: themecolor,
                    elevation: 5,
                    onPressed: () {
                      Navigator.pop(context);
                      openCamera();
                    },
                    child: const Text("Select from Camera")),
                const SizedBox(
                  height: 10,
                ),
                MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    textColor: Colors.white,
                    color: themecolor,
                    elevation: 5,
                    onPressed: () {
                      Navigator.pop(context);

                      openGallery();
                    },
                    child: const Text("Select from Gallery")),
              ]),
            ),
          );
        });
  }

  showLoaderDialogwithName(BuildContext context, String message) {
    AlertDialog alert = AlertDialog(
      contentPadding: const EdgeInsets.all(15),
      content: Row(
        children: [
          const CircularProgressIndicator(
            color: Colors.black,
          ),
          Container(
              margin: const EdgeInsets.only(left: 25),
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              )),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  String mimetype = '';
  String filepath = '';
  String filename = '';
  String filetypename = '';

  File? pdffile;
  File? imagefile;
  bool isfileselected = false;

  leave() async {
    log("Applying Leave...");
    try {
      var urii = "$customurl/controller/process/app/leave.php";
      // final responseneww = await http.post(Uri.parse(uri)i, body: {
      //   'uid': SharedPreferencesInstance.getString('uid'),
      //   'cid': SharedPreferencesInstance.getString('comp_id'),
      //   'type': 'apply_leave',
      //   'date_from': customFormat.format(selectedDate),
      //   if (_mycredit == '2' || _mycredit == '6')
      //     'date_to': customFormat.format(selectedDate)
      //   else if (_mycredit == '1')
      //     'date_to': customFormatnew.format(selectedDatenew)
      //   else if (_mycredit == '5')
      //     'date_to': customFormatnew.format(selectedDatenew),
      //   'credit': _mycredit,
      //   'avail_leave': _mylist,
      //   'reason': reasonController.text
      // },
      var headers = {
        'Accept': 'application/json',
        'Content-Type': mimetype.toString()
      };
      var request = http.MultipartRequest("POST", Uri.parse(urii));
      request.headers.addAll(headers);

      request.fields['uid'] = SharedPreferencesInstance.getString('uid');
      request.fields['cid'] = SharedPreferencesInstance.getString('comp_id');
      request.fields['type'] = 'apply_leave';
      request.fields['date_from'] = customFormat.format(selectedDate);
      if (_mycredit == '2' || _mycredit == '6') {
        request.fields['date_to'] = customFormat.format(selectedDate);
      } else if (_mycredit == '1') {
        request.fields['date_to'] = customFormatnew.format(selectedDatenew);
      } else if (_mycredit == '5') {
        request.fields['date_to'] = customFormatnew.format(selectedDatenew);
      }
      request.fields['credit'] = _mycredit!;
      request.fields['avail_leave'] = _mylist!;
      request.fields['reason'] = reasonController.text;

      if (isfileselected == true) {
        MultipartFile multipartFile = await http.MultipartFile.fromPath(
          'doc_file',
          filepath.toString() == 'f' ? pdffile!.path : imagefile!.path,
          filename: filename,
          contentType: MediaType('application', 'pdf'),
        );

        // add file to multipart
        request.files.add(multipartFile);
      }

      http.Response responseneww =
          await http.Response.fromStream(await request.send());

      log("Data we are Sending... : " +
          {
            'uid': SharedPreferencesInstance.getString('uid'),
            'cid': SharedPreferencesInstance.getString('comp_id'),
            'type': 'apply_leave',
            'date_from': customFormat.format(selectedDate),
            if (_mycredit == '2' || _mycredit == '6')
              'date_to': customFormat.format(selectedDate)
            else if (_mycredit == '1')
              'date_to': customFormatnew.format(selectedDatenew)
            else if (_mycredit == '5')
              'date_to': customFormatnew.format(selectedDatenew),
            'credit': _mycredit,
            'avail_leave': _mylist,
            'reason': reasonController.text
          }.toString());
      newdata = json.decode(responseneww.body);
      log("Leave Data : " + newdata.toString());
      if (newdata.containsKey('status')) {
        setState(() {
          // message =  mydataatt['msg'];
          visible = false;
        });
        if (newdata['status'] == true) {
          Navigator.pop(context);
          setState(
            () {
              Fluttertoast.showToast(
                  msg: "Successfully Applied",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 2,
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  fontSize: 16.0);
              _mycredit = null;
              _mylist = null;
              reasonController.clear();
            },
          );
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: ((context) => const ApplyLeave())));
        } else if (newdata['status'] == false) {
          Navigator.pop(context);
          setState(() {
            Fluttertoast.showToast(
                msg: "${newdata['error']}",
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
      if (debug == 'yes') {
        //debugPrint(newdata.toString());
        //print('from- ${customFormat.format(selectedDate)}');
        //print('To- ${customFormatnew.format(selectedDatenew)}');
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

  List? quota;

  Future fetchQuota() async {
    try {
      var uri = "$customurl/controller/process/app/leave.php";
      final response = await http.post(Uri.parse(uri), body: {
        'uid': SharedPreferencesInstance.getString('uid'),
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'type': 'fetch_quota'
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      data = json.decode(response.body);
      setState(() {
        quota = data!["data"];
      });
      if (quota!.isNotEmpty) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Leave Quota not assigned, please contact admin",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red));
    } catch (error) {
//
    }
  }

  String selectedCreditName = "";
  String? selectedItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const bottombar_ios(),
      drawer: CustomDrawer(currentScreen: AvailableDrawerScreens.applyLeave),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Apply Leave",
          style: TextStyle(
            color: Colors.white,
          ),
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
      body: quota == null
          ? Center(
              child: LoadingAnimationWidget.flickr(
                leftDotColor: Colors.indigo,
                rightDotColor: Colors.blue,
                size: 60,
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(8),
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10.0, top: 8),
                  child: Text(
                    "Select Leave Type",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff072a99),
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(10.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      underline: const SizedBox(),
                      hint: const Text("Select Leave Type"),
                      items: quota!.isEmpty
                          ? []
                          : userData.map((item) {
                                return DropdownMenuItem(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['type'],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontFamily: font1,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        " Available: " +
                                            (item['avail_quota']?.toString() ??
                                                ""),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontFamily: font1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  value: item['id'].toString(),
                                );
                              }).toList() ??
                              [],
                      value: _mylist,
                      onChanged: (String? newValue) {
                        setState(() {
                          _mylist = newValue;
                        });
                      },
                    ),
                  ),
                ),
                const Padding(
                    padding: EdgeInsets.only(left: 10.0, top: 8),
                    child: Text("Select Credit Type",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff072a99),
                        ))),
                Card(
                  margin: const EdgeInsets.all(10.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      underline: const SizedBox(),
                      hint: const Text(" Select Credit Type"),
                      items: userDatanew.isEmpty
                          ? []
                          : userDatanew.map((item) {
                              return DropdownMenuItem(
                                child: Text(
                                  item['credit'].toString(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontFamily: font1,
                                  ),
                                ),
                                value: item["id"].toString(),
                              );
                            }).toList(),
                      value: selectedItem,
                      onChanged: (String? newValue) {
                        selectedItem = newValue;
                        var item = userDatanew[userDatanew.indexWhere(
                            (element) =>
                                element["id"].toString() ==
                                newValue.toString())];
                        setState(() {
                          selectedCreditName = item['credit'].toString();
                          _mycredit = item['id'].toString();
                        });
                        print(selectedCreditName);
                        print(_mycredit);
                      },
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Select Date",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff072a99),
                      )),
                ),
                Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                showPicker(context);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text("From",
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff072a99),
                                      )),
                                  const SizedBox(height: 10),
                                  Text(
                                    DateFormat("dd MMM, y")
                                        .format(selectedDate),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                const VerticalDivider(
                                  indent: 4,
                                  endIndent: 4,
                                  color: Color(0x99072a99),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if ((selectedCreditName
                                              .contains("Half Day") ||
                                          selectedCreditName.contains("Short")))
                                        return;
                                      showPickernew(context);
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text("To",
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w500,
                                              color: ((selectedCreditName
                                                          .contains(
                                                              "Half Day") ||
                                                      selectedCreditName
                                                          .contains("Short")))
                                                  ? Colors.grey
                                                  : const Color(0xff072a99),
                                            )),
                                        const SizedBox(height: 10),
                                        Text(
                                            DateFormat("dd MMM, y")
                                                .format(selectedDatenew),
                                            style: TextStyle(
                                              color: ((selectedCreditName
                                                          .contains(
                                                              "Half Day") ||
                                                      selectedCreditName
                                                          .contains("Short")))
                                                  ? Colors.grey
                                                  : Colors.black,
                                            )),
                                      ],
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
                const SizedBox(height: 20),
                const Padding(
                    padding: EdgeInsets.only(left: 10.0, top: 8),
                    child: Text("Reason for Leave",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff072a99),
                        ))),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: reasonController,
                    cursorColor: const Color(0x33072a99),
                    keyboardType: TextInputType.name,
                    onSubmitted: (_) {},
                    minLines: 3,
                    maxLines: 15,
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(color: Color(0xff072a99)),
                    decoration: InputDecoration(
                      fillColor: const Color(0x33072a99),
                      filled: true,
                      hintText: "State your reason here",
                      contentPadding: const EdgeInsets.all(10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(11),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Choose Document / Image",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff072a99),
                        )),
                  ),
                ),
                imageBytes == null
                    ? GestureDetector(
                        onTap: () {
                          showoptionsheet();
                        },
                        // onTap: () => showDialog(
                        //     context: context,
                        //     builder: (context) => DocumentTypePickerDialogBox(
                        //           camera: openCamera,
                        //           gallery: openGallery,
                        //         )),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                SizedBox(height: 20),
                                Icon(
                                  Icons.upload_file_outlined,
                                  size: 30,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Click to Upload an Image',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ))
                    : Column(
                        children: [
                          filepath.toString() != 'f'
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(imageBytes),
                                  ),
                                )
                              : Text(filename.toString()),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  imageBytes = null;
                                  setState(() {});
                                },
                                style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.red),
                                ),
                                icon: const Icon(Icons.clear),
                                label: const Text("Remove"),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  showoptionsheet();
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text("Replace"),
                              ),
                            ],
                          ),
                        ],
                      ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (reasonController.text.isNotEmpty) {
                        showLoaderDialogwithName(context, "Applying..");
                        leave();
                      } else {
                        Fluttertoast.showToast(
                            msg: "Please fill all required fields..");
                      }
                    },
                    child: const Text("Apply Leave"),
                    style: ButtonStyle(
                      padding:
                          MaterialStateProperty.all(const EdgeInsets.all(15)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                      backgroundColor: MaterialStateProperty.all(
                        const Color(0xff072a99),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
      // //bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
