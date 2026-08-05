class ReviewBodyModel {
  String? _reviewId;
  String? _productId;
  String? _deliveryManId;
  String? _comment;
  String? _rating;
  List<String>? _fileUpload;
  String? _orderId;
  bool? _isAnonymous;

  ReviewBodyModel(
      {String? reviewId,
        String? productId,
        String? deliveryManId,
        String? comment,
        String? rating,
        String? orderId,
        bool? isAnonymous,
        List<String>? fileUpload}) {
    _reviewId = reviewId;
    _productId = productId;
    _deliveryManId = deliveryManId;
    _comment = comment;
    _rating = rating;
    _orderId = orderId;
    _isAnonymous = isAnonymous;
    _fileUpload = fileUpload;
  }

  String? get reviewId => _reviewId;
  String? get productId => _productId;
  String? get deliveryManId => _deliveryManId;
  String? get comment => _comment;
  String? get orderId => _orderId;
  String? get rating => _rating;
  bool? get isAnonymous => _isAnonymous;
  List<String>? get fileUpload => _fileUpload;

  ReviewBodyModel.fromJson(Map<String, dynamic> json) {
    _reviewId = json['review_id'];
    _productId = json['item_id'];
    _deliveryManId = json['delivery_man_id'];
    _comment = json['comment'];
    _orderId = json['order_id'];
    _rating = json['rating'];
    _isAnonymous = json['is_anonymous'] == 1 || json['is_anonymous'] == true;
    if(json['attachment'] != null) {
      _fileUpload = json['attachment'].cast<String>();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['review_id'] = _reviewId;
    data['item_id'] = _productId;
    data['delivery_man_id'] = _deliveryManId;
    data['comment'] = _comment;
    data['order_id'] = _orderId;
    data['rating'] = _rating;
    data['attachment'] = _fileUpload;
    data['is_anonymous'] = (_isAnonymous ?? false) ? '1' : '0';
    return data;
  }
}
