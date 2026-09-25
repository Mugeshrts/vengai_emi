class EmiInstallment {
  final String id;
  final String emiAccountId;
  final String customerId;
  final int installmentNumber;
  final double amount;
  final String dueDate; // ISO 8601 string: YYYY-MM-DD
  String status; // 'PAID', 'PENDING', 'DUE SOON', 'DUE TODAY', 'OVERDUE'
  String? paidDate; // ISO 8601 string
  String? paymentMethod; // 'Cash', 'UPI', 'Bank Transfer', 'Other'
  String? transactionId;
  String? notes;

  EmiInstallment({
    required this.id,
    required this.emiAccountId,
    required this.customerId,
    required this.installmentNumber,
    required this.amount,
    required this.dueDate,
    this.status = 'PENDING',
    this.paidDate,
    this.paymentMethod,
    this.transactionId,
    this.notes,
  });

  bool get isPaid => status.toUpperCase() == 'PAID';

  factory EmiInstallment.fromJson(Map<String, dynamic> json) {
    return EmiInstallment(
      id: json['id'] ?? '',
      emiAccountId: json['emiAccountId'] ?? '',
      customerId: json['customerId'] ?? '',
      installmentNumber: (json['installmentNumber'] as num?)?.toInt() ?? 1,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      dueDate: json['dueDate'] ?? '',
      status: json['status'] ?? 'PENDING',
      paidDate: json['paidDate'],
      paymentMethod: json['paymentMethod'],
      transactionId: json['transactionId'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emiAccountId': emiAccountId,
      'customerId': customerId,
      'installmentNumber': installmentNumber,
      'amount': amount,
      'dueDate': dueDate,
      'status': status,
      'paidDate': paidDate,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'notes': notes,
    };
  }

  EmiInstallment copyWith({
    String? id,
    String? emiAccountId,
    String? customerId,
    int? installmentNumber,
    double? amount,
    String? dueDate,
    String? status,
    String? paidDate,
    String? paymentMethod,
    String? transactionId,
    String? notes,
  }) {
    return EmiInstallment(
      id: id ?? this.id,
      emiAccountId: emiAccountId ?? this.emiAccountId,
      customerId: customerId ?? this.customerId,
      installmentNumber: installmentNumber ?? this.installmentNumber,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      paidDate: paidDate ?? this.paidDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      notes: notes ?? this.notes,
    );
  }
}
