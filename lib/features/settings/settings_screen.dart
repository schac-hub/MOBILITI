import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const route = '/settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _push = true;
  bool _email = false;
  bool _geo = true;
  bool _dark = false;
  String _lang = 'Français';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Paramètres'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          const _SectionTitle('Compte'),
          _Card(children: [
            _Nav(icon: Icons.person_outline, label: 'Informations personnelles'),
            const Divider(height: 1),
            _Nav(icon: Icons.lock_outline, label: 'Mot de passe & sécurité'),
            const Divider(height: 1),
            _Nav(icon: Icons.badge_outlined, label: 'Vérification d\'identité'),
          ]),
          const SizedBox(height: 20),
          const _SectionTitle('Notifications'),
          _Card(children: [
            SwitchListTile(
              value: _push,
              onChanged: (v) => setState(() => _push = v),
              activeThumbColor: AppColors.primary,
              title: const Text('Notifications push',
                  style: TextStyle(fontSize: 14)),
              subtitle: const Text('Réservations et messages',
                  style: TextStyle(fontSize: 12, color: AppColors.muted)),
            ),
            const Divider(height: 1),
            SwitchListTile(
              value: _email,
              onChanged: (v) => setState(() => _email = v),
              activeThumbColor: AppColors.primary,
              title: const Text('E-mails', style: TextStyle(fontSize: 14)),
              subtitle: const Text('Résumés hebdomadaires',
                  style: TextStyle(fontSize: 12, color: AppColors.muted)),
            ),
          ]),
          const SizedBox(height: 20),
          const _SectionTitle('Préférences'),
          _Card(children: [
            SwitchListTile(
              value: _geo,
              onChanged: (v) => setState(() => _geo = v),
              activeThumbColor: AppColors.primary,
              title: const Text('Géolocalisation',
                  style: TextStyle(fontSize: 14)),
            ),
            const Divider(height: 1),
            SwitchListTile(
              value: _dark,
              onChanged: (v) => setState(() => _dark = v),
              activeThumbColor: AppColors.primary,
              title: const Text('Thème sombre', style: TextStyle(fontSize: 14)),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.language,
                  size: 21, color: AppColors.primary),
              title: const Text('Langue', style: TextStyle(fontSize: 14)),
              trailing: Text(
                _lang,
                style: const TextStyle(fontSize: 13, color: AppColors.muted),
              ),
              onTap: () => setState(
                () => _lang = _lang == 'Français' ? 'English' : 'Français',
              ),
            ),
          ]),
          const SizedBox(height: 20),
          const _SectionTitle('À propos'),
          _Card(children: [
            _Nav(icon: Icons.description_outlined, label: 'Conditions générales'),
            const Divider(height: 1),
            _Nav(icon: Icons.privacy_tip_outlined, label: 'Confidentialité'),
            const Divider(height: 1),
            const ListTile(
              leading:
                  Icon(Icons.info_outline, size: 21, color: AppColors.primary),
              title: Text('Version', style: TextStyle(fontSize: 14)),
              trailing: Text('1.0.0',
                  style: TextStyle(fontSize: 13, color: AppColors.muted)),
            ),
          ]),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.border),
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text('Supprimer mon compte'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
            letterSpacing: 0.4,
          ),
        ),
      );
}

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(children: children),
      );
}

class _Nav extends StatelessWidget {
  const _Nav({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: () {},
        leading: Icon(icon, size: 21, color: AppColors.primary),
        title: Text(label, style: const TextStyle(fontSize: 14)),
        trailing:
            const Icon(Icons.chevron_right, size: 18, color: AppColors.muted),
      );
}
