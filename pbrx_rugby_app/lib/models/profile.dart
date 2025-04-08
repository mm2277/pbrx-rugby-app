enum Position {
  forward(name: 'Forward'),
  back(name: 'Back');

  const Position({ required this.name });

  final String name;
}

enum Skills {
  kickFromTee(name: 'Kicking from Tee'),
  boxKick(name: 'Box Kick'),
  dropKick(name: "Drop Kick"),
  normalKick(name: "Kick from hand"),
  grubberKick(name: "Grubber kick"),
  scrum(name: 'Scrum'),
  lineoutLifter(name: 'Lineone Lifter'),
  lineoutJumper(name: "Lineout Jumper"),
  hookerThrow(name: "Hooker Throw");

  const Skills({ required this.name });

  final String name;
}

class Profile {
  String name;
  Position position;
  List<Skills> skills;

  Profile({ required this.name, required this.position, required this.skills});

  @override
  String toString() {
    String finalString = "";

    if (name.isNotEmpty) {
      finalString += "$name\n";
    } else {
      finalString += "N/A\n";
    }
    
    finalString += "${position.name}\n";
    
    for (Skills skill in skills) {
      finalString += "${skill.name}\n";
    }

    return finalString;
  }

  void setName(String name){
    this.name = name;
  }

    void setPosition(Position position){
    this.position = position;
  }

    void setSkills(List<Skills> skills){
    this.skills = skills;
  }
  
}