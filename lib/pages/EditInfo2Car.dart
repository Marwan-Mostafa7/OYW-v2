import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:mapfltr/pages/EditInfo1User.dart';
import 'package:mapfltr/pages/home.dart';
import 'package:mapfltr/services/FBManager.dart';
import 'package:mapfltr/services/dataManager.dart';

import '../main.dart';

class EditInfoCar extends StatefulWidget {
  DataManager dmg;
  bool tog;

  EditInfoCar({DataManager dmg, bool togg}) {
    this.dmg = dmg;
    this.tog = togg;
  }
  @override
  State<StatefulWidget> createState() {
    return _EditInfoCar(dmg, this.tog);
  }
}

class _EditInfoCar extends State<EditInfoCar> {
  File carImg;
  String carImgPath;
  String carImgUrl; //  path of image on fireStore

  TextEditingController _brandContrl = TextEditingController();
  TextEditingController _modelCntrl = TextEditingController();
  TextEditingController _yearCntrl = TextEditingController();
  TextEditingController _sizeCntrl = TextEditingController();
  static Map<String, dynamic> _mp;
  DataManager dmg;
  bool toga;
  bool editImgToggle = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var _snackKey = GlobalKey<ScaffoldState>();

  _EditInfoCar(DataManager dmg, bool toga) {
    print("GOGOG");
    this.dmg = dmg;
    this.toga = toga;

    print(toga);

    print(dmg);
    _mp = dmg.getCar();
    print("LOLOLOLOLO");
  }

  // Car image
  Widget _buildCarImage() {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0),
      child: Center(
        child: Container(
            height: 100,
            width: 100,
            child: _mp['carImgPath'] != null && _mp['carImgPath'].isNotEmpty
                ? _showCarImg(path: true)
                : _mp['carImgUrl'] != null && _mp['carImgUrl'].isNotEmpty
                    ? _showCarImg(url: true)
                    : RaisedButton(
                        child: Icon(
                          Icons.add_a_photo,
                          size: 32,
                          color: Colors.white,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0)),
                        color: Color(0xff),
                        onPressed: _getCarImage,
                      )),
      ),
    );
  }

  // Go to Gallery and get Car image
  Future _getCarImage() async {
    var selectedImage =
        await ImagePicker.pickImage(source: ImageSource.gallery);

    if (selectedImage != null) {
      setState(() {
        carImg = selectedImage;
        carImgPath = carImg.path;
        _mp['carImgPath'] = carImgPath;
        editImgToggle = true;
      });
    }
  }

  // show image
  Widget _showCarImg({url: false, path: false}) {
    return InkWell(
      child: CircleAvatar(
          backgroundImage: path
              ? FileImage(File(_mp['carImgPath']))
              : NetworkImage(_mp['carImgUrl'])),
      splashColor: Colors.transparent,
      onTap: _getCarImage,
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
          //initialValue: _mp['brand'],
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
              if (!RegExp(r"^\d{4}$").hasMatch(value))
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

  Widget _buildDoneEditing() {
    return ButtonTheme(
      height: 60,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(90.0),
        ),
        onPressed: _buildActionCar,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Icon(
            Icons.edit,
            size: 30,
            color: Colors.white,
          ),
          Text("حفظ", style: TextStyle(color: Colors.white, fontSize: 29))
        ]),
        color: MyApp.myFront,
      ),
    );
  }

// Action Button
  _buildActionCar() async {
    if (!_formKey.currentState.validate()) {
      _showlossToast(context, "برجاء ادخال البيانات ");
      return;
    }

    if (editImgToggle) {
      carImgUrl = await uploadImage(carImgPath);
    }

    Map<String, String> mcar = {
      'brand': _brandContrl.text,
      'year': _yearCntrl.text,
      'size': _sizeCntrl.text,
      'model': _modelCntrl.text,
      'carImgUrl': carImgUrl
    };

    print("CAR <MAP> AFTER EDIT");
    print(mcar);

    await FBManager().updateCarData(mcar).then((s) {
      dmg.setCarImgPath(carImgPath);
      dmg.updateCar(carObj: mcar);
      _showlossToast(context, " تم التعديل بنجاح");
    });
  }

  Future<String> uploadImage(String imgPath) async {
    if (imgPath == null || imgPath.isEmpty) return "";
    StorageReference ref = FirebaseStorage.instance.ref().child(imgPath);
    StorageUploadTask uploadTask = ref.putFile(File(imgPath));
    var downUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
    var url = downUrl.toString();
    print("*******URL:: $url"); // String to be stored in the data base
    return url;
  }

  // Go to Car Data
  Widget _buildHomeDataBtn() {
    return ButtonTheme(
      height: 60,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(90.0),
        ),
        onPressed: () {
          Navigator.pop(context);
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomePage(dmg: dmg)));
        },
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Icon(
            Icons.home,
            size: 30,
            color: Colors.white,
          ),
          Text("الصفحة الرئيسية",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ]),
        color: Colors.transparent,
      ),
    );
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
              "بيانات السيارة",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 15),
            Icon(
              Icons.edit,
              size: 24,
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
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => EditInfoUser(dmg: dmg)));
          },
        ),
      ),
      body: Container(
        decoration: MyApp.mainDeco,
        child: Form(
          key: _formKey,
          child: _editInfoPage(),
        ),
      ),
    );
  }

  // whole Page UI
  _editInfoPage() {
    if (toga) {
      _brandContrl.text = _mp['brand'];
      _modelCntrl.text = _mp['model'];
      _sizeCntrl.text = _mp['size'];
      _yearCntrl.text = _mp['year'];
      carImgPath = _mp['carImgPath'];
      toga = false;
    }

    final screenSize = MediaQuery.of(context).size;

    return ListView(children: <Widget>[
      // image
      _buildCarImage(),

      // ماركة
      _buildCarBrand(),
      // Model
      _buildCarModel(),
      // year
      _buildCarYear(),
      // Size Number
      _buildCarSize(),
      // Space
      SizedBox(height: screenSize.height * 2 / 30),
      // done editing
      _buildDoneEditing(),
      SizedBox(height: screenSize.height / 45),
      _buildHomeDataBtn(),
    ]);
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
