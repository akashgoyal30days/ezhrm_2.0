import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ezhrm/change_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

import 'login.dart';
import 'constants.dart';
import 'editprofile.dart';
import 'services/shared_preferences_singleton.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({
    Key? key,
    this.openDrawer,
  }) : super(key: key);
  final VoidCallback? openDrawer;

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  bool showLoadingSpinner = true, showError = false;

  @override
  void initState() {
    super.initState();
    fetchUserProfileDetails();
  }

  Future fetchUserProfileDetails([bool refresh = false]) async {
    if (!refresh &&
        (SharedPreferencesInstance.instance!.getBool("userDataSaved") ??
            false)) {
      setState(() {
        showLoadingSpinner = false;
      });
      return;
    }
    try {
      var uri = "$customurl/controller/process/app/profile.php";
      final response = await http.post(Uri.parse(uri), body: {
        'type': 'fetch_profile',
        'cid': SharedPreferencesInstance.getString('comp_id') ?? "",
        'uid': SharedPreferencesInstance.getString('uid') ?? ""
      }, headers: <String, String>{
        'Accept': 'application/json',
      });
      var data = json.decode(response.body);
      log(data.toString());
      List userData = data["data"];
      await SharedPreferencesInstance.saveUserProfileData(userData[0]);
      setState(() {
        showLoadingSpinner = false;
      });
      return;
    } catch (error) {
      // error Statements...
    }
    setState(() {
      showError = true;
    });
    Fluttertoast.showToast(
        msg: "Problem Fetching Details",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    String userImageUrl = SharedPreferencesInstance.getString("Myimg");
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: widget.openDrawer,
        ),
        backgroundColor: Colors.blue,
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
        title: const Text(
          'Employee Profile',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            color: Colors.white,
            splashColor: Colors.blue,
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const EditProfile())),
          ),
        ],
      ),
      body: showLoadingSpinner
          ? const Center(
              child: SpinKitFadingFour(color: Color(0xff072a99)),
            )
          : ListView(
              padding: const EdgeInsets.all(5),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    elevation: 20,
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.blue,
                            Colors.indigo,
                          ],
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 10),
                          userImageUrl != null && userImageUrl != ""
                              ? GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      barrierColor: Colors.black87,
                                      barrierDismissible: true,
                                      builder: (_) => Dialog(
                                        elevation: 0,
                                        insetPadding: EdgeInsets.zero,
                                        backgroundColor: Colors.transparent,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            InteractiveViewer(
                                              child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      15.0),
                                                  child: CachedNetworkImage(
                                                    imageUrl: userImageUrl,
                                                  )),
                                            ),
                                            TextButton(
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                  fetchUserProfileDetails(
                                                      await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          const EditProfile(),
                                                    ),
                                                  ));
                                                },
                                                child:
                                                    const Text("Edit Image")),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white),
                                        padding: const EdgeInsets.all(2),
                                        child: ClipOval(
                                            child: CachedNetworkImage(
                                          imageUrl: userImageUrl,
                                          fit: BoxFit.cover,
                                        )),
                                      )))
                              : GestureDetector(
                                  onTap: () async => fetchUserProfileDetails(
                                      await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const EditProfile(),
                                    ),
                                  )),
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    child: const Icon(
                                      Icons.add_a_photo,
                                      color: Color(0xff072a99),
                                    ),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 8),
                          Text(
                            SharedPreferencesInstance.getString("Myname") ?? "",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            SharedPreferencesInstance.getString("Mydesig") ??
                                "",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            SharedPreferencesInstance.getString("Myemail") ??
                                "",
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _ProfileDataItem(
                  icon: const Icon(Icons.av_timer),
                  title: "Office Timing",
                  data: (SharedPreferencesInstance.getString("shiftstart") ??
                          "") +
                      " to " +
                      (SharedPreferencesInstance.getString("shiftend") ?? ""),
                ),
                _ProfileDataItem(
                  icon: const Icon(Icons.badge),
                  title: "Employee ID",
                  data: SharedPreferencesInstance.getString("Myid") ?? "",
                ),
                _ProfileDataItem(
                  icon: const Icon(Icons.phone),
                  title: "Phone Number",
                  data: SharedPreferencesInstance.getString("Myphone") ?? "",
                ),
                _ProfileDataItem(
                  icon: const Icon(Icons.flag),
                  title: "Reporting To",
                  data:
                      SharedPreferencesInstance.getString("Myreporting") ?? "",
                ),
                _ProfileDataItem(
                  icon: const Icon(Icons.work),
                  title: "Date Of Joining",
                  data: SharedPreferencesInstance.getString("Mydoj") ?? "",
                ),
                _ProfileDataItem(
                  icon: const Icon(Icons.cake),
                  title: "Date Of Birth",
                  data: SharedPreferencesInstance.getString("Mydob") ?? "",
                  addDivider: false,
                ),
                const SizedBox(height: 30),
                // TextButton(
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => const ChangePasswordScreen(),
                //       ),
                //     );
                //   },
                //   style: ButtonStyle(
                //       foregroundColor:
                //           MaterialStateProperty.all(const Color(0xff072a99))),
                //   child: const Text("Change Password"),
                // ),
                // TextButton.icon(
                //     icon: const Icon(Icons.logout),
                //     onPressed: () {
                //       GoogleSignIn().disconnect();
                //       SharedPreferencesInstance.logOut();
                //       Navigator.pushReplacement(
                //         context,
                //         MaterialPageRoute(
                //           builder: (context) => const Login(),
                //         ),
                //       );
                //     },
                //     label: const Text("Log Out"),
                //     style: ButtonStyle(
                //         padding: MaterialStateProperty.all(EdgeInsets.zero),
                //         foregroundColor: MaterialStateProperty.all(
                //           Colors.red,
                //         ))),
                const SizedBox(height: 10),
              ],
            ),
    );
  }
}

class _ProfileDataItem extends StatelessWidget {
  const _ProfileDataItem({
    Key? key,
    @required this.title,
    @required this.data,
    @required this.icon,
    this.addDivider = true,
  }) : super(key: key);

  final String? title, data;
  final bool? addDivider;
  final Icon? icon;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: icon,
              ),
              Expanded(
                child: Text(
                  title!,
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
              ),
              Expanded(
                  child: Text(
                data!,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              )),
            ],
          ),
          const SizedBox(height: 8),
          if (addDivider!) const Divider(),
        ],
      ),
    );
  }
}
