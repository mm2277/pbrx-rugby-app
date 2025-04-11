class SessionType {
  final String name;

  static final Map<String, SessionType> _registry = {};

  const SessionType._internal(this.name);

  /// Predefined session types
  static final hiit = SessionType._internal('hiit');
  static final cardio = SessionType._internal('cardio');
  static final weights = SessionType._internal('weights');
  static final mobility = SessionType._internal('mobility');
  static final recovery = SessionType._internal('recovery');

  /// Get all known types (both static and registered)
  static List<SessionType> get values => _registry.values.toList();

  /// Register a new session type dynamically
  static SessionType registerType(String name) {
    final key = name.toLowerCase();
    if (_registry.containsKey(key)) {
      return _registry[key]!;
    } else {
      final newType = SessionType._internal(name);
      _registry[key] = newType;
      return newType;
    }
  }

  /// Parse from string (with fallback to dynamic registration)
  static SessionType fromJson(String json) {
    final key = json.toLowerCase();
    return _registry[key] ?? registerType(json);
  }

  /// Convert to JSON
  String toJson() => name;

  @override
  String toString() => name;
}
