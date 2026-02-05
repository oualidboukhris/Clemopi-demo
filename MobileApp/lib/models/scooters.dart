

class Scooter {
   String station;
   int battery;
   int driveStatus;
   int faultCode;
   int remainingDistance;
   String rider;
   int ridingTime;
   bool isReserved;
   bool isScanned;
  static  List scootersData=[];
  static Map<String, dynamic> scooterData = {};

  Scooter(
      this.station,
      this.battery,
      this.driveStatus,
      this.faultCode,
      this.remainingDistance,
      this.rider,
      this.ridingTime,
      this.isReserved,
      this.isScanned
     );
  Map<String, Object?> toJson() {
    return {
      "station": station,
      "battery": battery,
      "driveStatus": driveStatus,
      "faultCode": faultCode,
      "remainingDistance": remainingDistance,
      "rider": rider,
      "ridingTime": ridingTime,
      "isReserved": isReserved,
      "isScanned": isScanned,
    };
  }


}
