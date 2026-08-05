import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/api/local_client.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/home/domain/models/cashback_model.dart';
import 'package:sixam_mart/features/home/domain/models/homepage_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'home_repository_interface.dart';

class HomeRepository implements HomeRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  HomeRepository({required this.sharedPreferences, required this.apiClient});

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future<List<CashBackModel>> getList({int? offset}) async {
    List<CashBackModel> cashBackModelList = [];
    Response response = await apiClient.getData(AppConstants.cashBackOfferListUri);
    if(response.statusCode == 200) {
      response.body.forEach((data) {
        cashBackModelList.add(CashBackModel.fromJson(data));
      });
    }
     return cashBackModelList;
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

  @override
  Future<CashBackModel?> getCashBackData(double amount) async {
    CashBackModel? cashBackModel;
    Response response = await apiClient.getData('${AppConstants.getCashBackAmountUri}?amount=$amount');
    if(response.statusCode == 200) {
      cashBackModel = CashBackModel.fromJson(response.body);
    }
    return cashBackModel;
  }

  @override
  Future<bool> saveRegistrationSuccessful(bool status) async {
    return await sharedPreferences.setBool(AppConstants.dmRegisterSuccess, status);
  }

  @override
  Future<bool> saveIsRestaurantRegistration(bool status) async {
    return await sharedPreferences.setBool(AppConstants.isRestaurantRegister, status);
  }

  @override
  bool getRegistrationSuccessful() {
    return sharedPreferences.getBool(AppConstants.dmRegisterSuccess) ?? false;
  }

  @override
  bool getIsRestaurantRegistration() {
    return sharedPreferences.getBool(AppConstants.isRestaurantRegister) ?? false;
  }

  @override
  Future<HomepageModel?> getHomepageData({required DataSourceEnum source}) async {
    HomepageModel? homepageModel;
    int homepageCacheVersion = Get.find<SplashController>().configModel?.homepageCacheVersion ?? 1;
    int? moduleId = Get.find<SplashController>().module?.id;
    String cacheId = '${AppConstants.homepageUri}-${moduleId ?? 'default'}-$homepageCacheVersion';

    switch(source) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData(AppConstants.homepageUri);
        if(response.statusCode == 200) {
          homepageModel = HomepageModel.fromJson(response.body);
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body), apiClient.getHeader());
        }
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          homepageModel = HomepageModel.fromJson(jsonDecode(cacheResponseData));
        }
    }
    return homepageModel;
  }

}
