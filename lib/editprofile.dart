import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ezhrm/custom_text_field.dart';
import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:ezhrm/upload_type_picker.dart';
import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:getwidget/types/gf_loader_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'camera_screen.dart';
import 'change_password_screen.dart';
import 'constants.dart';

int? _value;

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile>
    with SingleTickerProviderStateMixin<EditProfile> {
  DateTime selectedDate = DateTime.now();
  var customFormat = DateFormat('yyyy-MM-dd');
  String? img64;
  File? _image;
  File? imageResized;
  final picker = ImagePicker();

  // Camera
  String? imgpath;
  final GlobalKey _globalKey = GlobalKey();
  Future<void>? _initializeControllerFuture;
  bool iscameraExcute = false;
  bool forImageShow = false;
  String? imgnew;
  bool showPassword = false;
  TextEditingController dateCtl = TextEditingController();
  dynamic phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  dynamic altphoneController = TextEditingController();
  dynamic genderController = TextEditingController();
  dynamic dobController = TextEditingController();
  dynamic imgController = TextEditingController();
  final FocusNode myFocusNode = FocusNode();
  bool visible = false;

  Map? data;
  Map? datanew;
  List? userData;
  String? myname;
  String? myskills;
  String? myphone;
  String? mygender;
  String? myreporting;
  String? myemail;
  String? mydoj;
  String? myid;
  String? mydob;
  String? myimg;
  String? mydesig;
  List? userDatanew;
  String? username;
  String? email;
  String? ppic;
  String? ppic2;
  String? uid;
  String? cid;
  var difference = "";
  String? resulted;
  DateTime selectedDatenew = DateTime.now();

  @override
  void initState() {
    super.initState();
    _value = null;
    fetchList();
    var difference = selectedDate.difference(selectedDatenew).inDays;
    if (0 == difference) {
      setState(() {
        resulted = "Good Morning.";
      });
    } else if (0 > difference) {
      setState(() {
        resulted = "Can Proceed.";
      });
    } else if (0 < difference) {
      setState(() {
        resulted = "not a correct birthdate.";
      });
    }
    if (debug == 'yes') {
      //print('result id - ${resulted}');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  String? enmergency;
  Future getEmail() async {
    setState(() {
      visible = true;
      userData = data!["data"];
      myname = userData![0]['uname'];
      mydoj = userData![0]['u_doj'];
      myemail = userData![0]['u_email'];
      mygender = userData![0]['u_gender'];
      myphone = userData![0]['u_phone'];
      myid = userData![0]['uid'];
      myimg = userData![0]['img'];
      mydesig = userData![0]['u_designation'];
      myreporting = userData![0]['reporting_to'];
      mydob = userData![0]['u_dob'];
      myskills = userData![0]['u_skills'];
      //da = data["data"]["status"];
      visible = true;
      _nameController.text = myname ?? "";
    });
  }

  Future fetchList() async {
    try {
      var uri = "$customurl/controller/process/app/profile.php";
      final response = await http.post(Uri.parse(uri), body: {
        'uid': SharedPreferencesInstance.getString('uid'),
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'type': 'fetch_profile',
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      data = json.decode(response.body);
      log(data.toString());
      setState(() {
        visible = true;
        userData = data!["data"];
        myname = userData![0]['uname'];
        mydoj = userData![0]['u_doj'];
        myemail = userData![0]['u_email'];
        mygender = userData![0]['u_gender'];
        myphone = userData![0]['u_phone'];
        mydob = userData![0]['u_dob'];
        myimg = userData![0]['img'];
        enmergency = userData![0]['u_emergency_contact'];
        visible = true;
      });
      if (data!['status'] == true) {
        getEmail();
      } else {
        Fluttertoast.showToast(
          msg: "Problem Fetching Details",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0,
        );
      }
    } catch (error) {}
  }

  submitButton() async {
    CachedNetworkImage.evictFromCache(myimg!);
    if (altphoneController.text == '' &&
        _image != null &&
        _nameController.text == '' &&
        phoneController.text == '' &&
        _value == null &&
        resulted == "Good Morning." &&
        resulted != "can proceed.") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Please Wait We Are Trying To Save Your Image",
        ),
      ));
    } else if (altphoneController.text == '' &&
        _image == null &&
        _nameController.text != '' &&
        phoneController.text == '' &&
        _value == null &&
        resulted == "Good Morning." &&
        resulted != "can proceed.") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Please Wait We Are Trying To Save Your Name",
        ),
      ));
    } else if (altphoneController.text == '' &&
        _image == null &&
        _nameController.text == '' &&
        phoneController.text != '' &&
        _value == null &&
        resulted == "Good Morning." &&
        resulted != "can proceed.") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Please Wait We Are Trying To Save Your Phone Number",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.black,
      ));
    } else if (altphoneController.text != '' &&
        _image == null &&
        _nameController.text == '' &&
        phoneController.text == '' &&
        _value == null &&
        resulted == "Good Morning." &&
        resulted != "can proceed.") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Please Wait We Are Trying To Save Your Alternate Contact Number",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.black,
      ));
    } else if (altphoneController.text == '' &&
        _image == null &&
        _nameController.text == '' &&
        phoneController.text == '' &&
        _value != null &&
        resulted == "Good Morning." &&
        resulted != "can proceed.") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Please Wait We Are Trying To Save Selected Gender",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.black,
      ));
    } else if (altphoneController.text == '' &&
        _image == null &&
        _nameController.text == '' &&
        phoneController.text == '' &&
        _value == null &&
        resulted != "Good Morning." &&
        resulted != "can proceed.") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Please Wait We Are Trying To Save Your D.O.B",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.black,
      ));
    } else if (altphoneController.text != '' ||
        _image != null ||
        _nameController.text != '' ||
        phoneController.text != '' ||
        _value != null ||
        resulted != "Good Morning." ||
        resulted != "can proceed.") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Please Wait We Are Trying To Save Your Details",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.black,
      ));
    }
    try {
      var uri = "$customurl/controller/process/app/profile.php";
      final response = await http.post(Uri.parse(uri), body: {
        'uid': SharedPreferencesInstance.getString('uid'),
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'type': 'update_profile',
        'u_dob': mydob,
        'uname': myname,
        if (enmergency == '' && altphoneController.text == '')
          'u_emergency_contact': ''
        else if (enmergency == '' && altphoneController.text != '')
          'u_emergency_contact': altphoneController.text
        else if (enmergency != '' && altphoneController.text == '')
          'u_emergency_contact': enmergency
        else if (enmergency != '' && altphoneController.text != '')
          'u_emergency_contact': altphoneController.text,
        if (phoneController.text == '')
          'u_phone': myphone
        else if (phoneController.text != '')
          'u_phone': phoneController.text,
        'u_gender': mygender,
        if (imageBytes != null) 'img': base64.encode(imageBytes!)
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
      if (data!['status'] == true) {
        Navigator.pop(context, true);
        Fluttertoast.showToast(
            msg: "Details Successfully Updated",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: "Problem Fetching Details",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0);
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

  Uint8List? imageBytes;

  openCamera() async {
    imageBytes = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CameraScreen(
              showFrame: false,
            ),
          ),
        ) ??
        imageBytes;
    setState(() {});
  }

  openGallery() async {
    var file =
        await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    imageBytes = await file.readAsBytes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: iscameraExcute == true ? Colors.black : Colors.white,
      appBar: AppBar(
        elevation: 0,
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
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white),
        ),
      ),
      //aman here
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
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.white],
                ),
              ),
              padding: const EdgeInsets.only(left: 16, top: 25, right: 16),
              child: GestureDetector(
                onTap: FocusScope.of(context).unfocus,
                child: ListView(
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    Center(
                      child: Stack(
                        children: [
                          GestureDetector(
                              onTap: () => showDialog(
                                  context: context,
                                  builder: (context) {
                                    return DocumentTypePickerDialogBox(
                                      camera: openCamera,
                                      gallery: openGallery,
                                    );
                                  }),
                              child: myimg == null && imageBytes == null
                                  ? Container(
                                      height: 150,
                                      width: 150,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border:
                                              Border.all(color: Colors.blue)),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(
                                            Icons.add_a_photo,
                                            color: Color(0xff072a99),
                                            size: 26,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'Upload an Image',
                                              textAlign: TextAlign.center,
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : SizedBox(
                                      height: 150,
                                      width: 150,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.blue),
                                        child: ClipOval(
                                            child: imageBytes != null
                                                ? Image.memory(
                                                    imageBytes!,
                                                    fit: BoxFit.cover,
                                                  )
                                                : CachedNetworkImage(
                                                    imageUrl: myimg!,
                                                    fit: BoxFit.cover,
                                                  )),
                                      ))),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 35,
                    ),
                    const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text("Contact Number",
                            style: TextStyle(
                              color: Color(0xff072a99),
                            ))),
                    CustomTextField(
                      hint: myphone,
                      controller: phoneController,
                      textInputType: TextInputType.phone,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text("Alternate Contact Number",
                            style: TextStyle(
                              color: Color(0xff072a99),
                            ))),
                    CustomTextField(
                      hint: enmergency,
                      controller: altphoneController,
                      textInputType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChangePasswordScreen(),
                          ),
                        );
                      },
                      style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(
                              const Color(0xff072a99))),
                      child: const Text("Change Password"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: submitButton,
                        child: const Text("Submit"),
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
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
