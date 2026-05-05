import 'package:flutter/material.dart';
import '../../data/value/image_path.dart';
import '../../model/election_row_data.dart';

class ListItemWidget extends StatelessWidget {
  const ListItemWidget({
    super.key,
    required this.electionRowData,
    required this.index,
  });

  final ElectionRowData electionRowData;
  final int index;

  @override
  Widget build(BuildContext context) {
    TextStyle fontStyle = TextStyle(
        fontSize: 13,
        color: (index % 2 == 1)
            ? const Color(0xFF004EBC)
            : const Color(0xFF153047),
        fontFamily: 'Noto Sans CJK TC');
    return Flex(
      direction: Axis.horizontal,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            electionRowData.key ?? '',
            style: fontStyle.copyWith(fontSize: 14),
          ),
        ),
        Expanded(
          flex: 1,
          child: electionRowData.renderText[0] == '*'
              ? Center(
                  child: Image.asset(ImagePath.electedIcon,
                      width: 17,
                      height: 17),
                )
              : Center(
                  child: Text(electionRowData.renderText[0], style: fontStyle)),
        ),
        const SizedBox(
          width: 7,
        ),
        Expanded(
          flex: 1,
          child: electionRowData.renderText[1] == '*'
              ? Center(
                  child: Image.asset(ImagePath.electedIcon,
                      width: 17,
                      height: 17),
                )
              : Center(
                  child: Text(electionRowData.renderText[1], style: fontStyle),
                ),
        ),
        const SizedBox(
          width: 7,
        ),
        Expanded(
          flex: 1,
          child: electionRowData.renderText[2] == '*'
              ? Center(
                  child: Image.asset(ImagePath.electedIcon,
                      width: 17,
                      height: 17))
              : Center(
                  child: Text(
                  electionRowData.renderText[2],
                  style: fontStyle,
                )),
        ),
        const SizedBox(
          width: 7,
        )
      ],
    );
  }
}
