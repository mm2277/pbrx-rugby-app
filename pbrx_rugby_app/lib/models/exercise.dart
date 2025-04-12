// Represents an individual exercise used in a warm-up or workout session
// Includes sets, reps, an optional description, and an optional image URL
class Exercise {
  final String name; // Name of the exercise (e.g., "Deadlift")
  final int reps; // Number of repetitions per set
  final int sets; //Number of sets
  final String? description; //Optional description or cue for the exercise
  final String? imageUrl; //Optional image URL for visual reference

  Exercise({
    required this.name,
    required this.reps,
    required this.sets,
    this.description,
    this.imageUrl,
  });

  // Factory constructor to create an Exercise from a JSON map, JSON-> Exercise
  // provides defaults for missing fields to ensure safe parsing, avoiding exceptions
  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        name: json['name'] ?? 'Unnamed Exercise',
        reps: json['reps'] ?? 0,
        sets: json['sets'] ?? 0,
        description: json['description'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
      );

  //Converts the Exercise to a JSON compatible map for saving on device
  // ignores `description` and `imageUrl` if they are null
  Map<String, dynamic> toJson() => {
        'name': name,
        'reps': reps,
        'sets': sets,
        if (description != null) 'description': description,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };
}
