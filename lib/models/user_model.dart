class UserModel {
  final String id;
  final String username;
  final int? age;
  final String? number;
  final String? city;
  final String? country;
  final String? language;
  final String? imageUrl;
  final String? bio;
  final String? fullName; // 💡 'fullname' ko yahan define kiya

  UserModel({
    required this.id,
    required this.username,
    // 💡 Constructor mein 'fullName' add kiya
    this.fullName,
    this.age,
    this.number,
    this.city,
    this.country,
    this.language,
    this.imageUrl,
    this.bio,
  });

  // Factory method: JSON/Map se Object banane ke liye
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: (json['username'] as String?) ?? '',
      fullName: json['fullname'] as String?,
      age: json['age'] as int?,
      number: json['number'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      language: json['language'] as String?,
      // NOTE: Database column name 'avatar_url' ya 'image_url' ho sakta hai
      imageUrl: json['image_url'] as String?,
      bio: json['bio'] as String?,
    );
  }
}