import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mapfltr/pages/home.dart';
import 'package:mapfltr/services/FBManager.dart';
import 'package:mapfltr/services/dataManager.dart';

import '../main.dart';
import 'AddTripPage.dart';

class ShowMyTrips extends StatefulWidget {
  DataManager dmg;

  ShowMyTrips({this.dmg});

  @override
  State<StatefulWidget> createState() {
    return _ShowMyTripState(dmg);
  }
}

class _ShowMyTripState extends State<ShowMyTrips> {
  List trips = [];
  static Map<String, dynamic> _mp;

  DataManager dmg;

  _ShowMyTripState(this.dmg) {
    _mp = dmg.getUser();
    Firestore.instance
        .collection('trips')
        .where("passengersIDS", arrayContains: dmg.getUserID())
        .snapshots()
        .listen((data) {
      data.documents.forEach((doc) => trips.add(doc.data));
      print("GET Trips For HAHGAHA ");
      print(trips);
      setState(() {});
      print("HERE");
      sortByFromTime(trips);
    });
  }

  Color cardfront = Color(0xff2d7298);
  Color cardBack = Color(0xffffffff);
  Color moreBtn = MyApp.myFront;

  List<dynamic> sortByFromTime(List<dynamic> allp) {
    print(allp[0]['timeFrom']);
  }

  _buildTXTFrom() {
    return // From TEXT
        Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        ":من",
        textAlign: TextAlign.right,
        style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent),
      ),
    );
  }

  // Value From
  _buildVALFrom(String from) {
    return Text(
      from,
      textAlign: TextAlign.center,
      style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: cardfront),
    );
  }

  _buildTXTTo() {
    return // To TEXT
        Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        ":الي",
        textAlign: TextAlign.right,
        style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent),
      ),
    );
  }

  // To Value
  _buildVALTo(String to) {
    return Text(
      to,
      textAlign: TextAlign.center,
      style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: cardfront),
    );
  }

  Widget _showmyTrips(context, index) {
    print("-------------------------------------");
    print(trips);
    print("HEEEEY");
    print("-------------------------------------");
    return Card(
      child: ExpansionTile(
        title: Table(
          textDirection: TextDirection.rtl,
          columnWidths: {
            0: FractionColumnWidth(0.1),
            2: FractionColumnWidth(0.1)
          },
          children: [
            TableRow(
              children: [
                // TIME
                _buildTXTFrom(),
                _buildVALFrom(trips[index]['timeFrom']),
                _buildTXTTo(),
                _buildVALTo(trips[index]['timeTo']),
              ],
            )
          ],
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 28.0),
            child: Table(
              textDirection: TextDirection.rtl,
              columnWidths: {
                0: FractionColumnWidth(0.1),
                2: FractionColumnWidth(0.1)
              },
              children: [
                TableRow(children: [
                  // PLACE
                  // TXT From
                  _buildTXTFrom(),
                  // VAL FROM
                  _buildVALFrom(trips[index]['placeFrom']),
                  // TXT To
                  _buildTXTTo(),
                  // VAL To
                  _buildVALTo(trips[index]['placeTo']),
                ])
              ],
            ),
          ),
          // Days Of trip
          Container(
            child: Wrap(
              spacing: 5,
              textDirection: TextDirection.rtl,
              alignment: WrapAlignment.center,
              children: trips[index]['days']
                  .map<Widget>((d) => Chip(
                        label: Text(
                          d,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ))
                  .toList(),
            ),
          ),

          // Delete Trip
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
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
                      "مسح",
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
                  print(trips[index]['tripID']);
                  FBManager().removeMefromTrip(
                      trips[index]['tripID'], _mp['userId'], _mp['token']);
                  dmg.deleteTrip(trips[index]['tripID']);
                  Navigator.pop(context);
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => HomePage(dmg: dmg)));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("رحلاتي")),
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
            }),
      ),
      body: Container(
        decoration: MyApp.mainDeco,
        child: trips.isEmpty
            ? Center(
                child: Text(
                "لا يوجد لديك رحلات",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ))
            : ListView.builder(
                itemBuilder: _showmyTrips,
                itemCount: trips.length,
              ),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: moreBtn,
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.pop(context);
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => AddTrip(dmg: dmg)));
          }),
    );
  }
}
