import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/theme/theme_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../login_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          // Profile Section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: 36,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. John Smith',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        'Dentist',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    color: colorScheme.primary,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // App Settings
          _buildSectionHeader(context, 'App Settings'),
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return SwitchListTile(
                secondary: Icon(
                  state.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: colorScheme.primary,
                ),
                title: const Text('Dark Mode'),
                subtitle: Text(
                  state.isDarkMode
                      ? 'Dark theme enabled'
                      : 'Light theme enabled',
                ),
                value: state.isDarkMode,
                onChanged: (_) => context.read<ThemeBloc>().add(ToggleTheme()),
              );
            },
          ),
          ListTile(
            leading:
                Icon(Icons.notifications_outlined, color: colorScheme.primary),
            title: const Text('Notifications'),
            subtitle: const Text('Manage notification preferences'),
            trailing: Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.sync, color: colorScheme.primary),
            title: const Text('Sync Data'),
            subtitle: const Text('Sync data with cloud'),
            trailing: Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant,
            ),
            onTap: () {},
          ),
          const Divider(indent: 16, endIndent: 16),

          // Security
          _buildSectionHeader(context, 'Security'),
          ListTile(
            leading: Icon(Icons.lock_outline, color: colorScheme.secondary),
            title: const Text('Change Password'),
            trailing: Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.fingerprint, color: colorScheme.secondary),
            title: const Text('Biometric Login'),
            subtitle: const Text('Use fingerprint or face ID'),
            trailing: Switch(
              value: false,
              onChanged: (_) {},
            ),
          ),
          const Divider(indent: 16, endIndent: 16),

          // About
          _buildSectionHeader(context, 'About'),
          ListTile(
            leading: Icon(Icons.info_outline, color: colorScheme.tertiary),
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: Icon(Icons.help_outline, color: colorScheme.tertiary),
            title: const Text('Help & Support'),
            trailing: Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant,
            ),
            onTap: () {},
          ),
          ListTile(
            leading:
                Icon(Icons.description_outlined, color: colorScheme.tertiary),
            title: const Text('Terms & Privacy'),
            trailing: Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant,
            ),
            onTap: () {},
          ),
          const Divider(indent: 16, endIndent: 16),

          // Logout
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.tonalIcon(
              onPressed: () {
                _showLogoutDialog(context);
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: FilledButton.styleFrom(
                foregroundColor: colorScheme.error,
                backgroundColor: colorScheme.errorContainer.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          Icons.logout,
          color: colorScheme.error,
          size: 48,
        ),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
