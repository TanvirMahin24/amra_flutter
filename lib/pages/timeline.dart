import 'package:amra/widgets/progress.dart';

import '../widgets/header.dart';
import 'package:flutter/material.dart';

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context),
      body: Container(
        child: linearProgress(),
      ),
    );
  }
}
