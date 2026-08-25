import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:path/path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:http_parser/http_parser.dart';
import 'package:sixam_mart/api/api_checker.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/common/models/error_response.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiClient extends GetxService {
  final String appBaseUrl;
  final SharedPreferences sharedPreferences;
  static final String noInternetMessage = 'connection_to_api_server_failed'.tr;
  final int timeoutInSeconds = 40;

  String? token;
  late Map<String, String> _mainHeaders;

  ApiClient({required this.appBaseUrl, required this.sharedPreferences}) {
    token = sharedPreferences.getString(AppConstants.token);
    if (kDebugMode) {
      print('Token: $token');
    }
    AddressModel? addressModel;
    try {
      addressModel = AddressModel.fromJson(jsonDecode(sharedPreferences.getString(AppConstants.userAddress)!));
    }catch(_) {}
    int? moduleID;
    if(GetPlatform.isWeb && sharedPreferences.containsKey(AppConstants.moduleId)) {
      try {
        moduleID = ModuleModel.fromJson(jsonDecode(sharedPreferences.getString(AppConstants.moduleId)!)).id;
      }catch(_) {}
    }
    updateHeader(
      token, addressModel?.zoneIds, addressModel?.areaIds,
      sharedPreferences.getString(AppConstants.languageCode), moduleID, addressModel?.latitude,
        addressModel?.longitude
    );
  }

  Map<String, String> updateHeader(String? token, List<int>? zoneIDs, List<int>? operationIds, String? languageCode, int? moduleID, String? latitude, String? longitude, {bool setHeader = true}) {
    Map<String, String> header = {};

    AddressModel? userAddress = AddressHelper.getUserAddressFromSharedPref();
    if (userAddress != null && (userAddress.house == 'manual' || userAddress.latitude == '0' || (userAddress.address != null && userAddress.address!.contains('\u200b\u200b\u200b')))) {
      latitude = '0';
      longitude = '0';
    }
    if ((zoneIDs == null || zoneIDs.isEmpty) && userAddress != null) {
      if (userAddress.zoneIds != null && userAddress.zoneIds!.isNotEmpty) {
        zoneIDs = userAddress.zoneIds;
      } else if (userAddress.zoneId != null) {
        zoneIDs = [userAddress.zoneId!];
      }
    }
    if ((zoneIDs == null || zoneIDs.isEmpty) && userAddress?.zoneId != null) {
      zoneIDs = [userAddress!.zoneId!];
    }
    if (zoneIDs == null || zoneIDs.isEmpty) {
      zoneIDs = [1];
    }

    if(moduleID != null || sharedPreferences.getString(AppConstants.cacheModuleId) != null) {
      header.addAll({AppConstants.moduleId: '${moduleID ?? ModuleModel.fromJson(jsonDecode(sharedPreferences.getString(AppConstants.cacheModuleId)!)).id}'});
    }
    String cleanCoord(String? input, String fallback) {
      if (input == null || input.isEmpty || input == '0' || input == 'null') return fallback;
      String clean = input.replaceAll('"', '').replaceAll("'", '').trim();
      double? val = double.tryParse(clean);
      return (val == null || val == 0) ? fallback : clean;
    }

    String validLat = cleanCoord(latitude, userAddress?.latitude != null ? userAddress!.latitude! : '15.369445');
    String validLng = cleanCoord(longitude, userAddress?.longitude != null ? userAddress!.longitude! : '44.191006');

    header.addAll({
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      AppConstants.zoneId: jsonEncode(zoneIDs),
      AppConstants.localizationKey: languageCode ?? AppConstants.languages[0].languageCode!,
      AppConstants.latitude: validLat,
      AppConstants.longitude: validLng,
      'Authorization': 'Bearer $token'
    });
    if (!header.containsKey(AppConstants.zoneId) || header[AppConstants.zoneId] == null || header[AppConstants.zoneId]!.isEmpty || header[AppConstants.zoneId] == '[]') {
      header[AppConstants.zoneId] = jsonEncode([1]);
    }
    if(setHeader) {
      _mainHeaders = header;
    }
    return header;
  }

  Map<String, String> _sanitizeHeaders(Map<String, String>? inputHeaders) {
    Map<String, String> resHeaders = Map.from(inputHeaders ?? _mainHeaders);

    String? rawZone = resHeaders[AppConstants.zoneId];
    if (rawZone == null || rawZone.isEmpty || rawZone == '[]' || rawZone == 'null') {
      resHeaders[AppConstants.zoneId] = jsonEncode([1]);
    } else {
      try {
        var decoded = jsonDecode(rawZone);
        if (decoded is! List || decoded.isEmpty) {
          if (decoded is int) {
            resHeaders[AppConstants.zoneId] = jsonEncode([decoded]);
          } else if (decoded is String) {
            int? parsed = int.tryParse(decoded);
            resHeaders[AppConstants.zoneId] = jsonEncode([parsed ?? 1]);
          } else {
            resHeaders[AppConstants.zoneId] = jsonEncode([1]);
          }
        }
      } catch (_) {
        int? parsed = int.tryParse(rawZone);
        resHeaders[AppConstants.zoneId] = jsonEncode([parsed ?? 1]);
      }
    }

    String cleanCoord(String? input, String fallback) {
      if (input == null || input.isEmpty || input == '0' || input == 'null') return fallback;
      String clean = input.replaceAll('"', '').replaceAll("'", '').trim();
      double? val = double.tryParse(clean);
      return (val == null || val == 0) ? fallback : clean;
    }

    resHeaders[AppConstants.latitude] = cleanCoord(resHeaders[AppConstants.latitude], '15.369445');
    resHeaders[AppConstants.longitude] = cleanCoord(resHeaders[AppConstants.longitude], '44.191006');

    return resHeaders;
  }

  Map<String, String> getHeader() => _sanitizeHeaders(_mainHeaders);

  Future<Response> getData(String uri, {Map<String, dynamic>? query, Map<String, String>? headers, bool handleError = true}) async {
    try {
      Map<String, String> finalHeaders = _sanitizeHeaders(headers);
      if (kDebugMode) {
        log('====> API Call: $uri\nHeader: $finalHeaders');
      }
      http.Response response = await http.get(
        Uri.parse(appBaseUrl+uri),
        headers: finalHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      if (kDebugMode) {
        print('------------${e.toString()}');
      }
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postData(String uri, dynamic body, {Map<String, String>? headers, int? timeout, bool handleError = true}) async {
    try {
      Map<String, String> finalHeaders = _sanitizeHeaders(headers);
      if(kDebugMode) {
        print('====> API Call: $uri\nHeader: $finalHeaders');
        print('====> API Body: $body');
      }

      Map<dynamic, dynamic> newBody = {};
      if(body != null) {
        body.forEach((key, value) {
          if (value != null && value.toString().isNotEmpty) {
            newBody.addAll({key: value});
          }
        });
      }

      http.Response response = await http.post(
        Uri.parse(appBaseUrl+uri),
        body: jsonEncode(newBody),
        headers: finalHeaders,
      ).timeout(Duration(seconds: timeout ?? timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postMultipartData(String uri, Map<String, String> body, List<MultipartBody> multipartBody, {List<MultipartDocument>? multipartDoc, Map<String, String>? headers, bool handleError = true}) async {
    try {
      Map<String, String> finalHeaders = _sanitizeHeaders(headers);
      debugPrint('====> API Call: $uri\nHeader: $finalHeaders');
      debugPrint('====> API Body: $body with ${multipartBody.length} and multipart ${multipartDoc?.length}');
      http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(appBaseUrl+uri));
      request.headers.addAll(finalHeaders);
      for(MultipartBody multipart in multipartBody) {
        if(multipart.file != null) {
          if(kIsWeb) {
            Uint8List list = await multipart.file!.readAsBytes();
            String extension = multipart.file!.path.split('.').last;
            http.MultipartFile part = http.MultipartFile(
              multipart.key, multipart.file!.readAsBytes().asStream(), list.length,
              filename: basename(multipart.file!.path), contentType: MediaType('image', extension),
            );
            request.files.add(part);
          }else {
            File file = File(multipart.file!.path);
            request.files.add(http.MultipartFile(
              multipart.key, file.readAsBytes().asStream(), file.lengthSync(), filename: file.path.split('/').last,
            ));
          }
        }
      }

      if(multipartDoc != null && multipartDoc.isNotEmpty){
        for(MultipartDocument file in multipartDoc){
          if(kIsWeb) {
            PlatformFile platformFile = file.file!.files.first;
            request.files.add(
              http.MultipartFile.fromBytes(
                file.key,
                platformFile.bytes!,
                filename: platformFile.name,
              ),
            );
          } else {
            File other = File(file.file!.files.single.path!);
            Uint8List list0 = await other.readAsBytes();
            var part = http.MultipartFile(file.key, other.readAsBytes().asStream(), list0.length, filename: basename(other.path));
            request.files.add(part);
          }
        }
      }

      request.fields.addAll(body);
      http.Response response = await http.Response.fromStream(await request.send());
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> putData(String uri, dynamic body, {Map<String, String>? headers, bool handleError = true}) async {
    try {
      Map<String, String> finalHeaders = _sanitizeHeaders(headers);
      if(kDebugMode) {
        print('====> API Call: $uri\nHeader: $finalHeaders');
        print('====> API Body: $body');
      }

      Map<dynamic, dynamic> newBody = {};
      if(body != null) {
        body.forEach((key, value) {
          if (value != null && value.toString().isNotEmpty) {
            newBody.addAll({key: value});
          }
        });
      }

      http.Response response = await http.put(
        Uri.parse(appBaseUrl+uri),
        body: jsonEncode(newBody),
        headers: finalHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> deleteData(String uri, {Map<String, String>? headers, bool handleError = true}) async {
    try {
      Map<String, String> finalHeaders = _sanitizeHeaders(headers);
      if(kDebugMode) {
        print('====> API Call: $uri\nHeader: $finalHeaders');
      }
      http.Response response = await http.delete(
        Uri.parse(appBaseUrl+uri),
        headers: finalHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Response handleResponse(http.Response response, String uri, bool handleError) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    }catch(_) {}
    Response response0 = Response(
      body: body ?? response.body, bodyString: response.body.toString(),
      request: Request(headers: response.request!.headers, method: response.request!.method, url: response.request!.url),
      headers: response.headers, statusCode: response.statusCode, statusText: response.reasonPhrase,
    );
    if(response0.statusCode != 200 && response0.body != null && response0.body is !String) {
      if(response0.body.toString().startsWith('{errors: [{code:')) {
        ErrorResponse errorResponse = ErrorResponse.fromJson(response0.body);
        response0 = Response(statusCode: response0.statusCode, body: response0.body, statusText: errorResponse.errors![0].message);
      }else if(response0.body.toString().startsWith('{message')) {
        response0 = Response(statusCode: response0.statusCode, body: response0.body, statusText: response0.body['message']);
      }
    }else if(response0.statusCode != 200 && response0.body == null) {
      response0 = Response(statusCode: 0, statusText: noInternetMessage);
    }
    if(kDebugMode) {
      print('====> API Response: [${response0.statusCode}] $uri');
      if(!ResponsiveHelper.isWeb() || response.statusCode != 500){
        print('${response0.body}');
      }
    }
    if(handleError) {
      if(response0.statusCode == 200) {
        return response0;
      } else {
        ApiChecker.checkApi(response0);
        return const Response();
      }
    } else {
      return response0;
    }
  }
}

class MultipartBody {
  String key;
  XFile? file;

  MultipartBody(this.key, this.file);
}

class MultipartDocument {
  String key;
  FilePickerResult? file;
  MultipartDocument(this.key, this.file);
}