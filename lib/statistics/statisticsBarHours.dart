import 'dart:math';

/// Bar chart example
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:mapfltr/services/dataManager.dart';
import 'package:mapfltr/statistics/statHome.dart';

class StatisticsBarHours extends StatefulWidget {
  DataManager dmg;
  List trips = [];
  StatisticsBarHours({this.dmg, this.trips});

  @override
  State<StatefulWidget> createState() {
    return _StatState(dmg, trips);
  }
}

class _StatState extends State<StatisticsBarHours> {
  List<charts.Series<OrdinalSales, String>> _seriesList;
  List trips = [];
  DataManager dmg;
  Map<String, int> mm = {
    'الاحد': 0,
    'الاثنين': 0,
    'الثلاثاء': 0,
    'الاربعاء': 0,
    'الخميس': 0,
    'الجمعة': 0,
    'السبت': 0,
  };
  int totalHours = 0;
  _StatState(this.dmg, this.trips);

  List<Color> topColors = [
    Colors.redAccent,
    Colors.green,
    Colors.blueAccent,
    Colors.deepPurple,
    Colors.pinkAccent,
    Colors.orangeAccent,
    Colors.teal,
  ];

  _generateData(List tt) {
    for (var i = 0; i < tt.length; i++) {
      _countHours(tt[i]['days'], tt[i]['timeFrom'].toString(),
          tt[i]['timeTo'].toString());
    }
    for (var h in mm.values) {
      totalHours += h;
    }
    print("TOTAL HOURS =  $totalHours");

    List<OrdinalSales> data = [];
    int i = 0;
    for (var d in mm.keys) {
      data.add(OrdinalSales(d, mm[d], topColors[i]));
      i++;
    }

    _seriesList.add(charts.Series(
      id: 'Hoursw',
      domainFn: (OrdinalSales sales, _) => sales.day,
      measureFn: (OrdinalSales sales, _) => sales.count,
      colorFn: (OrdinalSales sales, _) =>
          charts.ColorUtil.fromDartColor(sales._color),
      data: data,
      labelAccessorFn: (OrdinalSales sales, _) =>
          '${sales.day} :  ${sales.count}',
      insideLabelStyleAccessorFn: (OrdinalSales sales, _) =>
          charts.TextStyleSpec(
              fontSize: 24, color: charts.MaterialPalette.white),
    ));
  }

  _countHours(List days, String from, String to) {
    int fH = int.parse(from.split(":")[0]);
    int tH = int.parse(to.split(":")[0]);
    int fM = int.parse(from.split(":")[1].split(" ")[0]);
    int tM = int.parse(to.split(":")[1].split(" ")[0]);
    fH = fH + (fM / 60).round();
    tH = tH + (tM / 60).round();

    if ((from.endsWith("PM") && to.endsWith("PM")) ||
        (from.endsWith("AM") && to.endsWith("AM"))) {
      for (var d in days) {
        mm[d] = mm[d] + tH - fH;
      }
    }
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
            "عدد الساعات اسبوعيا $totalHours ",
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
                Expanded(
                  child: charts.BarChart(
                    _seriesList,
                    vertical: false,
                    barRendererDecorator: charts.BarLabelDecorator<String>(),
                    animate: true,
                    animationDuration: Duration(seconds: 2),
                    domainAxis: new charts.OrdinalAxisSpec(
                      renderSpec: charts.NoneRenderSpec(),
                    ),
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
  String day;
  int count;
  Color _color;

  OrdinalSales(this.day, this.count, this._color);
}

// new charts.BarChart(
//   _seriesList,
//   animate: animate,
// );
