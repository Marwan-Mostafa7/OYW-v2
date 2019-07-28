// TODO:
//--------
// 1- Check
//     • Full_name -> String[letters only NO DIGITS]
//     • userName -> String[One part]
//     • Password & password Conf match -> Alpha-Numeric[Not less than 6 characters]
//     • Phone -> number
//     • Img -> Not-Null

// 2- Add User Data to --> JSON file ['Personal']
// 3- Add User Data to --> Firebase
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapfltr/auth/RegisterBcar.dart';
import 'package:mapfltr/auth/login.dart';
import 'package:mapfltr/models/user.dart';
import 'package:mapfltr/services/dataManager.dart';

import 'dart:async';
import 'dart:io';

import '../main.dart';
import '../services/dataManager.dart';

class RegisterDriverPage extends StatefulWidget {
  DataManager dmg;
  RegisterDriverPage(DataManager dmg) {
    this.dmg = dmg;
  }

  @override
  State<StatefulWidget> createState() {
    return _DriverState();
  }
}

class _DriverState extends State<RegisterDriverPage> {
  File userImg; // image file
  String userImgPath; // path of image on phone
  String userImgUrl; //  path of image on fireStore
  User me;

  Color pink = Color.fromARGB(255, 255, 89, 89);

  TextEditingController userEmail =
      TextEditingController(text: 'maro@yahoo.com');
  TextEditingController userName = TextEditingController(text: 'Maco');
  TextEditingController phone = TextEditingController(text: "01273989169");
  TextEditingController pass = TextEditingController(text: '123456');
  TextEditingController rePass = TextEditingController(text: '123456');

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  FirebaseMessaging _messaging = FirebaseMessaging();

  // E-mail

