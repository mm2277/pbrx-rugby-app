//Represents a type of training session (e.g. HIIT, cardio, weights and so on)
//Supports both predefined types and custom, dynamically registered types
class SessionType { 
  final String name; // Name of the session type 

  //internal registry to store all session types by lowercase name
  static final Map<String, SessionType> _registry = {};

  // Private constructor to enforce use of predefined or registered types 
  const SessionType._internal(this.name);

  //predefined static session types as examples 
  static final hiit = SessionType._internal('HIIT');
  static final cardio = SessionType._internal('Cardio');
  static final weights = SessionType._internal('Weights');
  static final mobility = SessionType._internal('Mobility');
  static final recovery = SessionType._internal('Recovery');
  static final unknown = SessionType._internal("Unknown");

  // Returns a list of all registered session types 
  static List<SessionType> get values => _registry.values.toList();

  //Registers a new session type, if not already registered
  //always returns the existing or newly created instance
  static SessionType registerType(String name) {
    final key = name.toLowerCase(); // Normalize for case insensitive storage 
    if (_registry.containsKey(key)) {
      return _registry[key]!;
    } else {
      final newType = SessionType._internal(name); 
      _registry[key] = newType;
      return newType; 
    }
  }

  // Parses a session type from a JSON string
  // Falls back to registering a new type if it's not already known.
  static SessionType fromJson(String json) { 
    final key = json.toLowerCase(); 
    return _registry[key] ?? registerType(json); 
  }

  // Converts this session type to a JSON string
  String toJson() => name; 
 
  // returns the name as the string
  @override
  String toString() => name; 
}
