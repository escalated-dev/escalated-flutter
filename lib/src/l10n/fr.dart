const Map<String, String> fr = {
  // Navigation
  'tickets': 'Tickets',
  'knowledge_base': 'Base de Connaissances',
  'settings': 'Param\u00e8tres',
  'login': 'Connexion',
  'register': "S'inscrire",
  'logout': 'D\u00e9connexion',

  // Statuses
  'open': 'Ouvert',
  'in_progress': 'En Cours',
  'waiting_on_customer': 'En Attente du Client',
  'waiting_on_agent': "En Attente de l'Agent",
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
  'close_ticket': 'Fermer le Ticket',
  'reopen_ticket': 'Rouvrir le Ticket',
  'create_ticket': 'Cr\u00e9er un Ticket',
  'new_ticket': 'Nouveau Ticket',

  // Reply
  'reply': 'R\u00e9ponse',
  'send_reply': 'Envoyer la R\u00e9ponse',
  'write_reply': '\u00c9crivez votre r\u00e9ponse...',
  'attachments': 'Pi\u00e8ces Jointes',
  'internal_note': 'Note Interne',

  // Rating
  'customer_rating': '\u00c9valuation du Client',
  'how_was_experience': 'Comment \u00e9tait votre exp\u00e9rience ?',
  'terrible': 'Terrible',
  'poor': 'Mauvaise',
  'okay': 'Correcte',
  'good': 'Bonne',
  'excellent': 'Excellente',
  'submit_rating': "Soumettre l'\u00c9valuation",
  'thank_you_feedback': 'Merci pour votre retour !',

  // SLA
  'overdue': 'En Retard',
  'breached': 'Non Respect\u00e9',
  'first_response': 'Premi\u00e8re R\u00e9ponse',
  'resolution': 'R\u00e9solution',
  'due_in': '\u00c9ch\u00e9ance dans',
  'hours': 'heures',
  'minutes': 'minutes',

  // KB
  'search_articles': 'Rechercher des articles...',
  'helpful': 'Utile',
  'not_helpful': 'Pas Utile',
  'related_articles': 'Articles Connexes',
  'no_articles': 'Aucun article trouv\u00e9',
  'views': 'vues',
  'published': 'Publi\u00e9',

  // Guest
  'submit_ticket': 'Soumettre le Ticket',
  'your_name': 'Votre Nom',
  'your_email': 'Votre Email',
  'bookmark_notice':
      'Ajoutez cette page \u00e0 vos favoris pour v\u00e9rifier le statut de votre ticket plus tard.',
  'copy_link': 'Copier le Lien',
  'sign_in': 'Se Connecter',

  // Filters
  'search_tickets': 'Rechercher des tickets...',
  'all_statuses': 'Tous les Statuts',
  'all_priorities': 'Toutes les Priorit\u00e9s',
  'filter': 'Filtrer',

  // Files
  'browse_files': 'Parcourir les Fichiers',
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
  'password': 'Mot de Passe',
  'confirm_password': 'Confirmer le Mot de Passe',
  'name': 'Nom',
  'forgot_password': 'Mot de passe oubli\u00e9 ?',
  'create_account': 'Cr\u00e9er un Compte',
  'already_have_account': 'Vous avez d\u00e9j\u00e0 un compte ?',
  'login_title': 'Bon Retour',
  'register_title': 'Cr\u00e9ez Votre Compte',

  // Settings
  'appearance': 'Apparence',
  'theme': 'Th\u00e8me',
  'light': 'Clair',
  'dark': 'Sombre',
  'system': 'Syst\u00e8me',
  'language': 'Langue',
  'confirm_logout': 'Se D\u00e9connecter',
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
