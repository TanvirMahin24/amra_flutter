import 'package:flutter/material.dart';

AppBar header(context,
    {bool isAppTitle = true, String title = '', bool back = false}) {
  return AppBar(
    automaticallyImplyLeading: true,
    title: Text(
      isAppTitle
          ? 'Amra'
          : title != ''
              ? title
              : 'Profile',
      style: TextStyle(
        overflow: TextOverflow.ellipsis,
        fontFamily: 'Signatra',
        color: Colors.white,
        fontSize: isAppTitle ? 40 : 30,
      ),
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).primaryColor,
  );
}
