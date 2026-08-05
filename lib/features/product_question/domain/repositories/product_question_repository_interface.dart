import 'package:sixam_mart/interfaces/repository_interface.dart';

abstract class ProductQuestionRepositoryInterface extends RepositoryInterface {
  @override
  Future<dynamic> getList({int? offset, int? itemID});
  Future<dynamic> submitQuestion(int itemID, String question, {bool isAnonymous = false});
  Future<dynamic> getUserQuestions({int? offset});
  Future<dynamic> likeQuestion(int questionID);
  Future<dynamic> unlikeQuestion(int questionID);
  // Future<dynamic> replyQuestion(int questionID, String reply); // If user can reply? Usually needed for vendor.
}
