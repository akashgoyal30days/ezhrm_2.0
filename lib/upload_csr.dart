import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:ezhrm/bottombar_ios.dart/bottombar_ios.dart';
import 'package:ezhrm/custom_text_field.dart';
import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'constants.dart';
import 'drawer.dart';

class CSRUploadActivity extends StatefulWidget {
  const CSRUploadActivity({Key? key}) : super(key: key);

  @override
  _CSRUploadActivityState createState() => _CSRUploadActivityState();
}

class _CSRUploadActivityState extends State<CSRUploadActivity> {
  showLoaderDialogwithName(BuildContext context, String message) {
    AlertDialog alert = AlertDialog(
      contentPadding: const EdgeInsets.all(15),
      content: Row(
        children: [
          const CircularProgressIndicator(color: themecolor),
          Container(
              margin: const EdgeInsets.only(left: 25),
              child: Text(
                message,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, color: themecolor),
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

  void showcustomDailog(
    String title,
    String bodymessage,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(color: themecolor),
          ),
          content: Text(bodymessage),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            MaterialButton(
              color: themecolor,
              child: const Text(
                "Close",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool visible = true;
  Map? data;
  List? userData;
  String? _mylist;
  var newdata;
  TextEditingController reasonController = TextEditingController();
  Future<void>? _initializeControllerFuture;
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
  }

  File? finalimage;
  File? compressedFile;
  imagepicker() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
      Permission.photos
    ].request();

    final image = await ImagePicker().getImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      finalimage = File(image.path);
      log("Orignal Image Length : " +
          (finalimage!.readAsBytesSync().lengthInBytes / 1024).toString() +
          " KB");
    });
    compressedFile = await FlutterNativeImage.compressImage(finalimage!.path,
        quality: 80, percentage: 100);
    log("Final Image Length : " +
        (compressedFile!.readAsBytesSync().lengthInBytes / 1024).toString() +
        " KB");
  }

  upload() async {
    log("File Available : " + (compressedFile != null).toString());

    var url = "$customurl/controller/process/app/activity.php";
    try {
      log("Uploading...");
      var request = http.MultipartRequest("POST", Uri.parse(url));
      request.fields['cid'] = SharedPreferencesInstance.getString("comp_id");
      request.fields['uid'] = SharedPreferencesInstance.getString("uid");
      request.fields['type'] = "upload";
      request.fields['text'] = reasonController.text;

      request.files.add(
          await http.MultipartFile.fromPath('doc_file', compressedFile!.path));
      http.Response response =
          await http.Response.fromStream(await request.send());

      var rsp = json.decode(response.body);
      log("CSR Response : " + rsp.toString());

      if (rsp.containsKey("status")) {
        Navigator.pop(context);

        if (rsp["status"].toString() == "true") {
          finalimage = null;
          reasonController.clear();
          setState(() {});

          showcustomDailog("Thankyou!!", "Post Upload Successfully");
        } else {
          showcustomDailog(
              "Sorry!!", "Post Not Uploaded ..Try Again after some time..");
        }
      }
    } catch (error) {
      log("Error : " + error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const bottombar_ios(),
      drawer: const CustomDrawer(
          currentScreen: AvailableDrawerScreens.csrpostactivity),
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
          'Post Activity',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          const SizedBox(
            height: 10,
          ),
          CustomTextField(
            hint: "Write Something",
            controller: reasonController,
          ),
          const Padding(
            padding: EdgeInsets.all(11),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Choose Image",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff072a99),
                  )),
            ),
          ),
          finalimage == null
              ? GestureDetector(
                  onTap: imagepicker,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
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
                  ))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          child: Image.file(finalimage!)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            finalimage = null;
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
                            imagepicker();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text("Replace Image"),
                        ),
                      ],
                    ),
                  ],
                ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              showLoaderDialogwithName(context, "Uploading..");
              await upload();
            },
            child: const Text("Upload"),
            style: ButtonStyle(
              padding: MaterialStateProperty.all(const EdgeInsets.all(15)),
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
    );
  }
}
