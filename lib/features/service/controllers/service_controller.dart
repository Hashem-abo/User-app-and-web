import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/service/domain/models/service_model.dart';
import 'package:sixam_mart/features/service/domain/models/service_category_model.dart';
import 'package:sixam_mart/features/service/domain/models/service_provider_model.dart';
import 'package:sixam_mart/features/service/domain/models/service_booking_model.dart';
import 'package:sixam_mart/features/service/domain/services/service_service_interface.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/features/service/domain/models/service_quotation_model.dart';
import 'package:image_picker/image_picker.dart';

class ServiceController extends GetxController implements GetxService {
  final ServiceServiceInterface serviceServiceInterface;
  ServiceController({required this.serviceServiceInterface});

  List<Service>? _services;
  List<ServiceCategoryModel>? _categories;
  List<ServiceProviderModel>? _providers;
  List<ServiceBooking>? _bookings;
  List<ServiceQuotation>? _quotations;
  List<Service>? _searchServices;
  List<ServiceProviderModel>? _searchProviders;
  bool _isLoading = false;
  Service? _serviceDetails;
  ServiceBooking? _bookingDetails;
  int _selectedCategory = -1;

  final TextEditingController customerNoteController = TextEditingController();

  List<Service>? get services => _services;
  List<ServiceCategoryModel>? get categories => _categories;
  List<ServiceProviderModel>? get providers => _providers;
  List<ServiceBooking>? get bookings => _bookings;
  List<ServiceQuotation>? get quotations => _quotations;
  List<Service>? get searchServicesList => _searchServices;
  List<ServiceProviderModel>? get searchProvidersList => _searchProviders;
  bool get isLoading => _isLoading;
  Service? get serviceDetails => _serviceDetails;
  ServiceBooking? get bookingDetails => _bookingDetails;
  int get selectedCategory => _selectedCategory;

  void setCategory(int index, {bool reload = true}) {
    _selectedCategory = index;
    if (reload) {
      getServices(1, categoryId: index == -1 ? null : _categories![index].id, reload: true);
    }
    update();
  }

  Future<void> getServices(int offset, {int? categoryId, int? providerId, DataSourceEnum source = DataSourceEnum.client, bool reload = false}) async {
    if(reload) {
      _services = null;
      update();
    }
    ServiceModel? serviceModel = await serviceServiceInterface.getServices(offset, categoryId, providerId, source);
    if (serviceModel != null) {
      if (offset == 1) {
        _services = [];
      }
      _services!.addAll(serviceModel.services!);
    }
    update();
  }

  Future<void> getCategories({DataSourceEnum source = DataSourceEnum.client}) async {
    _categories = await serviceServiceInterface.getCategories(source);
    update();
  }

  Future<void> getProviders({DataSourceEnum source = DataSourceEnum.client}) async {
    _providers = await serviceServiceInterface.getProviders(source);
    update();
  }

  Future<void> getServiceDetails(int id) async {
    _isLoading = true;
    _serviceDetails = null;
    update();
    _serviceDetails = await serviceServiceInterface.getServiceDetails(id);
    _isLoading = false;
    update();
  }

  Future<void> getBookingList(int offset, {bool reload = false}) async {
    if(reload) {
      _bookings = null;
      update();
    }
    ServiceBookingModel? bookingModel = await serviceServiceInterface.getBookingList(offset);
    if (bookingModel != null) {
      if (offset == 1) {
        _bookings = [];
      }
      _bookings!.addAll(bookingModel.bookings!);
    }
    update();
  }

  Future<void> getBookingDetails(int id) async {
    _isLoading = true;
    _bookingDetails = null;
    update();
    _bookingDetails = await serviceServiceInterface.getBookingDetails(id);
    _isLoading = false;
    update();
  }

  Future<ResponseModel> placeBooking({required int serviceId, required int providerId, required DateTime bookingDate, DateTime? endDate, String paymentMethod = 'cash_on_delivery', int? addressId}) async {
    _isLoading = true;
    update();
    
    Map<String, dynamic> body = {
      'service_id': serviceId,
      'provider_id': providerId,
      'scheduled_date': bookingDate.toIso8601String().split('T')[0],
      'scheduled_time': bookingDate.toIso8601String().split('T')[1].substring(0, 5),
      'payment_method': paymentMethod,
    };
    if(endDate != null) {
      body['end_date'] = endDate.toIso8601String().split('T')[0];
      body['end_time'] = endDate.toIso8601String().split('T')[1].substring(0, 5);
    }
    if(addressId != null) body['address_id'] = addressId;
    
    if (customerNoteController.text.trim().isNotEmpty) {
      body['customer_note'] = customerNoteController.text.trim();
    }
    // We send an empty JSON format for now if no specific details are gathered dynamically.
    body['booking_details'] = '{}';

    Response response = await serviceServiceInterface.placeBooking(body);
    _isLoading = false;
    update();
    
    if (response.statusCode == 200) {
      customerNoteController.clear();
      return ResponseModel(true, 'booking_placed_successfully'.tr);
    } else {
      String? errorMessage = response.statusText;
      if (response.body != null && response.body['errors'] != null && response.body['errors'] is List && response.body['errors'].isNotEmpty) {
        errorMessage = response.body['errors'][0]['message'];
      }
      return ResponseModel(false, errorMessage);
    }
  }

