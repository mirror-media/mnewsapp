import 'package:bloc/bloc.dart';
import 'package:tv/helpers/dataConstants.dart';

part 'section_state.dart';

class SectionCubit extends Cubit<SectionStateCubit> {
  SectionCubit() : super(SectionInitState());

  void loaded(MNewsSection sectionId) => emit(SectionLoaded(sectionId: sectionId));

  @override
  void onError(Object error, StackTrace stackTrace) {
    print('SectionError: $error');
    super.onError(error, stackTrace);
    emit(SectionError(error: error));
  }
}
