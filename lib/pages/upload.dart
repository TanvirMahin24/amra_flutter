import 'dart:io';
import 'package:amra/models/user.dart';
import 'package:amra/pages/home.dart';
import 'package:amra/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  late final User? currentUser;
  Upload({required this.currentUser});
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  late File? imageFile = null;
  bool isUploading = false;
  String postId = Uuid().v4();
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();

  takePhotoFunc() async {
    Navigator.pop(context);
    PickedFile? file = await ImagePicker.platform
        .pickImage(source: ImageSource.camera, maxHeight: 675, maxWidth: 960);
    setState(() {
      imageFile = File(file!.path);
    });
  }

  galleryImgFunc() async {
    Navigator.pop(context);
    PickedFile? file =
        await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    setState(() {
      imageFile = File(file!.path);
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

  compressImg() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image? imageToUpload = Im.decodeImage(imageFile!.readAsBytesSync());
    final compressedImgFile = File('$path/post_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageToUpload!, quality: 85));
    setState(() {
      imageFile = compressedImgFile;
    });
  }

  uploadImage(imgFile) async {
    //UploadTask uploadTask =
    //    storageRef.child('post_$postId.jpg').putFile(imgFile);
    //TaskSnapshot snapshot = await uploadTask.snapshot;
    //String downloadUrl = await snapshot.ref.getDownloadURL().toString();
    Reference ref = storageRef.child('post_$postId.jpg');
    TaskSnapshot uploadTask = await ref.putFile(imgFile);
    var downUrl = uploadTask.ref.getDownloadURL();

    return downUrl;
  }

  createPostInFirestore(
      {required String mediaUrl,
      required String location,
      required String description}) async {
    print(widget.currentUser!.id);
    postsRef
        .doc(widget.currentUser!.id)
        .collection('userPosts')
        .doc(postId)
        .set({
      "userId": widget.currentUser!.id,
      "postId": postId,
      "ownerId": widget.currentUser!.id,
      "username": widget.currentUser!.username,
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
      "timestamp": DateTime.now(),
      "likes": {}
    });
  }

  submitForm() async {
    setState(() {
      isUploading = true;
    });
    await compressImg();
    String mediaUrl = await uploadImage(imageFile);
    await createPostInFirestore(
        mediaUrl: mediaUrl,
        location: locationController.text,
        description: captionController.text);
    captionController.clear();
    locationController.clear();
    setState(() {
      imageFile = null;
      isUploading = false;
      postId:
      Uuid().v4();
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
        // title: Text(
        //   'Post Details',
        //   style: TextStyle(
        //     fontFamily: 'Signatra',
        //     color: Colors.black,
        //     fontSize: 30,
        //   ),
        // ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Colors.transparent, shadowColor: Colors.transparent),
            onPressed: isUploading ? null : () => submitForm(),
            child: Text(
              'Post Now',
              style: TextStyle(
                fontFamily: 'Signatra',
                color: Colors.red[300],
                fontSize: 30,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          isUploading ? linearProgress() : Text(''),
          SizedBox(
            height: 20,
          ),
          Container(
            height: 220,
            width: MediaQuery.of(context).size.width * .8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(imageFile!),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                widget.currentUser!.photoUrl,
              ),
            ),
            title: Container(
              width: 250,
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                  hintText: "Caption for your post....",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop_outlined,
              color: Colors.red[200],
              size: 30,
            ),
            title: Container(
              width: 250,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: "Location of the photo....",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 200,
            height: 100,
            alignment: Alignment.center,
            child: ElevatedButton.icon(
              onPressed: getCurrentDeviceLocation,
              icon: Icon(Icons.my_location),
              label: Text('Use current location'),
            ),
          ),
        ],
      ),
    );
  }

  getCurrentDeviceLocation() async {
    //CHECK PERMISSION
    late bool serviceEnabled;
    late LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      print('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return print('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      print(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks =
        await placemarkFromCoordinates(pos.latitude, pos.longitude);
    Placemark placemark = placemarks[0];
    String locationFinal = "${placemark.locality}, ${placemark.country}";
    locationController.text = locationFinal;
  }

  @override
  Widget build(BuildContext context) {
    return imageFile == null ? buildSplashScreen() : buildUploadForm();
  }
}
