import 'package:flutter/material.dart';

import 'constants.dart';

class MenuItem extends StatelessWidget {
  final IconData? icon;
  final String? title;
  final void Function()? onTap;

  const MenuItem({Key? key, this.icon, this.title, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap!,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 12, 4, 8),
        child: Column(
          children: [
            Row(
              children: <Widget>[
                Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(
                  width: 9,
                ),
                Expanded(
                  child: Text(
                    title!,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontFamily: font1,
                        fontSize: 17,
                        color: Colors.white),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget oldbuild(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MaterialButton(
        onPressed: (){},
        disabledElevation: 80,
        disabledColor: Colors.blue.withOpacity(0.1),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(
              width: 9,
            ),
            Text(
              title!,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontFamily: font1,
                  fontSize: 17,
                  color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
