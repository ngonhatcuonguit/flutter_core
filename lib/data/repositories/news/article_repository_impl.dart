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
      final httpResponse = await _newsApiService.getNewsArticles(
        apiKey: newsAPIKey,
        country: newsAPICountry,
        category: newsAPICategory,
      );

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        return DataSuccess(
          httpResponse.data ?? [],
        );
      } else {
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
      return DataFailed(e);
    }
  }
}
