class Parent {
  String name;
  String phoneNumber;
  String imageUrl; // Field to store the image URL

  Parent({
    required this.name,
    required this.phoneNumber,
    required this.imageUrl,
  });

  // Method to convert the object to a map (useful for Firestore or other databases)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'imageUrl': imageUrl, // Include imageUrl in the map
    };
  }

  // Factory method to create an object from a map (useful for Firestore or other databases)
  factory Parent.fromMap(Map<String, dynamic> map) {
    return Parent(
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      imageUrl: map['imageUrl'], // Initialize imageUrl from the map
    );
  }
}
