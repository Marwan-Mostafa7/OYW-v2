import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoder/geocoder.dart'; // Address --to--> Coordinates[lat, lng]
import 'package:geolocator/geolocator.dart';

import 'package:mapfltr/main.dart';
import 'package:mapfltr/services/dataManager.dart';

class MapDefault extends StatefulWidget {
  MapDefault();

  @override
  State<StatefulWidget> createState() {
    return _MapDefaultState();
  }
}

class _MapDefaultState extends State<MapDefault> {
  GoogleMapController mapController;
  bool clientsToggle = false;
  bool mapToggle = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      print("WELCOOOMME *********************");
      mapToggle = true;
      getLocations();
    });
  }

  var clients = [];
  var places = [];
  getLocations() {
    Firestore.instance.collection('trips').getDocuments().then((docs) {
      if (docs.documents.isNotEmpty) {
        setState(() {
          clientsToggle = true;
        });
        for (var i = 0; i < docs.documents.length; i++) {
          if (clientExist(docs.documents[i].data)) continue;
          print(docs.documents[i].data);
          print("LENGHT = ");
          print(docs.documents.length);
          clients.add(docs.documents[i].data);
          places.add(docs.documents[i].data['placeTo'].toLowerCase());
          initMarker(docs.documents[i].data);
        }
      }
    });
  }

  bool clientExist(client) {
    print("///////////////////");
    print(client['placeTo']);
    if (places.contains(client['placeTo'].toLowerCase())) return true;
    return false;
  }

  initMarker(client) {
    try {
      mapController.addMarker(MarkerOptions(
          position: LatLng(client['locTo'].latitude, client['locTo'].longitude),
          icon: BitmapDescriptor.defaultMarker,
          draggable: false,
          infoWindowText: InfoWindowText(client['placeFrom'] + " : " + client['placeTo'],
              client['timeFrom'] + " : " + client['timeTo'])));
    } catch (e) {
      print("markers :(((((((((  ${e}");
    }
  }

  Widget clientCard(client) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          mapController
              .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(client['locTo'].latitude, client['locTo'].longitude),
            zoom: 15.0,
            bearing: 90,
            tilt: 45,
          )));
        },
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(5.0),
          child: Container(
            height: 100,
            width: 125,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: MyApp.myFront3),
            child: Center(
              child: Text(
                client['placeTo'],
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("All Trips"),
        ),
        body: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height - 100,
                  width: double.infinity,
                  child: mapToggle
                      ? GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: LatLng(31.2001, 29.9187),
                            zoom: 10,
                          ),
                        )
                      : Container(
                          child: Center(
                            child: Text("Looding .....",
                                style: TextStyle(
                                    fontSize: 24, color: Colors.white)),
                          ),
                        ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height - 200,
                  left: 10.0,
                  child: Container(
                    height: 100.0,
                    width: MediaQuery.of(context).size.width,
                    child: clientsToggle
                        ? ListView(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.all(8.0),
                            children: clients.map((element) {
                              return clientCard(element);
                            }).toList(),
                          )
                        : Container(
                            height: 1.0,
                            width: 1.0,
                          ),
                  ),
                )
              ],
            )
          ],
        ));
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }
}
