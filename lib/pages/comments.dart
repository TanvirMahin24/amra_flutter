import 'package:amra/pages/home.dart';
import 'package:amra/widgets/header.dart';
import 'package:amra/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  late final String postId;
  late final String postOwnerId;
  late final String postMediaUrl;

  Comments(
      {required this.postId,
      required this.postOwnerId,
      required this.postMediaUrl});
  @override
  CommentsState createState() => CommentsState(
      postId: this.postId,
      postOwnerId: this.postOwnerId,
      postMediaUrl: this.postMediaUrl);
}

class CommentsState extends State<Comments> {
  late final String postId;
  late final String postOwnerId;
  late final String postMediaUrl;
  TextEditingController commentController = TextEditingController();

  CommentsState(
      {required this.postId,
      required this.postOwnerId,
      required this.postMediaUrl});

  buildComments() {
    return StreamBuilder(
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<Widget> comments = [];
        snapshot.data!.docs.forEach((doc) {
          comments.add(Comment.fromDocument(doc));
        });
        return ListView(children: comments);
      },
      stream: commentsRef
          .doc(postId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .snapshots(),
    );
  }

  addComment() async {
    await commentsRef.doc(postId).collection('comments').add({
      "username": currentUser!.username,
      "comment": commentController.text,
      "timestamp": DateTime.now(),
      "avatarUrl": currentUser!.photoUrl,
      "userId": currentUser!.id
    });

    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, title: "Comments", isAppTitle: false),
      body: Column(
        children: [
          Expanded(
            child: buildComments(),
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration: InputDecoration(hintText: "Write a comment..."),
            ),
            trailing: OutlinedButton(
              onPressed: addComment,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.transparent, width: 0),
              ),
              child: Text(
                'Post',
                style: TextStyle(
                  color: Colors.red[300],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  late final String username;
  late final String userId;
  late final String avatarUrl;
  late final String comment;
  late final Timestamp timestamp;

  Comment({
    required this.username,
    required this.userId,
    required this.avatarUrl,
    required this.comment,
    required this.timestamp,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
        username: doc['username'],
        userId: doc['userId'],
        avatarUrl: doc['avatarUrl'],
        comment: doc['comment'],
        timestamp: doc['timestamp']);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(comment),
          leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(avatarUrl)),
          subtitle: Text(timeago.format(timestamp.toDate())),
        ),
        Divider(),
      ],
    );
  }
}
