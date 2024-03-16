import 'dart:convert';
import 'dart:developer';

import 'package:ezhrm/bottombar_ios.dart/bottombar_ios.dart';
import 'package:ezhrm/constants.dart';
import 'package:ezhrm/drawer.dart';
import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:ezhrm/viewpolicydoc.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ViewPolicies extends StatefulWidget {
  const ViewPolicies({Key? key}) : super(key: key);

  @override
  State<ViewPolicies> createState() => _ViewDocumentsState();
}

class _ViewDocumentsState extends State<ViewPolicies> {
  @override
  void initState() {
    fetchcompanypolicy();
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

  List viewdocuments = [];
  Future fetchcompanypolicy() async {
    try {
      var urii = "$customurl/controller/process/app/profile.php";
      final responsenew = await http.post(Uri.parse(urii), body: {
        'uid': SharedPreferencesInstance.getString('uid'),
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'type': 'policy_fetch'
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      log(responsenew.request.toString());
      log({
        'uid': SharedPreferencesInstance.getString('uid'),
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'type': 'policy_fetch'
      }.toString());
      var datanew = json.decode(responsenew.body);
      if (datanew["status"].toString() == "true") {
        viewdocuments = datanew["data"];
      } else {
        viewdocuments = [];
      }
      setState(() {});

      log("Policy :" + datanew.toString());
    } catch (error) {
      log("ERROR : " + error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const bottombar_ios(),
      drawer:
          const CustomDrawer(currentScreen: AvailableDrawerScreens.Policies),
      appBar: AppBar(
        title: const Text("Policies"),
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
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      viewdocuments[index]['name'].toString(),
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 18),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      viewdocuments[index]['descr'].toString(),
                                      style: const TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w300,
                                          fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: ((context) => viewpolicydoc(
                                                filename: viewdocuments[index]
                                                        ['name']
                                                    .toString(),
                                                documentname:
                                                    viewdocuments[index]
                                                            ['file_type']
                                                        .toString(),
                                                filepath: viewdocuments[index]
                                                        ['url']
                                                    .toString(),
                                              ))));
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                      color: themecolor,
                                      shape: BoxShape.circle),
                                  height: 50,
                                  width: 50,
                                  child: const Icon(
                                    Icons.remove_red_eye,
                                    color: Colors.white,
                                  ),
                                ),
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
