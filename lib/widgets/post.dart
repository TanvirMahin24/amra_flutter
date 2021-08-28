import 'package:amra/models/user.dart';
import 'package:amra/pages/home.dart';
import 'package:amra/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Post extends StatefulWidget {
  late final String postId;
  late final String ownerId;
  late final String username;
  late final String location;
  late final String description;
  late final String mediaUrl;
  late final dynamic likes;

  Post({
    required this.postId,
    required this.ownerId,
    required this.username,
    required this.location,
    required this.description,
    required this.likes,
    required this.mediaUrl,
  });

  factory Post.fromDocument(doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      likes: doc['likes'],
      mediaUrl: doc['mediaUrl'],
    );
  }

  int getLikeCount(likes) {
    if (likes == null) {
      return 0;
    }
    int count = 0;
    likes.values.forEach((val) {
      if (val == true) {
        count++;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
      postId: this.postId,
      ownerId: this.ownerId,
      username: this.username,
      location: this.location,
      description: this.description,
      mediaUrl: this.mediaUrl,
      likes: this.likes,
      likeCount: getLikeCount(this.likes));
}

class _PostState extends State<Post> {
  late final String postId;
  late final String ownerId;
  late final String username;
  late final String location;
  late final String description;
  late final String mediaUrl;

  late Map likes;
  late int likeCount;

  _PostState(
      {required this.postId,
      required this.ownerId,
      required this.username,
      required this.location,
      required this.description,
      required this.mediaUrl,
      required this.likes,
      required this.likeCount});

  buildPostHeader() {
    return FutureBuilder(
        future: usersRef.doc(ownerId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          User user = User.fromDocument(snapshot.data as DocumentSnapshot);
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              backgroundColor: Colors.grey,
            ),
            title: GestureDetector(
              onTap: () {},
              child: Text(
                user.username,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            subtitle: Text(location),
            trailing: IconButton(
              onPressed: () {},
              icon: Icon(Icons.more_vert),
            ),
          );
        });
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: () {},
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(mediaUrl),
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 40,
              width: 20,
            ),
            GestureDetector(
              onTap: () {},
              child: Icon(
                Icons.favorite_border,
                size: 28,
                color: Colors.red[200],
              ),
            ),
            SizedBox(
              width: 20,
            ),
            GestureDetector(
              onTap: () {},
              child: Icon(
                Icons.chat,
                size: 28,
                color: Colors.red[300],
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                "$likeCount Loves",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                "$username ",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Text(description),
            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
        Divider()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }
}
