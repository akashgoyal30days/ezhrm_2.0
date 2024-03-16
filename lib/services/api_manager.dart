// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class API_Manager {
//   void getQuota() {
//     Future fetchQuots(String uuid, String ccid) async {
//       var uri = "https://ezhrm.30days.host/controller/process/app/leave.php";
//       final response = await http.post(Uri.parse(uri), body: {
//         'uid': uuid,
//         'cid': ccid,
//         'type': 'fetch_quota'
//       }, headers: <String, String>{
//         'Accept': 'application/json',
//       });
//       var convertedDatatoJson = jsonDecode(response.body);
//       var items = jsonDecode(response.body);
//       //print(items);
//     }
//   }
// }
