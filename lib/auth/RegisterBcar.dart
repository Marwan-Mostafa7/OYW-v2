// TODO:
//--------
// 1- Check
//     • brand -> One of the Car Brands List (cars_brands.txt) or new One   //Combo_box like City
//     • model -> String   // الموديل
//     • Year -> number    // السنة
//     • NumberOfPeople -> number  // عدد الافراد
//     • Image -> Not-Null

// 2- Add Car Data to --> JSON file  ['car']
// 3- Add Car Data to --> Firebase  [Require: User-Id]

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapfltr/auth/RegisterAdriver.dart';
import 'package:mapfltr/auth/login.dart';
import 'package:mapfltr/models/car.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mapfltr/pages/home.dart';
import 'package:mapfltr/services/FBManager.dart';

import 'dart:io';
import 'dart:async';

import 'package:mapfltr/services/dataManager.dart';
import '../main.dart';
import '../models/user.dart';

class RegisterCarPage extends StatefulWidget {
  DataManager dmg;
  User me;

  RegisterCarPage(User me, DataManager dmg) {
    this.dmg = dmg;
    this.me = me;
  }

  @override
  State<StatefulWidget> createState() {
    return _CarPageState();
  }
}

class _CarPageState extends State<RegisterCarPage> {
  File carImg;
  String carImgPath;
  String carImgUrl; //  path of image on fireStore

  bool press = false;
  bool wrong = false;

