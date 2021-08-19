import 'package:flutter/material.dart';

Container circularProgress() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 20),
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.red[300]),
    ),
  );
}

Container linearProgress() {
  return Container(
    padding: EdgeInsets.only(bottom: 10),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.red[300]),
      backgroundColor: Colors.red[200],
    ),
  );
}
