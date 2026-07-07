class Task {
  final String id;
  final String? baseId;
  final bool isInstance;
  String name;
  String desc;
  String time; // "HH:mm" 24-hr
  int duration; // minutes
  String category; // 'personal' | 'professional'
  String priority; // 'medium'
  String recurring; // 'once'|'daily'|'weekday'|'weekend'|'weekly'|'monthly'|'interval'
  List<String>? days; // for weekly: ['Mon','Tue',...]
  List<int>? dates; // for monthly: [1,2,...31]
  int? intervalDays;
  String? recurEndDate; // 'yyyy-MM-dd'
  String date; // 'yyyy-MM-dd' key
  bool done;

  Task({
    required this.id,
    this.baseId,
    required this.isInstance,
    required this.name,
    this.desc = '',
    required this.time,
    this.duration = 30,
    required this.category,
    this.priority = 'medium',
    required this.recurring,
    this.days,
    this.dates,
    this.intervalDays,
    this.recurEndDate,
    required this.date,
    this.done = false,
  });

  Task copyWith({
    String? id,
    String? baseId,
    bool? isInstance,
    String? name,
    String? desc,
    String? time,
    int? duration,
    String? category,
    String? priority,
    String? recurring,
    List<String>? days,
    List<int>? dates,
    int? intervalDays,
    String? recurEndDate,
    String? date,
    bool? done,
  }) {
    return Task(
      id: id ?? this.id,
      baseId: baseId ?? this.baseId,
      isInstance: isInstance ?? this.isInstance,
      name: name ?? this.name,
      desc: desc ?? this.desc,
      time: time ?? this.time,
      duration: duration ?? this.duration,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      recurring: recurring ?? this.recurring,
      days: days ?? this.days,
      dates: dates ?? this.dates,
      intervalDays: intervalDays ?? this.intervalDays,
      recurEndDate: recurEndDate ?? this.recurEndDate,
      date: date ?? this.date,
      done: done ?? this.done,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'baseId': baseId,
        'isInstance': isInstance,
        'name': name,
        'desc': desc,
        'time': time,
        'duration': duration,
        'category': category,
        'priority': priority,
        'recurring': recurring,
        'days': days,
        'dates': dates,
        'intervalDays': intervalDays,
        'recurEndDate': recurEndDate,
        'date': date,
        'done': done,
      };

  factory Task.fromMap(Map<dynamic, dynamic> map) => Task(
        id: map['id'] as String,
        baseId: map['baseId'] as String?,
        isInstance: map['isInstance'] as bool? ?? false,
        name: map['name'] as String,
        desc: map['desc'] as String? ?? '',
        time: map['time'] as String,
        duration: map['duration'] as int? ?? 30,
        category: map['category'] as String,
        priority: map['priority'] as String? ?? 'medium',
        recurring: map['recurring'] as String,
        days: (map['days'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
        dates: (map['dates'] as List<dynamic>?)
            ?.map((e) => e as int)
            .toList(),
        intervalDays: map['intervalDays'] as int?,
        recurEndDate: map['recurEndDate'] as String?,
        date: map['date'] as String,
        done: map['done'] as bool? ?? false,
      );
}
