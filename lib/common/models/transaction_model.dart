class TransactionModel {
  int? totalSize;
  String? limit;
  String? offset;
  List<Transaction>? data;

  TransactionModel({this.totalSize, this.limit, this.offset, this.data});

  TransactionModel.fromJson(Map<String, dynamic> json) {
    totalSize = json["total_size"];
    limit = json["limit"].toString();
    offset = json["offset"].toString();
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(Transaction.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Transaction {
  int? userId;
  String? transactionId;
  double? credit;
  double? debit;
  double? adminBonus;
  double? balance;
  String? transactionType;
  String? reference;
  DateTime? createdAt;
  DateTime? updatedAt;

  Transaction({
    this.userId,
    this.transactionId,
    this.credit,
    this.debit,
    this.adminBonus,
    this.balance,
    this.transactionType,
    this.reference,
    this.createdAt,
    this.updatedAt,
  });

  Transaction.fromJson(Map<String, dynamic> json) {
    userId = json["user_id"];
    transactionId = json["transaction_id"];
    credit = json["credit"] != null ? double.tryParse(json["credit"].toString()) : 0.0;
    debit = json["debit"] != null ? double.tryParse(json["debit"].toString()) : 0.0;
    if (json["admin_bonus"] != null) {
      adminBonus = double.tryParse(json["admin_bonus"].toString());
    }
    balance = json["balance"] != null ? double.tryParse(json["balance"].toString()) : 0.0;
    transactionType = json["transaction_type"];
    reference = json["reference"];
    createdAt = json["created_at"] != null ? DateTime.tryParse(json["created_at"].toString()) : null;
    updatedAt = json["updated_at"] != null ? DateTime.tryParse(json["updated_at"].toString()) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["user_id"] = userId;
    data["transaction_id"] = transactionId;
    data["credit"] = credit;
    data["debit"] = debit;
    data["admin_bonus"] = adminBonus;
    data["balance"] = balance;
    data["transaction_type"] = transactionType;
    data["reference"] = reference;
    data["created_at"] = createdAt!.toIso8601String();
    data["updated_at"] = updatedAt!.toIso8601String();
    return data;
  }
}
