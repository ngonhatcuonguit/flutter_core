import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_core_project/data/models/news/ArticleModel.dart';
import 'package:flutter_core_project/data/sources/datastate.dart';
import '../../../constants/constants.dart';
import '../../../domain/repository/news/article_repository.dart';
import '../../data_sources/remote/news_api_service.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsApiService _newsApiService;

  ArticleRepositoryImpl(this._newsApiService);

  @override
  Future<DataState<List<ArticleModel>>> getNewsArticles() async {
    try {
      print('🌐 Fetching articles from NewsAPI...');
      print('📍 URL: $newsAPIBaseURL');
      print('🔑 API Key: ${newsAPIKey.substring(0, 8)}...');

      final httpResponse = await _newsApiService.getNewsArticles(
        apiKey: newsAPIKey,
        country: newsAPICountry,
        category: newsAPICategory,
      );

      print('✅ Response received: ${httpResponse.response.statusCode}');

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        print('📰 Articles count: ${httpResponse.data.length}');
        return DataSuccess(
          httpResponse.data,
        );
      } else {
        print(
            '❌ HTTP Error: ${httpResponse.response.statusCode} - ${httpResponse.response.statusMessage}');
        return DataFailed(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              statusCode: httpResponse.response.statusCode,
              statusMessage: httpResponse.response.statusMessage,
              requestOptions: RequestOptions(path: ''),
            ),
          ),
        );
      }
    } on DioException catch (e) {
      print('❌ DioException caught in repository:');
      print('   Type: ${e.type}');
      print('   Message: ${e.message}');
      print('   Error: ${e.error}');

      // Enhanced error for DNS/connection issues
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        print('⚠️ Connection/DNS error detected');
      }

      return DataFailed(e);
    } catch (e) {
      print('❌ Unexpected error: $e');
      return DataFailed(
        DioException(
          requestOptions: RequestOptions(path: ''),
          error: e,
        ),
      );
    }
  }
}
