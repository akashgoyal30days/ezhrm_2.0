import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:ezhrm/bottombar_ios.dart/bottombar_ios.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ezhrm/screensize.dart';
import 'package:http/http.dart' as http;
import 'package:lecle_flutter_absolute_path/lecle_flutter_absolute_path.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'drawer.dart';

class FeedBack extends StatefulWidget {
  const FeedBack({Key? key}) : super(key: key);

  @override
  _FeedBackState createState() => _FeedBackState();
}

class _FeedBackState extends State<FeedBack>
    with SingleTickerProviderStateMixin<FeedBack> {
  Map? data;
  String? username;
  String? email;
  String? ppic;
  String? ppic2;
  String? uid;
  String? cid;
  String? cname;
  final _formKey = GlobalKey<FormState>();
  List<Asset> images = <Asset>[];
  List files = [];
  List<Asset>? resultList;
  @override
  void initState() {
    super.initState();
    getEmail();
  }

  Widget buildGridView() => Card(
        margin: const EdgeInsets.all(8),
        color: Colors.lightBlue.withOpacity(0.6),
        elevation: 5,
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(images.length, (index) {
            Asset asset = images[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  AssetThumb(
                    asset: asset,
                    width: 200,
                    height: 200,
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                        onPressed: () {
                          images.remove(images[index]);
                          setState(() {});
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        )),
                  )
                ],
              ),
            );
          }),
        ),
      );

  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];

    try {
      resultList = await MultiImagePicker.pickImages(
        selectedAssets: images,
      );
    } catch (e) {
      e.toString();
    }

    if (!mounted) return;

    setState(() {
      images = resultList;
    });
  }

  getImageFileFromAsset(String path) async {
    final file = File(path);

    return file;
  }

  Future getEmail() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    SharedPreferences preferencess = await SharedPreferences.getInstance();
    SharedPreferences preferencesimg = await SharedPreferences.getInstance();
    SharedPreferences preferencesimg2 = await SharedPreferences.getInstance();
    SharedPreferences preferencesuid = await SharedPreferences.getInstance();
    SharedPreferences preferencecuid = await SharedPreferences.getInstance();
    SharedPreferences preferencescname = await SharedPreferences.getInstance();
    setState(() {
      email = preferences.getString('email');
      username = preferencess.getString('username');
      ppic = preferencesimg.getString('profile');
      ppic2 = preferencesimg2.getString('profile2');
      uid = preferencesuid.getString('uid');
      cid = preferencecuid.getString('comp_id');
      cname = preferencescname.getString('companyname');
    });
  }

  Future _upload() async {
    SharedPreferences preferencecuid = await SharedPreferences.getInstance();
    SharedPreferences preferencesuid = await SharedPreferences.getInstance();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    SharedPreferences preferencess = await SharedPreferences.getInstance();
    SharedPreferences preferencescname = await SharedPreferences.getInstance();
    for (int i = 0; i < images.length; i++) {
      var path2 = await LecleFlutterAbsolutePath.getAbsolutePath(
          uri: images[i].identifier.toString());
      var file = await getImageFileFromAsset(path2!);
      var base64Image = base64Encode(file.readAsBytesSync());
      files.add(base64Image);
    }
    var urii = "$customurl/controller/process/app/face_recog.php";
    var bodydata = {
      'uid': preferencesuid.getString('uid'),
      'cid': preferencecuid.getString('comp_id'),
      'type': 'feedback_query',
      'files': files,
      'query': feedbackController.text,
      'uname': preferencess.getString('username'),
      'uemail': preferences.getString('email'),
      'ucomp': preferencescname.getString('companyname'),
    };
    try {
      var response = await http.post(Uri.parse(urii),
          body: json.encode(bodydata),
          headers: <String, String>{
            'Accept': 'application/json',
          });
      data = json.decode(response.body);
      if (debug == 'yes') {
        //print(data);
      }
      if (data!['status'] == true) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Thankyou for the Feedback",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0),
          ),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
        ));
      }
    } catch (error) {}
  }

  submitButton() {
    if (feedbackController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Please write a message to submit",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
      ));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(
        "Submitting your Feedback",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16.0,
        ),
      ),
      duration: Duration(seconds: 3),
      backgroundColor: Colors.black,
      elevation: 80,
    ));
    _upload();
  }

  final feedbackController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      bottomNavigationBar: const bottombar_ios(),
      drawer:
          const CustomDrawer(currentScreen: AvailableDrawerScreens.feedback),
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
        elevation: 0,
        title: const Text(
          'Feedback',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                        padding: EdgeInsets.only(top: 8, left: 8.0, bottom: 4),
                        child: Text("Feedback/Suggestions",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xff072a99),
                            ))),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: feedbackController,
                      cursorColor: const Color(0x33072a99),
                      keyboardType: TextInputType.name,
                      onSubmitted: (_) {},
                      minLines: 10,
                      maxLines: 15,
                      textInputAction: TextInputAction.done,
                      style: const TextStyle(color: Color(0xff072a99)),
                      decoration: InputDecoration(
                        fillColor: const Color(0x33072a99),
                        filled: true,
                        hintText:
                            "Write Feedback to the developer, Any suggestions are welcome",
                        contentPadding: const EdgeInsets.all(10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  if (images.isNotEmpty) buildGridView(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Center(
                      child: TextButton.icon(
                          icon: const Icon(
                            Icons.add_a_photo,
                            size: 20,
                          ),
                          onPressed: loadAssets,
                          label: const Text("Add Images (Optional)"),
                          style: ButtonStyle(
                              padding:
                                  MaterialStateProperty.all(EdgeInsets.zero),
                              foregroundColor: MaterialStateProperty.all(
                                const Color(0xff072a99),
                              ))),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: submitButton,
                      child: const Text("Submit Feedback"),
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
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
      // bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}
