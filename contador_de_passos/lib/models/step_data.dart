class StepData {
  final int totalSteps;
  final DateTime date;
  final String source;

  StepData({
    required this.totalSteps,
    required this.date,
    required this.source,
  });

  factory StepData.fromJson(Map<String, dynamic> json) {
    return StepData(
      totalSteps: json['totalSteps'] ?? 0,
      date: DateTime.parse(json['date']),
      source: json['source'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSteps': totalSteps,
      'date': date.toIso8601String(),
      'source': source,
    };
  }
}