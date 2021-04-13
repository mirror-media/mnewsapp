import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/story/events.dart';
import 'package:tv/blocs/story/bloc.dart';
import 'package:tv/blocs/story/states.dart';
import 'package:tv/models/story.dart';

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

  _loadStory(String slug) async {
    context.read<StoryBloc>().add(FetchPublishedStoryBySlug(slug));
  }

  @override
  Widget build(BuildContext context) {
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

          return _storyContent(story);
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

  Widget _storyContent(Story story) {
    return Center(child: Text(story.name));
  }
}