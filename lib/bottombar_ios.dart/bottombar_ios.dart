import 'dart:io';

import 'package:ezhrm/home_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class bottombar_ios extends StatefulWidget {
  const bottombar_ios({Key? key}) : super(key: key);

  @override
  State<bottombar_ios> createState() => _bottombar_iosState();
}

int? _currentindex;

class _bottombar_iosState extends State<bottombar_ios> {
  @override
  void initState() {
    getscreenstatus();
    super.initState();
  }

  String? currentscreen;
  getscreenstatus() async {
    SharedPreferences getscreenstatus = await SharedPreferences.getInstance();
    currentscreen = getscreenstatus.getString('screen') ?? "";
  }

  opendrawer() {
    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.indigo,
                  Colors.blue.shade600,
                ],
              ),
              // gradient: const LinearGradient(
              //   begin: Alignment.topCenter,
              //   end: Alignment.bottomCenter,
              //   colors: [
              //     Colors.black,
              //     Colors.indigo,
              //   ],
              // ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: const Icon(
                    Icons.menu,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  width: 55,
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) =>
                                  const HomeBottomNavigationBar())));
                    },
                    child: const Icon(
                      Icons.home,
                      color: Colors.white,
                    )),
                const SizedBox(
                  width: 55,
                ),
                GestureDetector(
                    onTap: () {
                      if (currentscreen != 'homescreen') {
                        Navigator.pop(context);
                      }
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    )),
              ],
            ),
            height: 50,
          )
        : const SizedBox();
  }
}
