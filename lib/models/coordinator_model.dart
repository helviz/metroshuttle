// Coordinator model
class Coordinator {
  String id;
  String name;
  String email;
  String telephoneNumber;
  String schoolName;

  Coordinator({required this.id, required this.name, required this.email, required this.telephoneNumber, required this.schoolName});

  factory Coordinator.fromMap(Map<String, dynamic> map) {
    return Coordinator(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      telephoneNumber: map['telephoneNumber'],
      schoolName: map['schoolName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'telephoneNumber': telephoneNumber,
      'schoolName': schoolName,
    };
  }
}