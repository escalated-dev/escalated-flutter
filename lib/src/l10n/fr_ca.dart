// Canadian French. Only the strings that differ from `fr` live here; every
// other key falls back to `fr`, then to `en`.
const Map<String, String> frCA = {
  'email': 'Courriel',
  'your_email': 'Votre courriel',
  // Quebec says « billet » for a support ticket.
  'tickets': 'Billets',
  'no_tickets': 'Aucun billet trouv\u00e9',
  'close_ticket': 'Fermer le billet',
  'reopen_ticket': 'Rouvrir le billet',
  'create_ticket': 'Cr\u00e9er un billet',
  'new_ticket': 'Nouveau billet',
  'submit_ticket': 'Soumettre le billet',
  'search_tickets': 'Rechercher des billets...',
  'failed_to_load_tickets': 'Impossible de charger les billets.',
  'failed_to_load_ticket': 'Impossible de charger le billet.',
  'failed_to_create_ticket':
      'Impossible de cr\u00e9er le billet. Veuillez r\u00e9essayer.',
  'failed_to_close_ticket': 'Impossible de fermer le billet.',
  'failed_to_reopen_ticket': 'Impossible de rouvrir le billet.',
  // Verified guest access
  'guest_access_expires':
      "L'accès à cette page prend fin le {date}. Conservez votre référence {reference} pour retrouver ce billet.",
  'verification_explainer':
      'Nous vous enverrons un code par courriel pour confirmer votre adresse.',
  'guest_access_required':
      "Votre accès à ce billet a pris fin. Vérifiez votre courriel pour l'ouvrir à nouveau.",
  'guest_tickets_disabled': 'Les billets invités ne sont pas disponibles.',
  'verify_email': 'Vérifier le courriel',
  'find_ticket': 'Retrouver votre billet',
  'find_ticket_hint':
      'Saisissez la référence de votre billet et le courriel utilisé. Nous vous enverrons un code.',
  'no_matching_tickets':
      'Aucun billet ne correspond à cette référence et à ce courriel.',
  'invalid_email': 'Saisissez un courriel valide',
};
