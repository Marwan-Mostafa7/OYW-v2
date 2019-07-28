// TODO
// -----
// 1- Get All Users of Specific Trip
//      Require: (2 requests)
//           1- 'Trip' Request with specific ID (to get all Users IDs)
//                 --> Save them in a dict to avoid another request when entering
//                   > More data on such user (المزيد)
//           2- 'User' Request with returned IDs from 1st Request

// 2- Send Notification to all Users when Applying to Such trip

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mapfltr/pages/allTrips.dart';
import 'package:mapfltr/services/FBManager.dart';
import 'package:mapfltr/services/dataManager.dart';
import 'dart:async';

import '../main.dart';
import './passenger.dart';

class TripPage extends StatefulWidget {
  DataManager dmg;
  dynamic passengersIDs;
  Map<String, dynamic> tripData;

  TripPage(this.passengersIDs, this.tripData, this.dmg) {
    print("8888888888888888888888888");
    print(this.passengersIDs);
    print("3333333333333333333333333");
    print(this.tripData);
  }

  @override
  State<StatefulWidget> createState() {
    return _TripState(passengersIDs, tripData, dmg);
  }
}

enum Answer { YES, NO }

class _TripState extends State<TripPage> {
  static Map<String, dynamic> _mp;
  DataManager dmg;
  Map<String, dynamic> tripData;

  dynamic passengersData = [];
  var _snackKey = GlobalKey<ScaffoldState>();

  _TripState(
      List passengersIDS, Map<String, dynamic> tripData, DataManager dmg) {
    _mp = dmg.getUser();
    this.tripData = tripData;
    print(passengersIDS);
    passengersData.clear();

    Firestore.instance.collection('users').snapshots().listen((data) {
      data.documents.forEach((doc) {
        if (passengersIDS.contains(doc.data['userId']))
          passengersData.add(doc.data);
      });
      print("GET USERS AAAL DATA");
      print(passengersData);
      setState(() {
        passToggle = true;
      });
    });
  }

  Color moreBtn = MyApp.myFront;
  bool passToggle = false;
  bool carToggle = false;
  bool disableBtn = false;

  String _ans = '';

  setAnswer(val) {
    setState(() {
      _ans = val;
      if (_ans == 'yes') {
        FBManager()
            .addWaiting(_mp['userId'].toString(), _mp['token'].toString(),
                _mp['userName'], tripData)
            .then((exist) {
          if (exist == null) {
            _showlossToast(context, "يتم ارسال طلبك");
            disableBtn = true;
          } else {
            _showlossToast(context, "  غير مسموح بتنفيذ العملية ");
          }
        });
      }
    });
  }

  Widget _buildTrip(context, index) {
    final screenSize = MediaQuery.of(context).size;
    // print("USER IMAGE");
    // print(passengersData[index]['userImgUrl'] == "null");
    return Card(
      child: ExpansionTile(
        title: Row(
          textDirection: TextDirection.rtl,
          children: [
            // User image
            Container(
              width: screenSize.width / 5,
              height: 100,
              child: passengersData[index]['userImg'] != null &&
                      passengersData[index]['userImg'].isNotEmpty
                  ? _showUserImg(
                      path: true, imgPath: passengersData[index]['userImg'])
                  : passengersData[index]['userImgUrl'] != null &&
                          passengersData[index]['userImgUrl'].isNotEmpty
                      ? _showUserImg(
                          url: true,
                          imgUrl: passengersData[index]['userImgUrl'])
                      : CircleAvatar(
                          backgroundImage: AssetImage('assets/person.jpg')),
            ),
            Container(
              width: screenSize.width * 3 / 7,
              padding: const EdgeInsets.only(right: 25.0),
              child: Text(
                passengersData[index]['userName'],
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            )
          ],
        ),
        children: [
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // More About Passenger
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(90.0)),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PassengerPage(passengersData[index]['userId']))),
                child: Text(
                  "المزيد",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                color: moreBtn,
              ),
              Text(
                passengersData[index]['userEmail'],
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: MyApp.myFront3),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future _joinTripReqDialog() async {
    switch (await showDialog(
      context: context,
      child: SimpleDialog(
        title: Text(
          "هل تريد الانضمام الي هذه الرحلة ؟",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        children: <Widget>[
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, Answer.YES),
            child: Text(
              "نعم",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, Answer.NO),
            child: Text(
              "رجوع",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    )) {
      case Answer.YES:
        print(_ans);
        setAnswer('yes');

        break;

      case Answer.NO:
        print(_ans);
        setAnswer('no');
        print(_ans);
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _snackKey,
      appBar: AppBar(
        title: Center(
          child: Text(
            "تفاصيل الرحلة",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => AllTripsPage(dmg)));
            }),
      ),
      body: Container(
        decoration: MyApp.mainDeco,
        child: Center(
          child: !passToggle
              ? CircularProgressIndicator()
              : ListView.builder(
                  itemBuilder: _buildTrip,
                  itemCount: passengersData.length,
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: moreBtn,
        child: Icon(Icons.person_add),
        elevation: 2.0,
        tooltip: "Add me to the trip",
        onPressed: disableBtn ? null : _joinTripReqDialog,
      ),
    );
  }

  Widget _showUserImg({url: false, path: false, imgPath, imgUrl}) {
    return InkWell(
      child: CircleAvatar(
          backgroundImage:
              path ? FileImage(File(imgPath)) : NetworkImage(imgUrl)),
      splashColor: Colors.transparent,
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

//
}
