enum Position {
  forward(name: 'Forward'),
  back(name: 'Back');

  const Position({required this.name});
  final String name;

  Position positionFromString(String value) {
    return Position.values.firstWhere((e) => e.name == value);
  }
}

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

  Skills skillsFromString(String value) {
    return Skills.values.firstWhere((e) => e.name == value);
  }
}

enum Ability {
  beginner(name: 'Beginner'),
  intermediate(name: 'Intermediate'),
  advanced(name: 'Advanced');

  const Ability({required this.name});
  final String name;

  static Ability fromString(String value) {
    return Ability.values.firstWhere(
      (a) => a.name.toLowerCase() == value.toLowerCase(),
      orElse: () => Ability.beginner,
    );
  }
}

class Profile {
  String? name;
  Position? position;
  List<Skills>? skills;
  Ability? ability;

  Profile({this.name, this.position, this.skills, this.ability});

  String get safeName => name ?? "N/A";
  String get safePosition => position?.name ?? "Unknown";
  String get safeAbility => ability?.name ?? "Unknown";
  List<Skills> get safeSkillsList => skills ?? [];

  String get safeSkills => (skills != null && skills!.isNotEmpty)
      ? skills!.map((s) => s.name).join(', ')
      : "No skills selected";

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

  // Setters
  void setName(String name) => this.name = name;
  void setPosition(Position position) => this.position = position;
  void setSkills(List<Skills> skills) => this.skills = skills;
  void setAbility(Ability ability) => this.ability = ability;

  // Parses string back to profile
  static Profile stringToProfile(String string) {
    List<String> lines = string.trim().split('\n');

    if (lines.length < 3) {
      throw FormatException(
          "Invalid profile format: expected name, position, ability, and optionally skills");
    }

    final name = lines[0];
    final positionString = lines[1];
    final abilityString = lines[2];

    final Position position = Position.values.firstWhere(
      (p) => p.name == positionString,
      orElse: () => Position.back,
    );

    final Ability ability = Ability.fromString(abilityString);

    final skills = lines.length > 3
        ? lines.sublist(3).map<Skills>((line) {
            return Skills.values.firstWhere(
              (s) => s.name == line,
              orElse: () => Skills.boxKick,
            );
          }).toList()
        : <Skills>[];

    return Profile(
        name: name, position: position, skills: skills, ability: ability);
  }
}
