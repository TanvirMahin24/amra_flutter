import 'package:amra/pages/home.dart';
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
  Future getActivityFeedData() async {
    QuerySnapshot snapshot = await activityFeedRef
        .doc(currentUser!.id)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();

    List<ActivityFeedItem> feeds = [];
    feeds = snapshot.docs.map((element) {
      return ActivityFeedItem.fromDocument(element);
    }).toList();
    return feeds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        title: "Notification",
        isAppTitle: false,
      ),
      body: Container(
        child: FutureBuilder(
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }
            return ListView(
              children: snapshot.data as List<ActivityFeedItem>,
            );
          },
          future: getActivityFeedData(),
        ),
      ),
    );
  }
}

late Widget mediaPreview;
late String activityTitleText;

class ActivityFeedItem extends StatelessWidget {
  late final String username;
  late final String mediaUrl;
  late final String userId;
  late final String type;
  late final String postId;
  late final String userProfileImg;
  late final Timestamp timestamp;
  late final String text;

  ActivityFeedItem({
    required this.username,
    required this.mediaUrl,
    required this.userId,
    required this.type,
    required this.postId,
    required this.userProfileImg,
    required this.timestamp,
    required this.text,
  });

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
        username: doc['username'],
        mediaUrl: doc['mediaUrl'],
        userId: doc['userId'],
        type: doc['type'],
        postId: doc['postId'],
        userProfileImg: doc['userProfileImg'],
        timestamp: doc['timestamp'],
        text: doc['text']);
  }

  configMediaPerview() {
    if (type == 'like' || type == 'comment') {
      mediaPreview = GestureDetector(
        onTap: () => print('click'),
        child: Container(
          height: 50,
          width: 50,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(mediaUrl),
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

  @override
  Widget build(BuildContext context) {
    configMediaPerview();
    return Padding(
      padding: EdgeInsets.only(bottom: 2),
      child: Container(
        color: Colors.red.withOpacity(.2),
        child: ListTile(
          title: GestureDetector(
            onTap: () {},
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
            backgroundImage: CachedNetworkImageProvider(userProfileImg),
          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }
}
