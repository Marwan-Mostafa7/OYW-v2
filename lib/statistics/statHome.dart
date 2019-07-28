import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapfltr/statistics/statisticsBarDays.dart';
import 'package:mapfltr/statistics/statisticsBarHours.dart';
import 'package:mapfltr/statistics/statisticsPiePlaces.dart';

/// Bar chart example
//import 'package:charts_flutter/flutter.dart' as charts;

import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mapfltr/pages/home.dart';
import 'package:mapfltr/services/dataManager.dart';

import '../main.dart';

class StatHome extends StatefulWidget {
  DataManager dmg;
  StatHome({this.dmg});

  @override
  State<StatefulWidget> createState() {
    return _StatHomeState(dmg);
  }
}

class _StatHomeState extends State<StatHome> {
  List trips = [];
  DataManager dmg;

  _StatHomeState(this.dmg) {
    Firestore.instance
        .collection('trips')
        .where("passengersIDS", arrayContains: dmg.getUserID())
        .snapshots()
        .listen((data) {
      data.documents.forEach((doc) => trips.add(doc.data));
      print("GET Trips For HAHGAHA ");
      print(trips);
      print("HERE");
      setState(() {});
    });
  }

  var barData = [0.0, 0.2, 0.5, 0.6, 0.1, 0.4];
  List<CircularStackEntry> pieData = <CircularStackEntry>[
    new CircularStackEntry(
      <CircularSegmentEntry>[
        new CircularSegmentEntry(500.0, Colors.red[200], rankKey: 'Q1'),
        new CircularSegmentEntry(1000.0, Colors.green[200], rankKey: 'Q2'),
        new CircularSegmentEntry(2000.0, Colors.blue[200], rankKey: 'Q3'),
        new CircularSegmentEntry(1000.0, Colors.yellow[200], rankKey: 'Q4'),
      ],
      rankKey: 'Quarterly Profits',
    ),
  ];

  Material myItems(String title, String chartName) {
    final screenSize = MediaQuery.of(context).size;
    return Material(
      color: Colors.white,
      elevation: 14,
      shadowColor: Colors.white10,
      borderRadius: BorderRadius.circular(24),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // text
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(title,
                          style: TextStyle(
                              color: MyApp.myFront2,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),

                  // Chart
                  chartName == null
                      ? Container(
                          child: Text("${trips.length}",
                              style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: MyApp.myFront4)),
                        )
                      : chartName == "BAR"
                          ? RaisedButton(
                              child: Sparkline(
                                data: barData,
                                lineColor: MyApp.myFront4,
                                pointsMode: PointsMode.all,
                                pointSize: 10,
                                pointColor: MyApp.myFront2,
                              ),
                              onPressed: () => Navigator.of(context)
                                  .pushReplacement(MaterialPageRoute(
                                      builder: (context) => StatisticsBar(
                                          dmg: widget.dmg, trips: trips))),
                              color: Colors.white,
                              elevation: 0,
                            )
                          : chartName == "PIE"
                              ? RaisedButton(
                                  child: AnimatedCircularChart(
                                    initialChartData: pieData,
                                    size: Size(screenSize.width / 3, 200.0),
                                    chartType: CircularChartType.Pie,
                                  ),
                                  onPressed: () => Navigator.of(context)
                                      .pushReplacement(MaterialPageRoute(
                                          builder: (context) => StatisticsPie(
                                              dmg: widget.dmg, trips: trips))),
                                  color: Colors.white,
                                  elevation: 0,
                                )
                                // Weekly Hours
                              : InkWell(
                                  splashColor: Colors.transparent,
                                  child: Text("اسبوعيا",
                                      style: TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          color: MyApp.myFront4)),
                                  onTap: () => Navigator.of(context)
                                      .pushReplacement(MaterialPageRoute(
                                          builder: (context) =>
                                              StatisticsBarHours(
                                                  dmg: widget.dmg,
                                                  trips: trips))),
                                )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text("الاحصائيات",
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
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
                  builder: (context) => HomePage(dmg: widget.dmg)));
            },
          ),
        ),
        body: StaggeredGridView.count(
          crossAxisCount: 4,
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
          staggeredTiles: [
            StaggeredTile.extent(4, 200.0),
            StaggeredTile.extent(2, 300.0),
            StaggeredTile.extent(2, 150.0),
            StaggeredTile.extent(2, 150.0),
          ],
          children: <Widget>[
            myItems("ايام الرحلات", "BAR"),
            myItems("المناطق", "PIE"),
            myItems("عدد الرحلات", null),
            myItems("ساعات الطريق", "HOUR")
          ],
        ));
  }
}
