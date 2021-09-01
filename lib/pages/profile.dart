import 'package:amra/models/user.dart';
import 'package:amra/pages/edit_profile.dart';
import 'package:amra/pages/home.dart';
import 'package:amra/widgets/header.dart';
import 'package:amra/widgets/post.dart';
import 'package:amra/widgets/post_tile.dart';
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
  bool isFollowing = false;
  bool isLoading = false;
  int postCount = 0;
  int folloewrCount = 0;
  int followingCount = 0;
  List<Post> posts = [];
  bool isListPost = false;

  @override
  initState() {
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkFollowing();
  }

  checkFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.profileId)
        .collection("userFollowers")
        .doc(currentUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowers() async {
    QuerySnapshot doc = await followersRef
        .doc(widget.profileId)
        .collection("userFollowers")
        .get();
    setState(() {
      folloewrCount = doc.docs.length;
    });
  }

  getFollowing() async {
    QuerySnapshot doc = await followingRef
        .doc(widget.profileId)
        .collection("userFollowing")
        .get();
    setState(() {
      followingCount = doc.docs.length;
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    var snapshot = await postsRef
        // .doc(widget.profileId)
        // .collection('userPosts')
        .where('userId', isEqualTo: widget.profileId)
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
          child: Text(
            text,
            style: TextStyle(color: isFollowing ? Colors.black : Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            primary: isFollowing ? Colors.red[100] : Colors.red[300],
          ),
        ),
      ),
    );
  }

  buildEditProfileButton() {
    bool isOwner = currentUserId == widget.profileId;
    if (isOwner) {
      return buildButton(text: "Edit Profile", func: editProfile);
    } else if (isFollowing) {
      return buildButton(text: "Unfollow", func: unfollowFunc);
    } else if (!isFollowing) {
      return buildButton(text: "Follow", func: followFunc);
    }
  }

  unfollowFunc() {
    setState(() {
      isFollowing = false;
    });
    //Remove follower from profile owner
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });

    //Remove following from current user
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });

    //Delete notification to profile owner
    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });
  }

  followFunc() async {
    setState(() {
      isFollowing = true;
    });
    //Adding follower to profile owner
    await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .set({});

    //Adding following to current user
    await followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({});

    //Add notification to profile owner
    await activityFeedRef
        .doc(currentUserId)
        .collection('feedItems')
        .doc(widget.profileId)
        .set({
      "type": "follow",
      "text": "",
      "postId": "",
      "mediaUrl": "",
      "username": currentUser!.username,
      "userId": currentUserId,
      "userProfileImg": currentUser!.photoUrl,
      "timestamp": DateTime.now(),
    });
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
                            buildCountCol("Followers", folloewrCount),
                            buildCountCol("Following", followingCount),
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
    } else if (isListPost) {
      return Column(
        children: posts,
      );
    }

    List<GridTile> gridTiles = [];
    posts.forEach((element) {
      gridTiles.add(GridTile(
        child: PostTile(element),
      ));
    });

    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 1,
      mainAxisSpacing: 1.5,
      crossAxisSpacing: 1.5,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: gridTiles,
    );
  }

  buildPostViewToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () => setToogleFunc('grid'),
          icon: Icon(
            Icons.grid_on,
            color: !isListPost ? Colors.red[300] : Colors.grey,
          ),
        ),
        IconButton(
          onPressed: () => setToogleFunc('list'),
          icon: Icon(
            Icons.list,
            color: isListPost ? Colors.red[300] : Colors.grey,
          ),
        ),
      ],
    );
  }

  setToogleFunc(String type) {
    setState(() {
      isListPost = type == "list" ? true : false;
    });
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
          buildPostViewToggle(),
          Divider(
            height: 0,
          ),
          buildProfilePosts(),
        ],
      ),
    );
  }
}
