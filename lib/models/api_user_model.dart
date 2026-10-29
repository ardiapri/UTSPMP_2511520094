
class ApiUserModel {
  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String website;
  final String companyName;

  const ApiUserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.website,
    required this.companyName,
  });

  factory ApiUserModel.fromJson(Map<String, dynamic> json) {
    final company = json['company'] as Map<String, dynamic>? ?? {};

    return ApiUserModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      website: json['website'] as String? ?? '',
      companyName: company['name'] as String? ?? '',
    );
  }
}
