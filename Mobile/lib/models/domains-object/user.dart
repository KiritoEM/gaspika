class User {
  int id;
  String email;
  String firstName;
  String lastName;
  int? householdSize;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.householdSize,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      householdSize: json['household_size'],
    );
  }

  @override
  String toString() {
    return 'User{id: $id, email: $email, firstName: $firstName, lastName: $lastName, householdSize: $householdSize}';
  }
}
