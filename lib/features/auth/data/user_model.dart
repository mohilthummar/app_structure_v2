/// User data model. Used directly by all layers — DataSource → Repository →
/// Controller → View — with no entity/DTO split. Fields are nullable so the
/// model tolerates partial server payloads.
///
/// `fromJson` accepts both snake_case (`first_name`) and camelCase
/// (`firstName`) keys so this model survives backend casing changes.
class UserModel {
  const UserModel({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.image,
  });

  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? image;

  /// Convenience: full name (trimmed). Empty string if both parts null.
  String get fullName => [firstName, lastName].where((p) => p != null && p.isNotEmpty).join(' ').trim();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? json['_id'] as String?,
      firstName: json['first_name'] as String? ?? json['firstName'] as String?,
      lastName: json['last_name'] as String? ?? json['lastName'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String? ?? json['phoneNumber'] as String?,
      image: json['image'] as String? ?? json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (firstName != null) 'first_name': firstName,
    if (lastName != null) 'last_name': lastName,
    if (email != null) 'email': email,
    if (phoneNumber != null) 'phone_number': phoneNumber,
    if (image != null) 'image': image,
  };

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? image,
  }) => UserModel(
    id: id ?? this.id,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    email: email ?? this.email,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    image: image ?? this.image,
  );
}