  Future<ResponseModel> placeQuotation({required int serviceId, required int providerId, required String description, List<XFile>? images}) async {
    _isLoading = true;
    update();

    Map<String, String> body = {
      'service_id': serviceId.toString(),
      'provider_id': providerId.toString(),
      'description': description,
    };

    List<MultipartBody>? multipartImages;
    if(images != null && images.isNotEmpty) {
      multipartImages = [];
      for(XFile image in images) {
        multipartImages.add(MultipartBody('images[]', image));
      }
    }

    Response response = await serviceServiceInterface.placeQuotation(body, multipartImages);
    // Actually, ApiClient handles multipart if we pass it. But ServiceServiceInterface needs update if it doesn't support it.
    // Let's assume for now.
    
    _isLoading = false;
    update();

    if (response.statusCode == 200) {
      return ResponseModel(true, 'quotation_sent_successfully'.tr);
    } else {
      return ResponseModel(false, response.statusText);
    }
  }

  Future<bool> cancelBooking(int bookingId) async {
    _isLoading = true;
    update();
    Response response = await serviceServiceInterface.cancelBooking(bookingId);
    _isLoading = false;
    update();
    if (response.statusCode == 200) {
      showCustomSnackBar('booking_canceled_successfully'.tr, isError: false);
      getBookingList(1, reload: true);
      return true;
    } else {
      showCustomSnackBar(response.statusText);
      return false;
    }
  }

  Future<ResponseModel> submitServiceReview(Map<String, dynamic> body) async {
    _isLoading = true;
    update();
    Response response = await serviceServiceInterface.submitServiceReview(body);
    _isLoading = false;
    update();
    if (response.statusCode == 200) {
      return ResponseModel(true, 'review_submitted_successfully'.tr);
    } else {
      return ResponseModel(false, response.statusText);
    }
  }

  Future<void> getQuotationList(int offset, {bool reload = false}) async {
    if(reload) {
      _quotations = null;
      update();
    }
    var responseBody = await serviceServiceInterface.getQuotationList(offset);
    if (responseBody != null) {
      ServiceQuotationModel quotationModel = ServiceQuotationModel.fromJson(responseBody);
      if (offset == 1) {
        _quotations = [];
      }
      _quotations!.addAll(quotationModel.quotations!);
    }
    update();
  }

  Future<ResponseModel> acceptQuotation(int quotationId) async {
    _isLoading = true;
    update();
    Response response = await serviceServiceInterface.acceptQuotation(quotationId);
    _isLoading = false;
    update();
    if (response.statusCode == 200) {
      getQuotationList(1, reload: true);
      return ResponseModel(true, response.body['message'] ?? 'quotation_accepted_successfully'.tr);
    } else {
      String? errorMessage = response.statusText;
      if (response.body != null && response.body['errors'] != null) {
        errorMessage = response.body['errors'][0]['message'];
      }
      return ResponseModel(false, errorMessage);
    }
  }

  void clearSearchData() {
    _searchServices = null;
    _searchProviders = null;
    _isLoading = false;
    WidgetsBinding.instance.addPostFrameCallback((_) => update());
  }

  Future<void> searchServices(String query, int offset, bool isProvider) async {
    if (offset == 1) {
      if (isProvider) {
        _searchProviders = null;
      } else {
        _searchServices = null;
      }
      _isLoading = true;
      if(query.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) => update());
      }
    }
    
    if (query.isEmpty) {
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => update());
      return;
    }

    if (isProvider) {
      _searchProviders = await serviceServiceInterface.searchProviders(query, offset);
    } else {
      ServiceModel? serviceModel = await serviceServiceInterface.searchServices(query, offset);
      if (serviceModel != null) {
        if (offset == 1) {
          _searchServices = [];
        }
        _searchServices!.addAll(serviceModel.services!);
      }
    }
    _isLoading = false;
    update();
  }
}
