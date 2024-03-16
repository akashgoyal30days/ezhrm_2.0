// import 'dart:convert';
// import 'package:data_connection_checker/data_connection_checker.dart';
// import 'package:ezhrm/bottombar_ios.dart/bottombar_ios.dart';
// import 'package:ezhrm/services/shared_preferences_singleton.dart';
// import 'package:flutter/material.dart';
// import 'package:jitsi_meet/feature_flag/feature_flag.dart';
// import 'package:jitsi_meet/jitsi_meet.dart';
// import 'package:ezhrm/constants.dart';
// import 'package:http/http.dart' as http;

// import 'drawer.dart';

// class MyMeetings extends StatefulWidget {
//   const MyMeetings({Key? key}) : super(key: key);

//   @override
//   _MyMeetingsState createState() => _MyMeetingsState();
// }

// class _MyMeetingsState extends State<MyMeetings>
//     with SingleTickerProviderStateMixin<MyMeetings> {
//   var data;
//   List userData = [];
//   String name;
//   String email;
//   String avatar;
//   var internet = 'yes';

//   void checkinternetconnection() async {
//     var listener = DataConnectionChecker().onStatusChange.listen((status) {
//       switch (status) {
//         case DataConnectionStatus.connected:
//           //print('Data connection is available.');
//           // OverlayScreen().pop();
//           setState(() {
//             internet = 'yes';
//           });
//           break;
//         case DataConnectionStatus.disconnected:
//           //print('You are disconnected from the internet.');
//           //   OverlayScreen().show(context, identifier: 'custom2');

//           setState(() {
//             internet = 'no';
//           });
//           NoInternet().noInternetConnectiondailog2(context);

//           break;
//       }
//     });
//     await Future.delayed(const Duration(seconds: 5));
//     await listener.cancel();
//   }

//   @override
//   void initState() {
//     super.initState();
//     // checkinternetconnection();
//     fetchMeetings();
//     getEmails();
//   }

//   Future getEmails() async {
//     setState(() {
//       email = SharedPreferencesInstance.getString('email');
//       name = SharedPreferencesInstance.getString('username');
//       if (SharedPreferencesInstance.getString('profile') == '') {
//         setState(() {
//           avatar = 'https://login.ezhrm.in/views/assets/img/download.png';
//         });
//       } else {
//         setState(() {
//           avatar = SharedPreferencesInstance.getString('profile');
//         });
//       }
//     });
//     if (debug == 'yes') {
//       //print(name);
//       //print(email);
//     }
//   }

//   Future fetchMeetings() async {
//     try {
//       var uri = "$customurl/controller/process/app/profile.php";
//       final response = await http.post(Uri.parse(uri), body: {
//         'uid': SharedPreferencesInstance.getString('uid'),
//         'cid': SharedPreferencesInstance.getString('comp_id'),
//         'type': 'fetch_meeting'
//       }, headers: <String, String>{
//         'Accept': 'application/json',
//       });
//       data = json.decode(response.body);
//       setState(() {
//         userData = data["data"];
//       });
//       if (debug == 'yes') {
//         //debugPrint(userData.toString());
//       }
//     } catch (error) {}
//   }

//   Future _joinMeeting(String rno, String subj) async {
//     if (debug == 'yes') {
//       //print('avatar- ${avatar}');
//     }
//     try {
//       FeatureFlag featureFlag = FeatureFlag();
//       featureFlag.welcomePageEnabled = false;
//       featureFlag.kickOutEnabled = false;
//       featureFlag.meetingPasswordEnabled = false;
//       featureFlag.inviteEnabled = false;
//       featureFlag.videoShareButtonEnabled = false;
//       featureFlag.liveStreamingEnabled = false;
//       featureFlag.pipEnabled = true;
//       featureFlag.tileViewEnabled = true;
//       featureFlag.closeCaptionsEnabled = false;
//       featureFlag.toolboxAlwaysVisible = false;
//       featureFlag.raiseHandEnabled = true;
//       featureFlag.callIntegrationEnabled = false;
//       featureFlag.recordingEnabled = false;
//       featureFlag.resolution = FeatureFlagVideoResolution
//           .MD_RESOLUTION; // Limit video resolution to 360p
//       var options = JitsiMeetingOptions()
//         ..room = rno // Required, spaces will be trimmed
//         ..serverURL = "https://meet.jit.si"
//         ..subject = subj
//         ..userDisplayName = name
//         ..userEmail = email
//         ..userAvatarURL = avatar // or .png
//         ..audioOnly = true
//         ..audioMuted = true
//         ..videoMuted = true
//         ..featureFlag = featureFlag;

