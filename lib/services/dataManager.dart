import 'dart:io';
import 'dart:convert';

import 'package:mapfltr/models/car.dart';
import 'package:mapfltr/services/FBManager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:random_string/random_string.dart';

import '../models/user.dart';

class DataManager {
  // GLOBAL DATA

  static const List<String> CITIES = [
    'القاهرة ',
    'الجيزة ',
    'القليوبية ',
    'الإسكندرية ',
    'البحيرة ',
    'مطروح ',
    'دمياط ',
    'الدقهلية ',
    'كفر الشيخ ',
    'الغربية ',
    'المنوفية ',
    'الشرقية ',
    'بورسعيد ',
    'الإسماعيلية ',
    'السويس ',
    'شمال سيناء ',
    'جنوب سيناء ',
    'بني سويف ',
    'الفيوم ',
    'المنيا ',
    'أسيوط ',
    'الوادي الجديد ',
    'البحر الأحمر ',
    'سوهاج ',
    'قنا ',
    'الأقصر ',
    'أسوان'
  ];
  static const List<String> DAYS = [
    'الاحد',
    'الاثنين',
    'الثلاثاء',
    'الاربعاء',
    'الخميس',
    'الجمعة',
    'السبت'
  ];

  Directory dir;
  File jsonFile;
  String fileName = "db.json";
  bool fExists = false;

// File Methods -1
  DataManager() {
    if (fExists) return;
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      print("dir.path ====");
      print(dir.path);
      jsonFile = new File(dir.path + "/" + fileName);
      fExists = jsonFile.existsSync();
      print("-------fExists");
      print(fExists);
    });
  }
// File Methods 0
  void createFile(
      Map<String, dynamic> userContent, Directory dir, String fileName) {
    File file = new File(dir.path + "/" + fileName);
    file.createSync();
    fExists = true;
    file.writeAsStringSync(jsonEncode(userContent));
  }

  // File Methods 1
  void initUser() {
    if (fExists) return;
    print("CREATING FILE");

    Map<String, dynamic> all = {};
    all['personal'] = {};
    all['car'] = {};
    all['trips'] = Map<String, Map<String, dynamic>>();
    all['waiting'] = [];

    createFile(all, dir, fileName);
  }

  bool isLoggedIn() {
    print("HEEY  2");
    Map<String, dynamic> all;
    try {
      all = json.decode(jsonFile.readAsStringSync());
    } catch (e) {
      print("IN THE EXCEPTION");
      return false;
    }
    if (all == null) return false;
    if (all['loginState'] == "IN") return true;

    print("HEEY  3");
    return false;
  }

  void logOut() {
    Map<String, dynamic> all = json.decode(jsonFile.readAsStringSync());
    all['loginState'] = "OUT";

    print("HEEY  5 Logged OOUUTT");
  }

  void logIn() {
    Map<String, dynamic> all = json.decode(jsonFile.readAsStringSync());
    all['loginState'] = "IN";

    print("HEEY  4  Logged IN");
  }

  // $$$$$$$$$$$$$$$$$$$$$$ Part 1 $$$$$$$$$$$$$$$$$$$$$$
  Map<String, dynamic> getUser({Map<String, dynamic> all}) {
    Map<String, dynamic> allin =
        all ?? json.decode(jsonFile.readAsStringSync());

    return allin['personal'];
  }

  void updateUserName(String userName) {
    Map<String, dynamic> all = json.decode(jsonFile.readAsStringSync());
    all['personal']['userName'] = userName;
    jsonFile.writeAsStringSync(jsonEncode(all));
  }

  void setUserImgURL(String v, {String imgPath}) async {
    print("SETTING IMG URL DMG  :: $v");
    Map<String, dynamic> all = json.decode(jsonFile.readAsStringSync());
    all['personal']['userImgUrl'] = v;
    all['personal']['userImg'] = imgPath ?? all['personal']['userImg'];
    jsonFile.writeAsStringSync(jsonEncode(all));
  }

  void setUserImgPath(String path) {
    Map<String, dynamic> all = json.decode(jsonFile.readAsStringSync());
    all['personal']['userImg'] = path;
    jsonFile.writeAsStringSync(jsonEncode(all));
  }

  void createUser({User myperson, Map<String, dynamic> userObj}) {
    // Create file
    initUser();
    // read All user data
    Map<String, dynamic> all = json.decode(jsonFile.readAsStringSync());
    Map<String, dynamic> user = {};

    user = myperson.toJson() ?? userObj;

    user['userId'] = randomAlphaNumeric(10);

    // add data
    all['personal'] = user;
    // write user data into file
    jsonFile.writeAsStringSync(jsonEncode(all));
  }

  void updateUser({User myperson, Map<String, dynamic> userObj}) {
    // read All user data
    Map<String, dynamic> all = json.decode(jsonFile.readAsStringSync());
    Map<String, dynamic> user = {};
    // assign data
    user = myperson?.toJson() ?? userObj;
    // add data
    all['personal'] = user;
    print("USER AFTER UPDATE ===============");
    print(all['personal']);
    // write user data into file
    jsonFile.writeAsStringSync(jsonEncode(all));
  }

