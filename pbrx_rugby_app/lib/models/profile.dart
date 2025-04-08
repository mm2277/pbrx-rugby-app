import 'package:flutter/material.dart';
import 'package:pbrx_rugby_app/models/store_data_locally.dart';

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
  
  Profile stringToProfile(String string){
    Profile profile = Profile(name: "", position: Position.back, skills: []);
    
    List<String> listOfLines = string.split("\n");
    //first line should be name
    profile.setName(listOfLines[0]);

    //second line is the postion
    Position position = Position.back;
    position = position.positionFromString(listOfLines[1]);
    
    //the rest of the lines are skills
    List<Skills> skills = [];
    for (int i = 2; i < listOfLines.length; i++) {
      //tmp value
      Skills skill = Skills.boxKick;

      skills.add(skill);
    }
    profile.setSkills(skills);
    //second line should be name of position

    return profile;
  }

}