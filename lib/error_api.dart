import 'package:ezhrm/main.dart';
import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:http/http.dart';

import 'constants.dart';

class ErrorAPI {
  static errorOccuredAPI(String error, {String? url, String? body}) {
    print(
        "user name: ${SharedPreferencesInstance.getString("Myname")} company name: ${goGreenModel!.companyName} error: $error url:$url body:$body");
    post(Uri.parse("$customurl/controller/process/app/extras.php"), body: {
      "type": "log_error",
      "error":
          "user name: ${SharedPreferencesInstance.getString("Myname")} company name: ${goGreenModel!.companyName} error: $error url:$url body:$body"
    });
  }
}
