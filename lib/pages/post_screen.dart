import 'package:amra/pages/home.dart';
import 'package:amra/widgets/header.dart';
import 'package:amra/widgets/post.dart';
import 'package:amra/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PostScreen extends StatelessWidget {
  late final String userId;
  late final String postId;

  PostScreen({required this.postId, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsRef.doc(postId).get(),
      //future: postsRef.doc(userId).collection('userPosts').doc(postId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        Post post = Post.fromDocument(snapshot.data as DocumentSnapshot);
        return Center(
          child: Scaffold(
            appBar: header(context, title: post.description, isAppTitle: false),
            body: ListView(
              children: [
                Container(
                  child: post,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
