import 'package:amra/models/user.dart';
import 'package:amra/pages/edit_profile.dart';
import 'package:amra/pages/home.dart';
import 'package:amra/widgets/header.dart';
import 'package:amra/widgets/post.dart';
import 'package:amra/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  late final String profileId;

  Profile({required this.profileId});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String currentUserId = currentUser!.id;
  bool isLoading = false;
  int postCount = 0;
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
    var snapshot = await postsRef
        .doc(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  Column buildCountCol(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey, fontSize: 15),
        )
      ],
    );
  }

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(currentUserId: currentUserId)));
  }

  Container buildButton({required String text, Function? func}) {
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: Center(
        child: ElevatedButton(
          onPressed: () => func!(),
          child: Text(text),
          style: ElevatedButton.styleFrom(primary: Colors.red[300]),
        ),
      ),
    );
  }

  buildEditProfileButton() {
    bool isOwner = currentUserId == widget.profileId;
    if (isOwner) {
      return buildButton(text: "Edit Profile", func: editProfile);
    }
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: usersRef.doc(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data as DocumentSnapshot);
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildCountCol("Posts", postCount),
                            buildCountCol("Followers", 0),
                            buildCountCol("Following", 0),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildEditProfileButton(),
                          ],
                        )
                      ],
                    ),
                    flex: 1,
                  ),
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  user.username,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                padding: EdgeInsets.only(top: 12),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  user.displayName,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                padding: EdgeInsets.only(top: 5),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  user.bio,
                ),
                padding: EdgeInsets.only(top: 3),
              ),
            ],
          ),
        );
      },
    );
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    }
    return Column(
      children: posts,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isAppTitle: false),
      body: ListView(
        children: [
          buildProfileHeader(),
          Divider(
            height: 0,
          ),
          buildProfilePosts(),
        ],
      ),
    );
  }
}
