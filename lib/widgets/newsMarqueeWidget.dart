import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/newsMarquee/bloc.dart';
import 'package:tv/blocs/newsMarquee/events.dart';
import 'package:tv/blocs/newsMarquee/states.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/routeGenerator.dart';
import 'package:tv/models/storyListItemList.dart';
import 'package:tv/widgets/marqueeWidget.dart';

class BuildNewsMarquee extends StatefulWidget {
  @override
  _BuildNewsMarqueeState createState() => _BuildNewsMarqueeState();
}

class _BuildNewsMarqueeState extends State<BuildNewsMarquee> {
  @override
  void initState() {
    _loadNewsList();
    super.initState();
  }

  _loadNewsList() async {
    context.read<NewsMarqueeBloc>().add(NewsMarqueeEvents.fetchNewsList);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewsMarqueeBloc, NewsMarqueeState>(
      builder: (BuildContext context, NewsMarqueeState state) {
        if (state is NewsMarqueeError) {
          final error = state.error;
          String message = '${error.message}\nTap to Retry.';
          return Center(
            child: Text(message),
          );
        }
        if (state is NewsMarqueeLoaded) {
          StoryListItemList newsList = state.newsList;

          if(newsList.length == 0) {
            return Container();
          }
          return NewsMarquee(
            newsList: newsList,
          );
        }

        // state is Init, loading, or other 
        return Container();
      }
    );
  }
}

class NewsMarquee extends StatefulWidget {
  final StoryListItemList newsList;
  final Axis direction;
  final double height;
  final Duration animationDuration, backDuration, pauseDuration;

  NewsMarquee({
    @required this.newsList,
    this.direction: Axis.horizontal,
    this.height: 48.0,
    this.animationDuration: const Duration(milliseconds: 3000),
    this.backDuration: const Duration(milliseconds: 800),
    this.pauseDuration: const Duration(milliseconds: 800),
  });

  @override
  _NewsMarqueeState createState() => _NewsMarqueeState();
}

class _NewsMarqueeState extends State<NewsMarquee> {
  CarouselController _carouselController;
  CarouselOptions _options;

  @override
  void initState() {
    _carouselController = CarouselController();
    _options = CarouselOptions(
      scrollPhysics: NeverScrollableScrollPhysics(),
      height: widget.height,
      viewportFraction: 1,
      scrollDirection: Axis.vertical,
      initialPage: 0,
      autoPlay: true,
      autoPlayInterval: Duration(milliseconds: 6000),
      enableInfiniteScroll: false,
      enlargeCenterPage: false,
      onPageChanged: (index, reason) {},
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Row(
      children: [
        Container(
          color: newsMarqueeLeadingColor,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              '快訊',
              style: TextStyle(fontSize: 17, color: newsMarqueeContentColor),
            ),
          ),
        ),
        Expanded(
          child: CarouselSlider(
            items: _buildList(width, widget.newsList),
            carouselController: _carouselController,
            options: _options,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildList(double width, StoryListItemList newsList) {
    List<Widget> resultList = List<Widget>();
    for (int i = 0; i < newsList.length; i++) {
      resultList.add(InkWell(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SizedBox(
            width: width,
            child: MarqueeWidget(
              child: Text(
                newsList[i].name,
                style: TextStyle(fontSize: 17, color: newsMarqueeContentColor),
              ),
              animationDuration: Duration(milliseconds: 4000),
            ),
          ),
        ),
        onTap: () {
          RouteGenerator.navigateToStory(context, newsList[i].slug);
        },
      ));
    }

    return resultList;
  }
}
