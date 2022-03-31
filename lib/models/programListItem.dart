class ProgramListItem {
  final String channelId;
  final int year;
  final int weekDay;
  final int startTimeHour;
  final int startTimeMinute;
  final int? duration;
  final String programme;
  final String programmeEn;
  final double? epNo;
  final String epName;
  final String? seasonNo;
  final String showClass;
  final String txCategory;
  final int month;
  final int day;

  ProgramListItem({
    required this.channelId,
    required this.year,
    required this.weekDay,
    required this.startTimeHour,
    required this.startTimeMinute,
    this.duration,
    required this.programme,
    required this.programmeEn,
    this.epNo,
    required this.epName,
    this.seasonNo,
    required this.showClass,
    required this.txCategory,
    required this.month,
    required this.day,
  });

  factory ProgramListItem.fromJson(Map<String, dynamic> json) {
    int weekday = 0;
    switch (json['WeekDay']) {
      case 'mon':
        weekday = 1;
        break;
      case 'tue':
        weekday = 2;
        break;
      case 'wed':
        weekday = 3;
        break;
      case 'thu':
        weekday = 4;
        break;
      case 'fri':
        weekday = 5;
        break;
      case 'sat':
        weekday = 6;
        break;
      case 'sun':
        weekday = 7;
        break;
    }

    int? duration;
    if (json['Duration'] != null) {
      duration = int.tryParse(json['Duration']);
    }

    int year;
    if (json['Year'] is int) {
      year = json['Year'];
    } else {
      year = int.parse(json['Year']);
    }

    int startTimeHour;
    if (json['Start Time(hh)'] is int) {
      startTimeHour = json['Start Time(hh)'];
    } else {
      startTimeHour = int.parse(json['Start Time(hh)']);
    }

    int startTimeMinute;
    if (json['Start Time(mm)'] is int) {
      startTimeMinute = json['Start Time(mm)'];
    } else {
      startTimeMinute = int.parse(json['Start Time(mm)']);
    }

    int month;
    if (json['Month'] is int) {
      month = json['Month'];
    } else {
      month = int.parse(json['Month']);
    }

    int day;
    if (json['Day'] is int) {
      day = json['Day'];
    } else {
      day = int.parse(json['Day']);
    }

    return ProgramListItem(
      channelId: json['Channel ID'] ?? "鏡新聞",
      year: year,
      weekDay: weekday,
      startTimeHour: startTimeHour,
      startTimeMinute: startTimeMinute,
      duration: duration,
      programme: json['Programme'],
      programmeEn: json['Programme(en)'],
      epName: json['ep name'],
      seasonNo: json['season no'],
      showClass: json['Class'],
      txCategory: json['TxCategory'],
      month: month,
      day: day,
    );
  }

  Map<String, dynamic> toJson() => {
        'Channel ID': channelId,
        'Year': year,
        'WeekDay': weekDay,
        'Start Time(hh)': startTimeHour,
        'Start Time(mm)': startTimeMinute,
        'Duration': duration,
        'Programme': programme,
        'Programme(en)': programmeEn,
        'ep no': epNo,
        'ep name': epName,
        'season no': seasonNo,
        'Class': showClass,
        'TxCategory': txCategory,
        'Month': month,
        'Day': day
      };
}
