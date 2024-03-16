import 'dart:convert';
import 'dart:developer';

import 'package:ezhrm/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';
import 'services/shared_preferences_singleton.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen(
      {Key? key,
      @required this.openDrawer,
      @required this.saveFetchedNotifications,
      @required this.fetchedNotifications,
      @required this.showlogoutpopup})
      : super(key: key);
  final VoidCallback? openDrawer;
  final Map<String, List>? fetchedNotifications;
  final Function(Map<String, List>)? saveFetchedNotifications;
  final bool? showlogoutpopup;
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool showLoadingSpinner = false;
  // key is date, value is list of noticiations in the same date
  final Map<String, List> fetchedNotifications = {};
  showlogoutdailog() {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              actionsAlignment: MainAxisAlignment.end,
              titlePadding: const EdgeInsets.all(20),
              actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              elevation: 10,
              title: const Text(
                "Are you sure you want to logout?",
                style: TextStyle(fontSize: 15),
              ),
              actions: [
                MaterialButton(
                    textColor: Colors.white,
                    color: Colors.red,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("No")),
                MaterialButton(
                    textColor: Colors.white,
                    color: Colors.green,
                    onPressed: () {
                      applogout();
                    },
                    child: const Text("Yes"))
              ],
            ));
  }

  applogout() async {
    GoogleSignIn().disconnect();
    SharedPreferencesInstance.logOut();
    SharedPreferencesInstance.instance!.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Login(),
      ),
    );
  }

  @override
  void initState() {
    if (widget.showlogoutpopup!) {
      log("show update popup");

      Future.delayed(const Duration(seconds: 0), () {
        showlogoutdailog();
      });
    }
    _fetchNotifications();
    super.initState();
  }

  String getFormattedDate(String date) {
    DateTime dateTime = DateTime(
      int.parse(date.substring(0, 4)),
      int.parse(date.substring(5, 7)),
      int.parse(date.substring(8, 10)),
    );
    return DateFormat("MMM d, y").format(dateTime);
  }

  _fetchNotifications([bool reload = false]) async {
    if (!reload && widget.fetchedNotifications!.isNotEmpty) {
      fetchedNotifications.addAll(widget.fetchedNotifications!);
      if (mounted) setState(() => showLoadingSpinner = false);
      return;
    }
    setState(() {
      showLoadingSpinner = true;
    });
    fetchedNotifications.clear();
    try {
      const urii = "$customurl/controller/process/app/notification.php";
      final responsenew = await http.post(Uri.parse(urii), body: {
        'type': 'fetch',
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'uid': SharedPreferencesInstance.getString('uid'),
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      var mydataaatt = json.decode(responsenew.body);
      if (mydataaatt['status'] == true) {
        List userDatamy = mydataaatt["data"];
        for (var element in userDatamy) {
          var date = element["ctime"].toString().substring(0, 10);
          fetchedNotifications[date] = fetchedNotifications[date] ?? [];
          fetchedNotifications[date]!.add(element);
        }
        widget.saveFetchedNotifications!(fetchedNotifications);
      }
    } catch (error) {
      //error
    }
    if (mounted) {
      setState(() {
        showLoadingSpinner = false;
      });
    }
  }

  _deleteNotification(String notifid) async {
    try {
      var urii = "$customurl/controller/process/app/notification.php";
      final responsenew = await http.post(Uri.parse(urii), body: {
        'type': 'delete',
        'cid': SharedPreferencesInstance.getString('comp_id'),
        'uid': SharedPreferencesInstance.getString('uid'),
        'nid': notifid,
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      var mydataaatt = json.decode(responsenew.body);
      if (mydataaatt['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text("Notification deleted successful")));
        _fetchNotifications(true);
      } else {
        //Navigator.of(context).pop(false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text("Notification deletion failed")));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Unable to delete notification")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: widget.openDrawer,
          ),
          elevation: 0,
          title: const Text(
            "Notifications",
            style: TextStyle(color: Colors.white),
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
        body: showLoadingSpinner
            ? const Center(
                child: SpinKitFadingFour(color: Color(0xff072a99)),
              )
            : fetchedNotifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircleAvatar(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          child: Icon(Icons.notifications_none),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "No Notificatons Available",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async => await _fetchNotifications(true),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      children: fetchedNotifications.keys
                          .toList()
                          .map<Widget>((date) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 12),
                              child: Row(
                                children: [
                                  Text(
                                    getFormattedDate(date),
                                    style: const TextStyle(
                                      color: Color(0xff072a99),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Icon(
                                    Icons.calendar_month,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                  Expanded(
                                    child: Divider(
                                      indent: 4,
                                      endIndent: 4,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...fetchedNotifications[date]!
                                .map<Widget>(
                                  (notification) => Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons
                                                    .notifications_none_rounded,
                                                size: 14,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 5),
                                              Expanded(
                                                child: Text(
                                                  DateFormat("hh:mm a")
                                                      .format(DateTime(
                                                          2022,
                                                          1,
                                                          1,
                                                          int.parse(
                                                            notification[
                                                                    "ctime"]
                                                                .toString()
                                                                .substring(
                                                                    11, 13),
                                                          ),
                                                          int.parse(
                                                            notification[
                                                                    "ctime"]
                                                                .toString()
                                                                .substring(
                                                                    14, 16),
                                                          ))),
                                                  style: const TextStyle(
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      color: Colors.grey),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  showCupertinoDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return Theme(
                                                        data: ThemeData
                                                            .fallback(),
                                                        child:
                                                            CupertinoAlertDialog(
                                                          title: const Text(
                                                              'Delete'),
                                                          content: const Text(
                                                              'Are you sure want to delete this notification?'),
                                                          actions: <Widget>[
                                                            CupertinoDialogAction(
                                                              isDefaultAction:
                                                                  true,
                                                              child: const Text(
                                                                  'Yes'),
                                                              onPressed: () {
                                                                _deleteNotification(
                                                                    notification[
                                                                            "id"]
                                                                        .toString());
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(null);
                                                              },
                                                            ),
                                                            CupertinoDialogAction(
                                                              child: const Text(
                                                                  "No"),
                                                              onPressed: () =>
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(
                                                                          false),
                                                            )
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: const Icon(
                                                  Icons.delete,
                                                  size: 16,
                                                  color: Color.fromRGBO(
                                                      239, 154, 154, 1),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            notification["message"].toString(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .toList()
                          ],
                        );
                      }).toList(),
                    ),
                  ));
  }
}
