import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/service/domain/models/service_model.dart';
import 'package:sixam_mart/features/service/domain/models/service_category_model.dart';
import 'package:sixam_mart/features/service/domain/models/service_provider_model.dart';
import 'package:sixam_mart/features/service/domain/models/service_booking_model.dart';
import 'package:sixam_mart/features/service/domain/repositories/service_repository_interface.dart';
import 'package:sixam_mart/features/service/domain/services/service_service_interface.dart';

class ServiceService implements ServiceServiceInterface {
  final ServiceRepositoryInterface serviceRepositoryInterface;
  ServiceService({required this.serviceRepositoryInterface});

  @override
  Future<ServiceModel?> getServices(int offset, int? categoryId, int? providerId, DataSourceEnum source) async {
    return await serviceRepositoryInterface.getServices(offset, categoryId, providerId, source);
  }

  @override
  Future<List<ServiceCategoryModel>?> getCategories(DataSourceEnum source) async {
    return await serviceRepositoryInterface.getCategories(source);
  }

  @override
  Future<List<ServiceProviderModel>?> getProviders(DataSourceEnum source) async {
    return await serviceRepositoryInterface.getProviders(source);
  }

  @override
  Future<Service?> getServiceDetails(int id) async {
    return await serviceRepositoryInterface.getServiceDetails(id);
  }

  @override
  Future<ServiceModel?> searchServices(String query, int offset) async {
    return await serviceRepositoryInterface.searchServices(query, offset);
  }

  @override
  Future<dynamic> placeBooking(Map<String, dynamic> body) async {
    return await serviceRepositoryInterface.placeBooking(body);
  }

  @override
  Future<ServiceBookingModel?> getBookingList(int offset) async {
    return await serviceRepositoryInterface.getBookingList(offset);
  }

  @override
  Future<ServiceBooking?> getBookingDetails(int bookingId) async {
    return await serviceRepositoryInterface.getBookingDetails(bookingId);
  }

  @override
  Future<dynamic> cancelBooking(int bookingId) async {
    return await serviceRepositoryInterface.cancelBooking(bookingId);
  }

  @override
  Future<dynamic> placeQuotation(Map<String, String> body, List<MultipartBody>? images) async {
    return await serviceRepositoryInterface.placeQuotation(body, images);
  }

  @override
  Future<dynamic> getQuotationList(int offset) async {
    return await serviceRepositoryInterface.getQuotationList(offset);
  }

  @override
  Future<dynamic> acceptQuotation(int quotationId) async {
    return await serviceRepositoryInterface.acceptQuotation(quotationId);
  }

  @override
  Future<List<ServiceProviderModel>?> searchProviders(String query, int offset) async {
    return await serviceRepositoryInterface.searchProviders(query, offset);
  }

  @override
  Future<dynamic> submitServiceReview(Map<String, dynamic> body) async {
    return await serviceRepositoryInterface.submitServiceReview(body);
  }
}
