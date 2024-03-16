import 'dart:convert';
import 'dart:developer';

import 'package:ezhrm/bottombar_ios.dart/bottombar_ios.dart';
import 'package:ezhrm/constants.dart';
import 'package:ezhrm/drawer.dart';
import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:ezhrm/viewdocpdf.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ViewDocuments extends StatefulWidget {
  const ViewDocuments({Key? key}) : super(key: key);

  @override
  State<ViewDocuments> createState() => _ViewDocumentsState();
}

class _ViewDocumentsState extends State<ViewDocuments> {
  @override
  void initState() {
    super.initState();
    fetchDocumnts();
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

  List viewdocuments = [];
  Future fetchDocumnts() async {
    try {
      var uri = "$customurl/controller/process/app/document.php";
      final response = await http.post(Uri.parse(uri), body: {
        'uid': SharedPreferencesInstance.getString('uid'),
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'type': 'fetch_doc'
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      var rsp = json.decode(response.body);
      log("Documents Response : " + rsp.toString());
      if (rsp['status'].toString() == "true") {
        viewdocuments = rsp['data'];
      } else {
      }

      setState(() {});
    } catch (error) {
      log("Error : " + error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const bottombar_ios(),
      drawer: const CustomDrawer(
          currentScreen: AvailableDrawerScreens.viewDocuments),
      appBar: AppBar(
        title: const Text("View Documents"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.indigo, Colors.blue.shade600])),
        ),
      ),
      body: viewdocuments.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            )
          : viewdocuments == null
              ? const Center(
                  child: Text(
                    "Data Not Found",
                    style: TextStyle(color: Colors.black),
                  ),
                )
              : ListView.builder(
                  itemCount: viewdocuments.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.shade200),
                        width: MediaQuery.of(context).size.width * 0.90,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 15, bottom: 15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Document Type : ",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    viewdocuments[index]['type'].toString(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                    ),
                                  )
                                ],
                              ),
                              const Divider(
                                height: 15,
                                color: Colors.grey,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Number : ",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(
                                    width: 50,
                                  ),
                                  Text(
                                    viewdocuments[index]['doc_number']
                                        .toString(),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                    ),
                                  )
                                ],
                              ),
                              const Divider(
                                height: 15,
                                color: Colors.grey,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Status : ",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(
                                    width: 50,
                                  ),
                                  Text(
                                    viewdocuments[index]['status'].toString() ==
                                            "1"
                                        ? "Approved"
                                        : "Rejected",
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                    ),
                                  )
                                ],
                              ),
                              const Divider(
                                height: 15,
                                color: Colors.grey,
                              ),
                              viewdocuments[index]['remark'].toString() != ""
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Remarks : ",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          viewdocuments[index]['remark']
                                              .toString(),
                                          maxLines: 2,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        )
                                      ],
                                    )
                                  : Container(),
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: MaterialButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    elevation: 5,
                                    textColor: Colors.white,
                                    color: themecolor,
                                    onPressed: () {
                                      log(viewdocuments[index]['file_name']
                                          .toString());

                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: ((context) => ViewdocPdf(
                                                    documentname:
                                                        viewdocuments[index]
                                                                ['type']
                                                            .toString(),
                                                    filepath:
                                                        viewdocuments[index]
                                                                ['file_name']
                                                            .toString(),
                                                  ))));
                                    },
                                    child: const Text("View Document")),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
