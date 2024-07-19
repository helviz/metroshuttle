class Child {
  final String userId;
  final String name;
  final String pickupLocation;
  final String destinationLocation;
  final String region;
  final DateTime startDate;
  final DateTime endDate;
  final String? driver; // Nullable field
  final bool? request;   // Nullable field

  Child({
    required this.userId,
    required this.name,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.region,
    required this.startDate,
    required this.endDate,
    this.driver,
    this.request,
  });

  // Convert a Child object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'pickupLocation': pickupLocation,
      'destinationLocation': destinationLocation,
      'region': region,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'driver': driver,
      'request': request,
    };
  }

  // Create a Child object from a Map object
  factory Child.fromMap(Map<String, dynamic> map) {
    return Child(
      userId: map['userId'],
      name: map['name'],
      pickupLocation: map['pickupLocation'],
      destinationLocation: map['destinationLocation'],
      region: map['region'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      driver: map['driver'],
      request: map['request'],
    );
  }
}
