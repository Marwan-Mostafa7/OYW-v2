import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapfltr/pages/EditInfo2Car.dart';
import 'package:mapfltr/services/FBManager.dart';

import 'package:mapfltr/services/dataManager.dart';

import '../main.dart';
import 'home.dart';

class EditInfoUser extends StatefulWidget {
  DataManager dmg;

  EditInfoUser({DataManager dmg}) {
    this.dmg = dmg;
    // print("CONSTRUCCCCTOOOR USER");
    // print(dmg);
  }
  @override
  State<StatefulWidget> createState() {
    return _EditInfoUser(this.dmg);
  }
}

class _EditInfoUser extends State<EditInfoUser> {
  static Map<String, dynamic> _mp;
  DataManager dmg;

  _EditInfoUser(DataManager dmg) {
    // print("GOGOG USER");
    this.dmg = dmg;
    // print(dmg);
    _mp = dmg.getUser();
    // print("ALOHA USER");
    // print(_mp);
  }

  Color pink = Color.fromARGB(255, 255, 89, 89);

  File userImg; // image file
  String userImgPath; // path of image on phone
  String userImgUrl; // //  path of image on fireStore
  String newImgPath;
  bool userNtgle = false;
  bool imgToggle = false;

  TextEditingController email = TextEditingController();
  TextEditingController userName = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController newPass = TextEditingController();
  TextEditingController oldPass = TextEditingController();

  var _snackKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

// _mp['userName']
  // Add image
  Widget _buildAddImg() {
    return Padding(
      padding: EdgeInsets.only(top: 18.0),
      child: Center(
        child: Container(
          height: 100,
          width: 100,
          margin: EdgeInsets.only(bottom: 12),
          child: _mp['userImg'] != null && _mp['userImg'].isNotEmpty
              ? _showUserImg(path: true)
              : _mp['userImgUrl'] != null && _mp['userImgUrl'].isNotEmpty
                  ? _showUserImg(url: true)
                  : RaisedButton(
                      child: Icon(Icons.add_a_photo,
                          size: 32, color: Colors.white),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0)),
                      color: Color(0xff),
                      onPressed: _getUserImage,
                    ),
        ),
      ),
    );
  }

  Future _getUserImage() async {
    var selectedImage =
        await ImagePicker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      setState(() {
        imgToggle = true;
        userImg = selectedImage;
        userImgPath = userImg.path;
        _mp['userImg'] = userImgPath;
      });
    }
  }

  // show image
  Widget _showUserImg({url: false, path: false}) {
    return InkWell(
      child: CircleAvatar(
          backgroundImage: path
              ? FileImage(File(_mp['userImg']))
              : NetworkImage(_mp['userImgUrl'])),
      splashColor: Colors.transparent,
      onTap: _getUserImage,
    );
  }

  // user name
  Widget _buildUserName() {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0, left: 10.0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextField(
          decoration: InputDecoration(
            labelText: " تعديل اسم مختصر ",
            labelStyle: TextStyle(color: Colors.white),
            hintText: "ahmed69",
            hintStyle: TextStyle(color: Colors.white54),
            prefix: Icon(
              Icons.person_outline,
              color: Colors.white,
            ),
          ),
          style: TextStyle(fontSize: 20, color: Colors.white),
          controller: userName,
          onChanged: (v) {
            userNtgle = true;
          },
        ),
      ),
    );
  }

  // Old Pass
  Widget _buildOldPass() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextFormField(
          obscureText: true,
          controller: oldPass,
          decoration: InputDecoration(
              labelText: "الرقم السري القديم",
              labelStyle: TextStyle(color: Colors.black, fontSize: 20)),
          validator: (value) {
            if (value.isEmpty || value.length < 6) {
              return 'الرقم السري 6 احرف علي الاقل';
            }
          }),
    );
  }

  Widget _buildNewPass() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextFormField(
          obscureText: true,
          controller: newPass,
          decoration: InputDecoration(
              labelText: "الرقم السري الجديد",
              labelStyle: TextStyle(color: Colors.black, fontSize: 20)),
          validator: (value) {
            if (value.isEmpty || value.length < 6) {
              return 'الرقم السري 6 احرف علي الاقل';
            }
          }),
    );
  }

