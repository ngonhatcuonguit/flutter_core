import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_core_project/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:flutter_core_project/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:flutter_core_project/presentation/widgets/appbar/app_bar.dart';
import 'package:flutter_svg/svg.dart';
import '../../../core/configs/assets/app_vectors.dart';
import '../../bloc/article/remote/remote_article_event.dart';
import '../../widgets/article_widget.dart';

class DailyNews extends StatefulWidget {
  const DailyNews({super.key});

  @override
  State<DailyNews> createState() => _DailyNewsState();
}

class _DailyNewsState extends State<DailyNews> {
  @override
  void initState() {
    super.initState();

    // Lấy bloc từ context
    final bloc = context.read<RemoteArticlesBloc>();

    // Nếu bloc chưa bị đóng thì mới được add event
    if (!bloc.isClosed) {
      bloc.add(const GetArticles());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppBar(
        title: SvgPicture.asset(
          AppVectors.logo,
          height: 30,
          width: 30,
        ),
      ),
      body: _buildBody(),
    );
  }


}

Widget _buildBody() {
  return BlocBuilder<RemoteArticlesBloc, RemoteArticleState>(
    builder: (context, state) {
      if (state is RemoteArticleLoading) {
        return const Center(child: CircularProgressIndicator());
      } else if (state is RemoteArticleError) {
        return const Center(child: Icon(Icons.refresh));
      } else if (state is RemoteArticleDone) {
        return ListView.builder(
          itemCount: state.articles?.length,
          itemBuilder: (context, index) {
            return ArticleWidget(article: state.articles![index]);
          },
        );
      }
      return const SizedBox();
    },
  );
}

