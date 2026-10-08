const Map<String, String> fr = {
  // Navigation
  'tickets': 'Tickets',
  'knowledge_base': 'Base de connaissances',
  'settings': 'Param\u00e8tres',
  'login': 'Connexion',
  'register': "S'inscrire",
  'logout': 'D\u00e9connexion',

  // Statuses
  'open': 'Ouvert',
  'in_progress': 'En cours',
  'waiting_on_customer': 'En attente du client',
  'waiting_on_agent': "En attente de l'agent",
  'escalated': 'Escalad\u00e9',
  'resolved': 'R\u00e9solu',
  'closed': 'Ferm\u00e9',
  'reopened': 'R\u00e9ouvert',

  // Priorities
  'low': 'Faible',
  'medium': 'Moyenne',
  'high': 'Haute',
  'urgent': 'Urgente',
  'critical': 'Critique',

  // Ticket
  'reference': 'R\u00e9f\u00e9rence',
  'subject': 'Sujet',
  'requester': 'Demandeur',
  'status': 'Statut',
  'priority': 'Priorit\u00e9',
  'department': 'D\u00e9partement',
  'created': 'Cr\u00e9\u00e9',
  'description': 'Description',
  'no_tickets': 'Aucun ticket trouv\u00e9',
  'details': 'D\u00e9tails',
  'close_ticket': 'Fermer le ticket',
  'reopen_ticket': 'Rouvrir le ticket',
  'create_ticket': 'Cr\u00e9er un ticket',
  'new_ticket': 'Nouveau ticket',

  // Reply
  'reply': 'R\u00e9ponse',
  'send_reply': 'Envoyer la r\u00e9ponse',
  'write_reply': '\u00c9crivez votre r\u00e9ponse...',
  'attachments': 'Pi\u00e8ces jointes',
  'internal_note': 'Note interne',

  // Rating
  'customer_rating': '\u00c9valuation du client',
  'how_was_experience': 'Comment \u00e9tait votre exp\u00e9rience ?',
  'terrible': 'Terrible',
  'poor': 'Mauvaise',
  'okay': 'Correcte',
  'good': 'Bonne',
  'excellent': 'Excellente',
  'submit_rating': "Soumettre l'\u00e9valuation",
  'thank_you_feedback': 'Merci pour votre retour !',

  // SLA
  'overdue': 'En retard',
  'breached': 'Non respect\u00e9',
  'first_response': 'Premi\u00e8re r\u00e9ponse',
  'resolution': 'R\u00e9solution',
  'due_in': '\u00c9ch\u00e9ance dans',
  'hours': 'heures',
  'minutes': 'minutes',

  // KB
  'search_articles': 'Rechercher des articles...',
  'helpful': 'Utile',
  'not_helpful': 'Pas utile',
  'related_articles': 'Articles connexes',
  'no_articles': 'Aucun article trouv\u00e9',
  'views': 'vues',
  'published': 'Publi\u00e9',

  // Guest
  'submit_ticket': 'Soumettre le ticket',
  'your_name': 'Votre nom',
  'your_email': 'Votre email',
  'sign_in': 'Se connecter',

  // Verified guest access
  'guest_access_expires':
      "L'accès à cette page prend fin le {date}. Conservez votre référence {reference} pour retrouver ce ticket.",
  'copy_reference': 'Copier la référence',
  'reference_copied': 'Référence copiée',
  'send_code': 'Envoyer le code',
  'resend_code': 'Envoyer un nouveau code',
  'verification_code': 'Code de vérification',
  'verify_and_submit': 'Vérifier et envoyer',
  'verify': 'Vérifier',
  'verification_sent':
      'Nous avons envoyé un code à {email}. Il expire dans 10 minutes.',
  'verification_invalid':
      'Ce code est invalide, expiré ou déjà utilisé. Demandez un nouveau code.',
  'verification_explainer':
      'Nous vous enverrons un code par e-mail pour confirmer votre adresse.',
  'guest_rate_limited':
      'Trop de tentatives. Réessayez dans {seconds} secondes.',
  'guest_rate_limited_later': 'Trop de tentatives. Réessayez plus tard.',
  'guest_access_required':
      "Votre accès à ce ticket a pris fin. Vérifiez votre adresse e-mail pour l'ouvrir à nouveau.",
  'guest_tickets_disabled': 'Les tickets invités ne sont pas disponibles.',
  'verify_email': "Vérifier l'adresse e-mail",
  'find_ticket': 'Retrouver votre ticket',
  'find_ticket_hint':
      "Saisissez la référence de votre ticket et l'adresse e-mail utilisée. Nous vous enverrons un code.",
  'no_matching_tickets':
      'Aucun ticket ne correspond à cette référence et à cette adresse e-mail.',
  'failed_to_send_code': "Impossible d'envoyer le code. Veuillez réessayer.",
  'invalid_email': 'Saisissez une adresse e-mail valide',

  // Filters
  'search_tickets': 'Rechercher des tickets...',
  'all_statuses': 'Tous les statuts',
  'all_priorities': 'Toutes les priorit\u00e9s',
  'filter': 'Filtrer',

  // Files
  'browse_files': 'Parcourir les fichiers',
  'drop_or_browse': 'Appuyez pour s\u00e9lectionner des fichiers',
  'remove': 'Supprimer',
  'download': 'T\u00e9l\u00e9charger',

  // Common
  'loading': 'Chargement...',
  'error': 'Une erreur est survenue',
  'retry': 'R\u00e9essayer',
  'save': 'Enregistrer',
  'cancel': 'Annuler',
  'submit': 'Soumettre',
  'back': 'Retour',
  'no_results': 'Aucun r\u00e9sultat trouv\u00e9',

  // Auth
  'email': 'Email',
  'password': 'Mot de passe',
  'confirm_password': 'Confirmer le mot de passe',
  'name': 'Nom',
  'forgot_password': 'Mot de passe oubli\u00e9 ?',
  'create_account': 'Cr\u00e9er un compte',
  'already_have_account': 'Vous avez d\u00e9j\u00e0 un compte ?',
  'login_title': 'Bon retour',
  'register_title': 'Cr\u00e9ez votre compte',

  // Settings
  'appearance': 'Apparence',
  'theme': 'Th\u00e8me',
  'light': 'Clair',
  'dark': 'Sombre',
  'system': 'Syst\u00e8me',
  'language': 'Langue',
  'confirm_logout': 'Se d\u00e9connecter',
  'confirm_logout_message':
      '\u00cates-vous s\u00fbr de vouloir vous d\u00e9connecter ?',

  // Messages
  'replies': 'R\u00e9ponses',
  'none': 'Aucun',
  'sla': 'SLA',
  'field_required': '{field} est obligatoire',
  'unexpected_error': "Une erreur inattendue s'est produite.",
  'failed_to_load_tickets': 'Impossible de charger les tickets.',
  'failed_to_load_ticket': 'Impossible de charger le ticket.',
  'failed_to_create_ticket':
      'Impossible de cr\u00e9er le ticket. Veuillez r\u00e9essayer.',
  'failed_to_send_reply': "Impossible d'envoyer votre r\u00e9ponse.",
  'failed_to_close_ticket': 'Impossible de fermer le ticket.',
  'failed_to_reopen_ticket': 'Impossible de rouvrir le ticket.',
  'failed_to_load_articles': 'Impossible de charger les articles.',
  'failed_to_load_article': "Impossible de charger l'article.",
  'failed_to_sign_in':
      '\u00c9chec de la connexion. V\u00e9rifiez votre adresse e-mail et votre mot de passe.',
  'failed_to_register': "\u00c9chec de l'inscription.",
  'failed_to_update_profile': 'Impossible de mettre \u00e0 jour votre profil.',
};
