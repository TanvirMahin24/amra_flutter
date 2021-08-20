import 'package:amra/models/user.dart';
import 'package:amra/pages/home.dart';
import 'package:amra/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot>? searchResFuture = null;

  searchFunc(String query) {
    Future<QuerySnapshot> users =
        usersRef.where('displayName', isGreaterThanOrEqualTo: query).get();
    setState(() {
      searchResFuture = users;
    });
  }

  clearSearch() {
    searchController.clear();
  }

  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        onFieldSubmitted: searchFunc,
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search Users...',
          filled: true,
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search_outlined,
            color: Colors.red[300],
          ),
          suffixIcon: IconButton(
            onPressed: clearSearch,
            icon: Icon(
              Icons.clear,
              color: Colors.red[300],
            ),
          ),
        ),
      ),
    );
  }

  Container buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            SvgPicture.asset(
              'assets/images/search.svg',
              height: orientation == Orientation.portrait ? 250 : 150,
            ),
            Text(
              'Find new friends',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Signatra',
                  color: Colors.red[100]),
            ),
          ],
        ),
      ),
    );
  }

  buildSearchResults() {
    return FutureBuilder(
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        List<UserResult> searchRes = [];
        snapshot.data!.docs.forEach((doc) {
          User user = User.fromDocument(doc);
          UserResult resUser = UserResult(user);
          searchRes.add(resUser);
        });
        return ListView(
          children: searchRes,
        );
      },
      future: searchResFuture,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildSearchField(),
      body: searchResFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  late final User user;

  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {},
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.red[200],
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style: TextStyle(fontFamily: 'Signatra', fontSize: 24),
              ),
              subtitle: Text(
                user.username,
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ),
          Divider(
            height: 2.0,
          )
        ],
      ),
    );
  }
}
