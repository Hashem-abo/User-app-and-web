import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:path/path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:suliman/api/cancellation_token.dart';
import 'package:suliman/api/data_module_manager.dart';
import 'package:suliman/api/api_checker.dart';
import 'package:suliman/helper/network_info.dart';
import 'package:suliman/features/address/domain/models/address_model.dart';
import 'package:suliman/common/models/error_response.dart';
import 'package:suliman/common/models/module_model.dart';
import 'package:suliman/helper/address_helper.dart';
import 'package:suliman/helper/responsive_helper.dart';
import 'package:suliman/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiClient extends GetxService {
  final String appBaseUrl;
  final SharedPreferences sharedPreferences;
  static final String noInternetMessage = 'connection_to_api_server_failed'.tr;
  final int timeoutInSeconds = 30;
  final int uploadTimeoutInSeconds = 90;

  String? token;
  late Map<String, String> _mainHeaders;

  ApiClient({required this.appBaseUrl, required this.sharedPreferences, String? token}) {
    this.token = token ?? sharedPreferences.getString(AppConstants.token);
    if (kDebugMode) {
      print('Token: ${this.token}');
    }
    AddressModel? addressModel = AddressHelper.getUserAddressFromSharedPref();
    int? moduleID;
    if(GetPlatform.isWeb && sharedPreferences.containsKey(AppConstants.moduleId)) {
      try {
        moduleID = ModuleModel.fromJson(jsonDecode(sharedPreferences.getString(AppConstants.moduleId)!)).id;
      }catch(_) {}
    }
    updateHeader(
      this.token, addressModel?.zoneIds, addressModel?.areaIds,
      sharedPreferences.getString(AppConstants.languageCode), moduleID, addressModel?.latitude,
        addressModel?.longitude
    );
  }

  Map<String, String> updateHeader(String? token, List<int>? zoneIDs, List<int>? operationIds, String? languageCode, int? moduleID, String? latitude, String? longitude, {bool setHeader = true}) {
    Map<String, String> header = {};

    String? effectiveToken = (token != null && token.isNotEmpty && token != 'null')
        ? token
        : ((this.token != null && this.token!.isNotEmpty && this.token != 'null')
            ? this.token
            : sharedPreferences.getString(AppConstants.token));

    if (effectiveToken != null && effectiveToken.isNotEmpty && effectiveToken != 'null') {
      this.token = effectiveToken;
    }

    AddressModel? userAddress = AddressHelper.getUserAddressFromSharedPref();
    if (latitude == null || latitude.isEmpty || latitude == '0') {
      latitude = userAddress?.latitude;
    }
    if (longitude == null || longitude.isEmpty || longitude == '0') {
      longitude = userAddress?.longitude;
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
    });
    if (effectiveToken != null && effectiveToken.isNotEmpty && effectiveToken != 'null') {
      header['Authorization'] = 'Bearer $effectiveToken';
    }
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

  Map<String, String> _maskHeadersForLog(Map<String, String>? headers) {
    if (headers == null) return {};
    Map<String, String> masked = Map.from(headers);
    if (masked.containsKey('Authorization')) {
      String? auth = masked['Authorization'];
      if (auth != null && auth.startsWith('Bearer ') && auth.length > 15) {
        masked['Authorization'] = 'Bearer ${auth.substring(7, 11)}...[REDACTED]';
      } else if (auth != null && auth.isNotEmpty) {
        masked['Authorization'] = '[REDACTED]';
      }
    }
    return masked;
  }

  dynamic _maskBodyForLog(dynamic body) {
    if (body == null) return null;
    if (body is Map) {
      Map<dynamic, dynamic> masked = {};
      body.forEach((key, value) {
        String keyStr = key.toString().toLowerCase();
        if (keyStr.contains('password') ||
            keyStr == 'otp' ||
            keyStr == 'code' ||
            keyStr == 'token' ||
            keyStr == 'temp_token' ||
            keyStr == 'access_token' ||
            keyStr.contains('secret') ||
            keyStr == 'app_sign' ||
            keyStr.contains('cvv') ||
            keyStr.contains('card_number') ||
            keyStr == 'pin') {
          masked[key] = '[REDACTED]';
        } else if (value is Map || value is List) {
          masked[key] = _maskBodyForLog(value);
        } else {
          masked[key] = value;
        }
      });
      return masked;
    } else if (body is List) {
      return body.map((item) => _maskBodyForLog(item)).toList();
    }
    return body;
  }

  dynamic _maskResponseBodyForLog(String uri, dynamic body) {
    if (body == null) return null;
    String lowerUri = uri.toLowerCase();
    if (lowerUri.contains('/auth/') ||
        lowerUri.contains('/login') ||
        lowerUri.contains('/sign-up') ||
        lowerUri.contains('/verify-') ||
        lowerUri.contains('/reset-password') ||
        lowerUri.contains('/cm-firebase-token')) {
      return _maskBodyForLog(body);
    }
    return body;
  }

  Map<String, String> getHeader() => _sanitizeHeaders(_mainHeaders);

  bool _isAutoCacheable(String uri) {
    return uri.contains('/config') ||
        uri.contains('/banners') ||
        uri.contains('/categories') ||
        uri.contains('/modules') ||
        uri.contains('/customer/landing-page') ||
        uri.contains('/stores/details') ||
        uri.contains('/items/details') ||
        uri.contains('/dynamic-shelf') ||
        uri.contains('/store-corner') ||
        uri.contains('/brands') ||
        uri.contains('/zone');
  }

  void _invalidateOnMutation(String uri) {
    if (uri.contains('cart')) {
      DataModuleManager().invalidatePatterns(['cart', 'checkout']);
    } else if (uri.contains('address')) {
      DataModuleManager().invalidatePatterns(['address', 'zone']);
    } else if (uri.contains('order')) {
      DataModuleManager().invalidatePatterns(['order', 'cart']);
    } else if (uri.contains('favourite') || uri.contains('wish-list')) {
      DataModuleManager().invalidatePatterns(['favourite', 'wish-list']);
    } else if (uri.contains('profile') || uri.contains('customer/update')) {
      DataModuleManager().invalidatePatterns(['customer/info', 'profile']);
    }
  }

  void _revalidateInBackground(
    String uri,
    Map<String, dynamic>? query,
    Map<String, String> headers,
    String canonicalKey,
    Duration? cacheTtl,
    bool handleError,
  ) {
    DataModuleManager().coalesce<void>('REVALIDATE:$canonicalKey', () async {
      try {
        Uri requestUri = Uri.parse(appBaseUrl + uri);
        if (query != null && query.isNotEmpty) {
          requestUri = requestUri.replace(queryParameters: query.map((k, v) => MapEntry(k, v.toString())));
        }
        final http.Response httpResponse = await http
            .get(requestUri, headers: headers)
            .timeout(Duration(seconds: timeoutInSeconds));
        final Response response = handleResponse(httpResponse, uri, handleError);
        if (response.statusCode == 200) {
          DataModuleManager().cache.put(canonicalKey, response, ttl: cacheTtl);
          if (kDebugMode) {
            log('====> [SWR Revalidated & Updated Cache] $canonicalKey');
          }
        }
      } catch (_) {}
    });
  }

  Future<Response> getData(
    String uri, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    int? timeout,
    bool handleError = true,
    CancellationToken? cancelToken,
    bool useCache = false,
    Duration? cacheTtl,
  }) async {
    // 1. Immediate cancellation check
    if (cancelToken != null && cancelToken.isCancelled) {
      return Response(statusCode: -1, statusText: cancelToken.cancelReason ?? 'Request cancelled');
    }

    final bool shouldCache = useCache || _isAutoCacheable(uri);
    Map<String, String> finalHeaders = _sanitizeHeaders(headers);
    int? currentModuleId = int.tryParse(finalHeaders[AppConstants.moduleId] ?? '');
    String? langCode = finalHeaders[AppConstants.localizationKey];
    final String canonicalKey = DataModuleManager.buildCanonicalKey(
      uri,
      query: query,
      moduleId: currentModuleId,
      languageCode: langCode,
    );

    // 2. Smart In-Memory Cache with Stale-While-Revalidate (SWR)
    if (shouldCache) {
      final cached = DataModuleManager().cache.get(canonicalKey, allowStale: true);
      if (cached is Response) {
        final bool isStale = DataModuleManager().cache.isStale(canonicalKey);
        if (kDebugMode) {
          log('====> [LRU Cache Hit ${isStale ? "(Stale SWR)" : "(Fresh)"}] $canonicalKey');
        }
        if (isStale) {
          _revalidateInBackground(uri, query, finalHeaders, canonicalKey, cacheTtl, handleError);
        }
        return cached;
      }
    }

    // 3. In-flight Request Coalescing (Thundering Herd Protection)
    return DataModuleManager().coalesce<Response>('GET:$canonicalKey', () async {
      http.Client? client;
      try {
        if (cancelToken != null && cancelToken.isCancelled) {
          return Response(statusCode: -1, statusText: cancelToken.cancelReason ?? 'Request cancelled');
        }

        if (kDebugMode) {
          log('====> API Call: $uri\nHeader: ${_maskHeadersForLog(finalHeaders)}');
        }

        Uri requestUri = Uri.parse(appBaseUrl + uri);
        if (query != null && query.isNotEmpty) {
          requestUri = requestUri.replace(queryParameters: query.map((k, v) => MapEntry(k, v.toString())));
        }

        final http.Response httpResponse;
        int activeTimeout = timeout ?? timeoutInSeconds;
        if (cancelToken != null) {
          client = http.Client();
          cancelToken.onCancel(() {
            try {
              client?.close();
            } catch (_) {}
          });
          httpResponse = await client.get(requestUri, headers: finalHeaders).timeout(Duration(seconds: activeTimeout));
        } else {
          httpResponse = await http.get(requestUri, headers: finalHeaders).timeout(Duration(seconds: activeTimeout));
        }

        final Response response = handleResponse(httpResponse, uri, handleError);

        // Store in LRU cache if successful
        if (shouldCache && response.statusCode == 200) {
          DataModuleManager().cache.put(canonicalKey, response, ttl: cacheTtl);
        }

        return response;
      } catch (e) {
        if (cancelToken != null && cancelToken.isCancelled) {
          return Response(statusCode: -1, statusText: cancelToken.cancelReason ?? 'Request cancelled');
        }
        NetworkInfo.setLastKnownConnection(false);
        if (kDebugMode) {
          print('------------${e.toString()}');
        }
        return Response(statusCode: 1, statusText: noInternetMessage);
      } finally {
        try {
          client?.close();
        } catch (_) {}
      }
    });
  }

  Future<Response> postData(String uri, dynamic body, {Map<String, String>? headers, int? timeout, bool handleError = true}) async {
    try {
      Map<String, String> finalHeaders = _sanitizeHeaders(headers);
      if(kDebugMode) {
        print('====> API Call: $uri\nHeader: ${_maskHeadersForLog(finalHeaders)}');
        print('====> API Body: ${_maskBodyForLog(body)}');
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
      final Response result = handleResponse(response, uri, handleError);
      if (result.statusCode == 200 || result.statusCode == 201) {
        _invalidateOnMutation(uri);
      }
      return result;
    } catch (e) {
      NetworkInfo.setLastKnownConnection(false);
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postMultipartData(String uri, Map<String, String> body, List<MultipartBody> multipartBody, {List<MultipartDocument>? multipartDoc, Map<String, String>? headers, int? timeout, bool handleError = true}) async {
    try {
      Map<String, String> finalHeaders = _sanitizeHeaders(headers);
      debugPrint('====> API Call: $uri\nHeader: ${_maskHeadersForLog(finalHeaders)}');
      debugPrint('====> API Body: ${_maskBodyForLog(body)} with ${multipartBody.length} and multipart ${multipartDoc?.length}');
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
      int activeTimeout = timeout ?? uploadTimeoutInSeconds;
      http.StreamedResponse streamedResponse = await request.send().timeout(Duration(seconds: activeTimeout));
      http.Response response = await http.Response.fromStream(streamedResponse);
      final Response result = handleResponse(response, uri, handleError);
      if (result.statusCode == 200 || result.statusCode == 201) {
        _invalidateOnMutation(uri);
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('====> postMultipartData error: $e');
      }
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> putData(String uri, dynamic body, {Map<String, String>? headers, int? timeout, bool handleError = true}) async {
    try {
      Map<String, String> finalHeaders = _sanitizeHeaders(headers);
      if(kDebugMode) {
        print('====> API Call: $uri\nHeader: ${_maskHeadersForLog(finalHeaders)}');
        print('====> API Body: ${_maskBodyForLog(body)}');
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
      ).timeout(Duration(seconds: timeout ?? timeoutInSeconds));
      final Response result = handleResponse(response, uri, handleError);
      if (result.statusCode == 200 || result.statusCode == 201) {
        _invalidateOnMutation(uri);
      }
      return result;
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> deleteData(String uri, {Map<String, String>? headers, int? timeout, bool handleError = true}) async {
    try {
      Map<String, String> finalHeaders = _sanitizeHeaders(headers);
      if(kDebugMode) {
        print('====> API Call: $uri\nHeader: ${_maskHeadersForLog(finalHeaders)}');
      }
      http.Response response = await http.delete(
        Uri.parse(appBaseUrl+uri),
        headers: finalHeaders,
      ).timeout(Duration(seconds: timeout ?? timeoutInSeconds));
      final Response result = handleResponse(response, uri, handleError);
      if (result.statusCode == 200 || result.statusCode == 201) {
        _invalidateOnMutation(uri);
      }
      return result;
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
    }else if(!response0.isOk && response0.statusCode != 204 && response0.body == null) {
      response0 = Response(statusCode: 0, statusText: noInternetMessage);
    }
    if(kDebugMode) {
      print('====> API Response: [${response0.statusCode}] $uri');
      if(!ResponsiveHelper.isWeb() || response.statusCode != 500){
        print('${_maskResponseBodyForLog(uri, response0.body)}');
      }
    }
    if (response0.isOk) {
      NetworkInfo.setLastKnownConnection(true);
    } else if (response0.statusCode == 0 || response0.statusCode == 1 || response0.statusText == noInternetMessage) {
      NetworkInfo.setLastKnownConnection(false);
    }
    if(handleError) {
      if(response0.isOk) {
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