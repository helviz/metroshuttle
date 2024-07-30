class DriverRoutes {
  String driverId;
  String childsName;
  String pickupLocation;
  String destination;
  DateTime? startDate;
  DateTime? endDate;
  String? parentID;
  String? parentsName;
  String? phoneNumber;
  String? schoolAddress;
  String? homeAddress;
  bool active;

  DriverRoutes({
    required this.driverId,
    required this.childsName,
    required this.pickupLocation,
    required this.destination,
    this.startDate,
    this.endDate,
    this.parentID,
    this.parentsName,
    this.phoneNumber,
    this.schoolAddress,
    this.homeAddress,
    this.active = true,
  });

  // Factory constructor to create an instance from a JSON object
  factory DriverRoutes.fromJson(Map<String, dynamic> json) {
    return DriverRoutes(
      driverId: json['driverId'],
      childsName: json['childsName'],
      pickupLocation: json['pickupLocation'],
      destination: json['destination'],
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      parentID: json['parentID'],
      parentsName: json['parentsName'],
      phoneNumber: json['phoneNumber'],
      schoolAddress: json['schoolAddress'],
      homeAddress: json['homeAddress'],
      active: json['active'] ?? true,
    );
  }

  // Method to convert an instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'driverId': driverId,
      'childsName': childsName,
      'pickupLocation': pickupLocation,
      'destination': destination,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'parentID': parentID,
      'parentsName': parentsName,
      'phoneNumber': phoneNumber,
      'schoolAddress': schoolAddress,
      'homeAddress': homeAddress,
      'active': active,
    };
  }
}
