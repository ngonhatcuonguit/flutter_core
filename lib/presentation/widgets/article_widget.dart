import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core_project/domain/entities/news/article_entity.dart';

class ArticleWidget extends StatelessWidget {
  final ArticleEntity? article;

  const ArticleWidget({
    Key? key,
    this.article,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Guard against null article
    if (article == null) {
      return Container(
        padding: const EdgeInsetsDirectional.only(
          start: 14,
          end: 14,
          top: 10,
          bottom: 10,
        ),
        height: (MediaQuery.of(context).size.width / 3) * 1.6,
        child: const Center(
          child: Text('Article data not available'),
        ),
      );
    }

    return Container(
      padding: const EdgeInsetsDirectional.only(
        start: 14,
        end: 14,
        top: 10,
        bottom: 10,
      ),
      height: (MediaQuery.of(context).size.width / 3) * 1.6,
      child: Row(
        children: [
          _buildImage(context),
          _buildTitleAndDescription(context),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final imageUrl = article?.urlToImage ?? "";

    // Check if URL is valid and not empty
    final isValidUrl = imageUrl.isNotEmpty &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));

    return _buildImageContainer(
      context,
      screenWidth,
      isValidUrl ? imageUrl : null,
    );
  }

  Widget _buildImageContainer(
    BuildContext context,
    double screenWidth,
    String? imageUrl,
  ) {
    // If no valid URL, show placeholder
    if (imageUrl == null || imageUrl.isEmpty) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(
          end: 10,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: double.maxFinite,
            width: screenWidth / 3,
            decoration: BoxDecoration(
              color: Colors.grey[300],
            ),
            child: const Icon(Icons.image_not_supported, color: Colors.grey),
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Padding(
        padding: const EdgeInsetsDirectional.only(
          end: 10,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: double.maxFinite,
            width: screenWidth / 3,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.08),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
      progressIndicatorBuilder: (context, url, downloadProgress) => Padding(
        padding: const EdgeInsetsDirectional.only(
          end: 14,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
              height: double.maxFinite,
              width: screenWidth / 3,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.08),
              ),
              child: const CupertinoActivityIndicator()),
        ),
      ),
      errorWidget: (context, url, error) => Padding(
        padding: const EdgeInsetsDirectional.only(
          end: 14,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: double.maxFinite,
            width: screenWidth / 3,
            decoration: const BoxDecoration(
              color: Colors.grey,
            ),
            child: const Icon(Icons.error, color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndDescription(BuildContext context) {
    // article is guaranteed non-null at this point due to null check in build()
    final articleData = article!;

    return Expanded(
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          vertical: 7,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            //title
            Text(
              articleData.title ?? "Default Title",
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.black.withOpacity(0.87),
              ),
            ),

            //description
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  articleData.description ?? "",
                  maxLines: 2,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),

            //date time
            Row(
              children: [
                const Icon(Icons.timeline_outlined, size: 16),
                const SizedBox(width: 54),
                Expanded(
                  child: Text(
                    articleData.publishedAt ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
