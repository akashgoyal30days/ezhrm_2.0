import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:ezhrm/bottombar_ios.dart/bottombar_ios.dart';
import 'package:ezhrm/camera_screen.dart';
import 'package:ezhrm/custom_text_field.dart';
import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'constants.dart';
import 'drawer.dart';

class DocuMents extends StatefulWidget {
  const DocuMents({Key? key}) : super(key: key);

  @override
  _DocuMentsState createState() => _DocuMentsState();
}

class _DocuMentsState extends State<DocuMents> {
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
    fetchList();
    super.initState();
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

  Future fetchList() async {
    try {
      var uri = "$customurl/controller/process/app/document.php";
      final response = await http.post(Uri.parse(uri), body: {
        'uid': SharedPreferencesInstance.getString('uid'),
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'type': 'pending_doc'
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      data = json.decode(response.body);
      setState(() {
        visible = true;
        userData = data!["data"];
        visible = true;
      });
      if (debug == 'yes') {}
    } catch (error) {}
  }

  String? mimetype = '';
  Future uploadDocumentAPI() async {
    var urii = "$customurl/controller/process/app/document.php";
    // final responseneww = await http.post(Uri.parse(uri)i, body: {
    //   'uid': SharedPreferencesInstance.getString('uid'),
    //   'cid': SharedPreferencesInstance.getString('comp_id'),
    //   'type': 'upload_doc',
    //   'doc_no': reasonController.text,
    //   'doc_id': _mylist,
    //   'file': base64.encode(imageBytes)
    // }, headers: <String, String>{
    //   'Accept': 'application/json',
    // });
    log({
      'uid': SharedPreferencesInstance.getString('uid'),
      'cid': SharedPreferencesInstance.getString('comp_id'),
      'type': 'upload_doc',
      'doc_no': reasonController.text,
      'doc_id': _mylist,
      'doc_file': filename.toString()
    }.toString());
    var headers = {
      'Accept': 'application/json',
      'Content-Type': mimetype.toString()
    };
    var request = http.MultipartRequest("POST", Uri.parse(urii));
    request.headers.addAll(headers);

    request.fields['uid'] = SharedPreferencesInstance.getString('uid');
    request.fields['cid'] = SharedPreferencesInstance.getString('comp_id');
    request.fields['type'] = 'upload_doc';
    request.fields['doc_no'] = reasonController.text;
    request.fields['doc_id'] = _mylist!;

    MultipartFile multipartFile = await http.MultipartFile.fromPath(
      'doc_file',
      filepath.toString() == 'f' ? pdffile!.path : imagefile!.path,
      filename: filename,
      contentType: MediaType('application', 'pdf'),
    );

    // add file to multipart
    request.files.add(multipartFile);

    // request.files.add(http.MultipartFile(
    //   'doc_file',
    //   filepath.toString() == 'f'
    //       ? pdffile.readAsString()
    //       : imagefile.readAsBytes().asStream(),
    //   filepath.toString() == 'f'
    //       ? pdffile.lengthSync()
    //       : imagefile.lengthSync(),
    //   filename: filename,
    // ));
    http.Response responseneww =
        await http.Response.fromStream(await request.send());

    newdata = json.decode(responseneww.body);
    log("New Data : " + newdata.toString());

    if (newdata.containsKey('status')) {
      setState(() {
        // message =  mydataatt['msg'];
        visible = false;
      });
      if (newdata['status'] == true) {
        setState(() {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              "Uploaded Successfully",
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.green,
          ));
          _mylist = null;
          imageBytes = null;
          reasonController.clear();
        });
      } else if (newdata['status'] == false) {
        Navigator.pop(context);

        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              "Already Uploaded",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.red,
          ));

          _mylist = null;
          imageBytes = null;
          reasonController.clear();
        });
      }
    }
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
    file.writeAsBytesSync(imageBytes!);

    imagefile = File(file.path);
    filename = "image.png";
    setState(() {});
  }

  openGallery() async {
    var file =
        await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    imageBytes = await file.readAsBytes();

    filepath = file.path.toString().substring(file.path.toString().length - 1);
    filename = file.path.split('/').last.toString();
    filetypename =
        file.path.split('/').last.toString().split('.').last.toString();
    mimetype = lookupMimeType(filetypename.toString());
    log("Filepathlast : " + filepath.toString());

    log("Filetype : " + filetypename.toString());
    log("Mimetype : " + mimetype.toString());
    imagefile = File(file.path);
    setState(() {});
  }

  String filepath = '';
  String filename = '';
  String filetypename = '';

  File? pdffile;
  File? imagefile;

  selectdocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf'],
    );
    File file = File(result!.files.single.path!);

    filepath = file.path.toString().substring(file.path.toString().length - 1);
    filename = file.path.split('/').last.toString();
    filetypename =
        file.path.split('/').last.toString().split('.').last.toString();
    mimetype = lookupMimeType(filetypename);
    log("Filepathlast : " + filepath.toString());

    log("Filetype : " + filetypename.toString());
    log("Mimetype : " + mimetype.toString());

    setState(() {});

    if (file == null) return;
    imageBytes = await file.readAsBytes();
    if (filepath.toString() == 'f') {
      pdffile = file;
      log("PDF Path : " + pdffile!.path.toString());
    } else {
      imagefile = file;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const bottombar_ios(),
      drawer: const CustomDrawer(
          currentScreen: AvailableDrawerScreens.uploadDocuments),
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
          'Upload Documents',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: userData == null
          ? Center(
              child: LoadingAnimationWidget.hexagonDots(
                color: const Color(0xff072a99),
                size: 40,
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(10),
              children: [
                const Padding(
                  padding: EdgeInsets.all(11),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Select Pending Documents",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff072a99),
                      ),
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      underline: const SizedBox(),
                      hint: const Text("Pending Documents"),
                      value: _mylist,
                      items: userData?.map((item) {
                            return DropdownMenuItem(
                              child: Text(
                                item['type'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: font1,
                                ),
                              ),
                              value: item['id'].toString(),
                            );
                          })?.toList() ??
                          [],
                      onChanged: (String? newValue) {
                        setState(() {
                          _mylist = newValue;
                        });
                      },
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(11),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Document Serial Number",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff072a99),
                        )),
                  ),
                ),
                CustomTextField(
                  hint: "Enter the Serial Number",
                  controller: reasonController,
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
                        ))
                    : Column(
                        children: [
                          filepath.toString() != 'f'
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(imageBytes!),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (imageBytes == null || _mylist == null) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                                content: Text(
                          "Please upload Image/fill all the fields",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        )));
                        return;
                      }
                      showLoaderDialogwithName(context, "Please wait");
                      uploadDocumentAPI();

                      setState(() {
                        userData = null;
                        fetchList();
                        initState();
                      });
                    },
                    child: const Text("Submit"),
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
              ],
            ),
    );
  }
}
