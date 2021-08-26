import 'package:amra/models/user.dart';
import 'package:amra/pages/home.dart';
import 'package:amra/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";

class EditProfile extends StatefulWidget {
  late final currentUserId;
  EditProfile({this.currentUserId});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scfKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  late User user;
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool _bioValid = true;
  bool _displayNameValid = true;

  @override
  void initState() {
    getUser();
    super.initState();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.doc(widget.currentUserId).get();
    user = User.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;
    setState(() {
      isLoading = false;
    });
  }

  updateProfileData() {
    setState(() {
      _displayNameValid = displayNameController.text.trim().length < 3 ||
              displayNameController.text.isEmpty
          ? false
          : true;
      _bioValid = bioController.text.trim().length > 100 ? false : true;
    });
    if (_displayNameValid && _bioValid) {
      usersRef.doc(widget.currentUserId).update({
        "displayName": displayNameController.text,
        "bio": bioController.text,
      });

      SnackBar snackbar = SnackBar(
        content: Text(
          "Profile Updated",
        ),
      );
      _scfKey.currentState!.showSnackBar(snackbar);
    }
  }

  logoutFunc() async {
    await googleSignin.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scfKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Edit Profile",
          style: TextStyle(
            fontFamily: 'Signatra',
            color: Colors.red[300],
            fontSize: 30,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.done,
              size: 30,
              color: Colors.green,
            ),
          )
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: [
                Container(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 16,
                      ),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey,
                        backgroundImage:
                            CachedNetworkImageProvider(user.photoUrl),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 16,
                                ),
                                Text(
                                  "Display Name",
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                                TextField(
                                  controller: displayNameController,
                                  decoration: InputDecoration(
                                      hintText: "Update Display Name",
                                      errorText: _displayNameValid
                                          ? null
                                          : "Display name too short"),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Text(
                                  "Bio",
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                                TextField(
                                  controller: bioController,
                                  decoration: InputDecoration(
                                      hintText: "Update Bio",
                                      errorText:
                                          _bioValid ? null : "Bio too long"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: updateProfileData,
                        child: Text("Update Profile"),
                      ),
                      SizedBox(
                        height: 80,
                      ),
                      ElevatedButton(
                        onPressed: logoutFunc,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            Text(
                              "Logout",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                            primary: Colors.red, fixedSize: Size(140, 40)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
