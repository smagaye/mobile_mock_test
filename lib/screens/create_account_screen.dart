import 'package:flutter/material.dart';
import '../data/account_store.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _role = 'Utilisateur';
  bool _loading = false;
  String? _error;

  final _store = AccountStore();
  final _roles = ['Utilisateur', 'Manager', 'Admin'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    // Validation
    if (name.isEmpty || email.isEmpty) {
      setState(() => _error = 'Tous les champs sont obligatoires.');
      return;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      setState(() => _error = 'Adresse email invalide.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    // Simule un appel API
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    _store.addAccount(name: name, email: email, role: _role);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Compte de $name créé avec succès'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF10B981),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau compte',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: Semantics(
          identifier: 'cancel_button',
          child: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Annuler',
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: cs.primary.withOpacity(0.15),
                    child:
                        Icon(Icons.person_add_alt_1, color: cs.primary),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nouveau compte',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: cs.primary)),
                      Text('Remplir les informations ci-dessous',
                          style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Nom ───────────────────────────────
            Semantics(
              identifier: 'name_field',
              child: TextField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nom complet *',
                  hintText: 'Ex: Jean Dupont',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Email ─────────────────────────────
            Semantics(
              identifier: 'create_email_field',
              child: TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Adresse email *',
                  hintText: 'Ex: jean@example.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Rôle ──────────────────────────────
            Semantics(
              identifier: 'role_field',
              child: DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(
                  labelText: 'Rôle',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                items: _roles
                    .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(r),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _role = v!),
              ),
            ),

            // ── Erreur ────────────────────────────
            if (_error != null) ...[
              const SizedBox(height: 14),
              Semantics(
                identifier: 'create_error',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: cs.errorContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: cs.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(
                              color: cs.error, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 36),

            // ── Bouton créer ──────────────────────
            Semantics(
              identifier: 'create_button',
              child: FilledButton(
                onPressed: _loading ? null : _create,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text('Créer le compte',
                        style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
