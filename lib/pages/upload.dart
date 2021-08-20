import 'dart:io';

import 'package:amra/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class Upload extends StatefulWidget {
  late final User currentUser;
  Upload({required this.currentUser});
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  late PickedFile? imageFile = null;

  takePhotoFunc() async {
    Navigator.pop(context);
    PickedFile? file = await ImagePicker.platform
        .pickImage(source: ImageSource.camera, maxHeight: 675, maxWidth: 960);
    setState(() {
      imageFile = file;
    });
  }

  galleryImgFunc() async {
    Navigator.pop(context);
    PickedFile? file =
        await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    setState(() {
      imageFile = file;
    });
  }

  selectImageModal(contextMain) {
    return showDialog(
        context: contextMain,
        builder: (context) {
          return SimpleDialog(title: Text('Create Post'), children: [
            SimpleDialogOption(
              child: Text('Photo with Camera'),
              onPressed: takePhotoFunc,
            ),
            SimpleDialogOption(
              child: Text('Image from Gallery'),
              onPressed: galleryImgFunc,
            ),
            SimpleDialogOption(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
          ]);
        });
  }

  Container buildSplashScreen() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/upload.svg',
            height: 150,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Start Sharing Your Day',
            style: TextStyle(
              fontFamily: 'Signatra',
              fontSize: 40,
              color: Colors.red[100],
              fontWeight: FontWeight.w100,
            ),
          ),
          SizedBox(
            height: 40,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(primary: Colors.red[300]),
            onPressed: () => selectImageModal(context),
            child: Text('Upload Now'),
          ),
        ],
      ),
    );
  }

  clearImageFunc() {
    setState(() {
      imageFile = null;
    });
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          onPressed: clearImageFunc,
          icon: Icon(
            Icons.arrow_back,
            color: Colors.red[300],
          ),
        ),
        centerTitle: true,
        title: Text(
          'Post Details',
          style: TextStyle(
            fontFamily: 'Signatra',
            color: Colors.black,
            fontSize: 30,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Colors.transparent, shadowColor: Colors.transparent),
            onPressed: () {},
            child: Text(
              'Post',
              style: TextStyle(
                fontFamily: 'Signatra',
                color: Colors.black,
                fontSize: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return imageFile == null ? buildSplashScreen() : buildUploadForm();
  }
}
