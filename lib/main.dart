import 'package:flutter/material.dart';
import 'package:mapfltr/auth/login.dart';
import 'package:mapfltr/pages/AddTripPage.dart';
import 'package:mapfltr/pages/home.dart';
import 'package:mapfltr/statistics/statHome.dart';
import 'package:splashscreen/splashscreen.dart';

//import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:geolocator/geolocator.dart'; // Get User Location
//import 'package:geocoder/geocoder.dart'; // Address --> Coordinates[lat, lng]

import './pages/EditInfo1User.dart';
import './pages/EditInfo2Car.dart';
import './pages/notification.dart';
import './pages/MyTrips.dart';

import './services/dataManager.dart';

DataManager dmg = new DataManager();

void main() => runApp(MaterialApp(
      home: MyApp(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: MyApp.myFront3,
          canvasColor: MyApp.myFront3,
          highlightColor: Color(0xff8ec9d6),
          hintColor: Colors.white),
      routes: {
        '/Infotrip': (context) => AddTrip(),
        '/notify': (context) => NotificationPage(),
        '/editInfoUser': (context) => EditInfoUser(),
        '/editInfoCar': (context) => EditInfoCar(),
        '/myTrips': (context) => ShowMyTrips(),
        '/home': (context) => HomePage(),
        '/statHome': (context) => StatHome(),
        // To Be Removed
        '/login': (context) => LoginPage(dmg),
      },
    ));

class MyApp extends StatefulWidget {
  // static final Color myPink = Color.fromARGB(255, 255, 89, 89);
  static final Color myFront = Color(0xffcf96ee); // Color(0xff8ec9d6);
  static final Color myFront2 = Color(0xff4967a6);
  static final Color myFront3 = Color(0xff263859);
  static final Color myFront4 = Color(0xffd16abf);
  // static final Color myBlack = Color.fromARGB(255, 43, 80, 96);
  static final BoxDecoration mainDeco = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomCenter,
      stops: [0.1, 0.3, 0.4, 0.5, 0.7, 0.9, 1],
      colors: [
        Color(0xfff2a6ae),
        Color(0xffe787b5),
        Color(0xffdf74ba),
        Color(0xffdd71bc),
        Color(0xffb662c0),
        Color(0xff6463af),
        Color(0xff4d65a6),
      ],
    ),
  );

  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool logged;

  @override
  Widget build(BuildContext context) {
    print(logged);
    return Container(
      decoration: MyApp.mainDeco,
      child: SplashScreen(
        seconds: 5,
        navigateAfterSeconds: LoginPage(dmg),
        title: Text(
          "عَلَىٰ سِكْتَكْ",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 50.0, color: Colors.white),
        ),
        backgroundColor: Colors.transparent, //Color(0xff263859),
        loaderColor: Colors.white,
      ),
    );
  }
}
