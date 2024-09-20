enum IncidentSeverity {
  veryLow,
  low,
  medium,
  high,
  veryHigh,
}

class Incident {
  // General Info
  final DateTime _timestamp;
  final String _description;
  final IncidentSeverity _severity;
  final String? _image; // TODO: implement image

  Incident(
    this._timestamp,
    this._description,
    this._severity,
    this._image,
  );

  DateTime get timestamp => _timestamp;

  String get description => _description;

  IncidentSeverity get severity => _severity;

  String? get image => _image;

  factory Incident.fromMap(Map<String, dynamic> map) {
    return Incident(
      DateTime.parse(map['timestamp']),
      map['description'],
      IncidentSeverity.values[map['severity']],
      map['image'],
    );
  }
}
