class ChitMember {
  final String customerId;
  final String customerName;
  final String customerMobile;
  final int ticketNumber;
  final String enrolledDate;
  int monthsPaid;
  double totalContributed;
  String status; // 'ACTIVE', 'MATURED'

  ChitMember({
    required this.customerId,
    required this.customerName,
    required this.customerMobile,
    required this.ticketNumber,
    required this.enrolledDate,
    this.monthsPaid = 0,
    this.totalContributed = 0.0,
    this.status = 'ACTIVE',
  });

  factory ChitMember.fromJson(Map<String, dynamic> json) {
    return ChitMember(
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '',
      customerMobile: json['customerMobile'] ?? '',
      ticketNumber: (json['ticketNumber'] as num?)?.toInt() ?? 1,
      enrolledDate: json['enrolledDate'] ?? '',
      monthsPaid: (json['monthsPaid'] as num?)?.toInt() ?? 0,
      totalContributed: (json['totalContributed'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerMobile': customerMobile,
      'ticketNumber': ticketNumber,
      'enrolledDate': enrolledDate,
      'monthsPaid': monthsPaid,
      'totalContributed': totalContributed,
      'status': status,
    };
  }
}

class ChitFund {
  final String id;
  final String schemeName;
  final String category; // e.g. Gold Scheme, Cash Savings, Festival Chit, Product Scheme
  final double totalValue;
  final double monthlyContribution;
  final int durationMonths;
  final int maxMembers;
  final double bonusAmount;
  final String bonusDescription;
  final String startDate;
  String status; // 'ACTIVE', 'COMPLETED'
  final String createdAt;
  final List<ChitMember> members;
  final String? notes;

  ChitFund({
    required this.id,
    required this.schemeName,
    required this.category,
    required this.totalValue,
    required this.monthlyContribution,
    required this.durationMonths,
    required this.maxMembers,
    this.bonusAmount = 0.0,
    this.bonusDescription = '',
    required this.startDate,
    this.status = 'ACTIVE',
    required this.createdAt,
    required this.members,
    this.notes,
  });

  bool get isCompleted => status.toUpperCase() == 'COMPLETED';

  double get totalCollected =>
      members.fold(0.0, (sum, m) => sum + m.totalContributed);

  double get expectedTotalCollection =>
      monthlyContribution * durationMonths * members.length;

  double get collectionProgress {
    if (expectedTotalCollection <= 0) return 0.0;
    return (totalCollected / expectedTotalCollection).clamp(0.0, 1.0);
  }

  factory ChitFund.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['members'] as List? ?? [];
    return ChitFund(
      id: json['id'] ?? '',
      schemeName: json['schemeName'] ?? '',
      category: json['category'] ?? 'General',
      totalValue: (json['totalValue'] as num?)?.toDouble() ?? 0.0,
      monthlyContribution: (json['monthlyContribution'] as num?)?.toDouble() ?? 0.0,
      durationMonths: (json['durationMonths'] as num?)?.toInt() ?? 10,
      maxMembers: (json['maxMembers'] as num?)?.toInt() ?? 10,
      bonusAmount: (json['bonusAmount'] as num?)?.toDouble() ?? 0.0,
      bonusDescription: json['bonusDescription'] ?? '',
      startDate: json['startDate'] ?? '',
      status: json['status'] ?? 'ACTIVE',
      createdAt: json['createdAt'] ?? '',
      members: rawMembers.map((m) => ChitMember.fromJson(Map<String, dynamic>.from(m))).toList(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schemeName': schemeName,
      'category': category,
      'totalValue': totalValue,
      'monthlyContribution': monthlyContribution,
      'durationMonths': durationMonths,
      'maxMembers': maxMembers,
      'bonusAmount': bonusAmount,
      'bonusDescription': bonusDescription,
      'startDate': startDate,
      'status': status,
      'createdAt': createdAt,
      'members': members.map((m) => m.toJson()).toList(),
      'notes': notes,
    };
  }

  ChitFund copyWith({
    String? id,
    String? schemeName,
    String? category,
    double? totalValue,
    double? monthlyContribution,
    int? durationMonths,
    int? maxMembers,
    double? bonusAmount,
    String? bonusDescription,
    String? startDate,
    String? status,
    String? createdAt,
    List<ChitMember>? members,
    String? notes,
  }) {
    return ChitFund(
      id: id ?? this.id,
      schemeName: schemeName ?? this.schemeName,
      category: category ?? this.category,
      totalValue: totalValue ?? this.totalValue,
      monthlyContribution: monthlyContribution ?? this.monthlyContribution,
      durationMonths: durationMonths ?? this.durationMonths,
      maxMembers: maxMembers ?? this.maxMembers,
      bonusAmount: bonusAmount ?? this.bonusAmount,
      bonusDescription: bonusDescription ?? this.bonusDescription,
      startDate: startDate ?? this.startDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      members: members ?? this.members,
      notes: notes ?? this.notes,
    );
  }
}

class ChitPayment {
  final String id;
  final String chitFundId;
  final String schemeName;
  final String customerId;
  final String customerName;
  final int monthNumber;
  final double amount;
  final String paymentDate;
  final String paymentMethod;
  final String transactionId;
  final String? notes;

  ChitPayment({
    required this.id,
    required this.chitFundId,
    required this.schemeName,
    required this.customerId,
    required this.customerName,
    required this.monthNumber,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    required this.transactionId,
    this.notes,
  });

  factory ChitPayment.fromJson(Map<String, dynamic> json) {
    return ChitPayment(
      id: json['id'] ?? '',
      chitFundId: json['chitFundId'] ?? '',
      schemeName: json['schemeName'] ?? '',
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '',
      monthNumber: (json['monthNumber'] as num?)?.toInt() ?? 1,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentDate: json['paymentDate'] ?? '',
      paymentMethod: json['paymentMethod'] ?? 'UPI',
      transactionId: json['transactionId'] ?? '',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chitFundId': chitFundId,
      'schemeName': schemeName,
      'customerId': customerId,
      'customerName': customerName,
      'monthNumber': monthNumber,
      'amount': amount,
      'paymentDate': paymentDate,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'notes': notes,
    };
  }
}