  TextEditingController _brandContrl = TextEditingController(text: "Toyota");
  TextEditingController _modelCntrl = TextEditingController(text: "Yaris");
  TextEditingController _yearCntrl = TextEditingController(text: "2011");
  TextEditingController _sizeCntrl = TextEditingController(text: "5");

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var _snackKey = GlobalKey<ScaffoldState>();
  // Car image
  Widget _buildCarImage() {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0),
      child: Center(
        child: Container(
          height: 100,
          width: 100,
          child: carImgPath == null
              ? RaisedButton(
                  child: Icon(
                    Icons.add_a_photo,
                    size: 32,
                    color: Colors.white,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0)),
                  color: Color(0xff),
                  onPressed: _getCarImage,
                )
              : _showCarImg(),
        ),
      ),
    );
  }

  // Car brand
  Widget _buildCarBrand() {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0, left: 10.0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextFormField(
          style: TextStyle(color: Colors.white, fontSize: 25),
          decoration: InputDecoration(
            labelText: "ماركة",
            labelStyle: TextStyle(color: Colors.white, fontSize: 24),
            hintText: "هيونداي",
            hintStyle: TextStyle(
              fontSize: 20,
              color: Colors.white54,
            ),
            prefix: Icon(
              Icons.brightness_auto,
              color: Colors.white,
              size: 25,
            ),
          ),
          controller: _brandContrl,
          validator: (value) {
            if (!RegExp(r"[a-zA-Z]+").hasMatch(value))
              return "برجاء ادخال اسم ماركة صحيح";
          },
        ),
      ),
    );
  }

  // Car model
  Widget _buildCarModel() {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0, left: 10.0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextFormField(
          style: TextStyle(color: Colors.white, fontSize: 25),
          decoration: InputDecoration(
            labelText: "موديل السيارة",
            labelStyle: TextStyle(color: Colors.white, fontSize: 24),
            hintText: "  النترا ",
            hintStyle: TextStyle(
              fontSize: 20,
              color: Colors.white54,
            ),
            prefix: Icon(
              Icons.directions_car,
              color: Colors.white,
              size: 30,
            ),
          ),
          controller: _modelCntrl,
          validator: (value) {
            if (!RegExp(r"[a-zA-Z0-9]+").hasMatch(value))
              return "برجاء ادخال موديل سيارة صحيح";
          },
        ),
      ),
    );
  }

  // Car year
  Widget _buildCarYear() {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0, left: 10.0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextFormField(
            keyboardType: TextInputType.number,
            style: TextStyle(color: Colors.white, fontSize: 25),
            decoration: InputDecoration(
              labelText: "السنة",
              labelStyle: TextStyle(color: Colors.white, fontSize: 24),
              hintText: "  2005",
              hintStyle: TextStyle(
                fontSize: 20,
                color: Colors.white54,
              ),
              prefix: Icon(
                Icons.av_timer,
                color: Colors.white,
                size: 30,
              ),
            ),
            controller: _yearCntrl,
            validator: (value) {
              if (!RegExp(r"[0-9]{4}").hasMatch(value))
                return "برجاء ادخال تاريخ السيارة صحيح";
            }),
      ),
    );
  }

  // // Car size
  Widget _buildCarSize() {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0, left: 10.0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextFormField(
            keyboardType: TextInputType.number,
            style: TextStyle(color: Colors.white, fontSize: 25),
            decoration: InputDecoration(
              labelText: "عدد الافراد",
              labelStyle: TextStyle(color: Colors.white, fontSize: 24),
              hintText: "  4",
              hintStyle: TextStyle(
                fontSize: 20,
                color: Colors.white54,
              ),
              prefix: Icon(
                Icons.people,
                color: Colors.white,
                size: 30,
              ),
            ),
            controller: _sizeCntrl,
            validator: (value) {
              if (!RegExp(r"^(?!0)[\d]{1,2}$").hasMatch(value))
                return "برجاء ادخال عدد ركاب السيارة صحيح";
            }),
      ),
    );
  }

  // Done Button
  Widget _buildCarDoneButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: ButtonTheme(
        height: 60,
        child: RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(90.0)),
            onPressed: submitCar,
            child: Text(
              "حفظ",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            color: MyApp.myFront),
      ),
    );
  }

  // Submit car
  void submitCar() {
    if (!_formKey.currentState.validate()) return;

    // Create User
    widget.dmg.createUser(myperson: widget.me);

    Car mycar = Car(
        brand: _brandContrl.text,
        carModel: _modelCntrl.text,
        carSize: _sizeCntrl.text,
        carYear: _yearCntrl.text,
        carImgPath: carImgPath,
        userId: widget.dmg.getUserID());

    // put car data in file
    widget.dmg.createCar(mycar: mycar);

    // ***************** All Car data in json *****************

    // Add [User-Car] data -into- Firebase
    FBManager(dmg: widget.dmg).authenticateUser(widget.me, mycar).then((v) {
      Navigator.pop(context);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage(widget.dmg)));
    }).catchError((e) {
      setState(() {
        print(e);
        wrong = true;
        _showlossToast(context);
      });
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
              Icons.directions_car,
              size: 37,
            ),
            SizedBox(width: 15),
            Text("بيانات السيارة"),
          ],
        ),
        // Go back button (to Driver Sign-up again)
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
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => RegisterDriverPage(widget.dmg)));
          },
        ),
      ),
      body: Container(
        decoration: MyApp.mainDeco,
        child: (press && !wrong)
            ? _buildCircularProg()
            : ListView(
                children: <Widget>[
                  // [Car]
                  // image
                  _buildCarImage(),
                  // Car INFORMATION
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        // ماركة
                        _buildCarBrand(),
                        // Model
                        _buildCarModel(),
                        // year
                        _buildCarYear(),
                        // Size Number
                        _buildCarSize(),
                      ],
                    ),
                  ),

                  // space for buttons
                  SizedBox(height: 15),

                  //SAVE Button
                  _buildCarDoneButton()
                ],
              ),
      ),
    );
  }

  Future<String> _uploadImage() async {
    StorageReference ref = FirebaseStorage.instance.ref().child(carImgPath);
    StorageUploadTask uploadTask = ref.putFile(carImg);
    var downUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
    var url = downUrl.toString();
    print("*******URL:: $url"); // String to be stored in the data base
    return url;
  }

  // Go to Gallery and get Car image
  Future _getCarImage() async {
    var selectedImage =
        await ImagePicker.pickImage(source: ImageSource.gallery);

    if (selectedImage != null) {
      setState(() {
        carImg = selectedImage;
        carImgPath = carImg.path;
      });
    }
  }

  Widget _showCarImg() {
    return CircleAvatar(backgroundImage: FileImage(File(carImgPath)));
  }

  Widget _buildCircularProg() {
    return Center(
      child: CircularProgressIndicator(
        backgroundColor: MyApp.myFront,
      ),
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
              ' هذا الايميل نشط الان',
              style: TextStyle(fontSize: 21),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
