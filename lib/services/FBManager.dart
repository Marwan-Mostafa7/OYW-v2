import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geocoder/geocoder.dart';
import 'package:mapfltr/models/car.dart';

import 'package:mapfltr/services/dataManager.dart';
import 'package:mapfltr/models/user.dart';

class FBManager {
  DataManager dmg;
  dynamic _mpU, _mpC;

  FBManager({DataManager dmg}) {
    this.dmg = dmg;
    _mpU = dmg?.getUser();
    _mpC = dmg?.getCar();
  }

  Future authenticateUser(User me, Car myCar) async {
    // Aurthenticating user
    FirebaseUser signedUser = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: me.userEmail, password: me.pass);
    dmg.setUserPass(signedUser.uid);

    String userImgUrl = await uploadImage(me.userImgPath);
    dmg.setUserImgURL(userImgUrl);

    String carImgUrl = await uploadImage(myCar.carImgPath);
    dmg.setCarImgURL(carImgUrl);

    await addUser();

    await addCar();
  }

  Future<DocumentSnapshot> getUser(String email, String passUid) async {
    CollectionReference usrColl = Firestore.instance.collection('users');
    QuerySnapshot qsnp = await Firestore.instance
        .collection('users')
        .where('userEmail', isEqualTo: email)
        .where('pass', isEqualTo: passUid)
        .getDocuments();
    DocumentReference dcrf = usrColl.document(qsnp.documents[0].documentID);

    DocumentSnapshot dsnp;
    await Firestore.instance.runTransaction((trx) async {
      dsnp = await trx.get(dcrf);
    });

    return dsnp;
  }
  // return Firestore.instance
  //     .collection('user')
  //     .where("userId", isEqualTo: userId)
  //     .reference()
  //     .document()
  //     .get();

  Future<DocumentSnapshot> getCar(userId) async {
    CollectionReference carColl = Firestore.instance.collection('cars');
    QuerySnapshot qsnp = await Firestore.instance
        .collection('cars')
        .where('userId', isEqualTo: userId)
        .getDocuments();
    DocumentReference dcrf = carColl.document(qsnp.documents[0].documentID);
    DocumentSnapshot dsnp;
    await Firestore.instance.runTransaction((trx) async {
      dsnp = await trx.get(dcrf);
    });
    return dsnp;
  }

  // return Firestore.instance
  //     .collection('cars')
  //     .where("userId", isEqualTo: carId)
  //     .reference()
  //     .document()
  //     .get();

  Future addUser() async {
    Map<String, dynamic> me = dmg.getUser();
    Firestore.instance.collection('users').document().setData(me);
  }

  // Update UserName
  Future updateUserName(dynamic _mp, String userName) async {
    CollectionReference userColl = Firestore.instance.collection('users');
    QuerySnapshot qsnp = await Firestore.instance
        .collection('users')
        .where('userEmail', isEqualTo: _mp['userEmail'])
        .where('pass', isEqualTo: _mp['pass'])
        .getDocuments();
    DocumentReference dcrf = userColl.document(qsnp.documents[0].documentID);
    Firestore.instance.runTransaction((trx) async {
      await trx.update(dcrf, {'userName': userName});
    });
  }

  Future updateUserImgUrl(dynamic _mp, String userImgUrl) async {
    CollectionReference userColl = Firestore.instance.collection('users');

    QuerySnapshot qsnp = await Firestore.instance
        .collection('users')
        .where('userEmail', isEqualTo: _mp['userEmail'])
        .where('pass', isEqualTo: _mp['pass'])
        .getDocuments();
    DocumentReference dcrf = userColl.document(qsnp.documents[0].documentID);
    Firestore.instance.runTransaction((trx) async {
      await trx.update(dcrf, {'userImgUrl': userImgUrl});
    });
  }

  Future updateCarData(dynamic _mp) async {
    CollectionReference userColl = Firestore.instance.collection('cars');

    QuerySnapshot qsnp = await Firestore.instance
        .collection('cars')
        .where('carId', isEqualTo: _mp['carId'])
        .getDocuments();

    DocumentReference dcrf = userColl.document(qsnp.documents[0].documentID);

    Firestore.instance.runTransaction((trx) async {
      await trx.update(dcrf, {
        'brand': _mp['brand'],
        'year': _mp['year'],
        'size': _mp['size'],
        'model': _mp['model'],
        'carImgUrl': _mp['carImgUrl'],
      });
    });
  }

  Future addCar() async {
    Map<String, dynamic> car = dmg.getCar();
    print("add Car From FIRE ********");
    print(car);
    Firestore.instance.collection('cars').document().setData(car);
  }

  Future addTrip(Map<String, dynamic> trip, String userToken) async {
    // var fromAddress = await Geocoder.local.findAddressesFromQuery(trip['placeFrom']);
    // double flat = fromAddress.first.coordinates.latitude;
    // double flng = fromAddress.first.coordinates.longitude;
    var toAddress = await Geocoder.local
        .findAddressesFromQuery(trip['placeTo'] + " " + trip['city']);
    double tlat = toAddress.first.coordinates.latitude;
    double tlng = toAddress.first.coordinates.longitude;

    print("ADDRESSES");
    print(tlat);
    print(tlng);

    List<String> passengersIds = [];
    List<String> passengersTkns = [];
    passengersIds.add(trip['creatorId']);
    passengersTkns.add(userToken);

    Firestore.instance.collection('trips').document().setData({
      'placeFrom': trip['placeFrom'],
      'placeTo': trip['placeTo'],
      'locTo': GeoPoint(tlat, tlng),
      'timeFrom': trip['timeFrom'],
      'timeTo': trip['timeTo'],
      'city': trip['city'],
      'days': trip['days'],
      'tripID': trip['tripID'],
      'passengersIDS': passengersIds,
      'passengersToken': passengersTkns,
    });
  }

  Future getTripsFor(String id) {
    var arr = [];
    Firestore.instance
        .collection('trips')
        .where("tripID", isEqualTo: id)
        .snapshots()
        .listen((data) {
      data.documents.forEach((doc) => arr.add(doc.data));
      print("GET Trips For user $id ");
      print(arr);
      return arr;
    });
  }

  // get Trip
  Future getTrip(String tripId) async {
    CollectionReference tripCollection = Firestore.instance.collection('trips');
    QuerySnapshot qsnp = await Firestore.instance
        .collection('trips')
        .where('tripID', isEqualTo: tripId)
        .getDocuments();
    DocumentReference dcrf =
        tripCollection.document(qsnp.documents[0].documentID);
    DocumentSnapshot dsnp;
    Firestore.instance.runTransaction((trx) async {
      dsnp = await trx.get(dcrf);
    });
    return dsnp;
  }

  // Firestore.instance.runTransaction((trx) async {
  //   await trx.update(dcrf, {
  //     'brand': _mp['brand'],
  //     'year': _mp['year'],
  //     'size': _mp['size'],
  //     'model': _mp['model'],
  //     'carImgUrl': _mp['carImgUrl'],
  //   });
  // });

  // %%%%%%%%%%%%%
  Future removeMefromTrip(
      String tripId, String userId, String userToken) async {
    bool gate = true;
    print("WANT TO DELETE USER => $userId");
    Firestore.instance.collection('trips').snapshots().listen((d) {
      if (gate)
        for (var d in d.documents) {
          if (d.data['tripID'] == tripId) {
            print("THEY WAS ------------------------");
            print(d.data['passengersIDS']);
            print(d.data['passengersToken']);
            // Check if Only Me in list -> remove trip
            // else                     -> update trip (listPassIDs, listPassToken)
            List<String> ids = [];
            List<String> tkns = [];
            d.data['passengersIDS'].forEach((id) => ids.add(id.toString()));
            d.data['passengersToken'].forEach((t) => tkns.add(t.toString()));
            ids.remove(userId);
            tkns.remove(userToken);
            print("NOW THEY BECAME ------------------------");
            print(ids);
            print(tkns);

            if (ids.isEmpty) {
              print("BECAME EMPTY ");
              removeTrip(d.documentID);
              print("DELETE IT");
            }
            print(
                "UPDATING TRIP !!! after you have deleted it from your trips");
            updateTripPassengers(tripId, ids, tkns);
          }
        }
      gate = false;
    });
  }

  Future removeMefromWaitingPasgnrs(
      String tripId, String userId, String userToken) async {
    Firestore.instance.collection('waiting').snapshots().listen((d) {
      for (var d in d.documents) {
        if (d.data['tripID'] == tripId) {
          print("THEY WAS ----------WAITNG--------------");
          print(d.data['passengersIDS']);
          print(d.data['passengersToken']);
          // Check if Only Me in list -> remove trip
          // else                     -> update trip (listPassIDs, listPassToken)
          List<String> ids = [];
          List<String> tkns = [];
          d.data['passengersIDS'].forEach((id) => ids.add(id.toString()));
          d.data['passengersToken'].forEach((t) => tkns.add(t.toString()));
          ids.remove(userId);
          tkns.remove(userToken);
          print("NOW THEY BECAME ------------------------");
          print(ids);
          print(tkns);

          if (ids.isEmpty) {
            print("BECAME EMPTY ");
            removeTrip(d.documentID);
            print("DELETE IT");
          }
          print("UPDATING TRIP !!! after you have deleted it from your trips");
          updateTripPassengers(tripId, ids, tkns);
        }
      }
    });
  }

  Future removeTrip(String docId) async {
    CollectionReference userColl = Firestore.instance.collection('trips');

    DocumentReference dcrf = userColl.document(docId);

    Firestore.instance.runTransaction((trx) async {
      await trx.delete(dcrf);
    });
  }

  // When -->  "تريد الانضمام" is pressed
  // Create New
  // Waiting document
  // Decision document
  Future addWaiting(String reqId, String reqToken, String requsrName,
      Map<String, dynamic> trip) async {
    // check reqId not in trip Passengers -_-
    // prevent duplicate addition
    print("Check If in Passengers ??");
    if (trip['passengersIDS'].contains(reqId)) return true;
    print("Not in passegners");
    // Create waiting Document
    Firestore.instance.collection('waiting').document().setData({
      'reqID': reqId,
      'reqToken': reqToken,
      'reqName': requsrName,
      'tripID': trip['tripID'],
      'placeTo': trip['placeTo'],
      'passengersIDS': trip['passengersIDS'],
      'passengersToken': trip['passengersToken'],
      'nAccept': 0,
      "nReject": 0,
      "nSum": 0,
    });
    // Create Decision Document
    Firestore.instance.collection('decision').document().setData({
      'tripID': trip['tripID'],
      'reqID': reqId,
      'placeTo': trip['placeTo'],
      'decide': "waiting"
    });
  }