// Password
  Widget _buildEditPass() {
    return Card(
      color: Colors.white70,
      child: Form(
        key: _formKey,
        child: ExpansionTile(
            title: Center(child: Text("تعديل الرقم السري")),
            leading: Icon(Icons.security),
            children: [
              // Old Pass
              _buildOldPass(),
              // New Pass
              _buildNewPass(),
              // Update Button
              RaisedButton(
                onPressed: _updatePass,
                color: MyApp.myFront,
                child: Text(
                  "تعديل ",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ]),
      ),
    );
  }

  _updatePass() {
    // Check user entered data correctly
    if (!_formKey.currentState.validate()) return;

    FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: _mp['userEmail'], password: oldPass.text)
        .then((user) {
      Firestore.instance
          .collection('users')
          .where('userEmail', isEqualTo: user.email)
          .where('pass', isEqualTo: user.uid)
          .snapshots()
          .listen((user) {
        print("COMER ************");
        print(user.documents[0].data);

        FirebaseAuth.instance.currentUser().then((user) {
          print("UPDATING PASS :D :D ");
          print(user.email);
          user.updatePassword(newPass.text).then((s) {
            _showlossToast(context, " تم تعديل الرقم السري");
          }).catchError((e) {
            _showlossToast(context, " برجاء اعادة التسجيل");
            return;
          });
        });
      });
    }).catchError((e) {
      _showlossToast(context, " البيانات غير صحيحة");
      return;
    });
  }

// Save Data
  Widget _buildEditDataBtn() {
    return ButtonTheme(
      height: 60,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(90.0),
        ),
        onPressed: _buildUpdateUser,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Icon(
            Icons.edit,
            size: 30,
            color: Colors.white,
          ),
          Text("حفظ ",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ]),
        color: MyApp.myFront,
      ),
    );
  }

  // Action Button
  _buildUpdateUser() {
    if (!imgToggle && !userNtgle) {
      _showlossToast(context, "  برجاء ادخال بيانات ");
      return;
    }
    // print("THE DMG");
    // print(dmg);
    // Update Image
    // upload image .. get imgUrl

    // if img changed
    // get new url
    if (imgToggle) {
      print(imgToggle);
      print("------------------------------------------");
      _uploadImage(userImgPath).then((imgUrl) {
        dmg.setUserImgURL(imgUrl, imgPath: userImgPath);
        FBManager().updateUserImgUrl(_mp, imgUrl);
        _showlossToast(context, " تم تعديل الصورة بنجاح");
        imgToggle = false;
      });
    }
    print("Img Out");
    print(imgToggle);
    print("HERE");
    if (!userNtgle) return;

    print("editing username Now ");

    FBManager().updateUserName(_mp, userName.text).then((s) {
      dmg.updateUserName(userName.text);
      _showlossToast(context, " تم تعديل الاسم بنجاح");
      setState(() {
        _mp['userName'] = userName.text;
        imgToggle = false;
        userNtgle = false;
      });
      return;
    });
  }

  // Go to Car Data
  Widget _buildCarDataBtn() {
    return ButtonTheme(
      height: 60,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(90.0),
        ),
        onPressed: _goToCarPageAction,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Icon(
            Icons.directions_car,
            size: 30,
            color: Colors.white,
          ),
          Text("بيانات السيارة",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ]),
        color: Colors.transparent,
      ),
    );
  }

  _goToCarPageAction() {
    Navigator.pop(context);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => EditInfoCar(dmg: dmg, togg: true)));
  }

  Future<String> _uploadImage(String imgPath) async {
    StorageReference ref = FirebaseStorage.instance.ref().child(imgPath);
    StorageUploadTask uploadTask = ref.putFile(File(imgPath));
    var downUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
    var url = downUrl.toString();
    print("*******URL:: $url"); // String to be stored in the data base
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _snackKey,
      appBar: AppBar(
        title: Center(
            child: Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "بيانات المستخدم",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 15),
            Icon(
              Icons.edit,
              size: 20,
            )
          ],
        )),
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
            Navigator.pop(context);
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HomePage(dmg: dmg)));
          },
        ),
      ),
      body: Center(
        child: Container(
          decoration: MyApp.mainDeco,
          child: _editInfoPage(),
        ),
      ),
    );
  }

  Widget _editInfoPage() {
    final screenSize = MediaQuery.of(context).size;

    // email.text = _mp['userEmail'];
    // userName.text = _mp['userName'];

    //phone.text = _mp['phone'];

    return ListView(
      children: <Widget>[
        // Add Image
        _buildAddImg(),
        // // Email
        Center(
            child: Text(
          _mp['userEmail'],
          style: TextStyle(color: MyApp.myFront3, fontSize: 20),
        )),
        // // user name
        Center(
            child: Text(
          _mp['userName'],
          style: TextStyle(color: MyApp.myFront3, fontSize: 20),
        )),
        // username
        _buildUserName(),
        // phone
        //_buildPhone(),
        // Pass
        SizedBox(height: screenSize.height / 15),
        _buildEditPass(),

        SizedBox(height: screenSize.height * 2 / 45),
        // Edit Car Info
        _buildEditDataBtn(),
        SizedBox(height: screenSize.height / 45),

        // Edit Car Info
        _buildCarDataBtn()
      ],
    );
  }

  void _showlossToast(BuildContext context, String title) {
    final scaffold = _snackKey.currentState;
    scaffold.showSnackBar(
      SnackBar(
        backgroundColor: Color(0xff263859),
        duration: Duration(seconds: 2),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.error),
            Text(
              title,
              style: TextStyle(fontSize: 21),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }


}
