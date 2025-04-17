class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final int age;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.age,
  });

  // Factory constructor để tạo UserModel từ Map (Firebase)
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      firstName: map['first name'] ?? '',
      lastName: map['last name'] ?? '',
      email: map['email'] ?? '',
      age: map['age'] ?? 0,
    );
  }

  // Phương thức chuyển đổi UserModel thành Map (để lưu vào Firebase)
  Map<String, dynamic> toMap() {
    return {
      'first name': firstName,
      'last name': lastName,
      'email': email,
      'age': age,
    };
  }
}
