class Driver {
  String name;
  String phoneNumber;

  Driver({
    required this.name,
    required this.phoneNumber,
  });

  // Method to convert the object to a map (useful for Firestore or other databases)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
    };
  }

  // Factory method to create an object from a map (useful for Firestore or other databases)
  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      name: map['name'],
      phoneNumber: map['phoneNumber'],
    );
  }
}
