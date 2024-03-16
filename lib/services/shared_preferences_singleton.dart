import 'dart:developer';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesInstance {
  static SharedPreferences? instance;
  static initialize() async => instance = await SharedPreferences.getInstance();
  static bool get isUserLoggedIn => instance!.getString('username') != null;
  static getString(key) => instance!.getString(key);
  static setString(key, value) async =>
      await instance!.setString(key.toString(), value.toString());

  static logOut() async {
    GoogleSignIn().disconnect();
    DefaultCacheManager().emptyCache();
    await instance!.clear();
  }

  static saveLogs(
    url,
    request,
    response, {
    additionalInfo = "not Available",
    duration = "unknown",
  }) {
    List<String> logFiles = getLogs;
    logFiles.insert(0,
        "${DateTime.now()}\n\n$url\n\nduration: $duration seconds\n\nrequest:\n$request\n\nresponse:\n$response\n\nadditional Info:$additionalInfo");
    instance!.setStringList("logfiles", logFiles);
  }

  static saveError(error) {
    List<String> logFiles = getLogs;
    logFiles.insert(0, "error:\n$error");
    instance!.setStringList("logfiles", logFiles);
  }

  static List<String> get getLogs => instance!.getStringList("logfiles") ?? [];

  static saveUserProfileData(data) async {
    await setString("Myname", data['uname'] ?? "");
    await setString("Mydoj", data['u_doj'] ?? "");
    await setString("Myemail", data['u_email'] ?? "");
    await setString("Mygender", data['u_gender'] ?? "");
    await setString("Myphone", data['u_phone'] ?? "");
    await setString("Myid", data['uid'] ?? "");
    await setString("Myimg", data['img'] ?? "");
    await setString("Mydesig", data['u_designation'] ?? "");
    await setString("Myreporting", data['reporting_to'] ?? "");
    await setString("Mydob", data['u_dob'] ?? "");
    await setString("Myskills", data['u_skills'] ?? "");
    await setString("shiftname", data['shift_name'] ?? "");
    await setString("shiftstart", data['shift_start'] ?? "");
    await setString("shiftend", data['shift_end'] ?? "");
    await instance!.setBool("userDataSaved", true);
    log("Profile Data: " + data.toString());
  }

  static appInitialization(datak) async {
    await setString('appmgmt', datak['approval_mgmt']);
    await instance!.setInt('ucode', datak['code']);
    await setString('ucoden', datak['code']);
    await setString('freco', datak['face_recog']);
    await setString('offcstart', datak['office_start']);
    await setString('offcend', datak['office_end']);
    await setString('timing', datak['time']);
    await setString('locate', datak['loc_track']);
    await setString('greenid', datak['go_green']);
    await setString('reqatt', datak['req_attendance']);
    await setString('approval', datak['approval_mgmt']);
    await setString('ustatus', datak['user_status']);
    await setString('ulocat', datak['attendance_location']);
  }

  static loginDataInitialise(rsp) async {
    await setString('companyname', rsp['data']['comp_name']);
    await setString('username', rsp['data']['name']);
    await setString('email', rsp['data']['email']);
    await setString('profile2', rsp['data']['comp_logo']);
    await setString('profile', rsp['data']['profile']);
    await setString('uid', rsp['data']['uid']);
    await setString('empid', rsp['data']['emp_id']);
    await setString('comp_id', rsp['data']['cid']);
  }

  static goGreenLogin(data, datak) async {
    await setString('appmgmt', data['approval_mgmt']);
    await setString('freco', data['face_recog']);
    await setString('offcstart', data['office_start']);
    await setString('offcend', data['office_end']);
    await setString('timing', data['time']);
    await setString('locate', data['loc_track']);
    await setString('greenid', data['go_green']);
    await setString('reqatt', data['req_attendance']);
    await setString('approval', data['approval_mgmt']);
    await setString('ustatus', data['user_status']);
    await instance!.setInt('ucode', data['code']);
    if (datak != null) {
      await setString('ulocat', datak['attendance_location']);
    }
  }
}
