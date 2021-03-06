import 'dart:async';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:lpi_app/Screens/Dashboard/dashboard_screen.dart';
import 'package:lpi_app/Screens/Login/components/background.dart';
import 'package:lpi_app/components/four_radio_input_button.dart';
import 'package:lpi_app/components/radio_input_field.dart';
import 'package:lpi_app/components/rectangle_input_field.dart';
import 'package:lpi_app/components/rounded_button.dart';
import 'package:lpi_app/components/rounded_input_field.dart';
import 'package:lpi_app/components/text_field_container.dart';
import 'package:lpi_app/Screens/UserRegistration/components/uploader.dart';
import 'package:lpi_app/constants.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final _auth = FirebaseAuth.instance;
  int selectedValue;
  int selectedValue2;

  String imagePath;
  String imageCloudPath;
  String firstname;
  String surname;
  String gender;
  String membershipType;
  String email;
  String phone;
  Timestamp created;

  File _imageFile;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);
    setState(() {
      _imageFile = selected;
      //imagePath = _imageFile.path;
    });
  }

  Future<void> _cropImage() async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: _imageFile.path,
    );
    setState(() {
      _imageFile = cropped ?? _imageFile;
    });
  }

  void _clear() {
    setState(() => _imageFile = null);
  }

  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://lpiapp-4a5a5.appspot.com');

  StorageUploadTask _uploadTask;

  void _startUpload() {
    String filePath = 'images/${DateTime.now()}.png';
    imageCloudPath = filePath;
    setState(() {
      _uploadTask = _storage.ref().child(filePath).putFile(_imageFile);
    });
  }

  _downloadImg(imageRef) {
    var url = _storage.ref().child(imageRef).getDownloadURL();
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: new Stack(fit: StackFit.loose, children: <Widget>[
                    new Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ClipOval(
                          child: SizedBox(
                              width: 140,
                              height: 140,
                              child: (_imageFile != null)
                                  ? Image.file(
                                      _imageFile,
                                      fit: BoxFit.contain,
                                    )
                                  : Image.network(
                                      'https://cdn.business2community.com/wp-content/uploads/2017/08/blank-profile-picture-973460_640.png')),
                        ),
                        
                      ],
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 90.0, right: 100.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            (_imageFile != null) ?
                            CircleAvatar(
                              backgroundColor: kPrimaryColor,
                              radius: 25.0,
                              child: IconButton(
                                icon: Icon(Icons.crop),
                                onPressed: _cropImage,
                                color: Colors.black,
                              ),
                            ):
                            new CircleAvatar(
                              backgroundColor: kPrimaryColor,
                              radius: 25.0,
                              child: IconButton(
                                icon: Icon(Icons.photo_camera),
                                onPressed: () => _pickImage(ImageSource.camera),
                                color: Colors.black,
                              ),
                            )
                          ],
                        )),
                    Padding(
                        padding: EdgeInsets.only(top: 90.0, left: 90.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            (_imageFile != null) ?
                            new CircleAvatar(
                              backgroundColor: kPrimaryColor,
                              radius: 25.0,
                              child: IconButton(
                                icon: Icon(Icons.refresh),
                                onPressed: _clear,
                                color: Colors.black,
                              ),
                            ):
                            new CircleAvatar(
                              backgroundColor: kPrimaryColor,
                              radius: 25.0,
                              child: IconButton(
                                icon: Icon(Icons.photo_library),
                                onPressed: () =>
                                    _pickImage(ImageSource.gallery),
                                color: Colors.black,
                              ),
                            )
                          ],
                        )),
                  ]),
                )



                
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Column(),
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RectangleInputField(
                    icon: Icons.person,
                    hintText: "Surname",
                    onChanged: (value) {
                      //email = value;
                      surname = value;
                    },
                  ),
                  RectangleInputField(
                    icon: Icons.person,
                    hintText: "Firstname",
                    onChanged: (value) {
                      //email = value;
                      firstname = value;
                    },
                  ),
                  RectangleInputField(
                    icon: Icons.email,
                    hintText: "Email",
                    onChanged: (value) {
                      email = value;
                    },
                  ),
                  RectangleInputField(
                    icon: Icons.phone,
                    hintText: "Phone Number",
                    onChanged: (value) {
                      phone = value;
                    },
                  ),
                  DualRadioButton(
                    title: 'Gender',
                    option1: 'Female',
                    option2: 'Male',
                    selectedValue: selectedValue,
                    onChanged: (int selectionValue) {
                      setState(() {
                        selectedValue = selectionValue;
                        (selectionValue == 0)
                            ? gender = "Female"
                            : gender = "Male";
                      });
                    },
                  ),
                  QuadDualRadioButton(
                    title: 'Membership Type',
                    option1: 'Pay as you go',
                    option2: 'Izone (Individual)',
                    option3: 'Izone (Startup/Group)',
                    option4: 'Premium',
                    option5: 'Intern',
                    option6: 'Hub Courses',
                    selectedValue2: selectedValue2,
                    onChanged: (int selectionValue2) {
                      setState(() {
                        selectedValue2 = selectionValue2;
                        if (selectionValue2 == 2) {
                          membershipType = 'Pay as you go';
                        } else if (selectionValue2 == 3) {
                          membershipType = 'Izone (Individual)';
                        } else if (selectionValue2 == 4) {
                          membershipType = 'Izone (Startup/Group)';
                        } else if (selectionValue2 == 5) {
                          membershipType = 'Premium';
                        } else if (selectionValue2 == 6) {
                          membershipType = 'Intern';
                        } else if (selectionValue2 == 7) {
                          membershipType = 'Hub Course';
                        }
                      });
                    },
                  ),
                  Container(
                    child: Uploader(
                      file: _imageFile,
                      firstname: firstname,
                      surname: surname,
                      gender: gender,
                      created: created,
                      membershipType: membershipType,
                      email: email,
                      phone: phone,
                    ),
                  ),
                  // RoundedButton(
                  //   text: "REGISTER MEMBER",
                  //   press: () {

                  //     created = Timestamp.now();
                  //     _firestore.collection('members').add({
                  //       'firstname': firstname,
                  //       'email': email,
                  //       'createdAt': created,
                  //       'gender': gender,
                  //       'surname': surname,
                  //       'phone': phone,
                  //       'accountLevel': membershipType,
                  //       'profilepic': imageCloudPath
                  //     });
                  //     print('The Image path we seek is ---->  $imageCloudPath');
                  //     Navigator.pushNamed(context, DashboardScreen.id);
                  //     Uploader(
                  //       file: _imageFile,
                  //     );
                  //     _startUpload;
                  //   },
                  // ),
                  SizedBox(
                    height: 20,
                  ),
                ]),
          ],
        ),
      ),
    );
  }
}
