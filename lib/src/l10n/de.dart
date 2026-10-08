const Map<String, String> de = {
  // Navigation
  'tickets': 'Tickets',
  'knowledge_base': 'Wissensdatenbank',
  'settings': 'Einstellungen',
  'login': 'Anmelden',
  'register': 'Registrieren',
  'logout': 'Abmelden',

  // Statuses
  'open': 'Offen',
  'in_progress': 'In Bearbeitung',
  'waiting_on_customer': 'Warten auf Kunde',
  'waiting_on_agent': 'Warten auf Agent',
  'escalated': 'Eskaliert',
  'resolved': 'Gel\u00f6st',
  'closed': 'Geschlossen',
  'reopened': 'Wieder ge\u00f6ffnet',

  // Priorities
  'low': 'Niedrig',
  'medium': 'Mittel',
  'high': 'Hoch',
  'urgent': 'Dringend',
  'critical': 'Kritisch',

  // Ticket
  'reference': 'Referenz',
  'subject': 'Betreff',
  'requester': 'Anfragender',
  'status': 'Status',
  'priority': 'Priorit\u00e4t',
  'department': 'Abteilung',
  'created': 'Erstellt',
  'description': 'Beschreibung',
  'no_tickets': 'Keine Tickets gefunden',
  'details': 'Details',
  'close_ticket': 'Ticket schlie\u00dfen',
  'reopen_ticket': 'Ticket wieder \u00f6ffnen',
  'create_ticket': 'Ticket erstellen',
  'new_ticket': 'Neues Ticket',

  // Reply
  'reply': 'Antwort',
  'send_reply': 'Antwort senden',
  'write_reply': 'Schreiben Sie Ihre Antwort...',
  'attachments': 'Anh\u00e4nge',
  'internal_note': 'Interne Notiz',

  // Rating
  'customer_rating': 'Kundenbewertung',
  'how_was_experience': 'Wie war Ihre Erfahrung?',
  'terrible': 'Schrecklich',
  'poor': 'Schlecht',
  'okay': 'In Ordnung',
  'good': 'Gut',
  'excellent': 'Ausgezeichnet',
  'submit_rating': 'Bewertung abgeben',
  'thank_you_feedback': 'Vielen Dank f\u00fcr Ihr Feedback!',

  // SLA
  'overdue': '\u00dcberf\u00e4llig',
  'breached': 'Verletzt',
  'first_response': 'Erste Antwort',
  'resolution': 'L\u00f6sung',
  'due_in': 'F\u00e4llig in',
  'hours': 'Stunden',
  'minutes': 'Minuten',

  // KB
  'search_articles': 'Artikel suchen...',
  'helpful': 'Hilfreich',
  'not_helpful': 'Nicht hilfreich',
  'related_articles': 'Verwandte Artikel',
  'no_articles': 'Keine Artikel gefunden',
  'views': 'Aufrufe',
  'published': 'Ver\u00f6ffentlicht',

  // Guest
  'submit_ticket': 'Ticket einreichen',
  'your_name': 'Ihr Name',
  'your_email': 'Ihre E-Mail',
  'sign_in': 'Anmelden',

  // Verified guest access
  'guest_access_expires':
      'Der Zugriff auf diese Seite endet am {date}. Bewahren Sie Ihre Referenz {reference} auf, um dieses Ticket wiederzufinden.',
  'copy_reference': 'Referenz kopieren',
  'reference_copied': 'Referenz kopiert',
  'send_code': 'Code senden',
  'resend_code': 'Neuen Code senden',
  'verification_code': 'Bestätigungscode',
  'verify_and_submit': 'Bestätigen und absenden',
  'verify': 'Bestätigen',
  'verification_sent':
      'Wir haben einen Code an {email} gesendet. Er läuft in 10 Minuten ab.',
  'verification_invalid':
      'Dieser Code ist ungültig, abgelaufen oder bereits verwendet. Fordern Sie einen neuen Code an.',
  'verification_explainer':
      'Wir senden Ihnen einen Code per E-Mail, um Ihre Adresse zu bestätigen.',
  'guest_rate_limited':
      'Zu viele Versuche. Versuchen Sie es in {seconds} Sekunden erneut.',
  'guest_rate_limited_later':
      'Zu viele Versuche. Versuchen Sie es später erneut.',
  'guest_access_required':
      'Ihr Zugriff auf dieses Ticket ist abgelaufen. Bestätigen Sie Ihre E-Mail-Adresse, um es erneut zu öffnen.',
  'guest_tickets_disabled': 'Gast-Tickets sind nicht verfügbar.',
  'verify_email': 'E-Mail bestätigen',
  'find_ticket': 'Ihr Ticket finden',
  'find_ticket_hint':
      'Geben Sie Ihre Ticketreferenz und die verwendete E-Mail-Adresse ein. Wir senden Ihnen einen Code.',
  'no_matching_tickets':
      'Kein Ticket passt zu dieser Referenz und E-Mail-Adresse.',
  'failed_to_send_code':
      'Der Code konnte nicht gesendet werden. Bitte versuchen Sie es erneut.',
  'invalid_email': 'Geben Sie eine gültige E-Mail-Adresse ein',

  // Filters
  'search_tickets': 'Tickets suchen...',
  'all_statuses': 'Alle Status',
  'all_priorities': 'Alle Priorit\u00e4ten',
  'filter': 'Filtern',

  // Files
  'browse_files': 'Dateien durchsuchen',
  'drop_or_browse': 'Tippen Sie, um Dateien auszuw\u00e4hlen',
  'remove': 'Entfernen',
  'download': 'Herunterladen',

  // Common
  'loading': 'Laden...',
  'error': 'Ein Fehler ist aufgetreten',
  'retry': 'Erneut versuchen',
  'save': 'Speichern',
  'cancel': 'Abbrechen',
  'submit': 'Absenden',
  'back': 'Zur\u00fcck',
  'no_results': 'Keine Ergebnisse gefunden',

  // Auth
  'email': 'E-Mail',
  'password': 'Passwort',
  'confirm_password': 'Passwort best\u00e4tigen',
  'name': 'Name',
  'forgot_password': 'Passwort vergessen?',
  'create_account': 'Konto erstellen',
  'already_have_account': 'Haben Sie bereits ein Konto?',
  'login_title': 'Willkommen zur\u00fcck',
  'register_title': 'Erstellen Sie Ihr Konto',

  // Settings
  'appearance': 'Erscheinungsbild',
  'theme': 'Design',
  'light': 'Hell',
  'dark': 'Dunkel',
  'system': 'System',
  'language': 'Sprache',
  'confirm_logout': 'Abmelden',
  'confirm_logout_message':
      'Sind Sie sicher, dass Sie sich abmelden m\u00f6chten?',

  // Messages
  'replies': 'Antworten',
  'none': 'Keine',
  'sla': 'SLA',
  'field_required': '{field} ist erforderlich',
  'unexpected_error': 'Ein unerwarteter Fehler ist aufgetreten.',
  'failed_to_load_tickets': 'Tickets konnten nicht geladen werden.',
  'failed_to_load_ticket': 'Das Ticket konnte nicht geladen werden.',
  'failed_to_create_ticket':
      'Das Ticket konnte nicht erstellt werden. Bitte versuchen Sie es erneut.',
  'failed_to_send_reply': 'Ihre Antwort konnte nicht gesendet werden.',
  'failed_to_close_ticket': 'Das Ticket konnte nicht geschlossen werden.',
  'failed_to_reopen_ticket':
      'Das Ticket konnte nicht wieder ge\u00f6ffnet werden.',
  'failed_to_load_articles': 'Artikel konnten nicht geladen werden.',
  'failed_to_load_article': 'Der Artikel konnte nicht geladen werden.',
  'failed_to_sign_in':
      'Anmeldung fehlgeschlagen. Pr\u00fcfen Sie E-Mail und Passwort.',
  'failed_to_register': 'Registrierung fehlgeschlagen.',
  'failed_to_update_profile': 'Ihr Profil konnte nicht aktualisiert werden.',
};
