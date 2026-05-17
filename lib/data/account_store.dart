import '../models/account.dart';

/// Singleton in-memory store — remplace une vraie API dans ce mock
class AccountStore {
  static final AccountStore _instance = AccountStore._internal();
  factory AccountStore() => _instance;
  AccountStore._internal();

  final List<Account> _accounts = [
    Account(
      id: 'acc_1',
      name: 'Alice Martin',
      email: 'alice@example.com',
      role: 'Admin',
      isActive: true,
    ),
    Account(
      id: 'acc_2',
      name: 'Bob Dupont',
      email: 'bob@example.com',
      role: 'Manager',
      isActive: true,
    ),
    Account(
      id: 'acc_3',
      name: 'Claire Bernard',
      email: 'claire@example.com',
      role: 'Utilisateur',
      isActive: false,
    ),
  ];

  List<Account> get accounts => List.from(_accounts);

  void addAccount({
    required String name,
    required String email,
    required String role,
  }) {
    _accounts.add(Account(
      id: 'acc_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      role: role,
    ));
  }

  void toggleAccount(String id) {
    final index = _accounts.indexWhere((a) => a.id == id);
    if (index != -1) {
      _accounts[index].isActive = !_accounts[index].isActive;
    }
  }

  void deleteAccount(String id) {
    _accounts.removeWhere((a) => a.id == id);
  }
}
