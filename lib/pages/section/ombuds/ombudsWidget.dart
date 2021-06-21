import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/baseConfig.dart';
import 'package:tv/blocs/story/bloc.dart';
import 'package:tv/blocs/story/events.dart';
import 'package:tv/blocs/story/states.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/helpers/routeGenerator.dart';
import 'package:tv/models/paragrpahList.dart';
import 'package:tv/models/story.dart';
import 'package:tv/pages/section/ombuds/ombudsButton.dart';
import 'package:tv/widgets/story/mNewsVideoPlayer.dart';
import 'package:tv/widgets/story/youtubeViewer.dart';
import 'package:url_launcher/url_launcher.dart';

class OmbudsWidget extends StatefulWidget {
  @override
  _OmbudsWidgetState createState() => _OmbudsWidgetState();
}

class _OmbudsWidgetState extends State<OmbudsWidget> {
  //double _leftAndRightPaddingNumber = 24.0;
  
  @override
  void initState() {
    _loadOmbuds();
    super.initState();
  }

  _loadOmbuds() async {
    context.read<StoryBloc>().add(FetchPublishedStoryBySlug('biography'));
  }
  
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return BlocBuilder<StoryBloc, StoryState>(
      builder: (BuildContext context, StoryState state) {
        if (state is StoryError) {
          final error = state.error;
          print('NewsCategoriesError: ${error.message}');
          if( error is NoInternetException) {
            return error.renderWidget(onPressed: () => _loadOmbuds());
          } 
          
          return error.renderWidget(isNoButton: true);
        }
        if (state is StoryLoaded) {
          Story? story = state.story;
          if(story == null) {
            return Container();
          }

          return _buildContent(width, story);
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

  Widget _buildContent(double width, Story story) {
    return ListView(
      children: [
        SizedBox(height: 44,),
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
          child: _buildHeroWidget(width - 48, story),
        ),
        SizedBox(height: 28,),
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
          child: _buildBrief(story.brief!),
        ),
        SizedBox(height: 8,),
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
          child: _understandMoreBlock(),
        ),
        SizedBox(height: 40,),
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
          child: _appealBlock(width),
        ),
        SizedBox(height: 28,),
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
          child: _ombudsIntroBlock(width),
        ),
        SizedBox(height: 28,),
      ]
    );
  }

  Widget _buildHeroWidget(double width, Story story) {
    if(story.heroVideo != null) {
      return _buildVideoWidget(story.heroVideo!);
    }

    return Image.asset(
      ombudsDefaultJpg,
    );
  }

  _buildVideoWidget(String videoUrl) {
    String youtubeString = 'youtube';
    if(videoUrl.contains(youtubeString)) {
      if(videoUrl.contains(youtubeString)) {
        videoUrl = YoutubeViewer.convertUrlToId(videoUrl)!;
      }
      return YoutubeViewer(videoUrl);
    }
    
    return MNewsVideoPlayer(
      videourl: videoUrl,
      aspectRatio: 16 / 9,
    );
  }

  Widget _buildBrief(ParagraphList brief) {
    ParagraphList unstyledBrief = ParagraphList();
    for (int i = 0; i < brief.length; i++) {
      if (brief[i].type == 'unstyled') {
        unstyledBrief.add(brief[i]);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '公評人簡介',
          style: TextStyle(
            fontSize: 20,
            color: themeColor,
          ),
        ),
        SizedBox(height: 8.0),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: unstyledBrief.length,
          itemBuilder: (context, index) {
            return Text(
              unstyledBrief[index].contents![0].data,
              style: TextStyle(
                fontSize: 17,
              ),
            );
          }
        ),
      ],
    );
  }

  Widget _understandMoreBlock() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(),
        InkWell(
          child: Text(
            '了解更多＞',
            style: TextStyle(
              fontSize: 20,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w600,
            ),
          ),
          onTap: () => RouteGenerator.navigateToStory(context, 'biography'),
        )
      ]
    );
  }

  Widget _appealBlock(double width) {
    return Container(
      width: width,
      color: Colors.grey[300],
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 20.0),
        child: Column(
          children: [
            Text(
              '新聞申訴方式',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: themeColor,
              ),
            ),
            SizedBox(height: 12),
            _appealButton(width),
          ]
        ),
      ),
    );
  }

  Widget _appealButton(double width) {
    return Container(
      width: width,
      child: OutlinedButton(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 16.0),
          child: Text(
            '我要申訴',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: themeColor,
            ),
          ),
        ),
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all(
            TextStyle(
              color: themeColor,
            ),
          ),
          side: MaterialStateProperty.all(
            BorderSide(
              color: themeColor
            ),
          ),
        ),
        onPressed: () async{
          if (await canLaunch(baseConfig!.ombudsAppealUrl)) {
            await launch(baseConfig!.ombudsAppealUrl);
          } else {
            throw 'Could not launch ${baseConfig!.ombudsAppealUrl}';
          }
        }
      ),
    );
  }

  Widget _ombudsIntroBlock(double width) {
    double ombudsWidth = width/2 - 24 -4;

    return Column(
      children: [
        Row(
          children: [
            OmbudsButton(
              width: ombudsWidth,
              imageLocationString: tvPng,
              title1: '關於鏡電視',
              title2: '公評人',
              onTap: () => RouteGenerator.navigateToStory(context, 'biography'),
            ),
            SizedBox(width: 8),
            OmbudsButton(
              width: ombudsWidth,
              imageLocationString: phonePng,
              title1: '申述',
              title2: '流程',
              onTap: () => RouteGenerator.navigateToStory(context, 'complaint'),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            OmbudsButton(
              width: ombudsWidth,
              imageLocationString: paperPng,
              title1: '新聞製作',
              title2: '準則',
              onTap: () => RouteGenerator.navigateToStory(context, 'standards'),
            ),
            SizedBox(width: 8),
            OmbudsButton(
              width: ombudsWidth,
              imageLocationString: videoRecorderPng,
              title1: '影音',
              title2: '紀錄',
              onTap:  () async{
                if (await canLaunch(baseConfig!.ombudsvideoRecorderUrl)) {
                  await launch(baseConfig!.ombudsvideoRecorderUrl);
                } else {
                  throw 'Could not launch ${baseConfig!.ombudsvideoRecorderUrl}';
                }
              }
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            OmbudsButton(
              width: ombudsWidth,
              imageLocationString: faqPng,
              title1: '常見問題',
              title2: 'FAQ',
              onTap: () => RouteGenerator.navigateToStory(context, 'faq'),
            ),
            SizedBox(width: 8),
            OmbudsButton(
              width: ombudsWidth,
              imageLocationString: reportPng,
              title1: '季報',
              title2: '年報',
              onTap:  () async{
                if (await canLaunch(baseConfig!.ombudsReportsUrl)) {
                  await launch(baseConfig!.ombudsReportsUrl);
                } else {
                  throw 'Could not launch ${baseConfig!.ombudsReportsUrl}';
                }
              }
            ),
          ],
        ),
      ],
    );
  }
}