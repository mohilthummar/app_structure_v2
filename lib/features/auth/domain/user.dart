/// Domain entity - Pure business object (no JSON, no Flutter)
class User {
  final String? id;
  final String? name;
  final String? mobileNumber;
  final String? address;
  final String? profileImage;
  final String? alternateMobileNumber;
  final bool? isAlternateMobileNumberVerified;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? version;
  final String? token;

  const User({
    this.id,
    this.name,
    this.mobileNumber,
    this.address,
    this.profileImage,
    this.alternateMobileNumber,
    this.isAlternateMobileNumberVerified,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.version,
    this.token,
  });
}
