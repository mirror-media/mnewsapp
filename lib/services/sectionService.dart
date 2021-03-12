import 'package:tv/models/mNewsSection.dart';

abstract class SectionRepos {
  MNewsSection changeSection(MNewsSection section);
}

class SectionServices implements SectionRepos{
  @override
  MNewsSection changeSection(MNewsSection section){
    return section;
  }
}