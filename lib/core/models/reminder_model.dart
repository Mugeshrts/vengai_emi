class ReminderModel {
  final String id;
  final String customerId;
  final String installmentId;
  final String title;
  final String message;
  final String createdAt;
  bool isRead;

  ReminderModel({
    required this.id,
    required this.customerId,
    required this.installmentId,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      installmentId: json['installmentId'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      createdAt: json['createdAt'] ?? '',
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'installmentId': installmentId,
      'title': title,
      'message': message,
      'createdAt': createdAt,
      'isRead': isRead,
    };
  }

  ReminderModel copyWith({
    String? id,
    String? customerId,
    String? installmentId,
    String? title,
    String? message,
    String? createdAt,
    bool? isRead,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      installmentId: installmentId ?? this.installmentId,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
