import 'package:bloc/bloc.dart';
import 'package:flutter_core_project/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:flutter_core_project/presentation/bloc/article/remote/remote_article_state.dart';
import '../../../../data/sources/datastate.dart';
import '../../../../domain/usecases/get_article.dart';

class RemoteArticlesBloc extends Bloc<RemoteArticleEvent, RemoteArticleState> {
  final GetArticleUseCase _getArticleUseCase;

  RemoteArticlesBloc(this._getArticleUseCase)
      : super(const RemoteArticleLoading()) {
    on<GetArticles>(onGetArticles);
  }

  void onGetArticles(
    GetArticles event,
    Emitter<RemoteArticleState> emit,
  ) async {
    final dataState = await _getArticleUseCase();

    if (dataState is DataSuccess && dataState.data!.isNotEmpty) {
      emit(RemoteArticleDone(dataState.data ?? []));
    } else if (dataState is DataFailed) {
      emit(RemoteArticleError(dataState.error!));
    }
  }
}
