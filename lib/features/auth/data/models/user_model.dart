/// Data model representing a user profile stored in Firestore.
class UserModel {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String gender;
  final String nationality;
  final String languageSpoken;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.dateOfBirth = '',
    this.gender = '',
    this.nationality = '',
    this.languageSpoken = '',
    required this.createdAt,
  });

  /// Full name computed from first and last name.
  String get fullName => '$firstName $lastName'.trim();

  /// Converts Firestore document data into a [UserModel].
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      dateOfBirth: map['dateOfBirth'] ?? '',
      gender: map['gender'] ?? '',
      nationality: map['nationality'] ?? '',
      languageSpoken: map['languageSpoken'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  /// Converts [UserModel] to a Map for Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'nationality': nationality,
      'languageSpoken': languageSpoken,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Returns a copy with updated fields.
  UserModel copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    String? gender,
    String? nationality,
    String? languageSpoken,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      nationality: nationality ?? this.nationality,
      languageSpoken: languageSpoken ?? this.languageSpoken,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
