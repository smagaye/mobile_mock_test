import 'package:flutter/material.dart';
import '../data/account_store.dart';
import '../models/account.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final _store = AccountStore();

  // ── Suppression avec confirmation ─────────────
  Future<void> _confirmDelete(Account account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content:
            Text('Supprimer le compte de ${account.name} ? Cette action est irréversible.'),
        actions: [
          Semantics(
            identifier: 'delete_cancel_button',
            child: TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler'),
            ),
          ),
          Semantics(
            identifier: 'delete_confirm_button',
            child: FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.shade600),
              child: const Text('Supprimer'),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _store.deleteAccount(account.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${account.name} supprimé'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ── Couleur par rôle ──────────────────────────
  Color _roleColor(String role) => switch (role) {
        'Admin' => const Color(0xFF6366F1),
        'Manager' => const Color(0xFF0EA5E9),
        _ => const Color(0xFF10B981),
      };

  @override
  Widget build(BuildContext context) {
    final accounts = _store.accounts;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Comptes', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              '${accounts.length} compte${accounts.length > 1 ? 's' : ''}',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          Semantics(
            identifier: 'logout_button',
            child: IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Déconnexion',
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/login'),
            ),
          ),
        ],
      ),

      // ── FAB ───────────────────────────────────
      floatingActionButton: Semantics(
        identifier: 'add_account_button',
        child: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.pushNamed(context, '/create');
            setState(() {});
          },
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Nouveau compte'),
        ),
      ),

      body: accounts.isEmpty
          // ── État vide ──────────────────────────
          ? Semantics(
              identifier: 'empty_state',
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline_rounded,
                        size: 72, color: cs.outlineVariant),
                    const SizedBox(height: 16),
                    Text('Aucun compte',
                        style: TextStyle(
                            fontSize: 16, color: cs.outline)),
                    const SizedBox(height: 8),
                    Text('Crée le premier compte avec le bouton +',
                        style: TextStyle(
                            fontSize: 13, color: cs.outlineVariant)),
                  ],
                ),
              ),
            )
          // ── Liste des comptes ──────────────────
          : Semantics(
              identifier: 'accounts_list',
              child: ListView.separated(
                padding:
                    const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: accounts.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  return _AccountCard(
                    account: account,
                    roleColor: _roleColor(account.role),
                    onToggle: () =>
                        setState(() => _store.toggleAccount(account.id)),
                    onDelete: () => _confirmDelete(account),
                  );
                },
              ),
            ),
    );
  }
}

// ── Widget carte compte ────────────────────────────
class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.account,
    required this.roleColor,
    required this.onToggle,
    required this.onDelete,
  });

  final Account account;
  final Color roleColor;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Semantics(
      identifier: 'account_item_${account.id}',
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: account.isActive
                ? cs.outlineVariant.withOpacity(0.4)
                : cs.outlineVariant.withOpacity(0.2),
          ),
        ),
        color: account.isActive ? null : cs.surfaceVariant.withOpacity(0.4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // ── Avatar ──────────────────────────
              CircleAvatar(
                radius: 26,
                backgroundColor: account.isActive
                    ? cs.primary.withOpacity(0.12)
                    : cs.outlineVariant.withOpacity(0.25),
                child: Text(
                  account.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: account.isActive ? cs.primary : cs.outline,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // ── Infos ────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      identifier: 'account_name_${account.id}',
                      child: Text(
                        account.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: account.isActive
                              ? cs.onSurface
                              : cs.outline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      account.email,
                      style: TextStyle(
                          fontSize: 13, color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Role badge
                        _Badge(
                          label: account.role,
                          color: roleColor,
                        ),
                        const SizedBox(width: 6),
                        // Status badge
                        Semantics(
                          identifier: 'account_status_${account.id}',
                          child: _Badge(
                            label: account.isActive ? 'Actif' : 'Inactif',
                            color: account.isActive
                                ? const Color(0xFF10B981)
                                : cs.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Actions ──────────────────────────
              Column(
                children: [
                  // Toggle
                  Semantics(
                    identifier: 'toggle_button_${account.id}',
                    child: IconButton(
                      onPressed: onToggle,
                      tooltip: account.isActive ? 'Désactiver' : 'Activer',
                      icon: Icon(
                        account.isActive
                            ? Icons.toggle_on_rounded
                            : Icons.toggle_off_rounded,
                        size: 34,
                        color: account.isActive
                            ? cs.primary
                            : cs.outline,
                      ),
                    ),
                  ),
                  // Supprimer
                  Semantics(
                    identifier: 'delete_button_${account.id}',
                    child: IconButton(
                      onPressed: onDelete,
                      tooltip: 'Supprimer',
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: cs.error,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Badge rôle / statut ────────────────────────────
class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
