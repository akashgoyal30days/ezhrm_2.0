import 'package:flutter/material.dart';

const kBlackColor = Color(0xFF393939);
const kLightBlackColor = Color(0xFF8F8F8F);
const kIconColor = Color(0x0ff48a37);
const kProgressIndicator = Color(0xFFBE7066);

final kShadowColor = const Color(0xFFD3D3D3).withOpacity(.84);
const Color themecolor = Color(0xff072a99);

// const String customurl = 'https://dev.ezhrm.in';
const String customurl = 'https://login.ezhrm.in';
const String adminurl = 'https://manage.ezhrm.in';
const String debug = 'no';

const String font1 = 'Myriad';

class NoInternet {
  noInternetConnectiondailog2(BuildContext context) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: AlertDialog(
                titlePadding: const EdgeInsets.only(
                    left: 15, right: 15, top: 15, bottom: 10),
                contentPadding: const EdgeInsets.only(
                    left: 15, right: 15, top: 10, bottom: 10),
                actionsAlignment: MainAxisAlignment.end,
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(" Okay "))
                ],
                title: const Text(
                  "No Internet Connection",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w500),
                ),
                content: const Text(
                  "Please check your connection status and try again.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                ),
              ),
            ));
  }
}
