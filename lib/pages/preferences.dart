import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../page_header.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final shades = AppShades.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const PageHeader(title: 'Account', subtitle: 'Profile and preferences'),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: scheme.primary,
                      child: Text(
                        'FB',
                        style: TextStyle(
                          color: scheme.onPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your name',
                              style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text('you@example.com', style: TextStyle(color: shades.muted)),
                        ],
                      ),
                    ),
                    const OutlinedButton(onPressed: null, child: Text('Edit profile')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _Section(
              title: 'Preferences',
              rows: [
                _Row(Icons.no_food_outlined, 'Dietary restrictions', 'None set'),
                _Row(Icons.straighten, 'Units', 'US customary'),
                _Row(Icons.notifications_none, 'Expiration reminders', 'Off'),
              ],
            ),
            const SizedBox(height: 16),
            const _Section(
              title: 'Account',
              rows: [
                _Row(Icons.lock_outline, 'Change password', ''),
                _Row(Icons.logout, 'Sign out', ''),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Row {
  final IconData icon;
  final String title;
  final String value;
  const _Row(this.icon, this.title, this.value);
}

class _Section extends StatelessWidget {
  final String title;
  final List<_Row> rows;
  const _Section({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    final shades = AppShades.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: shades.ink),
              ),
            ),
            for (final r in rows)
              ListTile(
                leading: Icon(r.icon, color: shades.muted),
                title: Text(r.title),
                trailing: r.value.isEmpty
                    ? Icon(Icons.chevron_right, color: shades.muted)
                    : Text(r.value, style: TextStyle(color: shades.muted)),
              ),
          ],
        ),
      ),
    );
  }
}
