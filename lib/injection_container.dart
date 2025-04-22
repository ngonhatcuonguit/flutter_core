
import 'package:dio/dio.dart';
import 'package:flutter_core_project/data/data_sources/remote/news_api_service.dart';
import 'package:flutter_core_project/domain/repository/news/article_repository.dart';
import 'package:flutter_core_project/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:get_it/get_it.dart';

import 'data/repositories/news/article_repository_impl.dart';
import 'domain/usecases/get_article.dart';

final sl = GetIt.instance;

Future<void> initializeInjection() async {
  // Register your dependencies here
  // Example:
  // sl.registerLazySingleton<SomeService>(() => SomeServiceImpl());
  // sl.registerFactory<SomeBloc>(() => SomeBloc(sl<SomeService>()));

  //Dio
  sl.registerSingleton<Dio>(Dio());
  // Dependency Injection
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));
  // Register your repositories
  sl.registerSingleton<ArticleRepository>(
    ArticleRepositoryImpl(sl()),
  );

  //use cases
  sl.registerSingleton<GetArticleUseCase>(
    GetArticleUseCase(sl()),
  );

  // Register your blocs
  sl.registerSingleton<RemoteArticlesBloc>(
    RemoteArticlesBloc(sl()),
  );


}