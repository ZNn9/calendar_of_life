class User {
  User({
    required this.id,
    required this.name,
    required this.age,
    required this.ageStop,
  });

  final int? id;
  final String? name;
  final int? age;
  final int? ageStop;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      name: json["name"],
      age: json["age"],
      ageStop: json["ageStop"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "birthDate": "2002-06-02",
        "ageStop": ageStop,
      };
}
