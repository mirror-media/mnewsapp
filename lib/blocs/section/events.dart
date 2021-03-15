import 'package:tv/blocs/section/states.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/services/sectionService.dart';

abstract class SectionEvents{
  Stream<SectionState> run(SectionRepos sectionRepos);
}

class ChangeSection extends SectionEvents {
  final MNewsSection sectionId;
  ChangeSection(this.sectionId);
  @override
  String toString() => 'ChangeSection { SectionId: $sectionId }';

  @override
  Stream<SectionState> run(SectionRepos sectionRepos) async*{
    print(this.toString());
    try {
      MNewsSection sectionId = sectionRepos.changeSection(this.sectionId);
      yield SectionLoaded(sectionId: sectionId);
    } catch (e) {
      yield SectionError(
        error: UnknownException(e.toString()),
      );
    }
  }
}