//Enum representing the two general rugby positions taken from background and lit review 
enum Position {
  forward(name: 'Forward'),
  back(name: 'Back');

  const Position({required this.name});
  final String name;

  //Finds a Position from a string based on its display name
  Position positionFromString(String value) {
    return Position.values.firstWhere((e) => e.name == value);
  }
}

/// enum representing various rugby skills
enum Skills {
  kickFromTee(name: 'Kicking from Tee'),
  boxKick(name: 'Box Kick'),
  dropKick(name: "Drop Kick"),
  normalKick(name: "Kick from hand"),
  grubberKick(name: "Grubber kick"),
  scrum(name: 'Scrum'),
  lineoutLifter(name: 'Lineont Lifter'),
  lineoutJumper(name: "Lineout Jumper"),
  hookerThrow(name: "Hooker Throw");

  const Skills({required this.name});
  final String name;

  // Finds a skill from a string based on its display name
  Skills skillsFromString(String value) {
    return Skills.values.firstWhere((e) => e.name == value);
  }
}

// enum representing the player's ability level 
enum Ability {
  beginner(name: 'Beginner'),
  intermediate(name: 'Intermediate'),
  advanced(name: 'Advanced');

  const Ability({required this.name});
  final String name;

  // Parses a string to an Ability, case-insensitive 
  // Defaults to Beginner if no match found
  static Ability fromString(String value) {
    return Ability.values.firstWhere(
      (a) => a.name.toLowerCase() == value.toLowerCase(),
      orElse: () => Ability.beginner,
    );
  }
}

//profile class
class Profile {
  String? name;
  Position? position;
  List<Skills>? skills;
  Ability? ability;

  Profile({this.name, this.position, this.skills, this.ability});

  // Safely returns the name or "N/A"
  String get safeName => name ?? "N/A";

  // Safely returns the position name or "Unknown"
  String get safePosition => position?.name ?? "Unknown";

  // Safely returns the ability name or "Unknown"
  String get safeAbility => ability?.name ?? "Unknown";

  //returns skills list, or empty list if null
  List<Skills> get safeSkillsList => skills ?? [];

  //returns a comma-separated string of skills or a fallback
  String get safeSkills => (skills != null && skills!.isNotEmpty)
      ? skills!.map((s) => s.name).join(', ')
      : "No skills selected";

  //converts profile into a human-readable string to save in txt
  @override
  String toString() {
    String finalString = "";

    finalString += "${name ?? "N/A"}\n";
    finalString += "${position?.name ?? "Unknown"}\n";
    finalString += "${ability?.name ?? "Unknown"}\n";

    if (skills != null && skills!.isNotEmpty) {
      for (var skill in skills!) {
        finalString += "${skill.name}\n";
      }
    } else {
      finalString += "No skills\n";
    }

    return finalString;
  }

  // --------------------------
  // Setters
  // --------------------------

  void setName(String name) => this.name = name;
  void setPosition(Position position) => this.position = position;
  void setSkills(List<Skills> skills) => this.skills = skills;
  void setAbility(Ability ability) => this.ability = ability;

  // --------------------------
  // Deserialization
  // --------------------------

  /// Parses a newline-separated string back into a Profile object.
  /// Expects format: name\nposition\nability\n[skills...]
  static Profile stringToProfile(String string) {
    List<String> lines = string.trim().split('\n');

    if (lines.length < 3) {
      throw FormatException(
        "Invalid profile format: expected name, position, ability, and optionally skills",
      );
    }

    final name = lines[0];
    final positionString = lines[1];
    final abilityString = lines[2];

    // Safely convert position and ability strings
    final Position position = Position.values.firstWhere(
      (p) => p.name == positionString,
      orElse: () => Position.back,
    );

    final Ability ability = Ability.fromString(abilityString);

    // Parse skills from remaining lines, if any
    final skills = lines.length > 3
        ? lines.sublist(3).map<Skills>((line) {
            return Skills.values.firstWhere(
              (s) => s.name == line,
              orElse: () => Skills.boxKick,
            );
          }).toList()
        : <Skills>[];

    return Profile(
      name: name,
      position: position,
      skills: skills,
      ability: ability,
    );
  }
}