//► `waiting`
  //  increment +1
  //      nAccept || nReject
  //      nSum
  // check
  // sum == len(passIDs)
  // nAccept > nReject
  // add reqId -> passengersID            (update ►`trips` )
  // add reqToken -> passengersTokens     (update ►`trips` )
  // assign  "accept"                     (update ►`decision`)
  // delete document                      (delete ►`waiting` )
  // nAccept < nReject
  // assign  "reject"                (update ►`decision`)
  // delete document                  (delete ►`waiting`)
  // sum != len(passIDs)
  // do Nothing
  Future idecide(
      String tripId, String reqId, String reqTkn, String decision) async {
    bool gate = true;
    CollectionReference userColl = Firestore.instance.collection('waiting');
    QuerySnapshot qsnp = await Firestore.instance
        .collection('waiting')
        .where('tripID', isEqualTo: tripId)
        .where('reqID', isEqualTo: reqId)
        .getDocuments();
    DocumentReference dcrf = userColl.document(qsnp.documents[0].documentID);
    dcrf.snapshots().listen((d) {
      if (gate) {
        print("gate OPEN");
        Firestore.instance.runTransaction((trx) async {
          print(decision);
          await trx.update(dcrf, {
            'nAccept':
                decision == "yes" ? d.data['nAccept'] + 1 : d.data['nAccept'],
            "nReject":
                decision == "no" ? d.data['nReject'] + 1 : d.data['nReject'],
            "nSum": d.data['nSum'] + 1
          });
          // .then((v) async {
          // print("OUT of the update");
          // if (d.data['nSum'] == d.data['passengersIDS'].length) {
          //   print("SUM == len(passIDs)");
          //   print(d.data['nSum'] + "  " + d.data['passengersIDS'].length);
          //   if (d.data['nAccept'] > d.data['nReject']) {
          //     print("ACCEPT USER");
          //     await acceptUser(reqId, reqTkn, tripId);
          //   } else {
          //     print("REJEECT USER");
          //     await rejectUser(reqId, tripId);
          //   }
          //   print("Delete Waiting Document  ${d.documentID}");
          //   await removeDoc(d.documentID);
          // }
          // print("OUT of the update 2222");
          // return null;
          // });
        });
      }
      print("gate closed !");

      if (!gate) {
        print("HELLO ************************************");
        print(dcrf);
        dcrf.snapshots().listen((d) async {
          if (d.data['nSum'] == d.data['passengersIDS'].length) {
            print("SUM == len(passIDs)");
            if (d.data['nAccept'] > d.data['nReject']) {
              print("ACCEPT USER");
              await acceptUser(reqId, reqTkn, tripId);
            } else {
              print("REJEECT USER");
              await rejectUser(reqId, tripId);
            }
            print("Delete Waiting Document  ${d.documentID}");
            await removeDoc(d.documentID);
          }
        });
      }
      gate = false;
    });
  }

  // assign "yes" --> decide             ► `decision`
  // add reqId    --> passengersId list  ► `trips`
  // add reqToken --> passengersTk list  ► `trips`
  Future acceptUser(String reqId, String reqTkn, String tripId) async {
    print("Accept  $reqId ---in----> $tripId");
    List<String> passengersIDs = [reqId];
    List<String> passengersTks = [reqTkn];

    CollectionReference userColl = Firestore.instance.collection('trips');

    QuerySnapshot qsnp = await Firestore.instance
        .collection('trips')
        .where('tripID', isEqualTo: tripId)
        .getDocuments();

    DocumentReference dcrf = userColl.document(qsnp.documents[0].documentID);

    Firestore.instance.runTransaction((trx) async {
      await trx.update(dcrf, {
        'passengersIDS': FieldValue.arrayUnion(passengersIDs),
        'passengersToken': FieldValue.arrayUnion(passengersTks)
      });
    });
    // assign "yes" --> decide
    await updateDecision(reqId, tripId, "yes");
  }

  // assign `no` --> decide  ► `decision`
  Future rejectUser(String reqId, String tripId) async {
    // assign `no`
    await updateDecision(reqId, tripId, "no");
  }

  // remove doc from Waiting Collection
  // if I deleted my request
  // or Decision have been conducted
  Future removeDoc(String waitId) {
    // delete document
    CollectionReference userColl = Firestore.instance.collection('waiting');
    DocumentReference dcrf = userColl.document(waitId);
    Firestore.instance.runTransaction((trx) async {
      await trx.delete(dcrf);
    });
  }

  // update decision after all passengers made a decision
  Future updateDecision(String reqId, String tripId, String decision) async {
    CollectionReference userColl = Firestore.instance.collection('decision');
    QuerySnapshot qsnp = await Firestore.instance
        .collection('decision')
        .where('reqID', isEqualTo: reqId)
        .where('tripID', isEqualTo: tripId)
        .getDocuments();
    DocumentReference dcrf = userColl.document(qsnp.documents[0].documentID);
    Firestore.instance.runTransaction((trx) async {
      await trx.update(dcrf, {'decide': decision});
    });
  }

  // Check whether my Request Accepted || Rejected
  Future checkDecision(String reqId, String tripId) async {
    CollectionReference userColl = Firestore.instance.collection('decision');

    QuerySnapshot qsnp = await Firestore.instance
        .collection('decision')
        .where('reqID', isEqualTo: reqId)
        .where('tripID', isEqualTo: tripId)
        .getDocuments();

    DocumentReference dcrf = userColl.document(qsnp.documents[0].documentID);

    DocumentSnapshot dsnp;
    Firestore.instance.runTransaction((trx) async {
      dsnp = await trx.get(dcrf);
    });
    return dsnp;
  }

  Future updateTripPassengers(
      String tripId, List<String> passIDs, List<String> passTks) async {
    print("UPDATE TRIP");
    print(passIDs);
    print("=================");
    CollectionReference userColl = Firestore.instance.collection('trips');
    QuerySnapshot qsnp = await Firestore.instance
        .collection('trips')
        .where('tripID', isEqualTo: tripId)
        .getDocuments();
    DocumentReference dcrf = userColl.document(qsnp.documents[0].documentID);
    Firestore.instance.runTransaction((trx) async {
      await trx
          .update(dcrf, {'passengersIDS': passIDs, 'passengersToken': passTks});
    });
  }

  // upload image on Server
  // get url
  Future<String> uploadImage(String imgPath) async {
    if (imgPath == null) return "";
    // if (imgPath == _mpU['userImg']) return _mpU['userImgUrl'];
    // if (imgPath == _mpC['carImgPath']) return _mpC['carImgUrl'];

    StorageReference ref = FirebaseStorage.instance.ref().child(imgPath);
    StorageUploadTask uploadTask = ref.putFile(File(imgPath));
    var downUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
    var url = downUrl.toString();
    print("*******URL:: $url"); // String to be stored in the data base
    return url;
  }
}