//       await JitsiMeet.joinMeeting(options);
//     } catch (error) {
//       if (debug == 'yes') {
//         //debugPrint("error: $error");
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: const bottombar_ios(),
//       drawer:
//           const CustomDrawer(currentScreen: AvailableDrawerScreens.joinMeeting),
//       appBar: AppBar(
//         title: const Text(
//           'Meeting Room',
//           style: TextStyle(color: Colors.white),
//         ),
//         elevation: 0,
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [
//                 Colors.indigo,
//                 Colors.blue[600],
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: SizedBox(
//         width: double.infinity,
//         height: MediaQuery.of(context).size.height,
//         child: userData.isEmpty
//             ? const Center(
//                 child: Text(
//                   "Currently, no meetings are available",
//                   style: TextStyle(
//                     color: Colors.grey,
//                     fontStyle: FontStyle.italic,
//                   ),
//                 ),
//               )
//             : Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: ListView.builder(
//                     itemCount: userData == null ? 0 : userData.length,
//                     itemBuilder: (BuildContext context, int index) {
//                       return Padding(
//                         padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
//                         child: Column(
//                           children: [
//                             Column(
//                               children: [
//                                 Container(
//                                   decoration: const BoxDecoration(
//                                     borderRadius:
//                                         BorderRadius.all(Radius.circular(10)),
//                                     gradient: LinearGradient(
//                                       begin: Alignment.center,
//                                       end: Alignment.centerLeft,
//                                       colors: [
//                                         Colors.blue,
//                                         Colors.indigo,
//                                       ],
//                                     ),
//                                   ),
//                                   width: MediaQuery.of(context).size.width,
//                                   child: Card(
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: Column(
//                                         children: [
//                                           Center(
//                                               child: Text(
//                                             userData[index]['subject'],
//                                             style: const TextStyle(
//                                                 fontFamily: font1,
//                                                 fontSize: 20),
//                                           )),
//                                           const Divider(),
//                                           SizedBox(
//                                             width: MediaQuery.of(context)
//                                                 .size
//                                                 .width,
//                                             child: Padding(
//                                               padding:
//                                                   const EdgeInsets.all(4.0),
//                                               child: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceAround,
//                                                 children: [
//                                                   Padding(
//                                                     padding:
//                                                         const EdgeInsets.all(
//                                                             8.0),
//                                                     child: Center(
//                                                         child: Column(
//                                                       children: [
//                                                         const Text(
//                                                           'Start Time',
//                                                           style: TextStyle(
//                                                               fontFamily: font1,
//                                                               fontSize: 18,
//                                                               color:
//                                                                   Colors.black),
//                                                         ),
//                                                         Text(
//                                                           '${userData[index]['start_time'][11]}${userData[index]['start_time'][12]}:${userData[index]['start_time'][14]}${userData[index]['start_time'][15]}',
//                                                           style:
//                                                               const TextStyle(
//                                                                   fontSize: 20,
//                                                                   fontFamily:
//                                                                       font1,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .bold,
//                                                                   color: Colors
//                                                                       .black),
//                                                         ),
//                                                       ],
//                                                     )),
//                                                   ),
//                                                   Padding(
//                                                     padding:
//                                                         const EdgeInsets.all(
//                                                             8.0),
//                                                     child: Center(
//                                                         child: Column(
//                                                       children: [
//                                                         const Text(
//                                                           'End Time',
//                                                           style: TextStyle(
//                                                               fontFamily: font1,
//                                                               color:
//                                                                   Colors.black,
//                                                               fontSize: 18),
//                                                         ),
//                                                         Text(
//                                                           '${userData[index]['end_time'][11]}${userData[index]['end_time'][12]}:${userData[index]['end_time'][14]}${userData[index]['end_time'][15]}',
//                                                           style:
//                                                               const TextStyle(
//                                                                   fontSize: 20,
//                                                                   fontFamily:
//                                                                       font1,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .bold,
//                                                                   color: Colors
//                                                                       .black),
//                                                         ),
//                                                       ],
//                                                     )),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                           Container(
//                                               height: 40,
//                                               decoration: const BoxDecoration(
//                                                 borderRadius: BorderRadius.all(
//                                                     Radius.circular(10)),
//                                                 gradient: LinearGradient(
//                                                   begin: Alignment.topCenter,
//                                                   end: Alignment.bottomCenter,
//                                                   colors: [
//                                                     Colors.blue,
//                                                     Colors.indigo
//                                                   ],
//                                                 ),
//                                               ),
//                                               width: MediaQuery.of(context)
//                                                   .size
//                                                   .width,
//                                               child: TextButton(
//                                                 // color: Colors.black,
//                                                 onPressed: () {
//                                                   //  checkinternetconnection();

//                                                   _joinMeeting(
//                                                       userData[index]
//                                                           ['room_id'],
//                                                       userData[index]
//                                                           ['subject']);
//                                                 },
//                                                 child: const Text(
//                                                   'Join Meeting',
//                                                   style: TextStyle(
//                                                       color: Colors.white,
//                                                       fontSize: 18),
//                                                 ),
//                                               ))
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       );
//                     }),
//               ),
//         // bottomNavigationBar: CustomBottomNavigationBar(),
//       ),
//     );
//   }
// }
