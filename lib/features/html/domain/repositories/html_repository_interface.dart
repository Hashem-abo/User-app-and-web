import 'package:suliman/interfaces/repository_interface.dart';
import 'package:suliman/util/html_type.dart';

abstract class HtmlRepositoryInterface extends RepositoryInterface {
  Future<dynamic> getHtmlText(HtmlType htmlType);
}