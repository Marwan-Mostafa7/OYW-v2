// TODO:
//-------
// 1- Check if User/Car data *both* exist
// 2- Design Page With
// • Place:
//         From
//         To
// • Time:
//           From
//           To
// • Days
//
// • Done Button

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:geocoder/geocoder.dart';
import 'package:intl/intl.dart'; // Date_time formats

import 'package:mapfltr/models/trip.dart';
import 'package:mapfltr/pages/allTrips.dart';
import 'package:mapfltr/pages/home.dart';
import '../main.dart';
import '../services/dataManager.dart';

class AddTrip extends StatefulWidget {
  DataManager dmg;
  AddTrip({DataManager dmg}) {
    this.dmg = dmg;
  }

  @override
  State<StatefulWidget> createState() {
    return _AddTripState(dmg);
  }
}

class _AddTripState extends State<AddTrip> {
  DataManager dmg;
  _AddTripState(this.dmg);

  List<String> cities = DataManager.CITIES;
  List<String> days = DataManager.DAYS;

  String _city = 'الإسكندرية ';
  Map<String, int> dayselected = {
    'الاحد': 0,
    'الاثنين': 0,
    'الثلاثاء': 0,
    'الاربعاء': 0,
    'الخميس': 0,
    'الجمعة': 0,
    'السبت': 0,
  };
  List<String> selectedDays = [];
  DateTime fromTimeTxt, toTimeTxt;

  bool _stopProcess = false;
  int tripToggle = 0;

