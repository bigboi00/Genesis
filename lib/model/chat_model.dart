class ChatModel {
  final String gender;
  final String name;
  final String age;
  final String id;
  final String userId;
  final String? profile;
    

  ChatModel({
    required this.name,
    required this.gender,
    required this.age,
    required this.id,
    required this.userId,
    this.profile,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gender': gender,
      'age': age,
      'id': id,
      'userId': userId,
      'profile': profile,
    };
  }

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      name: json['name'],
      gender: json['gender'],
      age: json['age'],
      id: json['id'],
      userId: json['userId'],
      profile: json['profile'],
    );
  }
}
