import 'package:tv/helpers/dataConstants.dart';

abstract class SectionRepos {
  MNewsSection changeSection(MNewsSection sectionId);
}

class SectionServices implements SectionRepos {
  @override
  MNewsSection changeSection(MNewsSection sectionId) {
    return sectionId;
  }
}
