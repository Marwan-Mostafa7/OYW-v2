class Trip {
  String placeFrom, placeTo, timeFrom, timeTo, creatorId, city;
  List<String> days;
  List<String> passengers;

  Trip(
      {this.days,
      this.placeFrom,
      this.placeTo,
      this.timeFrom,
      this.timeTo,
      this.creatorId,
      this.passengers,
      this.city});

  Map<String, dynamic> toJson() => {
        'placeFrom': placeFrom,
        'placeTo': placeTo,
        'timeFrom': timeFrom,
        'timeTo': timeTo,
        'city': city,
        'days': days,
        'tripID': creatorId,
        'passengers': passengers,
      };
}
