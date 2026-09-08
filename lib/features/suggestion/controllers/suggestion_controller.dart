import 'package:get/get.dart';
import 'package:sixam_mart/features/suggestion/domain/models/suggestion_model.dart';
import 'package:sixam_mart/features/suggestion/domain/services/suggestion_service_interface.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/models/response_model.dart';

class SuggestionController extends GetxController implements GetxService {
  final SuggestionServiceInterface suggestionServiceInterface;
  SuggestionController({required this.suggestionServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitLoading = false;
  bool get isSubmitLoading => _isSubmitLoading;

  CustomerSuggestionModel? _suggestionModel;
  CustomerSuggestionModel? get suggestionModel => _suggestionModel;

  Future<void> getUserSuggestions(int offset, {bool reload = false}) async {
    if (reload) {
      _suggestionModel = null;
      update();
    }
    _isLoading = true;
    update();

    CustomerSuggestionModel? suggestionModel = await suggestionServiceInterface.getUserSuggestions(offset);
    if (suggestionModel != null) {
      if (offset == 1) {
        _suggestionModel = suggestionModel;
      } else {
        _suggestionModel!.totalSize = suggestionModel.totalSize;
        _suggestionModel!.offset = suggestionModel.offset;
        _suggestionModel!.suggestions!.addAll(suggestionModel.suggestions!);
      }
    }
    _isLoading = false;
    update();
  }

  Future<bool> submitSuggestion({
    required String title,
    required String description,
    required String category,
    bool isAnonymous = false,
  }) async {
    _isSubmitLoading = true;
    update();

    ResponseModel responseModel = await suggestionServiceInterface.submitSuggestion(
      title: title,
      description: description,
      category: category,
      isAnonymous: isAnonymous,
    );

    _isSubmitLoading = false;
    update();

    if (responseModel.isSuccess) {
      getUserSuggestions(1, reload: true);
      showCustomSnackBar(responseModel.message, isError: false);
      return true;
    } else {
      showCustomSnackBar(responseModel.message);
      return false;
    }
  }

  Future<void> deleteSuggestion(int suggestionId) async {
    _isLoading = true;
    update();

    ResponseModel responseModel = await suggestionServiceInterface.deleteSuggestion(suggestionId);
    if (responseModel.isSuccess) {
      showCustomSnackBar(responseModel.message, isError: false);
      getUserSuggestions(1, reload: true);
    } else {
      _isLoading = false;
      showCustomSnackBar(responseModel.message);
      update();
    }
  }
}
