import 'package:random_string/random_string.dart' as random;

class Car {
  String carId,
      brand,
      carModel,
      carYear,
      userId,
      carImgPath,
      carImgUrl,
      carSize;
  Car(
      {this.userId,
      this.brand,
      this.carModel,
      this.carYear,
      this.carSize,
      this.carImgPath,
      this.carImgUrl}) {
    this.carId = random.randomAlphaNumeric(10);
  }

  set setCarID(newID) => this.carId = newID;
  String get getCarID => this.carId;

  set setCarImgURL(url) => this.carImgUrl = url;

  Map<String, dynamic> toJson() => {
        'carId': carId,
        'brand': brand,
        'year': carYear,
        'size': carSize,
        'model': carModel,
        'carImgPath': carImgPath,
        'carImgUrl': carImgUrl,
        'userId': userId,
      };

  

}
