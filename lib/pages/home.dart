import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapfltr/auth/login.dart';
import 'dart:io';

import 'package:mapfltr/pages/MyTrips.dart';
import 'package:mapfltr/pages/map_default.dart';
import 'package:mapfltr/pages/notification.dart';
import 'package:mapfltr/statistics/statHome.dart';

import '../main.dart';
import './map.dart';
import './allTrips.dart';
import '../services/dataManager.dart';
import 'AddTripPage.dart';
import 'EditInfo1User.dart';

class HomePage extends StatefulWidget {
  DataManager dmg;

  HomePage({DataManager dmg}) {
    this.dmg = dmg;
  }
  @override
  State<StatefulWidget> createState() {
    return _HomePgState(dmg);
  }
}

class _HomePgState extends State<HomePage> {
  static Map<String, dynamic> _mp;
  DataManager dmg;

  _HomePgState(DataManager dmg) {
    // print("HEEEEEEEEEEEEEEEERER");
    // print("GOGOG");
    this.dmg = dmg;

    _mp = dmg.getUser();

    // print("ALOHA");
    // print(_mp);
  }
  List<String> cities = DataManager.CITIES;

  String fr = "", to = "";
  TextEditingController queryF = TextEditingController();
  TextEditingController queryT = TextEditingController();

  String _city = 'الإسكندرية ';
  Color itemsBackColor = MyApp.myFront3.withAlpha(120);
  Color itemsFrontColor = Colors.white;

  void _setcity(ncty) {
    setState(() {
      _city = ncty;

      if (fr.isNotEmpty) queryF.text = fr;
      if (to.isNotEmpty) queryT.text = to;
    });
  }

  File userImg; // image file
  String userImgPath = ""; // // path of image on phone
  String userImgUrl = ""; // //  path of image on fireStore
  bool mapToggle = false;

  // Add image
  Widget _buildAddImg() {
    return Padding(
      padding: EdgeInsets.only(top: 2.0),
      child: Center(
        child: Container(
          height: 100,
          width: 100,
          margin: EdgeInsets.only(bottom: 12),
          child: _mp['userImg'] != null && _mp['userImg'].isNotEmpty
              ? _showUserImg(path: true)
              : _mp['userImgUrl'] != null && _mp['userImgUrl'].isNotEmpty
                  ? _showUserImg(url: true)
                  : CircleAvatar(
                      backgroundImage: AssetImage('assets/person.jpg')),
        ),
      ),
    );
  }

// Statistics
  Widget _buildStat() {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Center(
        child: RaisedButton(
          child: Table(
              columnWidths: {0: FractionColumnWidth(0.8)},
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              textDirection: TextDirection.rtl,
              children: [
                TableRow(children: [
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      "الاحصائيات",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 23,
                          color: itemsFrontColor),
                    ),
                  ),
                  Icon(
                    Icons.dashboard,
                    color: itemsFrontColor,
                    size: 50,
                  ),
                ]),
              ]),
          onPressed: () {
            // print("BEFORE GO TO EDIT USER //**/*/");
            // print(widget.dmg.getUser());
            Navigator.pop(context);

            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => StatHome(dmg: widget.dmg)));
          },
          color: itemsBackColor,
          elevation: 0,
        ),
      ),
    );
  }

