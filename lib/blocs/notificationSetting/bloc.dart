import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/notificationSetting/events.dart';
import 'package:tv/blocs/notificationSetting/states.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/models/notificationSetting.dart';
import 'package:tv/services/notificationSettingService.dart';

class NotificationSettingBloc
    extends Bloc<NotificationSettingEvents, NotificationSettingState> {
  final NotificationSettingRepos notificationSettingRepos;

  NotificationSettingBloc({required this.notificationSettingRepos})
      : super(NotificationSettingInitState()) {
    on<NotificationSettingEvents>(
      (event, emit) async {
        print(event.toString());
        try {
          if (event is GetNotificationSettingList) {
            emit(NotificationSettingLoading());
            List<NotificationSetting> notificationSettingList =
                await notificationSettingRepos.getNotificationSettingList();
            emit(NotificationSettingLoaded(
                notificationSettingList: notificationSettingList));
          } else if (event is NotificationOnExpansionChanged) {
            List<NotificationSetting> notificationSettingList =
                notificationSettingRepos.onExpansionChanged(
              event.inputNotificationSettingList,
              event.index,
              event.value,
            );
            emit(NotificationSettingLoaded(
                notificationSettingList: notificationSettingList));
          } else if (event is NotificationOnCheckBoxChanged) {
            List<NotificationSetting> notificationSettingList =
                notificationSettingRepos.onCheckBoxChanged(
              event.inputNotificationSettingList,
              event.checkboxList,
              event.index,
              event.isRepeatable,
            );
            emit(NotificationSettingLoaded(
                notificationSettingList: notificationSettingList));
          }
        } catch (e) {
          print('${event.toString()} error: $e');
          emit(NotificationSettingError(
            error: determineException(e),
          ));
        }
      },
    );
  }
}
