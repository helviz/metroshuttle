class DriverRoutes {
  String driverId;
  String childsName;
  String pickupLocation;
  String destination;
  DateTime startDate;
  DateTime endDate;
  String? parentsName;
  String? phoneNumber;
  String? schoolAddress;
  String? homeAddress;
  bool active;
  bool dropoff;

  DriverRoutes({
    required this.driverId,
    required this.childsName,
    required this.pickupLocation,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.parentsName,
    this.phoneNumber,
    this.schoolAddress,
    this.homeAddress,
    this.active = true,
    this.dropoff = false,
  });

  // Factory constructor to create an instance from a JSON object
  factory DriverRoutes.fromJson(Map<String, dynamic> json) {
    return DriverRoutes(
      driverId: json['driverId'],
      childsName: json['childsName'],
      pickupLocation: json['pickupLocation'],
      destination: json['destination'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      parentsName: json['parentsName'],
      phoneNumber: json['phoneNumber'],
      schoolAddress: json['schoolAddress'],
      homeAddress: json['homeAddress'],
      active: json['active'] ?? true,
      dropoff: json['dropoff'] ?? false,
    );
  }

  // Method to convert an instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'driverId': driverId,
      'childsName': childsName,
      'pickupLocation': pickupLocation,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'parentsName': parentsName,
      'phoneNumber': phoneNumber,
      'schoolAddress': schoolAddress,
      'homeAddress': homeAddress,
      'active': active,
      'dropoff': dropoff,
    };
  }
}