// Edit user Info
  Widget _buildEditInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: Center(
        child: RaisedButton(
          child: Table(
              columnWidths: {0: FractionColumnWidth(0.8)},
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              textDirection: TextDirection.rtl,
              children: [
                TableRow(children: [
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      "تعديل البيانات",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 23,
                          color: itemsFrontColor),
                    ),
                  ),
                  Icon(
                    Icons.edit,
                    color: itemsFrontColor,
                    size: 50,
                  ),
                ]),
              ]),
          onPressed: () {
            // print("BEFORE GO TO EDIT USER //**/*/");
            // print(widget.dmg.getUser());
            Navigator.pop(context);
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => EditInfoUser(dmg: widget.dmg)));
          },
          color: itemsBackColor,
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildAddTrip() {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: RaisedButton(
        child: Table(
            columnWidths: {0: FractionColumnWidth(0.8)},
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            textDirection: TextDirection.rtl,
            children: [
              TableRow(children: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    "اضافة رحلة",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 23,
                        color: itemsFrontColor),
                  ),
                ),
                Icon(
                  Icons.add,
                  color: itemsFrontColor,
                  size: 50,
                ),
              ]),
            ]),
        onPressed: () {
          Navigator.pop(context);

          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => AddTrip(dmg: widget.dmg)));
        },
        color: itemsBackColor,
        elevation: 0,
      ),
    );
  }

  Widget _buildMyTrips() {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: RaisedButton(
        child: Table(
            columnWidths: {0: FractionColumnWidth(0.8)},
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            textDirection: TextDirection.rtl,
            children: [
              TableRow(children: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    "رحلاتي",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 23,
                        color: itemsFrontColor),
                  ),
                ),
                Icon(
                  Icons.directions_bus,
                  color: itemsFrontColor,
                  size: 50,
                ),
              ]),
            ]),
        onPressed: () {
          Navigator.pop(context);

          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => ShowMyTrips(dmg: dmg)));
        },
        color: itemsBackColor,
        elevation: 0,
      ),
    );
  }

  Widget _buildNotification() {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: RaisedButton(
        child: Table(
            columnWidths: {0: FractionColumnWidth(0.8)},
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            textDirection: TextDirection.rtl,
            children: [
              TableRow(children: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    "الاشعارات",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 23,
                        color: itemsFrontColor),
                  ),
                ),
                Icon(
                  Icons.notifications,
                  color: itemsFrontColor,
                  size: 50,
                ),
              ]),
            ]),
        onPressed: () {
          Navigator.pop(context);

          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => NotificationPage(dmg: dmg)));
        },
        color: itemsBackColor,
        elevation: 0,
      ),
    );
  }

  Widget _buildLogOut() {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: RaisedButton(
        child: Table(
            columnWidths: {0: FractionColumnWidth(0.8)},
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            textDirection: TextDirection.rtl,
            children: [
              TableRow(children: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    "تسجيل خروج",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 23,
                        color: itemsFrontColor),
                  ),
                ),
                Icon(
                  Icons.exit_to_app,
                  color: itemsFrontColor,
                  size: 50,
                ),
              ]),
            ]),
        onPressed: () {
          // TODO
          // Log-Out with Firebase
          dmg.logOut();

          print("LOG OUT");

          FirebaseAuth.instance.signOut().then((value) {
            Navigator.pop(context);
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage(dmg)));
          }).catchError((e) {
            print(e);
          });
        },
        color: itemsBackColor,
        elevation: 0,
      ),
    );
  }

  Widget _buildChooseCity() {
    return // Choose City
        Container(
      child: Table(
        children: [
          // Drop Down Menu
          TableRow(
            children: [
              Center(
                child: DropdownButton(
                  value: _city,
                  iconSize: 0,
                  items: cities.map((value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Center(
                        child: Text(
                          value,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (ncty) {
                    _setcity(ncty);
                  },
                ),
              ),
              Text(
                "اختر محافظة",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textDirection: TextDirection.rtl,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFromText() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextField(
        textDirection: TextDirection.rtl,
        style: TextStyle(fontSize: 24, color: Colors.black),
        decoration: InputDecoration(
          labelText: " من :",
          labelStyle: TextStyle(
            fontSize: 25,
            color: Colors.black,
          ),
          filled: true,
          fillColor: Colors.white70,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        controller: queryF,
        onChanged: (queryFrom) {
          fr = queryFrom;
        },
      ),
    );
  }

  Widget _buildToText() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextField(
        style: TextStyle(fontSize: 24, color: Colors.black),
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          labelText: " : الي",
          labelStyle: TextStyle(
            fontSize: 25,
            color: Colors.black,
          ),
          filled: true,
          fillColor: Colors.white70,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        controller: queryT,
        onChanged: (queryTo) {
          to = queryTo;
        },
      ),
    );
  }

  Widget _buildGoTripsBTN() {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(90.0)),
      color: MyApp.myFront,
      onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AllTripsPage(dmg),
            ),
          ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        textDirection: TextDirection.rtl,
        children: <Widget>[
          Text(
            "الرحلات",
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Row(children: [
            Icon(
              Icons.train,
              color: Colors.white,
              size: 70,
            )
          ])
        ],
      ),
    );
  }

  Widget _buildGoToMapBTN() {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(90.0)),
      color: Color(0xff),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapPage(
                  queryF: fr,
                  queryT: to,
                  city: _city,
                ),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        textDirection: TextDirection.rtl,
        children: <Widget>[
          Text(
            "الخريطة",
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Icon(
            Icons.map,
            color: Colors.white,
            size: 70,
          ),
        ],
      ),
    );
  }

  Widget _buildGoToDefaultMap() {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(90.0)),
      color: Color(0xff),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapDefault(),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        textDirection: TextDirection.rtl,
        children: <Widget>[
          Text(
            "الخريطة",
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Icon(
            Icons.map,
            color: Colors.white,
            size: 70,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _mp = dmg.getUser();
    });
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      drawer: SizedBox(
        width: screenSize.width * 3 / 4,
        child: Drawer(
          child: Container(
            decoration: MyApp.mainDeco,
            child: ListView(
              children: [
                // Add image
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: _buildAddImg(),
                ),
                // User name Text
                Center(
                  child: Text(
                    _mp['userName'],
                    style: TextStyle(color: itemsFrontColor, fontSize: 24),
                  ),
                ),
                // Statistics Page
                _buildStat(),
                // Add New Trip Page
                _buildAddTrip(),
                // My Trips Page
                _buildMyTrips(),
                // See Notifications Page
                _buildNotification(),
                // Edit Info Page
                _buildEditInfo(),
                // Log Out Page
                _buildLogOut()
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: Center(
          child: Text(
            "عَلَىٰ سِكْتَك",
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
      body: Container(
        decoration: MyApp.mainDeco,
        child: ListView(
          children: [
            // User Input
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: [
                SizedBox(height: screenSize.height / 30),
                // City
                _buildChooseCity(),
                // "From" Text
                _buildFromText(),
                // Space
                SizedBox(height: screenSize.height / 25),
                // "To" Text
                _buildToText(),
                // Space
                SizedBox(height: screenSize.height / 7),
                // Drop Down Menu
              ]),
            ),
            // Buttons
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: [
                // [Go To Trips]
                _buildGoTripsBTN(),
                // Space
                SizedBox(height: 20),
                (queryF.text.isEmpty) && (queryT.text.isEmpty)
                    ? _buildGoToDefaultMap()
                    : _buildGoToMapBTN()
              ]),
            ),
          ],
        ),
      ),
    );
  }

  // show image
  Widget _showUserImg({url: false, path: false}) {
    return InkWell(
      child: CircleAvatar(
          backgroundImage: path
              ? FileImage(File(_mp['userImg']))
              : NetworkImage(_mp['userImgUrl'])),
      splashColor: Colors.transparent,
    );
  }
}
