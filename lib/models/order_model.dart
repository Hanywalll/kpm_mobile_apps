import 'package_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final String? packageId;
  final PackageModel? package;
  final String type;
  final String orderNumber;
  final double totalPrice;
  final bool isCustomAmount;
  final String paymentStatus;
  final String? transactionId;
  final String? paymentReference;
  final String? paymentUrl;
  final String? paymentType;
  final String? paymentTime;
  final String? createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    this.packageId,
    this.package,
    this.type = 'package',
    required this.orderNumber,
    required this.totalPrice,
    this.isCustomAmount = false,
    this.paymentStatus = 'pending',
    this.transactionId,
    this.paymentReference,
    this.paymentUrl,
    this.paymentType,
    this.paymentTime,
    this.createdAt,
  });

  bool get isPaid => paymentStatus.toLowerCase() == 'paid';
  bool get isPending => paymentStatus.toLowerCase() == 'pending';
  bool get isSuccess => isPaid || paymentStatus.toLowerCase() == 'settlement' || paymentStatus.toLowerCase() == 'success';
  bool get isExpired => paymentStatus.toLowerCase() == 'expire' || paymentStatus.toLowerCase() == 'expired' || paymentStatus.toLowerCase() == 'cancel';
  String get status => paymentStatus;
  String get packageTitle => package?.title ?? 'Paket Belajar KPM';
  double get amount => totalPrice;
  String get paymentMethod => paymentType ?? 'Midtrans Payment';
  String? get snapRedirectUrl => paymentUrl;
  DateTime get createdDateTime => createdAt != null ? (DateTime.tryParse(createdAt!) ?? DateTime.now()) : DateTime.now();

  String get statusFormatted {
    switch (paymentStatus.toLowerCase()) {
      case 'paid':
      case 'settlement':
      case 'success':
        return 'BERHASIL';
      case 'pending':
        return 'MENUNGGU';
      case 'expire':
      case 'expired':
        return 'KEDALUWARSA';
      case 'cancel':
      case 'failed':
        return 'GAGAL';
      default:
        return paymentStatus.toUpperCase();
    }
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      packageId: json['package_id']?.toString() ?? json['packageId']?.toString(),
      package: json['package'] != null ? PackageModel.fromJson(json['package']) : null,
      type: json['type']?.toString() ?? 'package',
      orderNumber: json['order_number']?.toString() ?? json['orderNumber']?.toString() ?? '',
      totalPrice: (json['total_price'] as num?)?.toDouble() ??
          (json['totalPrice'] as num?)?.toDouble() ??
          0.0,
      isCustomAmount: json['is_custom_amount'] == true,
      paymentStatus: json['payment_status']?.toString() ?? json['paymentStatus']?.toString() ?? 'pending',
      transactionId: json['transaction_id']?.toString(),
      paymentReference: json['payment_reference']?.toString(),
      paymentUrl: json['payment_url']?.toString(),
      paymentType: json['payment_type']?.toString(),
      paymentTime: json['payment_time']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'package_id': packageId,
      'type': type,
      'order_number': orderNumber,
      'total_price': totalPrice,
      'is_custom_amount': isCustomAmount,
      'payment_status': paymentStatus,
      'transaction_id': transactionId,
      'payment_reference': paymentReference,
      'payment_url': paymentUrl,
      'payment_type': paymentType,
      'payment_time': paymentTime,
      'created_at': createdAt,
    };
  }
}
