class UserModel {
  final String uid;
  final String name;
  final String email;
  final String imageUrl;
  final String phone;
  final String country;
  final String location;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.phone,
    required this.country,
    required this.location,
  });

  // Firestore → UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      phone: map['phone'] ?? '',
      country: map['country'] ?? '',
      location: map['location'] ?? '',
    );
  }

  // UserModel → Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'imageUrl': imageUrl,
      'phone': phone,
      'country': country,
      'location': location,
    };
  }
}
