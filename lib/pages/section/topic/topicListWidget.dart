import 'package:flutter/material.dart';
import 'package:tv/blocs/topicList/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/helpers/paragraphFormat.dart';
import 'package:tv/helpers/routeGenerator.dart';
import 'package:tv/models/paragrpahList.dart';
import 'package:tv/models/topic.dart';
import 'package:tv/models/topicList.dart';
import 'package:tv/pages/shared/tabContentNoResultWidget.dart';

class TopicListWidget extends StatefulWidget {
  @override
  _TopicListWidgetState createState() => _TopicListWidgetState();
}

class _TopicListWidgetState extends State<TopicListWidget> {
  TopicList topicList = TopicList();
  ParagraphFormat paragraphFormat = ParagraphFormat();
  @override
  void initState() {
    _fetchTopicList();
    super.initState();
  }

  _fetchTopicList() {
    context.read<TopicListBloc>().add(FetchTopicList());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopicListBloc, TopicListState>(
      builder: (BuildContext context, TopicListState state) {
        if (state.status == TopicListStatus.error) {
          final error = state.error;
          print('TopicListError: ${error.message}');
          if (error is NoInternetException) {
            return error.renderWidget(onPressed: () => _fetchTopicList());
          }

          return error.renderWidget();
        }

        if (state.status == TopicListStatus.loaded) {
          topicList = state.topicList!;
          if (topicList.isEmpty) {
            return TabContentNoResultWidget();
          }
          return Container(
            color: Colors.white,
            padding: EdgeInsets.only(top: 16, left: 20, right: 20),
            child: _buildTopicList(),
          );
        }

        return Center(
          child: CircularProgressIndicator.adaptive(),
        );
      },
    );
  }

  Widget _buildTopicList() {
    return SafeArea(
      top: false,
      right: false,
      left: false,
      child: SingleChildScrollView(
        child: ExpansionPanelList(
          elevation: 0,
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              topicList[index].isExpanded = !isExpanded;
            });
          },
          children: topicList.map<ExpansionPanel>((topic) {
            return ExpansionPanel(
              backgroundColor: Colors.white,
              isExpanded: topic.isExpanded,
              canTapOnHeader: true,
              headerBuilder: (BuildContext context, bool isExpanded) {
                if (isExpanded) {
                  return Container(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      topic.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(0, 51, 102, 1),
                      ),
                    ),
                  );
                }
                return Container(
                  padding: EdgeInsets.only(left: 20),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    topic.name,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(0, 77, 188, 1),
                    ),
                  ),
                );
              },
              body: Container(
                padding: EdgeInsets.only(bottom: 40),
                child: _buildItem(topic),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildItem(Topic topic) {
    double width = MediaQuery.of(context).size.width;
    ParagraphList brief = topic.brief!;
    List<Widget> briefContent = [];
    for (var paragraph in brief) {
      if (paragraph.contents != null &&
          paragraph.contents!.length > 0 &&
          !_isNullOrEmpty(paragraph.contents![0].data)) {
        briefContent
            .add(paragraphFormat.parseTheParagraph(paragraph, context, 17));
      }
    }
    if (briefContent.isEmpty) {
      briefContent = [
        const SizedBox(height: 140),
        const SizedBox(height: 20),
        const SizedBox(height: 48),
      ];
    } else if (briefContent.length == 1) {
      return Container(
        width: width - 40,
        // IntrinsicHeight cost expensive, so only use when there is only one item
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: width - 40 - 140 - 8,
                child: briefContent[0],
              ),
              const SizedBox(
                width: 8,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.network(
                    topic.photoUrl!,
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                  _intoTopicButton(topic),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: width - 40,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: briefContent.length,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: width - 40 - 140 - 8,
                  child: briefContent[index],
                ),
                const SizedBox(
                  width: 8,
                ),
                Image.network(
                  topic.photoUrl!,
                  width: 140,
                  height: 140,
                  fit: BoxFit.cover,
                ),
              ],
            );
          } else if (index == briefContent.length - 1) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: width - 40 - 140 - 8,
                  child: briefContent[index],
                ),
                const SizedBox(
                  width: 8,
                ),
                _intoTopicButton(topic),
              ],
            );
          } else {
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: width - 40 - 140 - 8,
                  child: briefContent[index],
                ),
                const SizedBox(
                  width: 8,
                ),
                const SizedBox(
                  width: 140,
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _intoTopicButton(Topic topic) {
    return Container(
      width: 140,
      height: 48,
      child: TextButton(
        onPressed: () {
          RouteGenerator.navigateToTopicStoryListPage(
            context,
            topic,
          );
        },
        child: Text('進入專題'),
        style: TextButton.styleFrom(
          primary: Color.fromRGBO(1, 77, 184, 1),
          side: BorderSide(
            color: Color.fromRGBO(1, 77, 184, 1),
            width: 1,
          ),
        ),
      ),
    );
  }

  bool _isNullOrEmpty(String? input) {
    return input == null || input == '';
  }
}
