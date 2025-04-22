import '../../../data/sources/datastate.dart';
import '../../entities/news/article_entity.dart';

abstract class ArticleRepository {
  Future<DataState<List<ArticleEntity>>> getNewsArticles();
}