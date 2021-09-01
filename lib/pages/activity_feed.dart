import 'package:amra/pages/home.dart';
import 'package:amra/pages/post_screen.dart';
import 'package:amra/pages/profile.dart';
import 'package:amra/widgets/header.dart';
import 'package:amra/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  final String currentUserId = currentUser!.id;
  bool isLoading = false;
  List<ActivityFeedItem> activities = [];
  @override
  initState() {
    super.initState();
    getActivityData();
    //print(currentUserId);
  }

  getActivityData() async {
    setState(() {
      isLoading = true;
    });
    var snapshot = await activityFeedRef
        .doc(currentUserId)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();
    //print('CALLL DONE:::::::::::::::::::::::::');
    setState(() {
      isLoading = false;
      activities = snapshot.docs
          .map((doc) => ActivityFeedItem.fromDocument(doc))
          .toList();
    });
  }

  buildActivities() {
    if (isLoading) {
      //print('Loading :::::::::::::::: $isLoading');
      return circularProgress();
    } else if (activities.isEmpty) {
      return Center(
        child: Text(
          "No Notifications",
          style: TextStyle(
            color: Colors.red[100],
            fontFamily: 'Signatra',
            fontSize: 48,
          ),
        ),
      );
    } else {
      return ListView(
        children: activities,
      );
    }
  }

  // Future getActivityFeedData() async {
  //   var snapshot = await activityFeedRef
  //       .doc(currentUser!.id)
  //       .collection('feedItems')
  //       .orderBy('timestamp', descending: true)
  //       .limit(50)
  //       .get();

  //   List<ActivityFeedItem> feeds = [];
  //   feeds = (snapshot.docs
  //         ..forEach((QueryDocumentSnapshot element) {
  //           feeds.add(ActivityFeedItem.fromDocument(element));
  //         }))
  //       .cast<ActivityFeedItem>();
  //   return feeds;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        title: "Notification",
        isAppTitle: false,
      ),
      // body: Container(
      //   child: FutureBuilder(
      //     builder: (context, snapshot) {
      //       if (!snapshot.hasData) {
      //         return circularProgress();
      //       }
      //       return ListView(
      //         children: snapshot.data as List<ActivityFeedItem>,
      //       );
      //     },
      //     future: getActivityFeedData(),
      //   ),
      // ),
      body: Container(
        child: buildActivities(),
      ),
    );
  }
}

late Widget mediaPreview;
late String activityTitleText;

class ActivityFeedItem extends StatelessWidget {
  late final String? username;
  late final String? mediaUrl;
  late final String? userId;
  late final String? type;
  late final String? postId;
  late final String? userProfileImg;
  late final Timestamp? timestamp;
  late final String? text;

  ActivityFeedItem({
    this.username,
    this.mediaUrl,
    this.userId,
    this.type,
    this.postId,
    this.userProfileImg,
    this.timestamp,
    this.text,
  });

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      // username: doc['username'],
      // mediaUrl: doc['mediaUrl'],
      // userId: doc['userId'],
      // type: doc['type'],
      // postId: doc['postId'],
      // userProfileImg: doc['userProfileImg'],
      // timestamp: doc['timestamp'],
      // text: doc['text']);
      username: doc.get('username'),
      mediaUrl: doc.get('mediaUrl'),
      userId: doc.get('userId'),
      type: doc.get('type'),
      postId: doc.get('postId'),
      userProfileImg: doc.get('userProfileImg'),
      timestamp: doc.get('timestamp'),
      text: doc.get('text').toString(),
    );
  }

  configMediaPerview(context) {
    if (type == 'like' || type == 'comment') {
      mediaPreview = GestureDetector(
        onTap: () => showPost(context),
        child: Container(
          height: 50,
          width: 50,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(mediaUrl!),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text("");
    }
    if (type == 'like') {
      activityTitleText = "liked your post";
    } else if (type == 'follow') {
      activityTitleText = "started following you";
    } else if (type == 'comment') {
      activityTitleText = "commented: $text";
    } else {
      activityTitleText = 'Error: "$type"';
    }
  }

  showPost(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(postId: postId!, userId: userId!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    configMediaPerview(context);
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      color: Colors.red.withOpacity(.1),
      child: ListTile(
        title: GestureDetector(
          onTap: () => showProfile(context, profileId: userId!),
          child: RichText(
            text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' $activityTitleText',
                  ),
                ]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(userProfileImg!),
        ),
        subtitle: Text(
          timeago.format(timestamp!.toDate()),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: mediaPreview,
      ),
    );
  }
}

showProfile(BuildContext context, {required String profileId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Profile(
        profileId: profileId,
      ),
    ),
  );
}
