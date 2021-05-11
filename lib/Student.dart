class Student {
  final int id;
  final String name;
  final String email;
  final int age;

  Student(this.id, this.name, this.email, this.age);

  Student.fromJson(Map<String, dynamic> json):
        id = json['id'],
        name = json['name'],
        email = json['email'],
        age = json['age'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'age': age
  };
}
