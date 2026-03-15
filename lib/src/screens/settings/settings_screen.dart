import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final themeState = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // User info section
          if (authState.user != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.03)
                      : Colors.grey.withOpacity(0.04),
                  borderRadius: AppRadius.cardBorder,
                  border: Border.all(
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      backgroundImage: authState.user!.avatarUrl != null
                          ? NetworkImage(authState.user!.avatarUrl!)
                          : null,
                      child: authState.user!.avatarUrl == null
                          ? Text(
                              authState.user!.name.isNotEmpty
                                  ? authState.user!.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 22,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authState.user!.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            authState.user!.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Appearance section
          _SectionHeader(title: l10n.t('appearance')),
          _SettingsTile(
            icon: Icons.dark_mode_outlined,
            title: l10n.t('theme'),
            subtitle: _themeModeLabel(l10n, themeState.themeMode),
            trailing: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: const Icon(Icons.light_mode, size: 18),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: const Icon(Icons.settings_brightness, size: 18),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: const Icon(Icons.dark_mode, size: 18),
                ),
              ],
              selected: {themeState.themeMode},
              onSelectionChanged: (Set<ThemeMode> selection) {
                ref
                    .read(themeProvider.notifier)
                    .setThemeMode(selection.first);
              },
              showSelectedIcon: false,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),

          // Language section
          _SectionHeader(title: l10n.t('language')),
          _LanguageTile(
            locale: const Locale('en'),
            label: 'English',
            currentLocale: themeState.locale,
            onTap: () =>
                ref.read(themeProvider.notifier).setLocale(const Locale('en')),
          ),
          _LanguageTile(
            locale: const Locale('es'),
            label: 'Espa\u00f1ol',
            currentLocale: themeState.locale,
            onTap: () =>
                ref.read(themeProvider.notifier).setLocale(const Locale('es')),
          ),
          _LanguageTile(
            locale: const Locale('fr'),
            label: 'Fran\u00e7ais',
            currentLocale: themeState.locale,
            onTap: () =>
                ref.read(themeProvider.notifier).setLocale(const Locale('fr')),
          ),
          _LanguageTile(
            locale: const Locale('de'),
            label: 'Deutsch',
            currentLocale: themeState.locale,
            onTap: () =>
                ref.read(themeProvider.notifier).setLocale(const Locale('de')),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // Logout
          if (authState.status == AuthStatus.authenticated)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l10n.t('confirm_logout')),
                      content: Text(l10n.t('confirm_logout_message')),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: Text(l10n.t('cancel')),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.statusEscalated,
                          ),
                          child: Text(l10n.logout),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    ref.read(authProvider.notifier).logout();
                  }
                },
                icon: const Icon(Icons.logout, size: 20),
                label: Text(l10n.logout),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.statusEscalated,
                  side: BorderSide(
                      color: AppColors.statusEscalated.withOpacity(0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

          const SizedBox(height: 32),

          // Version info
          Center(
            child: Text(
              'Escalated v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const _PoweredByEscalated(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _themeModeLabel(AppLocalizations l10n, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.t('light');
      case ThemeMode.dark:
        return l10n.t('dark');
      case ThemeMode.system:
        return l10n.t('system');
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.03)
              : Colors.grey.withOpacity(0.04),
          borderRadius: AppRadius.cardBorder,
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final Locale locale;
  final String label;
  final Locale currentLocale;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.locale,
    required this.label,
    required this.currentLocale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = locale.languageCode == currentLocale.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? AppColors.primary : null,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary, size: 22)
          : Icon(
              Icons.circle_outlined,
              size: 22,
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
      onTap: onTap,
    );
  }
}

class _PoweredByEscalated extends StatelessWidget {
  const _PoweredByEscalated();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Opacity(
      opacity: 0.5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.open_in_new,
            size: 12,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          const SizedBox(width: 4),
          Text(
            'Powered by Escalated',
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
