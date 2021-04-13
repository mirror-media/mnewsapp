import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tv/blocs/story/events.dart';
import 'package:tv/blocs/story/bloc.dart';
import 'package:tv/blocs/story/states.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/dateTimeFormat.dart';
import 'package:tv/models/people.dart';
import 'package:tv/models/peopleList.dart';
import 'package:tv/models/story.dart';
import 'package:tv/widgets/story/mNewsVideoPlayer.dart';
import 'package:tv/widgets/story/youtubeViewer.dart';

class StoryWidget extends StatefulWidget {
  final String slug;
  StoryWidget({
    @required this.slug,
  });

  @override
  _StoryWidgetState createState() => _StoryWidgetState();
}

class _StoryWidgetState extends State<StoryWidget> {
  @override
  void initState() {
    _loadStory(widget.slug);
    super.initState();
  }

  bool _isNullOrEmpty(String input) {
    return input == null || input == '';
  }

  _loadStory(String slug) async {
    context.read<StoryBloc>().add(FetchPublishedStoryBySlug(slug));
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return BlocBuilder<StoryBloc, StoryState>(
      builder: (BuildContext context, StoryState state) {
        if (state is StoryError) {
          final error = state.error;
          String message = '${error.message}\nTap to Retry.';
          return Center(
            child: Text(message),
          );
        }
        if (state is StoryLoaded) {
          Story story = state.story;
          if(story == null) {
            return Container();
          }

          return _storyContent(width, story);
        }

        // state is Init, loading, or other 
        return _loadingWidget();
      }
    );
  }

  Widget _loadingWidget() =>
      Center(
        child: CircularProgressIndicator(),
      );

  Widget _storyContent(double width, Story story) {
    return ListView(
      children: [
        _buildHeroWidget(width, story),
        SizedBox(height: 24),
        _buildCategoryAndPublishedDate(story),
        SizedBox(height: 10),
        _buildStoryTitle(story.name),
        SizedBox(height: 8),
        _buildAuthors(story),
      ],
    );
  }

  Widget _buildHeroWidget(double width, Story story) {
    double height = width / 16 * 9;

    return Column(
      children: [
        if (story.heroVideo != null)
          _buildVideoWidget(story.heroVideo),
        if (story.heroImage != null && story.heroVideo == null)
          CachedNetworkImage(
            width: width,
            imageUrl: story.heroImage,
            placeholder: (context, url) => Container(
              height: height,
              width: width,
              color: Colors.grey,
            ),
            errorWidget: (context, url, error) => Container(
              height: height,
              width: width,
              color: Colors.grey,
              child: Icon(Icons.error),
            ),
            fit: BoxFit.cover,
          ),
        if (!_isNullOrEmpty(story.heroCaption))
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 0.0),
            child: Text(
              story.heroCaption,
              style: TextStyle(
                fontSize: 15, 
                color: Color(0xff757575)
              ),
            ),
          ),
      ],
    );
  }

  _buildVideoWidget(String videoUrl) {
    String youtubeString = 'youtube';
    if(videoUrl.contains(youtubeString)) {
      if(videoUrl.contains(youtubeString)) {
        videoUrl = YoutubeViewer.convertUrlToId(videoUrl);
      }
      return YoutubeViewer(videoUrl);
    }
    
    return MNewsVideoPlayer(
      videourl: videoUrl,
      aspectRatio: 16 / 9,
    );
  }
  
  Widget _buildCategoryAndPublishedDate(Story story) {
    DateTimeFormat dateTimeFormat = DateTimeFormat();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if(story.categoryList.length == 0)
            Container(),
          if(story.categoryList.length > 0)
            Text(
              story.categoryList[0].name,
              style: TextStyle(
                fontSize: 15,
                color: appBarColor,
              ),
            ),
          Text(
            dateTimeFormat.changeStringToDisplayString(
                story.publishTime, 'yyyy-MM-ddTHH:mm:ssZ', 'yyyy.MM.dd HH:mm 臺北時間'),
            style: TextStyle(
              fontSize: 14,
              color: Color(0xff757575),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStoryTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
      child: Text(
        title,
        style: TextStyle(fontFamily: 'PingFang TC', fontSize: 26),
      ),
    );
  }

  Widget _buildAuthors(Story story) {
    Color authorColor = Color(0xff757575);
    List<Widget> authorItems = List();

    // VerticalDivider is broken? so use Container
    var myVerticalDivider = Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
      child: Container(
        color: Color(0xff757575),
        width: 1,
        height: 15,
      ),
    );

    if (story.writers.length > 0) {
      authorItems.add(
        Text(
          "作者",
          style: TextStyle(
            fontSize: 15, 
            color: authorColor
          ),
        ),
      );
      authorItems.add(myVerticalDivider);

      authorItems.addAll(_addAuthorItems(story.writers));
      authorItems.add(SizedBox(
        width: 12.0,
      ));
    }

    if (story.photographers.length > 0) {
      authorItems.add(
        Text(
          "攝影",
          style: TextStyle(
            fontSize: 15, 
            color: authorColor
          ),
        ),
      );
      authorItems.add(myVerticalDivider);

      authorItems.addAll(_addAuthorItems(story.photographers));
      authorItems.add(SizedBox(
        width: 12.0,
      ));
    }

    if (story.cameraOperators.length > 0) {
      authorItems.add(
        Text(
          "影音",
          style: TextStyle(
            fontSize: 15, 
            color: authorColor
          ),
        ),
      );
      authorItems.add(myVerticalDivider);

      authorItems.addAll(_addAuthorItems(story.cameraOperators));
      authorItems.add(SizedBox(
        width: 12.0,
      ));
    }

    if (story.designers.length > 0) {
      authorItems.add(
        Text(
          "設計",
          style: TextStyle(
            fontSize: 15, 
            color: authorColor
          ),
        ),
      );
      authorItems.add(myVerticalDivider);

      authorItems.addAll(_addAuthorItems(story.designers));
      authorItems.add(SizedBox(
        width: 12.0,
      ));
    }

    if (story.engineers.length > 0) {
      authorItems.add(
        Text(
          "工程",
          style: TextStyle(
            fontSize: 15, 
            color: authorColor
          ),
        ),
      );
      authorItems.add(myVerticalDivider);

      authorItems.addAll(_addAuthorItems(story.engineers));
      authorItems.add(SizedBox(
        width: 12.0,
      ));
    }

    if (story.vocals.length > 0) {
      authorItems.add(
        Text(
          "主播",
          style: TextStyle(
            fontSize: 15, 
            color: authorColor
          ),
        ),
      );
      authorItems.add(myVerticalDivider);

      authorItems.addAll(_addAuthorItems(story.engineers));
      authorItems.add(SizedBox(
        width: 12.0,
      ));
    }

    if (!_isNullOrEmpty(story.otherbyline)) {
      authorItems.add(
        Text(
          "作者",
          style: TextStyle(
            fontSize: 15, 
            color: authorColor
          ),
        ),
      );
      authorItems.add(myVerticalDivider);
      authorItems.add(Text(story.otherbyline));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: authorItems,
      ),
    );
  }

  List<Widget> _addAuthorItems(PeopleList peopleList) {
    List<Widget> authorItems = List();

    for (People author in peopleList) {
      authorItems.add(Padding(
        padding: const EdgeInsets.only(right: 4.0),
        child: Text(
          author.name,
          style: TextStyle(
            fontSize: 15, 
          ),
        ),
      ));
    }
    return authorItems;
  }
}