import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/api/api_client.dart';

abstract class ServiceServiceInterface {
  Future<dynamic> getServices(int offset, int? categoryId, int? providerId, DataSourceEnum source);
  Future<dynamic> getCategories(DataSourceEnum source);
  Future<dynamic> getProviders(DataSourceEnum source);
  Future<dynamic> getServiceDetails(int id);
  Future<dynamic> searchServices(String query, int offset);
  Future<dynamic> placeBooking(Map<String, dynamic> body);
  Future<dynamic> getBookingList(int offset);
  Future<dynamic> getBookingDetails(int bookingId);
  Future<dynamic> cancelBooking(int bookingId);
  Future<dynamic> placeQuotation(Map<String, String> body, List<MultipartBody>? images);
  Future<dynamic> getQuotationList(int offset);
  Future<dynamic> acceptQuotation(int quotationId);
  Future<dynamic> searchProviders(String query, int offset);
  Future<dynamic> submitServiceReview(Map<String, dynamic> body);
}