// List arr = [];
// Future getAllTrips() async {
//   arr.clear();
//   Firestore.instance.collection('trips').snapshots().listen((data) {
//     data.documents.forEach((doc) => arr.add(doc.data));
//     print("GET TRIPS FS");
//     print(arr);
//   });
// }

// Future checkUser(String phoneNum, DataManager dmg) {
//   print("CHECK USER ON FIRESTORE");
//   // check user Phone exist on FireStore
//   Firestore.instance
//       .collection('users')
//       .where('phone', isEqualTo: phoneNum)
//       .snapshots()
//       .listen((u) {
//     print("*******USER ID ON FIRESTORE *********");
//     print(u.documents[0].data['userId']);
//     if (u.documents.length == 0) return;
//     dmg.setUserID(u.documents[0].data['userId']);
//   });

//   // Assign userId on Firestore ->> userId on file
// }

// Future setUserID({String oldId, String newId}) {
//   print("UPDATE USER ID");
//   print(oldId);
//   String docID;
//   Firestore.instance.collection('users').snapshots().listen((d) {
//     for (var i = 0; i < d.documents.length; i++) {
//       if ((d.documents[i].data['userId'] == oldId))
//         docID = d.documents[i].documentID;
//     }
//     print("********* DOCUMEEEEEEEENT *********");
//     print(docID);
//     Firestore.instance
//         .document('users/' + docID)
//         .updateData({'userId': newId, 'pass': newId});

//     // Firestore.instance
//     //     .collection('users')
//     //     .where("userId", isEqualTo: oldId)
//     //     .reference()
//     //     .document()
//     //     .updateData({'userId': newId});
//   });
// }
