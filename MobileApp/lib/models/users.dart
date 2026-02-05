class Users {
  String userId;
  String displayName;
  String email;
  String phoneNumber;
  String address;
  String cinNumber;
  String city;
  String birthday;
  int balance;
  int unitePrice;
  int secondsPrice;
  int duration;
  int timeOutReserve;
  String photoUrl;
  String cardUrl;
  String typeCard;
  String inviteCode;
  bool qrcodeBooked;
  bool qrcodeScanned;
  String registerStatus;
  String scooterReserved;
  List rides;
    Map<String, int>  reserveCounter= {"counter":0,"dateTimeCounter":0};
  static Map<String, dynamic> userData = {};
  Users(
      this.userId,
      this.displayName,
      this.email,
      this.phoneNumber,
      this.address,
      this.cinNumber,
      this.city,
      this.birthday,
      this.balance,
      this.unitePrice,
      this.secondsPrice,
      this.duration,
      this.timeOutReserve,
      this.reserveCounter,
      this.photoUrl,
      this.cardUrl,
      this.typeCard,
      this.inviteCode,
      this.qrcodeBooked,
      this.qrcodeScanned,
      this.registerStatus,
      this.scooterReserved,
      this.rides);
  Map<String, Object?> toJson() {
    return {
      "userId": userId,
      "displayName": displayName,
      "email": email,
      "phoneNumber": phoneNumber,
      "address": address,
      "cinNumber": cinNumber,
      "city": city,
      "birthday": birthday,
      "balance": balance,
      "unitePrice": unitePrice,
      "secondsPrice":secondsPrice,
      "duration": duration,
      "timeOutReserve":timeOutReserve,
      "reserveCounter":reserveCounter,
      "photoUrl": photoUrl,
      "cardUrl": cardUrl,
      "typeCard": typeCard,
      "inviteCode": inviteCode,
      "qrcodeBooked": qrcodeBooked,
      "qrcodeScanned": qrcodeScanned,
      "registerStatus": registerStatus,
      "scooterReserved": scooterReserved,
      "rides": rides
    };
  }


}
