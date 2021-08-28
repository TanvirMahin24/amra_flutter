import 'package:amra/models/user.dart';
import 'package:amra/pages/create_account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import './activity_feed.dart';
import './profile.dart';
import './search.dart';
import './timeline.dart';
import './upload.dart';

final GoogleSignIn googleSignin = GoogleSignIn();
final usersRef = FirebaseFirestore.instance.collection('users');
final postDB = FirebaseFirestore.instance.collection('posts');
final CollectionReference<Map<String, dynamic>> postsRef = postDB;
final Reference storageRef = FirebaseStorage.instance.ref();
final timestamp = DateTime.now();

User? currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  late PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    //SIGNING IN
    googleSignin.onCurrentUserChanged.listen((account) {
      if (account != null) {
        //DO SOMETHING
        createUserInFirestore();
        //UPDATE STATE
        setState(() {
          isAuth = true;
        });
      } else {
        setState(() {
          isAuth = false;
        });
      }
    }, onError: (err) {
      print('ERROR SIGINING IN : $err');
    });

    //LOGIN
    googleSignin.signInSilently(suppressErrors: false).then((account) {
      if (account != null) {
        createUserInFirestore();
        //UPDATE STATE
        setState(() {
          isAuth = true;
        });
      } else {
        setState(() {
          isAuth = false;
        });
      }
    }).catchError((err) {
      print('ERROR LOGIN : $err');
    });
  }

  createUserInFirestore() async {
    final user = googleSignin.currentUser;
    DocumentSnapshot doc = await usersRef.doc(user!.id).get();

    if (!doc.exists) {
      final username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));

      //CREATE USER DOC
      usersRef.doc(user.id).set({
        "id": user.id,
        "username": username,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp": timestamp
      });

      doc = await usersRef.doc(user.id).get();
    }

    currentUser = User.fromDocument(doc);
  }

  @override
  dispose() {
    super.dispose();
    pageController.dispose();
  }

  login() {
    googleSignin.signIn();
  }

  logout() {
    googleSignin.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  tapHandeler(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(
        milliseconds: 400,
      ),
      curve: Curves.easeInOut,
    );
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: [
          Timeline(),
          ActivityFeed(),
          Upload(currentUser: currentUser),
          Search(),
          Profile(profileId: currentUser != null ? currentUser!.id : ""),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: tapHandeler,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.whatshot,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.notifications_active,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.photo_camera,
              size: 50,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.white70,
              Colors.redAccent,
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Amra',
              style: TextStyle(
                fontFamily: 'Signatra',
                color: Theme.of(context).primaryColor,
                fontSize: 90,
                shadows: [
                  Shadow(
                    offset: Offset(2.0, 2.0),
                    blurRadius: 3.0,
                    color: Color.fromARGB(180, 50, 0, 0),
                  )
                ],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 220,
                height: 50,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
