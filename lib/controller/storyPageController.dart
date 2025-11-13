import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/story.dart';
import 'package:tv/services/storyService.dart';
import '../services/comscoreService.dart';

class StoryPageController extends GetxController {
  final StoryRepos repository;
  String currentSlug;
  StoryPageController(this.repository, this.currentSlug);

  late Story story;
  late File ombudsLawFile;
  late MNewException error;
  bool isLoading = true;
  bool isError = false;

  void _log(String msg) => debugPrint('[StoryPageController][$currentSlug] $msg');

  @override
  void onInit() {
    super.onInit();
    _log('onInit, slug=$currentSlug');
    loadStory(currentSlug);
  }

  Future<void> loadStory(String slug) async {
    _log('loadStory START slug=$slug (before: isLoading=$isLoading, isError=$isError)');
    isLoading = true;
    isError = false;
    currentSlug = slug;
    update();

    try {
      _log('calling repository.fetchPublishedStoryBySlug("$slug") ...');
      story = await repository.fetchPublishedStoryBySlug(slug);

      _log('repository returned → '
          'name="${story.name}", slug="}", '
          'publishTime=${story.publishTime}, '
          'brief.len=${story.brief?.length ?? 0}, content.len=${story.contentApiData?.length ?? 0}, '
          'heroImage=${story.heroImage}, heroVideo=${story.heroVideo}, '
          'tags.len=${story.tags?.length ?? 0}, '
          'category=${(story.categoryList != null && story.categoryList!.isNotEmpty) ? story.categoryList!.first.name : 'none'}');

      if (slug == 'law') {
        ombudsLawFile = await DefaultCacheManager().getSingleFile(ombudsLaw);
        _log('ombudsLaw file cached at: ${ombudsLawFile.path}');
      }

      final categoryName =
      (story.categoryList != null && story.categoryList!.isNotEmpty)
          ? story.categoryList!.first.name
          : 'unknown';

      ComscoreService.trackArticleView(
        articleId: slug,
        title: story.name ?? '無標題',
        category: categoryName,
      );
      _log('Comscore trackArticleView sent (category=$categoryName)');

      isError = false;
    } catch (e, st) {
      _log('LOAD FAILED: ${e.runtimeType} → $e');
      error = determineException(e);
      _log('mapped error = ${error.runtimeType} / message="${error.message}"');
      isError = true;
      // _log('stack:\n$st'); // 若要看 stack 再打開
    } finally {
      isLoading = false;
      _log('loadStory END → isLoading=$isLoading, isError=$isError');
      update();
    }
  }
}