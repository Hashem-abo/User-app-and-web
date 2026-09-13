import 'package:suliman/common/enums/data_source_enum.dart';
import 'package:suliman/features/home/domain/models/cashback_model.dart';
import 'package:suliman/features/home/domain/models/homepage_model.dart';
import 'package:suliman/interfaces/repository_interface.dart';

abstract class HomeRepositoryInterface implements RepositoryInterface<CashBackModel> {
  Future<CashBackModel?> getCashBackData(double amount);
  Future<HomepageModel?> getHomepageData({required DataSourceEnum source});
  Future<bool> saveRegistrationSuccessful(bool status);
  Future<bool> saveIsRestaurantRegistration(bool status);
  bool getRegistrationSuccessful();
  bool getIsRestaurantRegistration();
}