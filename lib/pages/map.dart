import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoder/geocoder.dart'; // Address --to--> Coordinates[lat, lng]
import 'dart:async';

class MapPage extends StatefulWidget {
  final String queryF, queryT, city;

  // TODO
  final Map<Color, List<Coordinates>> trips;

  MapPage({this.queryF, this.queryT, this.city, this.trips});

  @override
  State<StatefulWidget> createState() {
    return _MapPageState();
  }
}

class _MapPageState extends State<MapPage> {
  GoogleMapController mapController;
  var addresses;
  double lat;
  double long;
  bool f;
  bool t;

  void showMyTrip({String qF = "", String qT = "", city = "الاسكندرية"}) async {
    // Wait for 2 Seconds
    await Future.delayed(const Duration(seconds: 2));
    if (qF.isNotEmpty) {
      qF = qF + " " + city;

      addresses = await Geocoder.local.findAddressesFromQuery(qF);
      lat = addresses.first.coordinates.latitude;
      long = addresses.first.coordinates.longitude;

      // Move camera to  "From" Location
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(lat, long), zoom: 15, tilt: 45, bearing: 90),
        ),
      );

      // Put Marker on from location [Red]
      mapController.addMarker(
        MarkerOptions(
            position: LatLng(lat, long),
            icon: BitmapDescriptor.fromAsset('assets/frf.png'),
            visible: true),
      );
    }

    // Stop For 2 Seconds
    await Future.delayed(const Duration(seconds: 2));
    f = true;
    // Check if Query To is not Null
    if (qT.isEmpty) return;
    // Append City to Query
    qT = qT + " " + city;
    addresses = await Geocoder.local.findAddressesFromQuery(qT);
    lat = addresses.first.coordinates.latitude;
    long = addresses.first.coordinates.longitude;

    // Move camera to  "To" Location
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, long),
          zoom: 15,
        ),
      ),
    );
    // Put Marker on "To" location [blue]
    mapController.addMarker(
      MarkerOptions(
          position: LatLng(lat, long),
          icon: BitmapDescriptor.fromAsset('assets/tot.png')),
    );
    t = true;
    await Future.delayed(const Duration(seconds: 2));
    if (f && t) {
      mapController.animateCamera(CameraUpdate.zoomBy(-2.5));
    }
  }

  @override
  void initState() {
    super.initState();
    String from = widget.queryF;
    String to = widget.queryT;
    String city = widget.city;
    f = false;
    t = false;

    if (from != null || to != null) {
      showMyTrip(qF: from, qT: to, city: city);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Trips"),
      ),
      body: Center(
        child: SizedBox(
          width: double.infinity,
          height: double.maxFinite,
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(0, 0),
              zoom: 2.0,
            ),
          ),
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }
}
