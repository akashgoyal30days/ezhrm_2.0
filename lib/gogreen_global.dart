import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

import 'constants.dart';
import 'main.dart';
import 'services/shared_preferences_singleton.dart';

class GoGreenGlobal {
  static initialize() async {
    log("Gogreen initialized");
    String platformtype;
    if (Platform.isAndroid) {
      platformtype = 'android';
    } else {
      platformtype = 'ios';
    }
    try {
      var body = {
        'uid': SharedPreferencesInstance.getString('uid') ?? "",
        'cid': SharedPreferencesInstance.getString('comp_id') ?? "",
        'type': 'go_green',
        'firebase_token':
            SharedPreferencesInstance.getString('fbasetoken') ?? "",
        'device_id': SharedPreferencesInstance.getString('deviceid') ?? "",
        'version': version,
        'platform': platformtype,
      };
      log("Gogreen Data we sending : " +
          {
            'uid': SharedPreferencesInstance.getString('uid') ?? "",
            'cid': SharedPreferencesInstance.getString('comp_id') ?? "",
            'type': 'go_green',
            'firebase_token':
                SharedPreferencesInstance.getString('fbasetoken') ?? "",
            'device_id': SharedPreferencesInstance.getString('deviceid') ?? "",
            'version': version,
            'platform': platformtype,
          }.toString());
      var apiStartTime = DateTime.now();

      final response = await http.post(


        Uri.parse(
          "$customurl/controller/process/app/extras.php"),
          body: body,
          headers: <String, String>{
            'Accept': 'application/json',
          });
      var apiEndTime = DateTime.now();

      datak = json.decode(response.body);
      log(datak.toString());
      SharedPreferencesInstance.saveLogs(
          response.request!.url.toString(), json.encode(body), response.body,
          duration: apiEndTime.difference(apiStartTime).inSeconds);
      if (datak.containsKey('code')) val = datak['code'].toString();
      log("Gogreen status : " + datak['status'].toString());
      if (datak['status'].toString() == "false") {
        // Fluttertoast.showToast(
        //     backgroundColor: Colors.grey.shade700,
        //     msg: "Invalid Device, please login with registered device");
        await SharedPreferencesInstance.logOut();
      }
      log(datak.toString());
      SharedPreferencesInstance.appInitialization(datak);
      log("Initialized");
      return;
    } catch (error) {
      log("Error in initialized");
      Fluttertoast.showToast(
          backgroundColor: Colors.grey.shade700,
          msg: "Unable to connect server, please try again.");
    }
  }
}

class GoGreenModel {
  final bool? backgroundLocationTrackingEnabled,
      faceRecognitionEnabled,
      locationEnabled,
      canSendRequest,
      showattendancetime,
      showUpdateAvailableDialog,
      debugEnable;
  final String? companyName, companyLogo;
  final int? backgroundLocationInterval;

  const GoGreenModel(
      {this.backgroundLocationTrackingEnabled,
      this.faceRecognitionEnabled,
      this.showUpdateAvailableDialog,
      this.showattendancetime,
      this.debugEnable,
      this.locationEnabled,
      this.canSendRequest,
      this.companyName,
      this.companyLogo,
      this.backgroundLocationInterval});
}
