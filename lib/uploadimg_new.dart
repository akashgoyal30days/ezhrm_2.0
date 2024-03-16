import 'package:ezhrm/bottombar_ios.dart/bottombar_ios.dart';
import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:ezhrm/upload_images_new.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:convert';
import 'constants.dart';
import 'drawer.dart';

class UploadImg extends StatefulWidget {
  const UploadImg({Key? key}) : super(key: key);

  @override
  _UploadImgState createState() => _UploadImgState();
}

class _UploadImgState extends State<UploadImg> {
  List? notice;
  bool showLoading = true;

  @override
  void initState() {
    super.initState();
    checkimgstatus();
  }

  Future checkimgstatus() async {
    var uri = "$customurl/controller/process/app/extras.php";
    var bodydata = {
      'uid': SharedPreferencesInstance.getString('uid'),
      'cid': SharedPreferencesInstance.getString('comp_id'),
      'type': 'img_upload_sts',
    };
    final response = await http
        .post(Uri.parse(uri), body: bodydata, headers: <String, String>{
      'Accept': 'application/json',
    });
    var responseData = json.decode(response.body);
    if (responseData['status'] == true) {
      setState(() {
        showLoading = false;
        var data = responseData['msg'].toString();
        notice = data
            .replaceAll(",", "\n")
            .replaceFirst(".", "\n")
            .replaceAll("-", ": ")
            .replaceFirst("Status:", "\n")
            .split("\n");
      });
    } else {
      setState(() {
        showLoading = false;
        if (!openedUploadedImagesScreeenOnce) uploadImagesScreen();
        openedUploadedImagesScreeenOnce = true;
      });
    }
  }

  uploadImagesScreen() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => const UploadImagesScreen()));
    checkimgstatus();
    return;
  }

  bool openedUploadedImagesScreeenOnce = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const bottombar_ios(),
      drawer: const CustomDrawer(
          currentScreen: AvailableDrawerScreens.faceRecognitionImages),

      appBar: AppBar(
        backgroundColor: Colors.blue,
        bottomOpacity: 0,
        elevation: 0,
        title: const Text(
          "Upload Images",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: font1,
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
      body: Center(
        child: showLoading
            ? LoadingAnimationWidget.twoRotatingArc(
                color: const Color(0xff072a99),
                size: 30,
              )
            : Card(
                elevation: 10,
                margin: const EdgeInsets.all(12.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: notice != null
                            ? Column(
                                children: [
                                  Text(
                                    notice![0],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  if (notice!.length > 2)
                                    _ImageStatusText(notice![2]),
                                  if (notice!.length > 3)
                                    _ImageStatusText(notice![3]),
                                  if (notice!.length > 4)
                                    _ImageStatusText(notice![4]),
                                ],
                              )
                            : const SizedBox(),
                      ),
                      ElevatedButton(
                        onPressed: uploadImagesScreen,
                        child: const Text("Upload Images"),
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
                    ],
                  ),
                ),
              ),
      ),
      //bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}

class _ImageStatusText extends StatelessWidget {
  const _ImageStatusText(this.text, {Key? key}) : super(key: key);
  final String text;
  @override
  Widget build(BuildContext context) {
    Color? color;
    String firstPart = text.trim().split(" ")[0].replaceAll(":", ""),
        secondPart = text.trim().split(" ")[1];
    if (firstPart == "Approved") {
      color = Colors.green;
    } else if (firstPart == "Rejected") {
      color = Colors.red;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            secondPart + " " + firstPart,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18,
                color: color ??  Color(0xff072a99),
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
