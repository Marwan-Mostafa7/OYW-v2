import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mapfltr/pages/home.dart';
import 'package:mapfltr/pages/passenger.dart';
import 'package:mapfltr/services/FBManager.dart';
import 'package:mapfltr/services/dataManager.dart';

import '../main.dart';

class NotificationPage extends StatefulWidget {
  DataManager dmg;
  NotificationPage({this.dmg});

  @override
  State<StatefulWidget> createState() {
    return _NotificationPage(dmg);
  }
}

class _NotificationPage extends State<NotificationPage> {
  List myWts = [];
  List myAcc = [];
  List myRej = [];
  List mydem = [];
  DataManager dmg;
  bool wArrTog = false;
  bool aArrTog = false;
  bool rArrTog = false;
  bool dArrTog = false;
  String userID = "";
  String userTkn = "";

  _NotificationPage(this.dmg) {
    userID = dmg.getUserID();
    userTkn = dmg.getUserToken();

    print("USER ID");
    print(userID);
    // Get Waiting Trips
    myWts.clear();
    Firestore.instance
        .collection('waiting')
        .where("reqID", isEqualTo: userID)
        .snapshots()
        .listen((data) {
      data.documents.forEach((doc) => myWts.add(doc.data));

      print("GET MY Waitings ");
      print(myWts);
      print("HERE");
      setState(() {
        if (myWts.isNotEmpty) wArrTog = true;
      });
    });

    // Get Acceptance Trips
    myAcc.clear();
    Firestore.instance
        .collection('decision')
        .where("reqID", isEqualTo: userID)
        .where('decide', isEqualTo: "yes")
        .snapshots()
        .listen((data) {
      data.documents.forEach((doc) => myAcc.add(doc.data));

      print("GET MY Acceptance Trips ");
      print(myAcc);
      print("HERE");
      setState(() {
        if (myAcc.isNotEmpty) aArrTog = true;
      });
    });

    // Get Rejection Trips IDs
    myRej.clear();
    Firestore.instance
        .collection('decision')
        .where("reqID", isEqualTo: userID)
        .where('decide', isEqualTo: "no")
        .snapshots()
        .listen((data) {
      data.documents.forEach((doc) => myRej.add(doc.data));

      print("GET MY Rejected Trips ");
      print(myRej);
      print("HERE");
      setState(() {
        if (myRej.isNotEmpty) rArrTog = true;
      });
    });

    // Get Trips need my Decision Trips IDs
    mydem.clear();
    Firestore.instance
        .collection('waiting')
        .where("passengersIDS", arrayContains: userID)
        .snapshots()
        .listen((data) {
      data.documents.forEach((doc) => mydem.add(doc.data));
      print("GET MY Demanded Trips ");
      print(mydem);
      print("HERE");
      setState(() {
        if (mydem.isNotEmpty) dArrTog = true;
      });
    });
  }

  Color cardfront = Color(0xff2d7298);
  Color cardBack = Color(0xffffffff);
  Color moreBtn = MyApp.myFront;
  var _snackKey = GlobalKey<ScaffoldState>();

