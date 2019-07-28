// TODO
// ------
// Get All trips from Firebase
// save in a Dictionary
// Show the trips

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mapfltr/main.dart';
import 'package:mapfltr/services/dataManager.dart';

import './trip.dart';
import 'AddTripPage.dart';
import 'home.dart';

class AllTripsPage extends StatefulWidget {
  DataManager dmg;
  AllTripsPage(this.dmg);

  @override
  State<StatefulWidget> createState() {
    return _TripsState();
  }
}

Color cardBack;
Color cardfront;
Color moreBtn;

class _TripsState extends State<AllTripsPage> {
  dynamic trips = [];

  _TripsState() {
    Firestore.instance.collection('trips').snapshots().listen((data) {
      setState(() {
        trips.clear();
      });
      data.documents.forEach((doc) => trips.add(doc.data));
      print("GET TRIPS AAAAAALL DATA");
      print(trips);
      setState(() {});
    });
  }

// Show each trip in a Card with ExpansionTile (that can expand on-click)
  Widget _buildTrips(context, index) {
    return Card(
      color: Colors.white,
      child: Dismissible(
        key: Key(trips[index]['tripID'] + trips.length.toString()),
        onDismissed: (direx) {
          setState(() {
            trips.remove(trips[index]);
          });
        },
        background: Container(color: MyApp.myFront4),
        child: ExpansionTile(
          backgroundColor: Colors.white,
          title: Table(
            textDirection: TextDirection.rtl,
            columnWidths: {
              0: FractionColumnWidth(0.1),
              2: FractionColumnWidth(0.1)
            },
            children: [
              TableRow(
                children: [
                  // From TEXT
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
                  ),
                  // From Value
                  Text(
                    trips[index]['placeFrom'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: cardfront),
                  ),
                  // To TEXT
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
                  ),
                  // To Value
                  Text(
                    trips[index]['placeTo'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: cardfront),
                  ),
                ],
              )
            ],
          ),
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      textDirection: TextDirection.rtl,
                      children: <Widget>[
                        Text(trips[index]['timeFrom'],
                          style: TextStyle(fontSize: 24, color: MyApp.myFront2),
                        ),
                        Text(trips[index]['timeTo'],
                          style: TextStyle(fontSize: 24, color: MyApp.myFront2),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        // Show More button
                        RaisedButton(
                          // Go To Selected Trip page
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(90.0)),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TripPage(
                                        trips[index]['passengersIDS'],
                                        trips[index],
                                        dmg)));
                          },

                          child: Text("المزيد",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20)),
                          color: moreBtn,
                        )
                      ],
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    cardfront = Color(0xff2d7298);
    cardBack = Color(0xffffffff);
    moreBtn = MyApp.myFront;
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("جميع الرحلات")),
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
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          // TODO
          // Read NEW Trips from the Data Base
          setState(() {
            trips.clear();
          });

          Firestore.instance.collection('trips').snapshots().listen((data) {
            data.documents.forEach((doc) => trips.add(doc.data));
            setState(() {});
          });
        },
        child: Container(
          decoration: MyApp.mainDeco,
          child: trips == null
              ? CircularProgressIndicator()
              : ListView.builder(
                  itemBuilder: _buildTrips,
                  itemCount: trips.length,
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: moreBtn,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pop(context);
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => AddTrip(dmg: dmg)));
        },
      ),
    );
  }
}
