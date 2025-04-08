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
  final String name;
  final Position position;
  final List<Skills> skills;

  const Profile({ required this.name, required this.position, required this.skills});
}