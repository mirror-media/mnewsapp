class ProgramListItem{
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
  final String month;
  final String day;

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

  factory ProgramListItem.fromJson(Map<String, dynamic> json){
    int weekday = 0;
    switch(json['WeekDay']){
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
    return ProgramListItem(
      channelId: json['Channel ID'],
      year: json['Year'],
      weekDay: weekday,
      startTimeHour: json['Start Time(hh)'],
      startTimeMinute: json['Start Time(mm)'],
      duration: json['Duration'],
      programme: json['Programme'],
      programmeEn: json['Programme(en)'],
      epNo: json['ep no'],
      epName: json['ep name'],
      seasonNo: json['season no'],
      showClass: json['Class'],
      txCategory: json['TxCategory'],
      month: json['Month'],
      day: json['Day'],
    );
  }

  Map<String, dynamic> toJson() =>{
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