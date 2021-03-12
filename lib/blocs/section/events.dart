import 'package:tv/blocs/section/states.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/mNewsSection.dart';
import 'package:tv/services/sectionService.dart';

abstract class SectionEvents{
  Stream<SectionState> run(SectionRepos sectionRepos);
}

class ChangeSection extends SectionEvents {
  final MNewsSection section;
  ChangeSection(this.section);
  @override
  String toString() => 'ChangeSection { MNewsSection: $section }';

  @override
  Stream<SectionState> run(SectionRepos sectionRepos) async*{
    print(this.toString());
    try {
      MNewsSection section = sectionRepos.changeSection(this.section);
      yield SectionLoaded(section: section);
    } catch (e) {
      yield SectionError(
        error: UnknownException(e.toString()),
      );
    }
  }
}