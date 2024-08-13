class UserParent {
  String name;
  String phoneNumber;
  String imageUrl; // Field to store the image URL
  String userType; // New field to store the user type

  UserParent({
    required this.name,
    required this.phoneNumber,
    required this.imageUrl,
    required this.userType, // Initialize the userType
  });

  // Method to convert the object to a map (useful for Firestore or other databases)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'imageUrl': imageUrl, // Include imageUrl in the map
      'userType': userType, // Include userType in the map
    };
  }

  // Factory method to create an object from a map (useful for Firestore or other databases)
  factory UserParent.fromMap(Map<String, dynamic> map) {
    return UserParent(
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      imageUrl: map['imageUrl'], // Initialize imageUrl from the map
      userType: map['userType'], // Initialize userType from the map
    );
  }
}
