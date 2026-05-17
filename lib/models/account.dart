class Account {
  final String id;
  String name;
  String email;
  String role;
  bool isActive;

  Account({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'Utilisateur',
    this.isActive = true,
  });
}