  Widget _buildAddUserImg() {
    return Padding(
      padding: EdgeInsets.only(top: 18.0),
      child: Center(
        child: Container(
          height: 100,
          width: 100,
          margin: EdgeInsets.only(bottom: 12),
          child: userImgPath == null
              ? RaisedButton(
                  child: Icon(
                    Icons.add_a_photo,
                    size: 32,
                    color: Colors.white,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0)),
                  color: Color(0xff),
                  onPressed: _getUserImage,
                )
              : _showUserImg(),
        ),
      ),
    );
  }

  Widget _buildUserForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          // E-mail
          _buildEmailTextField(),
          // user name
          _buildUsernameTextField(),
          // phone
          _buildPhoneTextField(),
          // Password
          _buildPasswordTextField(),
          // verify password
          _buildConfPasswordTextField()
        ],
      ),
    );
  }

  Widget _buildEmailTextField() {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0, left: 10.0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextFormField(
            decoration: InputDecoration(
              labelText: "البريد الالكتروني",
              labelStyle: TextStyle(color: Colors.white),
              prefix: Icon(
                Icons.person_outline,
                color: Colors.white,
              ),
            ),
            style: TextStyle(fontSize: 24, color: Colors.white),
            controller: userEmail,
            validator: (value) {
              if (value.isEmpty ||
                  !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                      .hasMatch(value)) {
                return 'Please enter a valid email';
              }
            }),
      ),
    );
  }

  // Username
  Widget _buildUsernameTextField() {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0, left: 10.0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextFormField(
            decoration: InputDecoration(
              labelText: "اسم مختصر",
              labelStyle: TextStyle(color: Colors.white),
              hintText: "ahmed69",
              hintStyle: TextStyle(color: Colors.white54),
              prefix: Icon(
                Icons.person_outline,
                color: Colors.white,
              ),
            ),
            style: TextStyle(fontSize: 24, color: Colors.white),
            controller: userName,
            validator: (value) {}),
      ),
    );
  }

  // Phone
  Widget _buildPhoneTextField() {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0, left: 10.0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "الهاتف",
              labelStyle: TextStyle(color: Colors.white),
              hintText: "01xxxxxxxxx",
              hintStyle: TextStyle(color: Colors.white54),
              prefix: Icon(
                Icons.phone,
                color: Colors.white,
              ),
            ),
            style: TextStyle(fontSize: 24, color: Colors.white),
            controller: phone,
            validator: (value) {
              if (!RegExp(r"^01\d{9}$").hasMatch(value))
                return " برجاء ادخال رقم هاتف صحيح";
            }),
      ),
    );
  }

  // Password
  Widget _buildPasswordTextField() {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0, left: 10.0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextFormField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: "الرقم السري",
              labelStyle: TextStyle(color: Colors.white),
              prefix: Icon(
                Icons.security,
                color: Colors.white,
              ),
            ),
            style: TextStyle(fontSize: 24, color: Colors.white),
            controller: pass,
            validator: (value) {
              if (value.isEmpty || value.length < 6) {
                return 'الرقم السري 6 احرف علي الاقل';
              }
            }),
      ),
    );
  }

  // Confirm Password
  Widget _buildConfPasswordTextField() {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0, left: 10.0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextFormField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: " تأكيد الرقم السري",
              labelStyle: TextStyle(color: Colors.white),
              prefix: Icon(
                Icons.security,
                color: Colors.white,
              ),
            ),
            style: TextStyle(fontSize: 24, color: Colors.white),
            controller: rePass,
            validator: (value) {
              if (pass.text != value) {
                return "الرقم السري غير مطابق";
              }
            }),
      ),
    );
  }

  // Submit button
  Widget _buildSubmitButton() {
    return ButtonTheme(
      height: 60,
      child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(90.0),
          ),
          onPressed: submitForm,
          child:
              Text("حفظ", style: TextStyle(color: Colors.white, fontSize: 29)),
          color: MyApp.myFront),
    );
  }

  // submit method
  void submitForm() {
    // Check user entered data correctly
    if (!_formKey.currentState.validate()) return;

    _messaging.onTokenRefresh;

    // Stream<String> fcmStream = _messaging.onTokenRefresh;
    // fcmStream.listen((token) {
    //   saveToken(token);
    // });
    //https://stackoverflow.com/questions/51519863/updating-fcm-token-on-flutter-app

    _messaging.getToken().then((token) {
      me = User(
          userEmail: userEmail.text,
          userName: userName.text,
          phone: phone.text,
          pass: pass.text,
          userImgPath: userImgPath,
          token: token,
          rating: "0");
      // ***************** All driver data in json *****************

      // Navigate to Car-page  and pass User Obj to it
      Navigator.of(context);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => RegisterCarPage(me, widget.dmg)));
    });
  }

  @override
  Widget build(BuildContext context) {
    //if (widget.dmg.fExists) checkData();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.person_outline,
              size: 37,
            ),
            SizedBox(width: 15),
            Text("بيانات المستخدم"),
          ],
        ),
        leading: RaisedButton(
            color: Colors.transparent,
            elevation: 0,
            highlightColor: Colors.transparent,
            highlightElevation: 0,
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context);
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => LoginPage(widget.dmg)));
            }),
      ),
      body: Container(
        decoration: MyApp.mainDeco,
        child: ListView(
          children: <Widget>[
            // [Driver]

            // Add image
            _buildAddUserImg(),
            // User Registration
            _buildUserForm(),
            // space for buttons
            SizedBox(height: 15),
            // Submit button
            _buildSubmitButton()
          ],
        ),
      ),
    );
  }

  // Go to Gallery and get User image
  Future _getUserImage() async {
    var selectedImage =
        await ImagePicker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      setState(() {
        userImg = selectedImage;
        userImgPath = userImg.path;
        dmg.setUserImgPath(userImgPath);
        //basename(userImg.path); // gives the name of the image, not full path
      });
    }
  }

  // show image
  Widget _showUserImg() {
    return CircleAvatar(backgroundImage: FileImage(File(userImgPath)));
  }

  // TODO `delete`
  // Avoid re-write data again when geting to same page again
  void checkData() {
    var isMe = widget.dmg.getUser();
    userImgPath = isMe['userImg'];
    userEmail.text = isMe['userEmail'];
    userName.text = isMe['userName'];
    phone.text = isMe['phone'];
    pass.text = isMe['pass'];
    rePass.text = isMe['pass'];
  }
}
