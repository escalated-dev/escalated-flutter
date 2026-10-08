const Map<String, String> es = {
  // Navigation
  'tickets': 'Tickets',
  'knowledge_base': 'Base de conocimiento',
  'settings': 'Configuraci\u00f3n',
  'login': 'Iniciar sesi\u00f3n',
  'register': 'Registrarse',
  'logout': 'Cerrar sesi\u00f3n',

  // Statuses
  'open': 'Abierto',
  'in_progress': 'En progreso',
  'waiting_on_customer': 'Esperando al cliente',
  'waiting_on_agent': 'Esperando al agente',
  'escalated': 'Escalado',
  'resolved': 'Resuelto',
  'closed': 'Cerrado',
  'reopened': 'Reabierto',

  // Priorities
  'low': 'Baja',
  'medium': 'Media',
  'high': 'Alta',
  'urgent': 'Urgente',
  'critical': 'Cr\u00edtica',

  // Ticket
  'reference': 'Referencia',
  'subject': 'Asunto',
  'requester': 'Solicitante',
  'status': 'Estado',
  'priority': 'Prioridad',
  'department': 'Departamento',
  'created': 'Creado',
  'description': 'Descripci\u00f3n',
  'no_tickets': 'No se encontraron tickets',
  'details': 'Detalles',
  'close_ticket': 'Cerrar ticket',
  'reopen_ticket': 'Reabrir ticket',
  'create_ticket': 'Crear ticket',
  'new_ticket': 'Nuevo ticket',

  // Reply
  'reply': 'Respuesta',
  'send_reply': 'Enviar respuesta',
  'write_reply': 'Escribe tu respuesta...',
  'attachments': 'Archivos adjuntos',
  'internal_note': 'Nota interna',

  // Rating
  'customer_rating': 'Calificaci\u00f3n del cliente',
  'how_was_experience': '\u00bfC\u00f3mo fue tu experiencia?',
  'terrible': 'Terrible',
  'poor': 'Mala',
  'okay': 'Aceptable',
  'good': 'Buena',
  'excellent': 'Excelente',
  'submit_rating': 'Enviar calificaci\u00f3n',
  'thank_you_feedback': '\u00a1Gracias por tu opini\u00f3n!',

  // SLA
  'overdue': 'Vencido',
  'breached': 'Incumplido',
  'first_response': 'Primera respuesta',
  'resolution': 'Resoluci\u00f3n',
  'due_in': 'Vence en',
  'hours': 'horas',
  'minutes': 'minutos',

  // KB
  'search_articles': 'Buscar art\u00edculos...',
  'helpful': '\u00datil',
  'not_helpful': 'No \u00fatil',
  'related_articles': 'Art\u00edculos relacionados',
  'no_articles': 'No se encontraron art\u00edculos',
  'views': 'vistas',
  'published': 'Publicado',

  // Guest
  'submit_ticket': 'Enviar ticket',
  'your_name': 'Tu nombre',
  'your_email': 'Tu correo electr\u00f3nico',
  'sign_in': 'Iniciar sesi\u00f3n',

  // Verified guest access
  'guest_access_expires':
      'El acceso a esta página termina el {date}. Guarda tu referencia {reference} para encontrar este ticket de nuevo.',
  'copy_reference': 'Copiar referencia',
  'reference_copied': 'Referencia copiada',
  'send_code': 'Enviar código',
  'resend_code': 'Enviar un código nuevo',
  'verification_code': 'Código de verificación',
  'verify_and_submit': 'Verificar y enviar',
  'verify': 'Verificar',
  'verification_sent': 'Enviamos un código a {email}. Caduca en 10 minutos.',
  'verification_invalid':
      'Este código no es válido, caducó o ya se usó. Solicita un código nuevo.',
  'verification_explainer':
      'Te enviaremos un código por correo para confirmar tu dirección.',
  'guest_rate_limited':
      'Demasiados intentos. Inténtalo de nuevo en {seconds} segundos.',
  'guest_rate_limited_later':
      'Demasiados intentos. Inténtalo de nuevo más tarde.',
  'guest_access_required':
      'Tu acceso a este ticket terminó. Verifica tu correo para abrirlo de nuevo.',
  'guest_tickets_disabled': 'Los tickets de invitado no están disponibles.',
  'verify_email': 'Verificar correo',
  'find_ticket': 'Buscar tu ticket',
  'find_ticket_hint':
      'Introduce la referencia de tu ticket y el correo que usaste. Te enviaremos un código.',
  'no_matching_tickets':
      'Ningún ticket coincide con esa referencia y ese correo.',
  'failed_to_send_code': 'No se pudo enviar el código. Inténtalo de nuevo.',
  'invalid_email': 'Introduce un correo electrónico válido',

  // Filters
  'search_tickets': 'Buscar tickets...',
  'all_statuses': 'Todos los estados',
  'all_priorities': 'Todas las prioridades',
  'filter': 'Filtrar',

  // Files
  'browse_files': 'Explorar archivos',
  'drop_or_browse': 'Toca para seleccionar archivos',
  'remove': 'Eliminar',
  'download': 'Descargar',

  // Common
  'loading': 'Cargando...',
  'error': 'Ocurri\u00f3 un error',
  'retry': 'Reintentar',
  'save': 'Guardar',
  'cancel': 'Cancelar',
  'submit': 'Enviar',
  'back': 'Volver',
  'no_results': 'Sin resultados',

  // Auth
  'email': 'Correo electr\u00f3nico',
  'password': 'Contrase\u00f1a',
  'confirm_password': 'Confirmar contrase\u00f1a',
  'name': 'Nombre',
  'forgot_password': '\u00bfOlvidaste tu contrase\u00f1a?',
  'create_account': 'Crear cuenta',
  'already_have_account': '\u00bfYa tienes una cuenta?',
  'login_title': 'Bienvenido de nuevo',
  'register_title': 'Crea tu cuenta',

  // Settings
  'appearance': 'Apariencia',
  'theme': 'Tema',
  'light': 'Claro',
  'dark': 'Oscuro',
  'system': 'Sistema',
  'language': 'Idioma',
  'confirm_logout': 'Cerrar sesi\u00f3n',
  'confirm_logout_message':
      '\u00bfEst\u00e1s seguro de que deseas cerrar sesi\u00f3n?',

  // Messages
  'replies': 'Respuestas',
  'none': 'Ninguno',
  'sla': 'SLA',
  'field_required': '{field} es obligatorio',
  'unexpected_error': 'Ocurri\u00f3 un error inesperado.',
  'failed_to_load_tickets': 'No se pudieron cargar los tickets.',
  'failed_to_load_ticket': 'No se pudo cargar el ticket.',
  'failed_to_create_ticket':
      'No se pudo crear el ticket. Int\u00e9ntalo de nuevo.',
  'failed_to_send_reply': 'No se pudo enviar tu respuesta.',
  'failed_to_close_ticket': 'No se pudo cerrar el ticket.',
  'failed_to_reopen_ticket': 'No se pudo reabrir el ticket.',
  'failed_to_load_articles': 'No se pudieron cargar los art\u00edculos.',
  'failed_to_load_article': 'No se pudo cargar el art\u00edculo.',
  'failed_to_sign_in':
      'No se pudo iniciar sesi\u00f3n. Revisa tu correo y contrase\u00f1a.',
  'failed_to_register': 'No se pudo completar el registro.',
  'failed_to_update_profile': 'No se pudo actualizar tu perfil.',
};
