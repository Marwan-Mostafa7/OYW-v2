// TODO
//-------
// Get User_Data and Car_Data of such User
//    Require:
//      1- Car Request with specific Id from User Object
//             which is returned from previuos Page (All users from this trip Page [trip.dart])

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mapfltr/pages/notification.dart';

import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import 'home.dart'; // For Calls

class PassengerPage extends StatefulWidget {
  dynamic userID;
  PassengerPage(this.userID) {
    print(userID);
  }

  @override
  State<StatefulWidget> createState() {
    return _PassengerPage(this.userID);
  }
}

class _PassengerPage extends State<PassengerPage> {
  String userIIDD;
  _PassengerPage(userID) {
    print(userID);
    userIIDD = userID;
    //DocumentReference drfu =
  }

  Color moreBtn = MyApp.myFront;

  var userdoc;
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          "بيانات الراكب",
          style: TextStyle(fontWeight: FontWeight.bold),
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
                  MaterialPageRoute(builder: (context) => NotificationPage(dmg: dmg)));
            }),
      ),
      body: Container(
          decoration: MyApp.mainDeco,
          child: ListView(
            children: <Widget>[
              // User Stream
              Container(
                height: screenSize.width > 600
                    ? (screenSize.height / 3)
                    : (screenSize.height / 5),
                child: StreamBuilder(
                  stream: Firestore.instance
                      .collection('users')
                      .where('userId', isEqualTo: userIIDD)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return Center(
                        child: Text("Loading ...."),
                      );
                    userdoc = snapshot.data.documents[0];
                    print(
                        "***********************************userdoc***********************************");
                    return _buildassengerPageUSER(userdoc);
                  },
                ),
              ),
              SizedBox(height: screenSize.height / 15),
              // Car Stream
              Container(
                height: screenSize.width > 600
                    ? (screenSize.height / 3)
                    : (screenSize.height / 5),
                child: StreamBuilder(
                  stream: Firestore.instance
                      .collection('cars')
                      .where('userId', isEqualTo: userIIDD)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return Center(
                        child: Text("Loading ...."),
                      );
                    var cardoc = snapshot.data.documents[0];
                    print(
                        "***********************************userdoc***********************************");
                    return _buildassengerPageCAR(cardoc);
                  },
                ),
              ),

              SizedBox(height: screenSize.height / 30),

              // Call Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 200,
                    height: 60,
                    child: RaisedButton(
                      onPressed: () => launch("tel://" + userdoc['phone']),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(90.0)),
                      color: moreBtn,
                      child: Row(
                        textDirection: TextDirection.rtl,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("اتصل ",
                              style:
                                  TextStyle(fontSize: 24, color: Colors.white)),
                          Icon(
                            Icons.call,
                            color: Colors.white,
                            size: 27,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenSize.height / 15),
            ],
          )),
    );
  }

  Widget _buildassengerPageUSER(user) {
    final screenSize = MediaQuery.of(context).size;

    return Card(
      color: Colors.white,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          // User Image
          Container(
            width: screenSize.width / 5,
            height: screenSize.width / 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: user['userImgUrl'] != null && user['userImgUrl'].isNotEmpty
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(user['userImgUrl']))
                  : CircleAvatar(
                      backgroundImage: AssetImage('assets/person.jpg')),
            ),
          ),
          // User info
          Container(
            width: screenSize.width * 3 / 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(user['userName'],
                    style:
                        TextStyle(fontWeight: FontWeight.w400, fontSize: 25)),
                SmoothStarRating(
                  allowHalfRating: false,
                  // onRatingChanged: (v) {
                  //   rating_val = v;
                  //   print(v);
                  // },
                  starCount: 5,
                  rating: double.parse(user['rating']),
                  size: 30.0,
                  color: moreBtn,
                  borderColor: moreBtn,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildassengerPageCAR(car) {
    final screenSize = MediaQuery.of(context).size;

    // Car Data
    return Container(
      height: screenSize.height / 4,
      child: Card(
        child: Row(
          textDirection: TextDirection.rtl,
          children: <Widget>[
            // Car Image
            Container(
              width: screenSize.width / 5,
              height: screenSize.width / 4,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: car['carImgUrl'] != null && car['carImgUrl'].isNotEmpty
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(car['carImgUrl']))
                      : CircleAvatar(
                          backgroundImage: AssetImage('assets/car.png'))),
            ),
            // Car info
            Container(
              width: 3 * screenSize.width / 4,
              child: Wrap(
                textDirection: TextDirection.rtl,
                alignment: WrapAlignment.spaceAround,
                spacing: 15,
                children: [
                  Chip(
                    label: Text(car['brand'],
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                  ),
                  Chip(
                    label: Text(car['model'],
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                  ),
                  Chip(
                    label: Text("${car['year']}",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                  ),
                  Chip(
                    label: Text("عدد الركاب:  " + "${car['size']}",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
