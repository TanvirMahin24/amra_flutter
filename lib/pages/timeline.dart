import 'package:amra/pages/home.dart';
import 'package:amra/widgets/post.dart';
import 'package:amra/widgets/progress.dart';

import '../widgets/header.dart';
import 'package:flutter/material.dart';

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  bool isLoading = false;
  List<Post> posts = [];

  @override
  initState() {
    super.initState();
    getProfilePosts();
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    var snapshot = await postsRef.orderBy('timestamp', descending: true).get();
    setState(() {
      isLoading = false;
      posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Container(
          padding: EdgeInsets.only(top: 80),
          child: Column(
            children: [
              Center(
                child: Icon(
                  Icons.yard_outlined,
                  color: Colors.red[100],
                  size: 60,
                ),
              ),
              Center(
                child: Text(
                  "No Posts Found",
                  style: TextStyle(
                    color: Colors.red[100],
                    fontFamily: 'Signatra',
                    fontSize: 48,
                  ),
                ),
              ),
              Center(
                child: Text(
                  "Try sharing your day",
                  style: TextStyle(
                    color: Colors.red[100],
                    fontFamily: 'Signatra',
                    fontSize: 28,
                  ),
                ),
              ),
            ],
          ));
    } else {
      return Column(
        children: posts,
      );
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context),
      body: Container(
        child: buildProfilePosts(),
      ),
    );
  }
}
