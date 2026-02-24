import 'package:app_structure/features/auth/domain/user.dart';

/// DTO (Data Transfer Object) - Maps JSON to domain entity
class UserModel {
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

  const UserModel({
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

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'mobileNumber': mobileNumber,
      'address': address,
      'profileImage': profileImage,
      'alternateMobileNumber': alternateMobileNumber,
      'isAlternateMobileNumberVerified': isAlternateMobileNumberVerified,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': version,
      'token': token,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      name: json['name'],
      mobileNumber: json['mobileNumber'],
      address: json['address'],
      profileImage: json['profileImage'],
      alternateMobileNumber: json['alternateMobileNumber'],
      isAlternateMobileNumberVerified: json['isAlternateMobileNumberVerified'],
      isActive: json['isActive'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      version: json['__v'],
      token: json['token'],
    );
  }

  /// Convert DTO to domain entity
  User toEntity() => User(
    id: id,
    name: name,
    mobileNumber: mobileNumber,
    address: address,
    profileImage: profileImage,
    alternateMobileNumber: alternateMobileNumber,
    isAlternateMobileNumberVerified: isAlternateMobileNumberVerified,
    isActive: isActive,
    createdAt: createdAt,
    updatedAt: updatedAt,
    version: version,
    token: token,
  );
}