  TextEditingController _place_from_cntr = TextEditingController();
  TextEditingController _place_to_cntr = TextEditingController();
  TextEditingController _time_from_cntr = TextEditingController();
  TextEditingController _time_to_cntr = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return addtrip();
  }

  Widget addtrip() {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          " اضف رحلة ",
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
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
            }),
      ),
      body: Builder(
        builder: (context) => Container(
              decoration: MyApp.mainDeco,
              child: tripToggle == 1
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView(
                      children: <Widget>[
                        // Place txt
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.location_on,
                                size: 34,
                                color: Colors.white,
                              ),
                              Text(
                                "المكان",
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                textDirection: prefix0.TextDirection.rtl,
                              ),
                            ],
                          ),
                        ),
                        // Choose City
                        Padding(
                          padding: const EdgeInsets.all(10.0),
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
                                              textDirection:
                                                  prefix0.TextDirection.rtl,
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
                                    textDirection: prefix0.TextDirection.rtl,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        // from
                        Directionality(
                          textDirection: prefix0.TextDirection.rtl,
                          child: TextField(
                            textDirection: prefix0.TextDirection.rtl,
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
                            controller: _place_from_cntr,
                          ),
                        ),
                        // Space
                        SizedBox(height: 20),
                        // to
                        Directionality(
                          textDirection: prefix0.TextDirection.rtl,
                          child: TextField(
                            textDirection: prefix0.TextDirection.rtl,
                            style: TextStyle(fontSize: 24, color: Colors.black),
                            decoration: InputDecoration(
                              labelText: " الي :",
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
                            controller: _place_to_cntr,
                          ),
                        ),
                        // Space
                        SizedBox(height: 20),

                        //time txt
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.timer,
                                size: 34,
                                color: Colors.white,
                              ),
                              Text(
                                "الوقت",
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                textDirection: prefix0.TextDirection.rtl,
                              ),
                            ],
                          ),
                        ),

                        // TIME  from
                        Directionality(
                          textDirection: prefix0.TextDirection.rtl,
                          child: DateTimePickerFormField(
                            onChanged: (dt) {
                              if (dt != null)
                                setState(() {
                                  fromTimeTxt = dt;
                                });
                            },
                            inputType: InputType.time,
                            format: DateFormat("h:mm a"),
                            editable: false,
                            style: TextStyle(fontSize: 24),
                            controller: _time_from_cntr,
                            decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.only(bottom: 15, right: 15),
                                labelText: 'من :',
                                hasFloatingPlaceholder: false,
                                filled: true,
                                fillColor: Colors.white70,
                                labelStyle: TextStyle(
                                  fontSize: 30,
                                  color: Colors.black,
                                )),
                          ),
                        ),
                        // Space
                        SizedBox(height: 20),
                        // TIME  to
                        Directionality(
                          textDirection: prefix0.TextDirection.rtl,
                          child: DateTimePickerFormField(
                            onChanged: (dt) {
                              if (dt != null)
                                setState(() {
                                  toTimeTxt = dt;
                                });
                            },
                            inputType: InputType.time,
                            format: DateFormat("h:mm a"),
                            editable: false,
                            style: TextStyle(fontSize: 24),
                            controller: _time_to_cntr,
                            decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.only(bottom: 15, right: 15),
                                labelText: 'الي :',
                                hasFloatingPlaceholder: false,
                                filled: true,
                                fillColor: Colors.white70,
                                labelStyle: TextStyle(
                                  fontSize: 30,
                                  color: Colors.black,
                                )),
                          ),
                        ),

                        // Space
                        SizedBox(height: 20),

                        //  Days txt
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.date_range,
                                size: 34,
                                color: Colors.white,
                              ),
                              Text("الايام",
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                  textDirection: prefix0.TextDirection.rtl),
                            ],
                          ),
                        ),
                        // Space
                        SizedBox(height: 20),
                        // Days
                        Column(
                            //scrollDirection: Axis.horizontal,
                            children: days.map((day) {
                          return Container(
                            width: double.infinity,
                            child: RaisedButton(
                              color: dayselected[day] == 0
                                  ? Colors.white70
                                  : MyApp.myFront2,
                              onPressed: () {
                                setState(() {
                                  if (dayselected[day] == 0) {
                                    dayselected[day] = 1;
                                    selectedDays.add(day);
                                  } else {
                                    dayselected[day] = 0;
                                    selectedDays.remove(day);
                                  }
                                });
                              },
                              child: Text(
                                day,
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0),
                              ),
                            ),
                          );
                        }).toList()),
                        // Space
                        SizedBox(height: 40),
                        // Done Button
                        RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(90.0)),
                          color: MyApp.myFront,
                          onPressed: () async {
                            if (!_checkFields()) {
                              _showlossToast(context);
                              return;
                            }

                            // print(fromTimeTxt.toString());
                            // print(toTimeTxt.toLocal());

                            _stopProcess = false;

                            _showDoneToast(context);
                            await Future.delayed(Duration(seconds: 3));

                            if (_stopProcess) return;

                            print("HHH");
                            //print(widget.dmg.getUserID());
                            // print(_time_from_cntr.text.split(":"));
                            // print(_time_to_cntr.text);

                            Map<String, dynamic> trip = {
                              'placeFrom': _place_from_cntr.text,
                              'placeTo': _place_to_cntr.text,
                              'timeFrom': _time_from_cntr.text,
                              'timeTo': _time_to_cntr.text,
                              'city': _city,
                              'days': selectedDays,
                              'creatorId': widget.dmg.getUserID(),
                              'passengers': [],
                            };
                            setState(() {
                              tripToggle = 1;
                            });
                            await widget.dmg.addUserTrips(trip);
                            setState(() {
                              tripToggle = 2;
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(dmg: widget.dmg),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            textDirection: prefix0.TextDirection.rtl,
                            children: <Widget>[
                              Text(
                                "اضافة رحلة",
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              Row(children: [
                                Icon(
                                  Icons.done,
                                  color: Colors.white,
                                  size: 70,
                                )
                              ])
                            ],
                          ),
                        ),
                        // Space
                        SizedBox(height: 20),
                      ],
                    ),
            ),
      ),
    );
  }

  void _setcity(ncty) {
    setState(() {
      _city = ncty;
    });
  }

  bool _checkFields() {
    return selectedDays.isNotEmpty &&
        _place_from_cntr.text.isNotEmpty &&
        _place_to_cntr.text.isNotEmpty &&
        _time_from_cntr.text.isNotEmpty &&
        _time_to_cntr.text.isNotEmpty;
  }

  void _showDoneToast(BuildContext context) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
          duration: Duration(seconds: 2),
          backgroundColor: MyApp.myFront3,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.done, size: 23),
              SizedBox(width: 10),
              Text('يتم اضافة الرحلة',
                  style: TextStyle(fontSize: 21), textAlign: TextAlign.center),
            ],
          ),
          action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                scaffold.hideCurrentSnackBar();
                _stopProcess = true;
              })),
    );
  }

  void _showlossToast(BuildContext context) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        backgroundColor: MyApp.myFront3,
        duration: Duration(seconds: 2),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.error),
            Text(
              ' برجاء استكمال البيانات',
              style: TextStyle(fontSize: 21),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
