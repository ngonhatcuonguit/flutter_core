import 'package:flutter_core_project/data/sources/datastate.dart';
import 'package:flutter_core_project/domain/entities/news/article_entity.dart';
import 'package:flutter_core_project/domain/usecases/usecase.dart';
import '../repository/news/article_repository.dart';

class GetArticleUseCase implements UseCase<DataState<List<ArticleEntity>>, void> {

  final ArticleRepository _articleRepository;

  GetArticleUseCase(this._articleRepository);

  @override
  Future<DataState<List<ArticleEntity>>> call({void params}) {
    return _articleRepository.getNewsArticles();
  }

}
