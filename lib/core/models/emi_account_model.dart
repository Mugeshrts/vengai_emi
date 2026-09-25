class EmiAccount {
  final String id;
  final String customerId;
  final String customerName;
  final String customerMobile;
  final String productName;
  final String category;
  final double productPrice;
  final double downPayment;
  final double interestRate; // e.g. 1% to 50%
  final double interestAmount; // Total interest charged
  final double totalPayable; // Principal + Interest
  double remainingAmount; // Current unpaid balance
  final int emiMonths;
  final double emiAmount;
  final String startDate; // ISO 8601 string
  final String firstDueDate; // ISO 8601 string
  String status; // 'ACTIVE', 'COMPLETED', 'OVERDUE'
  final String createdAt;
  final String? address;
  final String? referenceName;
  final String? notes;

  EmiAccount({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerMobile,
    required this.productName,
    required this.category,
    required this.productPrice,
    required this.downPayment,
    this.interestRate = 0.0,
    this.interestAmount = 0.0,
    double? totalPayable,
    required this.remainingAmount,
    required this.emiMonths,
    required this.emiAmount,
    required this.startDate,
    required this.firstDueDate,
    this.status = 'ACTIVE',
    required this.createdAt,
    this.address,
    this.referenceName,
    this.notes,
  }) : totalPayable = totalPayable ?? (productPrice - downPayment + interestAmount);

  bool get isCompleted => status.toUpperCase() == 'COMPLETED';

  factory EmiAccount.fromJson(Map<String, dynamic> json) {
    final price = (json['productPrice'] as num?)?.toDouble() ?? 0.0;
    final dp = (json['downPayment'] as num?)?.toDouble() ?? 0.0;
    final intRate = (json['interestRate'] as num?)?.toDouble() ?? 0.0;
    final intAmt = (json['interestAmount'] as num?)?.toDouble() ?? 0.0;
    final totPay = (json['totalPayable'] as num?)?.toDouble() ?? (price - dp + intAmt);

    return EmiAccount(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '',
      customerMobile: json['customerMobile'] ?? '',
      productName: json['productName'] ?? '',
      category: json['category'] ?? 'General',
      productPrice: price,
      downPayment: dp,
      interestRate: intRate,
      interestAmount: intAmt,
      totalPayable: totPay,
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble() ?? totPay,
      emiMonths: (json['emiMonths'] as num?)?.toInt() ?? 1,
      emiAmount: (json['emiAmount'] as num?)?.toDouble() ?? 0.0,
      startDate: json['startDate'] ?? '',
      firstDueDate: json['firstDueDate'] ?? '',
      status: json['status'] ?? 'ACTIVE',
      createdAt: json['createdAt'] ?? '',
      address: json['address'],
      referenceName: json['referenceName'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerMobile': customerMobile,
      'productName': productName,
      'category': category,
      'productPrice': productPrice,
      'downPayment': downPayment,
      'interestRate': interestRate,
      'interestAmount': interestAmount,
      'totalPayable': totalPayable,
      'remainingAmount': remainingAmount,
      'emiMonths': emiMonths,
      'emiAmount': emiAmount,
      'startDate': startDate,
      'firstDueDate': firstDueDate,
      'status': status,
      'createdAt': createdAt,
      'address': address,
      'referenceName': referenceName,
      'notes': notes,
    };
  }

  EmiAccount copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerMobile,
    String? productName,
    String? category,
    double? productPrice,
    double? downPayment,
    double? interestRate,
    double? interestAmount,
    double? totalPayable,
    double? remainingAmount,
    int? emiMonths,
    double? emiAmount,
    String? startDate,
    String? firstDueDate,
    String? status,
    String? createdAt,
    String? address,
    String? referenceName,
    String? notes,
  }) {
    return EmiAccount(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerMobile: customerMobile ?? this.customerMobile,
      productName: productName ?? this.productName,
      category: category ?? this.category,
      productPrice: productPrice ?? this.productPrice,
      downPayment: downPayment ?? this.downPayment,
      interestRate: interestRate ?? this.interestRate,
      interestAmount: interestAmount ?? this.interestAmount,
      totalPayable: totalPayable ?? this.totalPayable,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      emiMonths: emiMonths ?? this.emiMonths,
      emiAmount: emiAmount ?? this.emiAmount,
      startDate: startDate ?? this.startDate,
      firstDueDate: firstDueDate ?? this.firstDueDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      address: address ?? this.address,
      referenceName: referenceName ?? this.referenceName,
      notes: notes ?? this.notes,
    );
  }
}
