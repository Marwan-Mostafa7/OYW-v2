// TODO:
//--------
// ► Remember me
// ► New account? (حساب جديد) link to Register page

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapfltr/pages/home.dart';
import 'package:mapfltr/services/dataManager.dart';

import '../main.dart';
import '../services/dataManager.dart';
import './RegisterAdriver.dart';

class LoginPage extends StatefulWidget {
  DataManager dmg;
  LoginPage(DataManager dmg) {
    this.dmg = dmg;
  }

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController userEmail =
      TextEditingController(text: "maro@yahoo.com");
  TextEditingController pass = TextEditingController(text: "123456");

  bool press = false;
  bool wrong = false;

  var _snackKey = GlobalKey<ScaffoldState>();

  // Email
  Widget _buildEmail() {
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
          validator: (String value) {},
        ),
      ),
    );
  }

  // Password
  Widget _buildPassword() {
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
        ),
      ),
    );
  }

  // SAVE button
  Widget _buildDoneBtn() {
    return ButtonTheme(
      height: 60,
      child: RaisedButton(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(90.0)),
        onPressed: loginAction,
        child: Text(
          "تسجيل الدخول",
          style: TextStyle(color: Colors.white, fontSize: 29),
        ),
        color: MyApp.myFront,
      ),
    );
  }

  loginAction() {
    // Check from FireStore if such user Exist
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: userEmail.text, password: pass.text)
        .then((user) {
      dmg.checkUser(user.email.toString(), user.uid.toString()).then((v) {
        Navigator.pop(context);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage(dmg: widget.dmg)));
      }).catchError((e) {
        print(e);
      });
    }).catchError((e) {
      setState(() {
        wrong = true;
      });
      print("NOT CORRECET");
      print(e);
      _showlossToast(context);
    });
    setState(() {
      press = true;
      wrong = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _snackKey,
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
            Text("تسجيل الدخول"),
          ],
        ),
      ),
      body: Container(
        decoration: MyApp.mainDeco,
        child: Builder(
          builder: (context) => Container(
                child: (press && !wrong)
                    ? _buildLoginAnime()
                    : _buildWholeLoginPage(),
              ),
        ),
      ),
    );
  }

  Widget _buildLoginAnime() {
    return Center(
      child: CircularProgressIndicator(
        backgroundColor: MyApp.myFront,
      ),
    );
  }

  Widget _buildGoRegister() {
    return ButtonTheme(
      height: 60,
      child: RaisedButton(
        child: Text(
          "عمل حساب جديد",
          style: TextStyle(color: Colors.white, fontSize: 29),
        ),
        color: Colors.transparent,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(90.0)),
        onPressed: registerAction,
      ),
    );
  }

  registerAction() {
    Navigator.pop(context);
    return Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => RegisterDriverPage(widget.dmg)));
  }

  Widget _buildWholeLoginPage() {
    final screenSize = MediaQuery.of(context).size;
    return ListView(
      children: <Widget>[
        // Space
        SizedBox(height: screenSize.height / 16),
        // E-mail
        _buildEmail(),
        // Space
        SizedBox(height: screenSize.height / 16),
        // Password
        _buildPassword(),
        // Space
        SizedBox(height: screenSize.height / 8),
        // SAVE button
        _buildDoneBtn(),
        // Space
        SizedBox(height: screenSize.height / 16),
        // make an Account
        _buildGoRegister(),
      ],
    );
  }

  void _showlossToast(BuildContext context) {
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
              ' البيانات غير صحيحة',
              style: TextStyle(fontSize: 21),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
