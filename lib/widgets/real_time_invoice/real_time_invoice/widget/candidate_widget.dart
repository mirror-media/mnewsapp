import 'package:flutter/material.dart';
import '../../data/enum/organize.dart';

class CandidateWidget extends StatelessWidget {
  const CandidateWidget({
    super.key,
    this.imagePath,
    required this.organize,
  });

  final Organize organize;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.network(
          organize.candidatePictureUrl(),
          width: 40,
          height: 40,
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: 42,
          child: Row(
            children: [
              Image.asset(
                organize.logoPath(),
                width: 8,
                height: 8,
              ),
              const Spacer(),
              Image.asset(
                organize.numberIcon(),
                width: 20,
                height: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          organize.president(),
          style: const TextStyle(
              color: Color(0xFF153047),
              fontFamily: 'Noto Sans CJK TC',
              fontWeight: FontWeight.w700,
              fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(organize.vicePresident(),
            style: const TextStyle(
                color: Color(0xFF153047),
                fontFamily: 'Noto Sans CJK TC',
                fontWeight: FontWeight.w700,
                fontSize: 14)),
      ],
    );
  }
}
