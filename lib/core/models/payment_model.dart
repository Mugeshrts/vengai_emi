class PaymentModel {
  final String id;
  final String emiAccountId;
  final String installmentId;
  final String customerId;
  final String customerName;
  final int installmentNumber;
  final double amount;
  final String paymentDate; // ISO 8601 string
  final String paymentMethod; // 'Cash', 'UPI', 'Bank Transfer', 'Other'
  final String transactionId;
  final String status; // 'Paid', 'Pending'
  final String? notes;

  PaymentModel({
    required this.id,
    required this.emiAccountId,
    required this.installmentId,
    required this.customerId,
    required this.customerName,
    required this.installmentNumber,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    required this.transactionId,
    this.status = 'Paid',
    this.notes,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      emiAccountId: json['emiAccountId'] ?? '',
      installmentId: json['installmentId'] ?? '',
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '',
      installmentNumber: (json['installmentNumber'] as num?)?.toInt() ?? 1,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentDate: json['paymentDate'] ?? '',
      paymentMethod: json['paymentMethod'] ?? 'UPI',
      transactionId: json['transactionId'] ?? '',
      status: json['status'] ?? 'Paid',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emiAccountId': emiAccountId,
      'installmentId': installmentId,
      'customerId': customerId,
      'customerName': customerName,
      'installmentNumber': installmentNumber,
      'amount': amount,
      'paymentDate': paymentDate,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'status': status,
      'notes': notes,
    };
  }
}
