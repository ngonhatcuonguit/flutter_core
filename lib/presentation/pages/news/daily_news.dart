import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_core_project/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:flutter_core_project/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:flutter_core_project/presentation/widgets/appbar/app_bar.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/configs/assets/app_vectors.dart';
import '../../bloc/article/remote/remote_article_event.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => BlocProvider.of<RemoteArticlesBloc>(context)
            ..add(const GetArticles()),
        ),
      ],
      child: Scaffold(
        appBar: BasicAppBar(
          title: SvgPicture.asset(
            AppVectors.logo,
            height: 30,
            width: 30,
          ),
        ),
        body: _buildBody(),
      ),
    );
  }
}

_buildBody() {
  return BlocBuilder<RemoteArticlesBloc, RemoteArticleState>(
    builder: (_, state) {
      if (state is RemoteArticleLoading) {
        return const Center(child: CircularProgressIndicator());
      } else if (state is RemoteArticleError) {
        return const Center(child: Icon(Icons.refresh));
      } else if (state is RemoteArticleDone) {
        return ListView.builder(
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('$index'),
            );
          },
          itemCount: state.articles?.length,
        );
      }
      return const SizedBox();
    },
  );
}
