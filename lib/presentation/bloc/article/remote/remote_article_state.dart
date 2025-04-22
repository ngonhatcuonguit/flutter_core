

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import '../../../../domain/entities/news/article_entity.dart';

abstract class RemoteArticleState extends Equatable {
  final List<ArticleEntity> ? articles;
  final DioException ? error;

  const RemoteArticleState({this.articles, this.error});

  @override
  List<Object?> get props => [articles, error];

}

class RemoteArticleInitial extends RemoteArticleState {
  const RemoteArticleInitial() : super();
}

class RemoteArticleLoading extends RemoteArticleState {
  const RemoteArticleLoading() : super();
}

class RemoteArticleDone extends RemoteArticleState {
  const RemoteArticleDone(List<ArticleEntity> articles) : super(articles: articles);
}

class RemoteArticleError extends RemoteArticleState {
  const RemoteArticleError(DioException error) : super(error: error);
}