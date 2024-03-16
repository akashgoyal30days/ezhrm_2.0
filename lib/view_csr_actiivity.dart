import 'dart:developer';

import 'package:ezhrm/bottombar_ios.dart/bottombar_ios.dart';
import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart';
import 'drawer.dart';

class ViewCSRactivity extends StatefulWidget {
  const ViewCSRactivity({Key? key}) : super(key: key);

  @override
  _ViewCSRactivityState createState() => _ViewCSRactivityState();
}

class _ViewCSRactivityState extends State<ViewCSRactivity>
    with SingleTickerProviderStateMixin<ViewCSRactivity> {
  bool visible = false;
  Map? data;
  Map? datanew;
  List userData = [];
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
  var internet = 'yes';

  @override
  void initState() {
    super.initState();
    fetchList();
  }

  Future fetchList() async {
    try {
      var uri = "$customurl/controller/process/app/activity.php";
      final response = await http.post(Uri.parse(uri), body: {
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'type': 'fetch_data'
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      var rsp = json.decode(response.body);
      if (rsp.containsKey("status")) {
        if (rsp["status"].toString() == "true") {
          userData = rsp["data"];
        }
      }
      log(userData.toString());
      setState(() {});
    } catch (error) {
      log(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const bottombar_ios(),
      drawer: const CustomDrawer(
          currentScreen: AvailableDrawerScreens.Csrviewactivity),
      appBar: AppBar(
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
        elevation: 0,
        title: const Text(
          "CSR Activity",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
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
              child: userData.isEmpty
                  ? const Center(
                      child: Text(
                        'No Data Found',
                        style: TextStyle(
                            fontFamily: font1,
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: Colors.black),
                      ),
                    )
                  : ListView.builder(
                      itemCount: userData == null ? 0 : userData.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          elevation: 10,
                          margin: const EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userData[index]["u_full_name"].toString(),
                                  style: const TextStyle(
                                      color: themecolor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Divider(),
                                Text(
                                  userData[index]["text"].toString(),
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 15,
                                  ),
                                ),
                                const Divider(),
                                Container(
                                  child: Image.network(
                                      userData[index]["timeline_pic"]),
                                ),
                                const Divider(),
                              ],
                            ),
                          ),
                        );
                      }),
            ),
    );
  }
}
