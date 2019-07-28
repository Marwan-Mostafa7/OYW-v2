import 'dart:collection';
import 'dart:math';

/// Bar chart example
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:mapfltr/services/dataManager.dart';
import 'package:mapfltr/statistics/statHome.dart';

class StatisticsPie extends StatefulWidget {
  DataManager dmg;
  List trips = [];

  StatisticsPie({this.dmg, this.trips});

  @override
  State<StatefulWidget> createState() {
    return _StatState(dmg, trips);
  }
}

class _StatState extends State<StatisticsPie> {
  List<charts.Series<OrdinalSales, String>> _seriesList;
  List trips = [];
  DataManager dmg;
  Map<String, int> mm = {};
  List<String> places = [];
  int sumP = 0;
  _StatState(this.dmg, this.trips);

  List<Color> topColors = [
    Colors.redAccent,
    Colors.green,
    Colors.blueAccent,
    Colors.deepPurple,
    Colors.pinkAccent,
    Colors.orangeAccent
  ];

  _generateData(List trips) {
    // get places into list
    trips.forEach((trip) {
      places.add(trip['placeTo']);
    });
    print("All Places");
    print(places);
    // put them in map with Zero init value
    Map<String, int> mm = {};
    for (var p in places) {
      mm[p] = 0;
    }
    // count frequencies
    for (var p in places) {
      mm[p] += 1;
    }

    // Get the sum
    for (var p in mm.keys) {
      sumP += mm[p];
    }
    print(mm);
    // count Probabilities
    for (var p in mm.keys) {
      mm[p] = ((mm[p] / sumP) * 100).round();
    }
    print(mm);

    // Get top 6 places

    //  Sort map according to values Descendingly
    var sortedKeys = mm.keys.toList(growable: false)
      ..sort((k1, k2) => mm[k2].compareTo(mm[k1]));

    LinkedHashMap sortedMap = new LinkedHashMap.fromIterable(sortedKeys,
        key: (k) => k, value: (k) => mm[k]);

    print(sortedMap);

    List<OrdinalSales> data = [];
    var _places = sortedMap.keys.toList();
    var freq = sortedMap.values.toList();
    int top = 0;
    if (places.length <= 3)
      top = 2;
    else
      top = 4;
    print("TOOOP");
    print(top);
    print("//");
    print(places.length);
    for (var i = 0; i < _places.length; i++) {
      if (i == top) break;
      data.add(OrdinalSales(_places[i], freq[i], topColors[i]));
      print(i);
    }

    _seriesList.add(charts.Series(
      id: 'Places',
      domainFn: (OrdinalSales sales, _) => sales.place,
      measureFn: (OrdinalSales sales, _) => sales.count,
      colorFn: (OrdinalSales sales, _) =>
          charts.ColorUtil.fromDartColor(sales._color),
      data: data,
      labelAccessorFn: (OrdinalSales sales, _) => '${sales.count}' + "%",
      insideLabelStyleAccessorFn: (OrdinalSales sales, _) =>
          charts.TextStyleSpec(
              fontSize: 20, color: charts.MaterialPalette.white),
    ));
  }

  @override
  void initState() {
    super.initState();

    _seriesList = List<charts.Series<OrdinalSales, String>>();
    _generateData(trips);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "الاماكن الاكثر ذهابا",
            style: TextStyle(
                fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
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
                builder: (context) => StatHome(dmg: widget.dmg)));
          },
        ),
      ),
      body: Container(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Center(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: charts.PieChart(
                    _seriesList,
                    animationDuration: Duration(seconds: 2),
                    defaultRenderer: charts.ArcRendererConfig(
                      arcRendererDecorators: [charts.ArcLabelDecorator()],
                    ),
                    behaviors: [
                      charts.DatumLegend(
                          outsideJustification:
                              charts.OutsideJustification.middleDrawArea,
                          cellPadding: EdgeInsets.only(left: 20, bottom: 10),
                          desiredMaxColumns: 2,
                          entryTextStyle: charts.TextStyleSpec(
                            color: charts.MaterialPalette.white,
                            fontSize: 16,
                          ))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      )),
    );
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  String place;
  int count;
  Color _color;

  OrdinalSales(this.place, this.count, this._color);
}
