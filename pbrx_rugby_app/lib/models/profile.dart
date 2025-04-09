enum Position {
  forward(name: 'Forward'),
  back(name: 'Back');

  const Position({ required this.name });

  final String name;

  Position positionFromString(String value) {
  return Position.values.firstWhere(
    (e) => e.name == value,
  );
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

  const Skills({ required this.name });

  final String name;

  Skills skillsFromString(String value) {
  return Skills.values.firstWhere(
    (e) => e.name == value,
  );}
}

class Profile {
  String? name;
  Position? position;
  List<Skills>? skills;

  Profile({ this.name, this.position, this.skills });

  String get safeName => name ?? "N/A";

  String get safePosition => position?.name ?? "Unknown";

  List<Skills> get safeSkillsList => skills ?? [];

  String get safeSkills =>
      (skills != null && skills!.isNotEmpty)
          ? skills!.map((s) => s.name).join(', ')
          : "No skills selected";

  @override
  String toString() {
    String finalString = "";

    finalString += "${name ?? "N/A"}\n";
    finalString += "${position?.name ?? "Unknown"}\n";

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
  void setName(String name){
    this.name = name;
  }

  void setPosition(Position position){
    this.position = position;
  }

  void setSkills(List<Skills> skills){
    this.skills = skills;
  }
  
  //function to turn a string into a profile type
static Profile stringToProfile(String string) {
  List<String> lines = string.trim().split('\n');

  if (lines.length < 2) {
    throw FormatException("Invalid profile format: expected at least name and position");
  }

  final String name = lines[0];
  final String positionString = lines[1];

  // Convert position string to enum
  final Position position = Position.values.firstWhere(
    (p) => p.name == positionString,
    orElse: () => Position.back,
  );

  // Convert remaining lines to skills
  final List<Skills> skills = lines.sublist(2).map((line) {
    return Skills.values.firstWhere(
      (s) => s.name == line,
      orElse: () => Skills.boxKick, // fallback skill if unrecognized
    );
  }).toList();

  return Profile(name: name, position: position, skills: skills);
}

}