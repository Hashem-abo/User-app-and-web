import 'dart:convert';
import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/api/local_client.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/service/domain/models/service_model.dart';
import 'package:sixam_mart/features/service/domain/models/service_category_model.dart';
import 'package:sixam_mart/features/service/domain/models/service_provider_model.dart';
import 'package:sixam_mart/features/service/domain/models/service_booking_model.dart';
import 'package:sixam_mart/features/service/domain/repositories/service_repository_interface.dart';
import 'package:sixam_mart/util/app_constants.dart';

class ServiceRepository implements ServiceRepositoryInterface {
  final ApiClient apiClient;
  ServiceRepository({required this.apiClient});

  @override
  Future<ServiceModel?> getServices(int offset, int? categoryId, int? providerId, DataSourceEnum source) async {
    ServiceModel? serviceModel;
    String uri = '${AppConstants.servicesListUri}?limit=10&offset=$offset';
    if(categoryId != null) uri += '&category_id=$categoryId';
    if(providerId != null) uri += '&provider_id=$providerId';
    
    String cacheId = uri;

    switch(source) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData(uri);
        if (response.statusCode == 200) {
          serviceModel = ServiceModel.fromJson(response.body);
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body), apiClient.getHeader());
        }
        break;
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          serviceModel = ServiceModel.fromJson(jsonDecode(cacheResponseData));
        }
        break;
    }
    return serviceModel;
  }

  @override
  Future<List<ServiceCategoryModel>?> getCategories(DataSourceEnum source) async {
    List<ServiceCategoryModel>? categoryList;
    String uri = AppConstants.servicesCategoriesUri;
    String cacheId = uri;

    switch(source) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData(uri);
        if (response.statusCode == 200) {
          categoryList = [];
          response.body.forEach((v) => categoryList!.add(ServiceCategoryModel.fromJson(v)));
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body), apiClient.getHeader());
        }
        break;
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          categoryList = [];
          jsonDecode(cacheResponseData).forEach((v) => categoryList!.add(ServiceCategoryModel.fromJson(v)));
        }
        break;
    }
    return categoryList;
  }

  @override
  Future<List<ServiceProviderModel>?> getProviders(DataSourceEnum source) async {
    List<ServiceProviderModel>? providerList;
    String uri = AppConstants.servicesProvidersUri;
    String cacheId = uri;

    switch(source) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData(uri);
        if (response.statusCode == 200) {
          providerList = [];
          response.body.forEach((v) => providerList!.add(ServiceProviderModel.fromJson(v)));
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body), apiClient.getHeader());
        }
        break;
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          providerList = [];
          jsonDecode(cacheResponseData).forEach((v) => providerList!.add(ServiceProviderModel.fromJson(v)));
        }
        break;
    }
    return providerList;
  }

  @override
  Future<Service?> getServiceDetails(int id) async {
    Response response = await apiClient.getData('${AppConstants.servicesDetailsUri}$id');
    if (response.statusCode == 200) {
      return Service.fromJson(response.body);
    }
    return null;
  }

  @override
  Future<ServiceModel?> searchServices(String query, int offset) async {
    Response response = await apiClient.getData('${AppConstants.servicesSearchUri}?name=$query&offset=$offset&limit=10');
    if (response.statusCode == 200) {
      return ServiceModel.fromJson(response.body);
    }
    return null;
  }

  @override
  Future<List<ServiceProviderModel>?> searchProviders(String query, int offset) async {
    Response response = await apiClient.getData('${AppConstants.servicesProvidersSearchUri}?name=$query&offset=$offset&limit=10');
    if (response.statusCode == 200) {
      List<ServiceProviderModel> providerList = [];
      response.body.forEach((v) => providerList.add(ServiceProviderModel.fromJson(v)));
      return providerList;
    }
    return null;
  }

  @override
  Future<Response> placeBooking(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.serviceBookingPlaceUri, body);
  }

  @override
  Future<ServiceBookingModel?> getBookingList(int offset) async {
    Response response = await apiClient.getData('${AppConstants.serviceBookingListUri}?offset=$offset&limit=10');
    if (response.statusCode == 200) {
      return ServiceBookingModel.fromJson(response.body);
    }
    return null;
  }

  @override
  Future<ServiceBooking?> getBookingDetails(int bookingId) async {
    Response response = await apiClient.getData('${AppConstants.serviceBookingDetailsUri}?booking_id=$bookingId');
    if (response.statusCode == 200) {
      return ServiceBooking.fromJson(response.body);
    }
    return null;
  }

  @override
  Future<Response> cancelBooking(int bookingId) async {
    return await apiClient.putData(AppConstants.serviceBookingCancelUri, {'booking_id': bookingId});
  }

  @override
  Future<Response> placeQuotation(Map<String, String> body, List<MultipartBody>? images) async {
    return await apiClient.postMultipartData(AppConstants.serviceQuotationPlaceUri, body, images ?? []);
  }

  @override
  Future<dynamic> getQuotationList(int offset) async {
    Response response = await apiClient.getData('${AppConstants.serviceQuotationListUri}?offset=$offset&limit=10');
    if (response.statusCode == 200) {
      return response.body; 
    }
    return null;
  }

  @override
  Future<Response> acceptQuotation(int quotationId) async {
    return await apiClient.postData(AppConstants.serviceQuotationAcceptUri, {'id': quotationId});
  }

  @override
  Future<Response> submitServiceReview(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.serviceReviewSubmitUri, body);
  }

  @override
  Future add(value) => throw UnimplementedError();

  @override
  Future delete(int? id) => throw UnimplementedError();

  @override
  Future get(String? id) => throw UnimplementedError();

  @override
  Future getList({int? offset}) => throw UnimplementedError();

  @override
  Future update(Map<String, dynamic> body, int? id) => throw UnimplementedError();
}
