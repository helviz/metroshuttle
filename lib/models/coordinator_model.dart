class COORDINATOR {
  String name;
  String email;
  String telephoneNumber;
  String schoolName;
  String imageUrl;
  String userType;

  COORDINATOR({
    required this.name,
    required this.email,
    required this.telephoneNumber,
    required this.schoolName,
    required this.imageUrl,
    required this.userType,
  });

  factory COORDINATOR.fromMap(Map<String, dynamic> map) {
    return COORDINATOR(
      name: map['name'],
      email: map['email'],
      telephoneNumber: map['telephoneNumber'],
      schoolName: map['schoolName'],
      imageUrl: map['imageUrl'],
      userType: map['userType'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'telephoneNumber': telephoneNumber,
      'schoolName': schoolName,
      'imageUrl': imageUrl,
      'userType': userType,
    };
  }
}
