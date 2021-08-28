import 'package:amra/widgets/custom_image.dart';
import 'package:amra/widgets/post.dart';
import 'package:flutter/material.dart';

class PostTile extends StatelessWidget {
  late final Post post;
  PostTile(this.post);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}
