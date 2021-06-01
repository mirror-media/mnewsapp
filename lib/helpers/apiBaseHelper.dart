import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:tv/helpers/apiException.dart';

class ApiBaseHelper {

  Future<dynamic> getByUrl(
    String url,
    {
      Map<String,String> headers = const {'Cache-control': 'no-cache'},
    }
  ) async {
    Uri uri = Uri.parse(url);
    final response = await http.get(uri, headers: headers);
    var responseJson = returnResponse(response);
    print('Api get done.');
    return responseJson;
  }

  Future<dynamic> get(String baseUrl, String endpoint) async {
    getByUrl(baseUrl + endpoint);
  }

  Future<dynamic> postByUrl(String url, dynamic body, {Map<String, String> headers}) async {
    Uri uri = Uri.parse(url);
    final response = await http.post(uri, headers: headers, body: body);
    var responseJson = returnResponse(response);
    print('Api post done.');
    return responseJson;
  }

  Future<dynamic> post(String baseUrl, String endpoint, dynamic body) async {
    postByUrl(baseUrl + endpoint, body);
  }

  Future<dynamic> putByUrl(String url, dynamic body) async {
    Uri uri = Uri.parse(url);
    final response = await http.put(uri, body: body);
    var responseJson = returnResponse(response);
    print('Api put done.');
    return responseJson;
  }

  Future<dynamic> put(String baseUrl, String endpoint, dynamic body) async {
    putByUrl(baseUrl + endpoint, body);
  }

  Future<dynamic> deleteByUrl(String url) async {
    Uri uri = Uri.parse(url);
    final response = await http.delete(uri);
    var apiResponse = returnResponse(response);
    print('Api delete done.');
    return apiResponse;
  }

  Future<dynamic> delete(String baseUrl, String endpoint) async {
    deleteByUrl(baseUrl + endpoint);
  }
}

dynamic returnResponse(http.Response response) {
  switch (response.statusCode) {
    case 200:
      String utf8Json = utf8.decode(response.bodyBytes);
      var responseJson = json.decode(utf8Json);

      // properties responded by member graphql
      bool hasData = responseJson.containsKey('data') || 
        responseJson.containsKey('items') ||
        // search response
        (responseJson.containsKey('body') && responseJson['body'] != null && responseJson['body'].containsKey('hits')) ||
        // popular json
        responseJson.containsKey('report');
      
      if(!hasData) {
        throw FormatException(response.body.toString());
      }

      return responseJson;
    case 400:
    case 404:
      throw BadRequestException(response.body.toString());
    case 401:
    case 403:
      throw UnauthorisedException(response.body.toString());
    case 500:
    case 502:
      throw InternalServerErrorException(response.body.toString());
    default:
      throw FetchDataException(
          'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
  }
}
