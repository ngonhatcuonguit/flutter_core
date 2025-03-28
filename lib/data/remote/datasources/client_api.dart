import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart';

Object? _toEncodable(Object? nonEncodable) =>
    nonEncodable is DateTime ? nonEncodable.toIso8601String() : nonEncodable;

const token = 'api_token';
const provinceHeader = 'X-Province';

abstract class AppHttpClient {
  Future<dynamic> getJson(Uri url, {Map<String, dynamic>? headers});

  Future<dynamic> postMultipart(
    String url,
    List<int> bytes, {
    Map<String, String>? headers,
    Map<String, String>? fields,
    String? filename,
  });

  Future<Response> getJsonRaw(String url, {Map<String, dynamic>? headers});
  Future<dynamic> postJson(
    Uri url, {
    Map<String, String>? headers,
    Map<String, Object?>? body,
  });

  Future<dynamic> putJson(
    Uri url, {
    Map<String, String>? headers,
    Map<String, Object?>? body,
  });

  Future<dynamic> deleteJson(
    Uri url, {
    Map<String, String>? headers,
  });
}

class ClientDio implements AppHttpClient {
  final Dio _dio;

  ClientDio(this._dio);

  @override
  Future<Response<Map<String, dynamic>>> getJson(Uri url,
      {Map<String, dynamic>? headers}) async {
    final response = await _dio.fetch<Map<String, dynamic>>(RequestOptions(
      method: "GET",
      baseUrl: url.origin,
      path: url.path,
      queryParameters: url.queryParameters,
      headers: headers,
    ));
    return response;
  }

  @override
  Future<Response> getJsonRaw(String url,
      {Map<String, dynamic>? headers}) async {
    final response = await _dio.fetch(RequestOptions(
      method: "GET",
      baseUrl: url,
      headers: headers,
    ));
    return response;
  }

  @override
  Future<Response> postMultipart(
    String url,
    List<int> bytes, {
    Map<String, String>? headers,
    Map<String, String>? fields,
    String? filename,
  }) async {
    final request = await _dio.post(
      url,
      data: FormData.fromMap(
        {
          "image": MultipartFile.fromBytes(
            bytes,
            contentType: MediaType('image', 'jpeg'),
            filename: filename,
          ),
        },
      ),
      options: Options(
        headers: {
          ...?headers,
          HttpHeaders.contentTypeHeader: 'multipart/form-data',
        },
      ),
    );

    /* equestOptions(
        method: "POST",
        baseUrl: url.origin,
        path: url.path,
        queryParameters: url.queryParameters,
        data: FormData.fromMap({
          "image": await MultipartFile.fromFile(
            img.path,
          ),
        }),
        headers: {
          ...?headers,
          HttpHeaders.contentTypeHeader: 'multipart/form-data',
        },
      ), */

    print("ok");
    return request;
  }

  @override
  Future<Response> postJson(
    Uri url, {
    Map<String, String>? headers,
    Map<String, Object?>? body,
  }) async {
    final response = await _dio.fetch(RequestOptions(
      method: 'POST',
      baseUrl: url.origin,
      path: url.path,
      queryParameters: url.queryParameters,
      data: body != null ? jsonEncode(body, toEncodable: _toEncodable) : null,
      headers: {
        ...?headers,
        HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
      },
    ));
    return response;
  }

  @override
  Future<Response> putJson(
    Uri url, {
    Map<String, String>? headers,
    Map<String, Object?>? body,
  }) {
    final response = _dio.fetch(RequestOptions(
      method: 'PUT',
      baseUrl: url.origin,
      path: url.path,
      queryParameters: url.queryParameters,
      headers: {
        ...?headers,
        HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
      },
      data: body,
    ));
    return response;
  }

  @override
  Future<Response> deleteJson(
    Uri url, {
    Map<String, String>? headers,
  }) {
    final response = _dio.fetch(RequestOptions(
      method: 'DELETE',
      baseUrl: url.origin,
      path: url.path,
      queryParameters: url.queryParameters,
      headers: {
        ...?headers,
        HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
      },
    ));
    return response;
  }
}