// take hashed password from FireBase
// into json file
  Future setUserPass(String uid) async {
    Map<String, dynamic> all = json.decode(jsonFile.readAsStringSync());
    all['personal']['pass'] = uid;
    jsonFile.writeAsStringSync(jsonEncode(all));
    print('[DMG]  USER PASSWORD change !!!');
    //print(all['personal']);
  }

  Future<String> getUserPass() async {
    Map<String, dynamic> all = json.decode(jsonFile.readAsStringSync());
    return all['personal']['pass'];
  }

  void setUserID(dynamic id) {
    print("*******USER ID ON DMG *********");
    print(id.toString());
    Map<String, dynamic> allin = json.decode(jsonFile.readAsStringSync());
    allin['personal']['userId'] = id.toString();
    print(allin['personal']);
    jsonFile.writeAsStringSync(jsonEncode(allin));
  }

  String getUserID({Map<String, dynamic> all}) {
    print("all is null ?? ${all == null}");
    Map<String, dynamic> allin =
        all ?? json.decode(jsonFile.readAsStringSync());

    return allin['personal'].isNotEmpty
        ? allin['personal']['userId'].toString()
        : null;
  }

  String getUserToken({Map<String, dynamic> all}) {
    print("all is null ?? ${all == null}");
    Map<String, dynamic> allin =
        all ?? json.decode(jsonFile.readAsStringSync());

    return allin['personal'].isNotEmpty
        ? allin['personal']['token'].toString()
        : null;
  }

  String getUserImgURL() {
    Map<String, dynamic> all = json.decode(jsonFile.readAsStringSync());
    return (all['personal'].isEmpty) || (all['personal']['userImgUrl'] == null)
        ? null
        : all['personal']['userImgUrl'].toString();
  }

  String getUserImgPath() {
    Map<String, dynamic> all = json.decode(jsonFile.readAsStringSync());
    return (all['personal'].isEmpty) || (all['personal']['userImg'] == null)
        ? null
        : all['personal']['userImg'].toString();
  }

  // login with another email (and file not deleted)
  Future<void> checkUser(String email, String passUid) async {
    print("CHECK THE USER !!!!!!!!!!!!!!!");

    Map<String, dynamic> allin;
    try {
      allin = json.decode(jsonFile.readAsStringSync());
    } catch (e) {
      // App is first Open and want to login
      // App is un-installed then installed again
      // TODO
      // Check token
      print("NO FILE EXIST :P");
      initUser();
      // get user to file from Firestore
      await FBManager().getUser(email, passUid).then((user) {
        updateUser(userObj: user.data);
        allin = json.decode(jsonFile.readAsStringSync());
      });
      // get car to file from Firestore
      await FBManager().getCar(allin['personal']['userId']).then((car) {
        updateCar(carObj: car.data);
        allin = json.decode(jsonFile.readAsStringSync());
      });
    }

    if (allin['personal']['userEmail'] == email) {
      print("SAME USER NO UPDATE IN FILE");
      return "";
    }

    print("DiFF user UPDATE FILE");
    print("-----------------------------");

    // get user to file from Firestore
    await FBManager().getUser(email, passUid).then((user) {
      updateUser(userObj: user.data);
      allin = json.decode(jsonFile.readAsStringSync());
    });
    // get car to file from Firestore
    await FBManager().getCar(allin['personal']['userId']).then((car) {
      updateCar(carObj: car.data);
      allin = json.decode(jsonFile.readAsStringSync());
    });
  }

  // $$$$$$$$$$$$$$$$$$$$$$ Part 2 $$$$$$$$$$$$$$$$$$$$$$

  void createCar({Car mycar, Map<String, dynamic> carObj}) {
    // read All user data
    Map<String, dynamic> all = json.decode(jsonFile.readAsStringSync());
    Map<String, dynamic> car = {};

    car = mycar.toJson() ?? carObj;

    car['carId'] = randomAlphaNumeric(10);

    // add data
    all['car'] = car;
    // write car data into file
    jsonFile.writeAsStringSync(jsonEncode(all));
  }

  void updateCar({Car mycar, Map<String, dynamic> carObj}) {
    // read All user data
    Map<String, dynamic> all = json.decode(jsonFile.readAsStringSync());
    Map<String, dynamic> car = {};
    // assign data
    car = mycar?.toJson() ?? carObj;
    // add data
    all['car'] = car;
    // write car data into file
    jsonFile.writeAsStringSync(jsonEncode(all));
  }

  String getCarID(all) {
    return all['car'].isNotEmpty ? all['car']['carId'] : null;
  }

  void setCarImgURL(String v) {
    Map<String, dynamic> all = json.decode(jsonFile.readAsStringSync());
    all['car']['carImgUrl'] = v;
    jsonFile.writeAsStringSync(jsonEncode(all));
  }

  void setCarImgPath(String v, {Car mycar}) {
    Map<String, dynamic> all = json.decode(jsonFile.readAsStringSync());
    all['car']['carImgPath'] = v;
    jsonFile.writeAsStringSync(jsonEncode(all));
  }

  Map<String, dynamic> getCar({Map<String, dynamic> all}) {
    print("From DATA MANAGER GET Car ()");

    Map<String, dynamic> allin =
        all ?? json.decode(jsonFile.readAsStringSync());

    return allin['car'];
  }

  // $$$$$$$$$$$$$$$$$$$$$$ Part 3 $$$$$$$$$$$$$$$$$$$$$$
  void addUserTrips(Map<String, dynamic> myTrip) async {
    print('***** [dmg] TRIP ****');

    // read All user data
    Map<String, dynamic> all = await json.decode(jsonFile.readAsStringSync());
    Map<String, dynamic> trip = {};
    String tripId = randomAlphaNumeric(10);
    trip = {
      'placeFrom': myTrip['placeFrom'],
      'placeTo': myTrip['placeTo'],
      'locFrom': myTrip['locFrom'],
      'locTo': myTrip['locTo'],
      'timeFrom': myTrip['timeFrom'],
      'timeTo': myTrip['timeTo'],
      'city': myTrip['city'],
      'days': myTrip['days'],
      'tripID': tripId,
      'creatorId': all['personal']['userId'],
      'passengers': myTrip['passengers'],
    };

    // add trip
    all['trips'][tripId] = {};
    all['trips'][tripId] = trip;

    print('trips --------');
    print(all['trips']);

    print('DMG AFTER Trip ADDED ***************');
    //print(all);
    jsonFile.writeAsStringSync(jsonEncode(all));

    FBManager().addTrip(trip, all['personal']['token'].toString());
  }

  void deleteTrip(String tripId) {
    Map<String, dynamic> all = json.decode(jsonFile.readAsStringSync());

    all['trips'].remove(tripId);
    print("After Deletion");
    print(all['trips']);
    jsonFile.writeAsStringSync(jsonEncode(all));

    FBManager().removeMefromTrip(tripId, all['personal']['userId'].toString(),
        all['personal']['token'].toString());
  }

  // void addWaiting(String reqId) {
  //   Map<String, dynamic> all = json.decode(jsonFile.readAsStringSync());
  //   all['waiting'].add(reqId);
  //   jsonFile.writeAsStringSync(jsonEncode(all));
  // }

  // bool checkInwaiting(String reqId) {
  //   Map<String, dynamic> all = json.decode(jsonFile.readAsStringSync());
  //   if (all['waiting'].contains(reqId)) return true;
  //   return false;
  // }
}
