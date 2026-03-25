import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/theme/theme_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/notification_settings.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/services/biometric_service.dart';
import '../../../di/injection_container.dart';
import '../login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final BiometricService _biometricService = BiometricService();
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  bool _isSyncing = false;
  NotificationSettings _notificationSettings = const NotificationSettings();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load biometric settings
    final isAvailable = await _biometricService.isBiometricAvailable();
    final isEnabled = await _biometricService.isBiometricEnabled();

    // Load notification settings using GetIt service locator
    final notifSettings = await sl<AuthRepository>().getNotificationSettings();

    if (mounted) {
      setState(() {
        _isBiometricAvailable = isAvailable;
        _isBiometricEnabled = isEnabled;
        _notificationSettings = notifSettings;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // Clear any loading snackbar
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.error,
              ),
            );
          } else if (state is Authenticated) {
            // Show success message when user is updated
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Name updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: ListView(
          children: [
            // Profile Section
            _buildProfileSection(context),
            const SizedBox(height: 8),

            // App Settings
            _buildSectionHeader(context, 'App Settings'),
            _buildAppSettings(context),
            const Divider(indent: 16, endIndent: 16),

            // Security
            _buildSectionHeader(context, 'Security'),
            _buildSecuritySection(context),
            const Divider(indent: 16, endIndent: 16),

            // About
            _buildSectionHeader(context, 'About'),
            _buildAboutSection(context),
            const Divider(indent: 16, endIndent: 16),

            // Logout
            _buildLogoutSection(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        UserModel? user;
        String role = 'Dentist';

        if (state is Authenticated) {
          user = state.user;
          role = user.role.displayName;
        }

        return Container(
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
                child: Text(
                  user?.initials ?? 'U',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'User',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      role,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    Text(
                      user?.email ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                onPressed: () =>
                    _showEditNameDialog(context, user?.name ?? 'User'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppSettings(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Dark Mode
        BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            return SwitchListTile(
              secondary: Icon(
                state.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: colorScheme.primary,
              ),
              title: const Text('Dark Mode'),
              subtitle: Text(
                state.isDarkMode ? 'Dark theme enabled' : 'Light theme enabled',
              ),
              value: state.isDarkMode,
              onChanged: (_) => context.read<ThemeBloc>().add(ToggleTheme()),
            );
          },
        ),

        // Notifications
        ListTile(
          leading:
              Icon(Icons.notifications_outlined, color: colorScheme.primary),
          title: const Text('Notifications'),
          subtitle: Text(
            _notificationSettings.enabled
                ? 'Notifications enabled'
                : 'Notifications disabled',
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: colorScheme.onSurfaceVariant,
          ),
          onTap: () => _showNotificationSettingsDialog(context),
        ),

        // Sync Data
        ListTile(
          leading: _isSyncing
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                )
              : Icon(Icons.sync, color: colorScheme.primary),
          title: const Text('Sync Data'),
          subtitle: Text(_isSyncing ? 'Syncing...' : 'Sync data with cloud'),
          trailing: Icon(
            Icons.chevron_right,
            color: colorScheme.onSurfaceVariant,
          ),
          onTap: _isSyncing ? null : () => _syncData(context),
        ),
      ],
    );
  }

  Widget _buildSecuritySection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Change Password
        ListTile(
          leading: Icon(Icons.lock_outline, color: colorScheme.secondary),
          title: const Text('Change Password'),
          trailing: Icon(
            Icons.chevron_right,
            color: colorScheme.onSurfaceVariant,
          ),
          onTap: () => _showChangePasswordDialog(context),
        ),

        // Biometric Login
        ListTile(
          leading: Icon(Icons.fingerprint, color: colorScheme.secondary),
          title: const Text('Biometric Login'),
          subtitle: _isBiometricAvailable
              ? Text(_isBiometricEnabled ? 'Enabled' : 'Disabled')
              : const Text('Not available on this device'),
          trailing: _isBiometricAvailable
              ? Switch(
                  value: _isBiometricEnabled,
                  onChanged: (value) => _toggleBiometric(context, value),
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
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
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Help & Support coming soon')),
            );
          },
        ),
        ListTile(
          leading:
              Icon(Icons.description_outlined, color: colorScheme.tertiary),
          title: const Text('Terms & Privacy'),
          trailing: Icon(
            Icons.chevron_right,
            color: colorScheme.onSurfaceVariant,
          ),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Terms & Privacy coming soon')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLogoutSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
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

  // Dialog Methods

  void _showEditNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.edit, color: colorScheme.primary),
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != currentName) {
                final state = context.read<AuthBloc>().state;
                if (state is Authenticated) {
                  // Close dialog first
                  Navigator.pop(ctx);
                  // Show loading indicator
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 16),
                          Text('Updating name...'),
                        ],
                      ),
                      duration: Duration(seconds: 10),
                    ),
                  );
                  // Dispatch update event
                  context.read<AuthBloc>().add(
                        UpdateUserProfile(
                          userId: state.user.id,
                          name: newName,
                        ),
                      );
                }
              } else {
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettingsDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    NotificationSettings tempSettings = _notificationSettings;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            icon: Icon(Icons.notifications, color: colorScheme.primary),
            title: const Text('Notification Settings'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  value: tempSettings.enabled,
                  onChanged: (value) {
                    setDialogState(() {
                      tempSettings = tempSettings.copyWith(enabled: value);
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Sound'),
                  value: tempSettings.sound,
                  onChanged: tempSettings.enabled
                      ? (value) {
                          setDialogState(() {
                            tempSettings = tempSettings.copyWith(sound: value);
                          });
                        }
                      : null,
                ),
                SwitchListTile(
                  title: const Text('Vibration'),
                  value: tempSettings.vibration,
                  onChanged: tempSettings.enabled
                      ? (value) {
                          setDialogState(() {
                            tempSettings =
                                tempSettings.copyWith(vibration: value);
                          });
                        }
                      : null,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  await sl<AuthRepository>()
                      .saveNotificationSettings(tempSettings);
                  setState(() {
                    _notificationSettings = tempSettings;
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Notification settings saved')),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _syncData(BuildContext context) async {
    setState(() {
      _isSyncing = true;
    });

    try {
      final success = await sl<AuthRepository>().syncData();

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data synced successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Sync failed. Please try again.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            icon: Icon(Icons.lock, color: colorScheme.secondary),
            title: const Text('Change Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      errorMessage!,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                TextField(
                  controller: currentPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                    helperText: 'Minimum 8 characters',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final current = currentPasswordController.text;
                  final newPass = newPasswordController.text;
                  final confirm = confirmPasswordController.text;

                  if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
                    setDialogState(() {
                      errorMessage = 'Please fill in all fields';
                    });
                    return;
                  }

                  if (newPass.length < 8) {
                    setDialogState(() {
                      errorMessage = 'Password must be at least 8 characters';
                    });
                    return;
                  }

                  if (newPass != confirm) {
                    setDialogState(() {
                      errorMessage = 'New passwords do not match';
                    });
                    return;
                  }

                  Navigator.pop(ctx);

                  // Show loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  // Change password
                  context.read<AuthBloc>().add(
                        ChangePassword(
                          currentPassword: current,
                          newPassword: newPass,
                        ),
                      );

                  // Close loading and show result
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Password changed successfully')),
                  );
                },
                child: const Text('Change'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _toggleBiometric(BuildContext context, bool value) async {
    if (value) {
      // First authenticate with biometrics to enable
      final authenticated = await _biometricService.authenticate(
        reason: 'Authenticate to enable biometric login',
      );

      if (authenticated) {
        await _biometricService.setBiometricEnabled(true);
        setState(() {
          _isBiometricEnabled = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Biometric login enabled')),
          );
        }
      }
    } else {
      await _biometricService.setBiometricEnabled(false);
      setState(() {
        _isBiometricEnabled = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric login disabled')),
        );
      }
    }
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
