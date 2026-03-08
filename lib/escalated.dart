/// Escalated - A Flutter library package for customer support ticket management.
///
/// Provides pre-built screens, widgets, services, and providers for integrating
/// a full support ticket system into any Flutter app.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:escalated/escalated.dart';
///
/// EscalatedPlugin(
///   config: EscalatedConfig(
///     apiBaseUrl: 'https://example.com/support/api/v1',
///   ),
///   child: MaterialApp.router(routerConfig: yourRouter),
/// )
/// ```
library escalated;

// Configuration
export 'src/escalated_config.dart';
export 'src/escalated_plugin.dart';

// Theme
export 'src/theme/colors.dart';
export 'src/theme/app_theme.dart';

// Services
export 'src/services/auth_hooks.dart';
export 'src/services/api_client.dart';
export 'src/services/api_service.dart';

// Models
export 'src/models/user.dart';
export 'src/models/ticket.dart';
export 'src/models/ticket_summary.dart';
export 'src/models/reply.dart';
export 'src/models/attachment.dart';
export 'src/models/article.dart';
export 'src/models/department.dart';
export 'src/models/tag.dart';
export 'src/models/paginated_response.dart';

// Providers
export 'src/providers/auth_provider.dart';
export 'src/providers/ticket_provider.dart';
export 'src/providers/kb_provider.dart';
export 'src/providers/theme_provider.dart';

// Widgets
export 'src/widgets/status_badge.dart';
export 'src/widgets/priority_badge.dart';
export 'src/widgets/sla_timer.dart';
export 'src/widgets/attachment_list.dart';
export 'src/widgets/file_dropzone.dart';
export 'src/widgets/satisfaction_rating.dart';
export 'src/widgets/reply_thread.dart';
export 'src/widgets/reply_composer.dart';
export 'src/widgets/empty_state.dart';
export 'src/widgets/loading_shimmer.dart';
export 'src/widgets/error_view.dart';

// Screens
export 'src/screens/auth/login_screen.dart';
export 'src/screens/auth/register_screen.dart';
export 'src/screens/tickets/ticket_list_screen.dart';
export 'src/screens/tickets/create_ticket_screen.dart';
export 'src/screens/tickets/ticket_detail_screen.dart';
export 'src/screens/tickets/ticket_filters_sheet.dart';
export 'src/screens/kb/kb_list_screen.dart';
export 'src/screens/kb/kb_article_screen.dart';
export 'src/screens/guest/guest_create_screen.dart';
export 'src/screens/guest/guest_ticket_screen.dart';
export 'src/screens/settings/settings_screen.dart';

// Router
export 'src/router/app_router.dart';

// Localization
export 'src/l10n/app_localizations.dart';
