import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/enum/organize.dart';
import 'widget/candidate_widget.dart';
import 'widget/list_item_widget.dart';
import 'real_time_invoice_controller.dart';

class RealTimeInvoiceWidget extends GetView<RealTimeInvoiceController> {
  const RealTimeInvoiceWidget(
      {super.key,
      this.getMoreButtonClick,
      this.backgroundColor,
      required this.width});

  final Function()? getMoreButtonClick;
  final Color? backgroundColor;
  final double width;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<RealTimeInvoiceController>()) {
      Get.put(RealTimeInvoiceController());
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      width: double.infinity,
      color: backgroundColor ?? const Color(0xFFF5F5F5),
      child: Stack(
        children: [
          Obx(() {
            final index = controller.rxCurrentSelect.value;
            if (index == null) return const SizedBox.shrink();
            final blockWidth = (width - 24 - 7 * 3) / 4;
            final left = blockWidth + index * blockWidth + index * 7 + 3.5;
            return Positioned(
              top: 99 - 12,
              left: left,
              child: Container(
                width: blockWidth,
                height: 245,
                color: const Color(0xEAEAEAEA),
              ),
            );
          }),
          Column(
            children: [
              const SizedBox(
                height: 24,
                width: double.infinity,
                child: Text(
                  '2024總統及立委大選開票',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Noto Sans CJK TC',
                      fontSize: 16,
                      color: Color(0xFF153047),
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF153047),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: Center(child: Obx(() {
                      final electionData = controller.rxElectionData.value;
                      return Text(
                        electionData?.title ?? '',
                        style: const TextStyle(
                            color: Color(0xFFFFCC01),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Noto Sans CJK TC'),
                      );
                    }))),
              ),
              const SizedBox(height: 16),
              Flex(
                direction: Axis.horizontal,
                children: [
                  Expanded(flex: 1, child: Container()),
                  Expanded(
                    flex: 1,
                    child: CandidateWidget(
                      organize: Organize.tpp,
                    ),
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                  Expanded(
                    flex: 1,
                    child: CandidateWidget(
                      organize: Organize.dpp,
                    ),
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                  Expanded(
                    flex: 1,
                    child: CandidateWidget(
                      organize: Organize.kmt,
                    ),
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Obx(() {
                final electionDataList =
                    controller.rxElectionData.value?.electionRowDataList;
                return electionDataList == null || electionDataList.isEmpty
                    ? const SizedBox.shrink()
                    : ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return ListItemWidget(
                            index: index,
                            electionRowData: electionDataList[index],
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const Divider(color: Color(0xFFC2C2C2));
                        },
                        itemCount: electionDataList.length);
              }),
              const Text(
                '票數說明：1.呈現票數係根據各台已報導票數輸入，與其即時票數略有落差。2.正確結果以中選會為主。',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'Noto Sans CJK TC',
                  color: Color(0xFF153047),
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Obx(() {
                  final updateAt = controller.rxElectionData.value?.updateAt;
                  return Text(
                    '最後更新時間：$updateAt',
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'Noto Sans CJK TC',
                      color: Color(0xFF9B9B9B),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: () {
                  if (getMoreButtonClick != null) {
                    getMoreButtonClick!();
                  }
                },
                child: const Text(
                  '查看更多',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      color: Color(0xFF153047),
                      fontFamily: 'Noto Sans CJK TC'),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
