import 'dart:math';

/// Bar chart example
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mapfltr/services/dataManager.dart';
import 'package:mapfltr/statistics/statHome.dart';

class StatisticsBar extends StatefulWidget {
  DataManager dmg;
  List trips = [];
  StatisticsBar({this.dmg, this.trips});

  @override
  State<StatefulWidget> createState() {
    return _StatState(dmg, trips);
  }
}

class _StatState extends State<StatisticsBar> {
  List trips = [];
  List<charts.Series<OrdinalSales, String>> _seriesList;
  DataManager dmg;

  List<Color> topColors = [
    Colors.redAccent,
    Colors.green,
    Colors.blueAccent,
    Colors.deepPurple,
    Colors.pinkAccent,
    Colors.orangeAccent,
    Colors.tealAccent,
  ];
  Map<String, int> mm = {
    'السبت': 0,
    'الاحد': 0,
    'الاثنين': 0,
    'الثلاثاء': 0,
    'الاربعاء': 0,
    'الخميس': 0,
    'الجمعة': 0,
  };

  _StatState(this.dmg, this.trips);

  _generateData(List tt) {
    for (var i = 0; i < tt.length; i++) _countDays(tt[i]['days']);

    List<OrdinalSales> data = [];
    int i = 0;
    for (var d in mm.keys) {
      data.add(OrdinalSales(d, mm[d], topColors[i]));
      i++;
    }

    _seriesList.add(charts.Series(
      id: 'Days',
      domainFn: (OrdinalSales sales, _) => sales.year,
      measureFn: (OrdinalSales sales, _) => sales.count,
      colorFn: (OrdinalSales sales, _) =>
          charts.ColorUtil.fromDartColor(sales._color),
      data: data,
      labelAccessorFn: (OrdinalSales sales, _) => '${sales.count}',
    ));
  }

  _countDays(List days) {
    for (var d in days) mm[d] = mm[d] + 1;
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
            " عدد الرحلات يوميا",
            style: TextStyle(fontSize: 24, color: Colors.white),
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
                SizedBox(height: 10),
                Expanded(
                  child: charts.BarChart(
                    _seriesList,
                    animate: true,
                    animationDuration: Duration(seconds: 2),
                    //barRendererDecorator: charts.BarLabelDecorator<String>(),
                    domainAxis: new charts.OrdinalAxisSpec(
                        renderSpec: new charts.SmallTickRendererSpec(

                            // Tick and Label styling here.
                            labelStyle: new charts.TextStyleSpec(
                                fontSize: 18, // size in Pts.
                                color: charts.MaterialPalette.white),

                            // Change the line colors to match text color.
                            lineStyle: new charts.LineStyleSpec(
                                color: charts.MaterialPalette.black))),
                    primaryMeasureAxis: new charts.NumericAxisSpec(
                        renderSpec: new charts.GridlineRendererSpec(

                            // Tick and Label styling here.
                            labelStyle: new charts.TextStyleSpec(
                                fontSize: 18, // size in Pts.
                                color: charts.MaterialPalette.white),

                            // Change the line colors to match text color.
                            lineStyle: new charts.LineStyleSpec(
                                color: charts.MaterialPalette.white))),
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
  String year;
  int count;
  Color _color;

  OrdinalSales(this.year, this.count, this._color);
}

// new charts.BarChart(
//   _seriesList,
//   animate: animate,
// );
