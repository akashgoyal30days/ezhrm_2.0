import 'package:ezhrm/bottombar_ios.dart/bottombar_ios.dart';
import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:getwidget/types/gf_loader_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'constants.dart';
import 'drawer.dart';

class LeaveStatus extends StatefulWidget {
  const LeaveStatus({Key? key}) : super(key: key);

  @override
  _LeaveStatusState createState() => _LeaveStatusState();
}

class _LeaveStatusState extends State<LeaveStatus>
    with SingleTickerProviderStateMixin<LeaveStatus> {
  bool? visible = false;
  Map? data;
  Map? datanew;
  List? userData;
  List? userDatanew;
  String? username;
  String? email;
  String? ppic;
  String? ppic2;
  String? uid;
  String? cid;

  var internet = 'yes';
  @override
  void initState() {
    super.initState();
    //  checkinternetconnection();
    getEmail();
    fetchList();
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
        'type': 'leave_status',
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'uid': SharedPreferencesInstance.getString('uid')
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      data = json.decode(response.body);
      setState(() {
        visible = true;
        userData = data!["data"];

        //debugPrint(userData.toString());
        //da = data["data"]["status"];
        visible = true;
      });
      if (debug == 'yes') {
        //debugPrint(userData.toString());
      }
      if (userData == null) {
        setState(() {
          userData = [];
        });
      }
      if (userData!.isEmpty) {
        showCupertinoDialog(
          context: context,
          builder: (context) {
            return Theme(
              data: ThemeData.dark(),
              child: CupertinoAlertDialog(
                title: Column(
                  children: const [
                    Icon(
                      Icons.warning,
                      color: Colors.yellow,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text('No Leaves applied'),
                  ],
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: const Text('Ok'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      }
    } catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const bottombar_ios(),
      backgroundColor: Colors.white,
      drawer:
          const CustomDrawer(currentScreen: AvailableDrawerScreens.leaveStatus),
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.blue,
        title: const Text(
          'Leave Status',
          style: TextStyle(color: Colors.white, fontFamily: font1),
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
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.white],
                ),
              ),
              child: userData == null || userData!.isEmpty
                  ? const Center(
                      child: Text(
                        'Data Not Found',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: userData!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _Items(
                          data: userData![index],
                          onCancelRequest: () => showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  CupertinoAlertDialog(
                                    title: const Text(
                                      "Pending Leave",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    content: const Text(
                                        "Are You Sure You Want To Cancel This Request?"),
                                    actions: <Widget>[
                                      CupertinoDialogAction(
                                        isDefaultAction: true,
                                        child: const Text('Yes'),
                                        onPressed: () async {
                                          var urii =
                                              "$customurl/controller/process/app/leave.php";
                                          final response =
                                              await http.post(Uri.parse(urii), body: {
                                            'type': 'cancel_leave',
                                            'uid': SharedPreferencesInstance
                                                .getString('uid'),
                                            'cid': SharedPreferencesInstance
                                                .getString('comp_id'),
                                            'lid': userData![index]["id"]
                                          }, headers: <String, String>{
                                            'Accept': 'application/json',
                                          });
                                          Navigator.of(context).pop();
                                          datanew = json.decode(response.body);
                                          if (datanew!['status'] == true) {
                                            setState(() {
                                              userData = null;
                                            });
                                            fetchList();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    "Leave Request Cancelled"),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content:
                                                    Text("Please Try Again"),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                      CupertinoDialogAction(
                                        child: const Text("No"),
                                        onPressed: Navigator.of(context).pop,
                                      )
                                    ],
                                  )),
                        );
                      }),
            ),
      //bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}

class _Items extends StatelessWidget {
  const _Items({Key? key, @required this.data, @required this.onCancelRequest})
      : super(key: key);
  final Map? data;
  final VoidCallback? onCancelRequest;
  @override
  Widget build(BuildContext context) {
    final String dateFrom = data!["date_from"], dateTo = data!["date_to"];
    final DateTime fromDate = DateTime(int.parse(dateFrom.substring(0, 4)),
        int.parse(dateFrom.substring(5, 7)), int.parse(dateFrom.substring(8)));
    final DateTime toDate = DateTime(int.parse(dateTo.substring(0, 4)),
        int.parse(dateTo.substring(5, 7)), int.parse(dateTo.substring(8)));
    final String status = data!["status"] == "0"
        ? "Pending"
        : data!["status"] == "1"
            ? "Approved"
            : data!["status"] == "2"
                ? "Rejected"
                : data!["status"] == "3"
                    ? "Cancelled"
                    : "Unknown";
    final statusColor = data!["status"] == "0"
        ? const Color(0xff072a99)
        : data!["status"] == "1"
            ? Colors.green
            : data!["status"] == "2"
                ? Colors.red
                : data!["status"] == "3"
                    ? Colors.orange
                    : Colors.grey;
    return Card(
        elevation: 4,
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      data!["type"] ?? "",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    status,
                    style: TextStyle(
                        fontSize: 15,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat("d MMM,y").format(fromDate) +
                    (fromDate.difference(toDate).inDays != 0
                        ? " - ${DateFormat("d MMM,y").format(toDate)}"
                        : ""),
              ),
              const SizedBox(height: 8),
              RichText(
                  text: TextSpan(
                      style: const TextStyle(color: Colors.grey),
                      children: [
                    const TextSpan(text: "Credit Type: "),
                    TextSpan(
                      text: data!["credit"],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(97, 97, 97, 1)),
                    ),
                  ])),
              const SizedBox(height: 4),
              RichText(
                  text: TextSpan(
                      style: const TextStyle(color: Colors.grey),
                      children: [
                    const TextSpan(text: "Reason: "),
                    TextSpan(
                      text: data!["reason"]?.toString() ?? "",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(97, 97, 97, 1)),
                    ),
                  ])),
              if (status == "Rejected")
                RichText(
                    text: TextSpan(
                        style: const TextStyle(color: Colors.grey),
                        children: [
                      const TextSpan(text: "Reject Reason: "),
                      TextSpan(
                        text: data!["reject_reason"]?.toString() ?? "",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(97, 97, 97, 1)),
                      ),
                    ])),
              if (status != "Cancelled" &&
                  status != "Approved" &&
                  status != "Rejected")
                Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                        onPressed: onCancelRequest,
                        child: const Text("Cancel Request")))
            ],
          ),
        ));
  }
}