  Widget _buildDRequests(BuildContext context, int index) {
    return Card(
      child: ExpansionTile(
        title: Center(
            child: Text(
          " ${mydem[index]['placeTo']}   يريد الانضمام الي رحلة  ${mydem[index]['reqName']}",
          style: TextStyle(fontSize: 24),
        )),
        // Trip Place
        children: <Widget>[
          // Show Person Details
          // Accept
          //Reject
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              // Show Trip Details (Navigate -> make `tripDetails` Page)
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(90.0)),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.person,
                      size: 25,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "تفاصيل الشخص",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
                color: MyApp.myFront4,
                elevation: 0,
                onPressed: () {
                  print(index);
                  print(mydem[index]['reqID']);
                  Navigator.pop(context);
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) =>
                          PassengerPage(mydem[index]['reqID'])));
                },
              ),
              // Accept request
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(90.0)),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.done,
                      size: 25,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "موافقة",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
                color: MyApp.myFront4,
                elevation: 0,
                onPressed: () {
                  print(index);
                  print(mydem[index]['tripID']);
                  setState(() {
                    FBManager()
                        .idecide(mydem[index]['tripID'], mydem[index]['reqID'],
                            mydem[index]['reqToken'], "yes")
                        .then((s) {
                      mydem.removeAt(index);
                      FBManager()
                          .removeMefromWaitingPasgnrs(
                              mydem[index]['tripID'], userID, userTkn)
                          .then((s) {
                        _showlossToast(context, "تم القبول");
                        Navigator.pop(context);
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => HomePage(dmg: widget.dmg)));
                      });
                    });
                  });
                },
              ),
              // Reject request
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(90.0)),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.close,
                      size: 25,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "رفض",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
                color: MyApp.myFront4,
                elevation: 0,
                onPressed: () {
                  print(index);
                  print(mydem[index]['tripID']);
                  setState(() {
                    FBManager()
                        .idecide(mydem[index]['tripID'], mydem[index]['reqID'],
                            mydem[index]['reqToken'], "no")
                        .then((s) {
                      _showlossToast(context, "  تم الرقض ");
                      mydem.removeAt(index);
                      Navigator.pop(context);
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => HomePage(dmg: widget.dmg)));
                    });
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaitings(BuildContext context, int index) {
    print(myWts);
    return Card(
      child: ExpansionTile(
        title: Center(
            child: Text(
          " ${myWts[index]['placeTo']}  لم يتم القرار في رحلة",
          style: TextStyle(fontSize: 24),
        )),
        // Trip Place
        children: <Widget>[
          // Acceptance And Rejections
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              // Acceptanace Number
              Text(
                "عدد الموافقة  ${myWts[index]['nAccept']}",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              // Rejection Number
              Text(
                "عددالرفض  ${myWts[index]['nReject']}",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ],
          ),

          // Delete // Show Trip
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              // Show Trip Details (Navigate -> make `tripDetails` Page)
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(90.0)),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.date_range,
                      size: 25,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "تفاصيل الرحلة",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
                color: MyApp.myFront4,
                elevation: 0,
                onPressed: () {
                  print(index);
                  print(myWts[index]['tripID']);
                  // dmg.deleteTrip(myWts[index]['tripID']);
                  //myWts.clear();
                  // setState(() {});
                },
              ),
              // remove my waiting Request
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(90.0)),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.delete,
                      size: 25,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "الغاء الطلب",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
                color: MyApp.myFront4,
                elevation: 0,
                onPressed: () {
                  print(index);
                  print(myWts[index]['tripID']);
                  // dmg.deleteTrip(myWts[index]['tripID']);
                  //myWts.clear();
                  // setState(() {});
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccepted(BuildContext context, int index) {
    return Card(
      child: Center(
        child: Text(
          " ${myAcc[index]['placeTo']}  تم قبولك في رحلة ",
          style: TextStyle(fontSize: 24, color: MyApp.myFront2),
        ),
      ),
    );
  }

  Widget _buildRejected(BuildContext context, int index) {
    return Card(
      child: Center(
        child: Text(
          " ${myRej[index]['placeTo']}  تم رفضك في رحلة ",
          style: TextStyle(fontSize: 24, color: MyApp.myFront2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: MyApp.mainDeco,
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
            key: _snackKey,
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Center(
                child: Text(
                  'الاشعارات',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
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
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => HomePage(dmg: dmg)));
                },
              ),
              bottom: TabBar(
                //labelColor: MyApp.myFront,
                indicatorColor: Colors.white,
                labelStyle: TextStyle(color: MyApp.myFront),
                tabs: [
                  // Waiting for my decision
                  Tab(icon: Icon(Icons.message, size: 24, color: Colors.white)),
                  // My Waiting requests
                  Tab(icon: Icon(Icons.warning, size: 24, color: Colors.white)),
                  // ACCEPTED
                  Tab(icon: Icon(Icons.done, size: 24, color: Colors.white)),
                  // Rejected
                  Tab(
                      icon: Icon(Icons.do_not_disturb,
                          size: 24, color: Colors.white)),
                ],
              ),
            ),

            // 4 Pages
            body: TabBarView(
              children: <Widget>[
                // First Page Make Decision
                dArrTog
                    ? ListView.builder(
                        itemBuilder: _buildDRequests,
                        itemCount: mydem.length,
                      )
                    : Center(
                        child: Text(
                        "لا يوجد رحلات في الانتظار",
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      )),

                // First Page (Waiting)
                wArrTog
                    ? ListView.builder(
                        itemBuilder: _buildWaitings,
                        itemCount: myWts.length,
                      )
                    : Center(
                        child: Text(
                        "لا يوجد رحلات في الانتظار",
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      )),

                // Second Page (Accepted)
                myAcc.isNotEmpty
                    ? ListView.builder(
                        itemBuilder: _buildAccepted,
                        itemCount: myAcc.length,
                      )
                    : Center(
                        child: Text(
                        "لا يوجد رحلات في الموافقات",
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      )),

                // Third Page (REJECTED)
                myRej.isNotEmpty
                    ? ListView.builder(
                        itemBuilder: _buildRejected,
                        itemCount: myRej.length,
                      )
                    : Center(
                        child: Text(
                        "لا يوجد رحلات في المرفوضات",
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      )),
              ],
            )),
      ),
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
