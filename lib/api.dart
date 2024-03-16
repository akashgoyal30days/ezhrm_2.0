import 'dart:developer';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart';

Future loginUser(String email, String password, String did, String appversion,
    String ftoken) async {
  var uri = "$customurl/controller/process/app/login.php";
  final response = await http.post(Uri.parse(uri), body: {
    'email': email ?? "",
    'password': password ?? "",
    'device_id': did ?? "",
    'device_id2': did ?? "",
    'version': appversion ?? "",
    'firebase': ftoken ?? "",
    'platform': 'android',
  }, headers: <String, String>{
    'Accept': 'application/json',
  });
  log({
    'email': email ?? "",
    'password': password ?? "",
    'device_id': did ?? "",
    'device_id2': did ?? "",
    'version': appversion ?? "",
    'firebase': ftoken ?? "",
    'platform': 'android',
  }.toString());
  return json.decode(response.body);
}

Future fetchQuots(String uuid, String ccid) async {
  var uri = "$customurl/controller/process/app/leave.php";
  final response = await http.post(Uri.parse(uri), body: {
    'uid': uuid,
    'cid': ccid,
    'type': 'fetch_quota'
  }, headers: <String, String>{
    'Accept': 'application/json',
  });
  return json.decode(response.body);
}
