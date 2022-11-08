import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/models/election/candidate.dart';
import 'package:tv/models/election/municipality.dart';

class MunicipalityItem extends StatelessWidget {
  final Municipality municipality;
  const MunicipalityItem(this.municipality, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat("###,###,###,##0");
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        Candidate item = municipality.candidates[index];
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${item.number} ${item.name}',
                  style: TextStyle(
                    color: item.elected
                        ? Color.fromRGBO(219, 76, 101, 1)
                        : Color.fromRGBO(0, 77, 188, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(
                  width: 8,
                ),
                if (partyLogoMap[item.party] != null)
                  SvgPicture.asset(
                    partyLogoMap[item.party]!,
                    width: 16,
                    height: 16,
                  )
                else
                  Text(
                    item.party,
                    style: const TextStyle(
                      color: Color.fromRGBO(74, 74, 74, 0.75),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(
                  width: 8,
                ),
                if (item.elected)
                  SvgPicture.asset(
                    electedSvg,
                    width: 16,
                    height: 16,
                  ),
              ],
            ),
            LinearPercentIndicator(
              key: Key(item.name + item.number),
              percent: item.percentageOfVotesObtained / 100,
              center: Row(
                children: [
                  const SizedBox(
                    width: 6.68,
                  ),
                  Text(
                    numberFormat.format(item.votes),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              lineHeight: 24,
              animation: true,
              backgroundColor: const Color.fromRGBO(244, 245, 246, 1),
              progressColor: item.elected
                  ? const Color.fromRGBO(216, 76, 101, 1)
                  : const Color.fromRGBO(0, 51, 102, 1),
              padding: const EdgeInsets.only(top: 5),
            ),
          ],
        );
      },
      itemCount: municipality.candidates.length > 3
          ? 3
          : municipality.candidates.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 8),
    );
  }
}
