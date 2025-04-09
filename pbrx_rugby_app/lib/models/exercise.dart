class Exercise {
  final String name;
  final int reps;
  final int sets;
  final String? description;
  final String? imageUrl;

  Exercise({
    required this.name,
    required this.reps,
    required this.sets,
    this.description,
    this.imageUrl,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        name: json['name'],
        reps: json['reps'],
        sets: json['sets'],
        description: json['description'],
        imageUrl: json['imageUrl'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'reps': reps,
        'sets': sets,
        if (description != null) 'description': description,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };
}
