class UpdateUserSchema {
  String? firstName;
  String? lastName;
  String? email;

  UpdateUserSchema({this.firstName, this.lastName, this.email});

  @override
  String toString() {
    return 'UpdateUserSchema{firstName: $firstName, lastName: $lastName, email: $email}';
  }

  Map<String, dynamic> toMap() {
    return {
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (email != null) 'email': email,
    };
  }
}
