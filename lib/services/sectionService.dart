abstract class SectionRepos {
  String changeSection(String sectionId);
}

class SectionServices implements SectionRepos{
  @override
  String changeSection(String sectionId){
    return sectionId;
  }
}