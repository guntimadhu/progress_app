class Reminder {
  final String id;
  String date; // 'yyyy-MM-dd'
  String time; // 'HH:mm' 24-hr
  String msg;

  Reminder({
    required this.id,
    required this.date,
    required this.time,
    required this.msg,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date,
        'time': time,
        'msg': msg,
      };

  factory Reminder.fromMap(Map<dynamic, dynamic> map) => Reminder(
        id: map['id'] as String,
        date: map['date'] as String,
        time: map['time'] as String,
        msg: map['msg'] as String,
      );
}
