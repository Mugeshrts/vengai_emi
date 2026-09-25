class UserModel {
  final String id;
  final String username;
  final String password;
  final String name;
  final String mobile;
  final String role; // 'ADMIN' or 'CUSTOMER'
  final String? customerId;
  final bool isActive;

  UserModel({
    required this.id,
    required this.username,
    required this.password,
    required this.name,
    required this.mobile,
    required this.role,
    this.customerId,
    this.isActive = true,
  });

  bool get isAdmin => role.toUpperCase() == 'ADMIN';
  bool get isCustomer => role.toUpperCase() == 'CUSTOMER';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      role: json['role'] ?? 'CUSTOMER',
      customerId: json['customerId'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'name': name,
      'mobile': mobile,
      'role': role,
      'customerId': customerId,
      'isActive': isActive,
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? password,
    String? name,
    String? mobile,
    String? role,
    String? customerId,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      role: role ?? this.role,
      customerId: customerId ?? this.customerId,
      isActive: isActive ?? this.isActive,
    );
  }
}
