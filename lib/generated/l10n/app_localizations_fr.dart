// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Casa Pointage';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageArabic => 'العربية';

  @override
  String get loginHeroSubtitle =>
      'Espace superviseur · personnel des délégataires';

  @override
  String get loginHeroTagline =>
      'Pointage du personnel\npar reconnaissance faciale.';

  @override
  String get loginTitle => 'Se connecter';

  @override
  String get loginIdLabel => 'Identifiant';

  @override
  String get loginPasswordLabel => 'Mot de passe';

  @override
  String get loginShowPassword => 'Afficher le mot de passe';

  @override
  String get loginHidePassword => 'Masquer le mot de passe';

  @override
  String get loginSubmit => 'Se connecter';

  @override
  String get loginLoading => 'Connexion…';

  @override
  String get loginFooter =>
      'Application réservée aux superviseurs des délégataires.\nMot de passe oublié ? Contactez le service RH de votre délégataire.';

  @override
  String get loginErrorBoth =>
      'Saisissez votre identifiant et votre mot de passe.';

  @override
  String get loginErrorId => 'Saisissez votre identifiant.';

  @override
  String get loginErrorPassword => 'Saisissez votre mot de passe.';

  @override
  String get loginErrorInvalid => 'Identifiant ou mot de passe incorrect.';

  @override
  String get faceRecognized => 'Visage reconnu';

  @override
  String arrivalAt(String time) {
    return 'Arrivée $time';
  }

  @override
  String get tabsLabel => 'Navigation principale';

  @override
  String get tabTeam => 'Équipe';

  @override
  String get tabEnrolment => 'Enrôlement';

  @override
  String get tabHistory => 'Historique';

  @override
  String get tabProfile => 'Profil';

  @override
  String get tabClockIn => 'Pointer';

  @override
  String get tabClockInSemantic => 'Pointer une personne';

  @override
  String get shiftMorning => 'Poste du matin';

  @override
  String get shiftAfternoon => 'Poste de l\'après-midi';

  @override
  String get shiftNight => 'Poste de nuit';

  @override
  String get functionSupervisor => 'Superviseur';

  @override
  String get functionSweeperMale => 'Balayeur';

  @override
  String get functionSweeperFemale => 'Balayeuse';

  @override
  String get functionDriver => 'Chauffeur';

  @override
  String get functionLoader => 'Ripeur';

  @override
  String get functionSweeperDriver => 'Conducteur de balayeuse';

  @override
  String get functionTeamLead => 'Chef d\'équipe';

  @override
  String get syncOffline => 'Hors connexion';

  @override
  String syncOfflinePending(int count) {
    return 'Hors connexion · $count';
  }

  @override
  String syncPending(int count) {
    return '$count en attente';
  }

  @override
  String get syncDone => 'Synchronisé RH';

  @override
  String get teamPeopleClockedIn => 'personnes pointées';

  @override
  String get teamClockMe => 'Me pointer';

  @override
  String get teamClockMyExit => 'Ma sortie';

  @override
  String get teamMeClockedIn => 'Vous êtes pointé';

  @override
  String get teamMeNotClockedIn => 'Vous n\'avez pas encore pointé';

  @override
  String get teamMeClockBeforeTeam => 'Pointez-vous avant votre équipe';

  @override
  String get teamMeEnrolFirst => 'Enregistrez d\'abord votre visage';

  @override
  String get teamMeSupervisorDaily => 'Le superviseur pointe aussi chaque jour';

  @override
  String teamMeArrival(String time) {
    return 'Arrivée à $time';
  }

  @override
  String teamMeExit(String time) {
    return 'sortie à $time';
  }

  @override
  String get teamSearchLabel => 'Rechercher une personne';

  @override
  String get teamSearchHint => 'Nom, matricule, fonction';

  @override
  String get teamEmpty => 'Aucune personne ne correspond.';

  @override
  String teamArrivedAt(String time) {
    return 'Arrivé à $time';
  }

  @override
  String get teamManualTag => 'manuel';

  @override
  String get filterAll => 'Tous';

  @override
  String get filterNotClocked => 'Non pointés';

  @override
  String get filterPresent => 'Présents';

  @override
  String get filterLate => 'Retards';

  @override
  String get filterAbsent => 'Absents';

  @override
  String get filterOut => 'Sortis';

  @override
  String get filterNotEnrolled => 'Non enrôlés';

  @override
  String get statusPresent => 'Présent';

  @override
  String get statusOut => 'Sorti';

  @override
  String get statusLate => 'En retard';

  @override
  String get statusAbsentJustified => 'Absent justifié';

  @override
  String get statusNotClocked => 'Non pointé';

  @override
  String get statusNotEnrolled => 'Visage non enrôlé';

  @override
  String get statusPendingSync => 'En attente d\'envoi';

  @override
  String get absenceSickness => 'Maladie';

  @override
  String get absenceLeave => 'Congé';

  @override
  String get absenceFamilyEvent => 'Événement familial';

  @override
  String get absenceOther => 'Autre';

  @override
  String get comingSoon => 'Bientôt disponible';

  @override
  String get scanTitleTeam => 'Pointer une personne';

  @override
  String get scanClose => 'Fermer';

  @override
  String get scanFlipCamera => 'Changer de caméra';

  @override
  String get faceHintMultiple => 'Un seul visage dans le cadre';

  @override
  String get faceHintTooFar => 'Rapprochez-vous';

  @override
  String get faceHintTooClose => 'Éloignez-vous un peu';

  @override
  String get faceHintCenter => 'Centrez le visage dans l\'ovale';

  @override
  String get faceHintStraight => 'Regardez droit devant';

  @override
  String get faceHintLight => 'Il faut plus de lumière';

  @override
  String get scanDetectTitle => 'Placez le visage dans le cadre';

  @override
  String get scanDetectHint =>
      'Bonne lumière, sans casquette ni lunettes de soleil';

  @override
  String get scanAnalyseTitle => 'Analyse du visage…';

  @override
  String get scanAnalyseHint => 'Ne bougez pas';

  @override
  String get scanLiveTitle => 'Vérification de présence réelle';

  @override
  String get scanTurnFirst => 'Tournez la tête d\'un côté';

  @override
  String get scanTurnSecond => 'Maintenant de l\'autre côté';

  @override
  String get scanFailedTitle => 'Visage non reconnu';

  @override
  String get scanFailedHint => 'Réessayez ou utilisez le pointage manuel';

  @override
  String scanMatchScore(int score) {
    return 'Correspondance $score %';
  }

  @override
  String scanAtDepot(String depot) {
    return 'Au $depot';
  }

  @override
  String get scanOutsideDepot => 'Hors du dépôt';

  @override
  String get scanAssignment => 'Affectation du jour';

  @override
  String get scanEdit => 'Modifier';

  @override
  String scanLateBy(String amount) {
    return 'Retard de $amount · motif facultatif';
  }

  @override
  String get unitHour => 'h';

  @override
  String lateAmount(int minutes, String hours) {
    return '$minutes min · $hours';
  }

  @override
  String personLateBy(String amount) {
    return 'Retard : $amount';
  }

  @override
  String teamArrivedLate(String time, String amount) {
    return 'Arrivé à $time · retard $amount';
  }

  @override
  String get personShiftStart => 'Heure début circuit';

  @override
  String get personShiftEnd => 'Heure fin circuit';

  @override
  String get lateReasonTransport => 'Transport';

  @override
  String get lateReasonPersonal => 'Raison personnelle';

  @override
  String get lateReasonMedical => 'Raison médicale';

  @override
  String get lateReasonOther => 'Autre';

  @override
  String scanConfirmArrival(String time) {
    return 'Confirmer l\'arrivée à $time';
  }

  @override
  String scanConfirmExit(String time) {
    return 'Confirmer la sortie à $time';
  }

  @override
  String get scanNotThisPerson => 'Ce n\'est pas la bonne personne';

  @override
  String get scanRetry => 'Réessayer';

  @override
  String get scanManual => 'Pointage manuel';

  @override
  String get scanManualLink => 'Visage non reconnu ? Pointage manuel';

  @override
  String get personToday => 'Aujourd\'hui';

  @override
  String get personArrival => 'Arrivée';

  @override
  String get personExit => 'Sortie';

  @override
  String get personNotYet => 'Pas encore';

  @override
  String get personAssignment => 'Affectation';

  @override
  String get personLateReason => 'Motif du retard';

  @override
  String get personAbsence => 'Absence';

  @override
  String personMethodFace(int score) {
    return 'Visage $score %';
  }

  @override
  String personMethodManual(String reason) {
    return 'Manuel · $reason';
  }

  @override
  String get personManualArrival => 'Pointer manuellement';

  @override
  String get personManualExit => 'Pointer la sortie manuellement';

  @override
  String get personEnrol => 'Enrôler le visage';

  @override
  String get personDeclareAbsence => 'Déclarer une absence';

  @override
  String get personReportAnomaly => 'Signaler une anomalie';

  @override
  String get personNotFound => 'Personne introuvable';

  @override
  String get personClockArrival => 'Pointer l\'arrivée';

  @override
  String get personClockExit => 'Pointer la sortie';

  @override
  String get personFaceEnrolled => 'Visage enregistré';

  @override
  String get personFaceMissing => 'Visage non enregistré';

  @override
  String get personFaceRedo => 'Refaire';

  @override
  String get personFaceDo => 'Enregistrer';

  @override
  String get personHistory => 'Historique';

  @override
  String get personHistoryTitle => 'Historique des 14 derniers jours';

  @override
  String get personRest => 'Repos';

  @override
  String get paginationPrevious => 'Page précédente';

  @override
  String get paginationNext => 'Page suivante';

  @override
  String paginationPage(int page) {
    return 'Page $page';
  }

  @override
  String paginationRange(int from, int to, int total) {
    return '$from–$to sur $total';
  }

  @override
  String get teamSearchClear => 'Effacer la recherche';

  @override
  String get teamRefresh => 'Rafraîchir';

  @override
  String get syncScreenTitle => 'Synchronisation';

  @override
  String get syncConnected => 'Connecté au réseau';

  @override
  String get syncOfflineTitle => 'Hors ligne';

  @override
  String get syncOfflineHint =>
      'Les données restent sur le téléphone et partent dès le retour du réseau.';

  @override
  String get syncListTitle => 'En attente d\'envoi';

  @override
  String get syncEmpty => 'Tout est envoyé au module RH';

  @override
  String get syncNow => 'Envoyer maintenant';

  @override
  String get syncSent => 'Envoi terminé';

  @override
  String syncItemArrival(String time) {
    return 'Arrivée $time';
  }

  @override
  String syncItemExit(String time) {
    return 'Sortie $time';
  }

  @override
  String syncItemAbsence(String reason) {
    return 'Absence · $reason';
  }

  @override
  String syncItemAnomaly(String kind) {
    return 'Anomalie · $kind';
  }

  @override
  String get profileSector => 'Secteur';

  @override
  String get profileDelegate => 'Délégataire';

  @override
  String get profileDepot => 'Lieu de pointage';

  @override
  String get profileLanguage => 'Langue';

  @override
  String profileLanguageValue(String language) {
    return 'Langue : $language';
  }

  @override
  String get profileTeam => 'Équipe';

  @override
  String profileTeamCount(int count) {
    return '$count personnes';
  }

  @override
  String get profileSynced => 'Synchronisé avec le module RH';

  @override
  String get profileSyncedHint => 'Enrôlements et pointages transmis.';

  @override
  String get profileOffline => 'Hors connexion';

  @override
  String get profileOfflineHint =>
      'Les pointages restent sur le téléphone jusqu\'au retour du réseau.';

  @override
  String profilePending(int count) {
    return '$count élément(s) en attente';
  }

  @override
  String get profilePendingHint => 'Envoi automatique en cours.';

  @override
  String get profileSend => 'Envoyer';

  @override
  String get profileHelp => 'Aide';

  @override
  String get profileLogoutConfirm => 'Déconnexion';

  @override
  String profileLogoutPending(int count) {
    return 'Attention : $count élément(s) ne sont pas encore envoyés.';
  }

  @override
  String get helpEnrolLead => '1. Enregistrer les visages :';

  @override
  String get helpEnrolText =>
      'une seule fois par personne, avec son accord, depuis l\'onglet Enrôlement.';

  @override
  String get helpClockLead => '2. Pointer :';

  @override
  String get helpClockText =>
      'chaque jour, la personne se présente à vous. Touchez « Pointer » et placez son visage dans le cadre. L\'arrivée ou la sortie est détectée automatiquement.';

  @override
  String get helpSelfLead => '3. Vous aussi :';

  @override
  String get helpSelfText => 'pointez-vous avec « Me pointer ».';

  @override
  String get helpFailedLead => 'Visage non reconnu :';

  @override
  String get helpFailedText =>
      'réessayez avec une meilleure lumière, sinon utilisez le pointage manuel (photo et motif obligatoires).';

  @override
  String profileVersion(String version) {
    return 'Casa Pointage · version $version';
  }

  @override
  String get profileLogout => 'Se déconnecter';

  @override
  String get profileLogoutTitle => 'Se déconnecter ?';

  @override
  String get profileLogoutBody =>
      'Vous devrez saisir à nouveau votre identifiant et votre mot de passe.';

  @override
  String get profileCancel => 'Annuler';

  @override
  String get historyTitle => 'Historique des pointages';

  @override
  String get historyTodayShort => 'Auj.';

  @override
  String get historyFilterManual => 'Manuels';

  @override
  String get historyLateWord => 'en retard';

  @override
  String get historyFace => 'visage';

  @override
  String get historyToday => 'Aujourd\'hui';

  @override
  String get historyYesterday => 'Hier';

  @override
  String historyPresentCount(int present, int total) {
    return '$present / $total présents';
  }

  @override
  String historyLate(int count) {
    return '$count en retard';
  }

  @override
  String historyAbsent(int count) {
    return '$count absents';
  }

  @override
  String historyMissing(int count) {
    return '$count non pointés';
  }

  @override
  String get historySubtitle => '7 derniers jours';

  @override
  String get enrolTitle => 'Enrôlement des visages';

  @override
  String enrolProgress(int done, int total) {
    return '$done / $total personnes enregistrées';
  }

  @override
  String get enrolSectionTodo => 'À enregistrer';

  @override
  String get enrolSectionDone => 'Enregistrés';

  @override
  String get enrolAction => 'Enregistrer';

  @override
  String get enrolYou => '(vous)';

  @override
  String get enrolRegistered => 'enregistré';

  @override
  String enrolRegisteredOn(String date) {
    return 'enregistré le $date';
  }

  @override
  String personFaceDate(String date) {
    return 'le $date';
  }

  @override
  String get enrolAllDone => 'Toute l\'équipe est enregistrée.';

  @override
  String get faceEnrolTitle => 'Enrôler le visage';

  @override
  String get enrolConsentTitle => 'Enregistrement du visage';

  @override
  String get enrolConsentFace =>
      'Le visage est enregistré une seule fois, puis reconnu à chaque pointage.';

  @override
  String get enrolConsentShield =>
      'Seul un gabarit chiffré est conservé dans le module RH, pas de photo.';

  @override
  String get enrolConsentLock => 'Il sert uniquement au pointage de présence.';

  @override
  String get enrolConsentSelf =>
      'J\'accepte l\'enregistrement de mon visage pour le pointage.';

  @override
  String get enrolConsentTeam =>
      'La personne a été informée et accepte l\'enregistrement de son visage pour le pointage.';

  @override
  String get enrolConsentRequired =>
      'Le consentement de la personne est obligatoire.';

  @override
  String get enrolBegin => 'Commencer';

  @override
  String get enrolScanMove => 'Bougez lentement la tête';

  @override
  String get enrolScanCircle => 'pour compléter le cercle';

  @override
  String get enrolScanCircleAgain =>
      'pour compléter le cercle une seconde fois';

  @override
  String get enrolScanFirstDone => 'Premier scan terminé';

  @override
  String get enrolScanOneMore => 'Encore un tour pour finaliser';

  @override
  String get enrolSaving => 'Envoi au module RH…';

  @override
  String get enrolSaved => 'Visage enregistré';

  @override
  String get enrolSentHr => 'Envoyé au module RH';

  @override
  String get enrolQualityLow => 'Capture insuffisante, recommencez le scan.';

  @override
  String get enrolPoseFront => 'Regardez droit devant';

  @override
  String get enrolPoseLeft => 'Tournez doucement la tête à gauche';

  @override
  String get enrolPoseRight => 'Tournez doucement la tête à droite';

  @override
  String enrolStep(int current, int total) {
    return 'Étape $current sur $total';
  }

  @override
  String get enrolDone => 'Visage enrôlé';

  @override
  String enrolDoneHint(String name) {
    return '$name peut maintenant pointer par reconnaissance faciale.';
  }

  @override
  String get enrolFinish => 'Terminer';

  @override
  String get anomalyTitle => 'Signaler une anomalie';

  @override
  String get anomalyStepKind => '1. Type d\'anomalie';

  @override
  String get anomalyStepComment => 'Commentaire';

  @override
  String get anomalyDay => 'Jour concerné';

  @override
  String get anomalyTime => 'Heure correcte';

  @override
  String get anomalyClockError => 'Erreur de pointage';

  @override
  String get anomalyWrongAssignment => 'Mauvaise affectation';

  @override
  String get anomalyEquipment => 'Matériel défectueux';

  @override
  String get anomalyIncident => 'Accident ou incident';

  @override
  String get anomalyOther => 'Autre';

  @override
  String get anomalyCommentHint => 'Ex. a oublié de pointer sa sortie hier';

  @override
  String get anomalySubmit => 'Transmettre au module RH';

  @override
  String get anomalyIncomplete => 'Choisissez le type d\'anomalie';

  @override
  String get anomalyIncompleteComment => 'Décrivez l\'anomalie';

  @override
  String get anomalySaved => 'Anomalie signalée';

  @override
  String get personAnomalies => 'Anomalie signalée';

  @override
  String get absenceTitle => 'Déclarer une absence';

  @override
  String get absenceStepReason => '1. Motif';

  @override
  String get absenceStepDates => '2. Période';

  @override
  String get absenceStepComment => '3. Commentaire (facultatif)';

  @override
  String get absenceFrom => 'Du';

  @override
  String get absenceTo => 'Au';

  @override
  String get absenceCommentHint => 'Ex. certificat médical remis';

  @override
  String get absenceSubmit => 'Transmettre au module RH';

  @override
  String get absenceIncomplete => 'Choisissez un motif';

  @override
  String get absenceSaved => 'Absence déclarée';

  @override
  String get manualTitle => 'Pointage manuel';

  @override
  String get manualSubtitle => 'Exception · contrôlée par le service RH';

  @override
  String get manualWarning =>
      'À utiliser seulement si la reconnaissance échoue. Une photo et un motif sont obligatoires.';

  @override
  String get manualLabelPerson => 'Personne';

  @override
  String get manualLabelReason => 'Motif';

  @override
  String get manualLabelPhoto => 'Photo de la personne';

  @override
  String get manualPhotoAdded => 'Photo ajoutée';

  @override
  String get manualPhotoRemove => 'Retirer la photo';

  @override
  String get manualKindArrival => 'arrivée';

  @override
  String get manualKindExit => 'sortie';

  @override
  String get manualErrorPerson => 'Choisissez la personne.';

  @override
  String get manualErrorReason => 'Choisissez un motif.';

  @override
  String get manualErrorPhoto =>
      'La photo est obligatoire pour un pointage manuel.';

  @override
  String manualConfirm(String time) {
    return 'Enregistrer le pointage à $time';
  }

  @override
  String get manualStepPerson => '1. Personne';

  @override
  String get manualStepReason => '2. Motif du pointage manuel';

  @override
  String get manualStepPhoto => '3. Photo de preuve';

  @override
  String get manualChange => 'Changer';

  @override
  String get manualNoResult => 'Aucune personne trouvée';

  @override
  String get manualReasonFaceFailed => 'Visage non reconnu';

  @override
  String get manualReasonNotEnrolled => 'Visage non enrôlé';

  @override
  String get manualReasonCamera => 'Problème de caméra';

  @override
  String get manualReasonOther => 'Autre';

  @override
  String get manualPhotoHint =>
      'Photographiez la personne : la photo justifie le pointage manuel.';

  @override
  String get manualPhotoTake => 'Prendre la photo';

  @override
  String get manualPhotoRetake => 'Reprendre la photo';

  @override
  String get manualPhotoError => 'Impossible d\'ouvrir l\'appareil photo';

  @override
  String get manualIncomplete =>
      'Choisissez la personne, le motif et prenez la photo';

  @override
  String get assignmentManualSweeping => 'Balayage manuel';

  @override
  String get assignmentMechanicalSweeping => 'Balayage mécanique';

  @override
  String get assignmentCollection =>
      'Collecte des déchets ménagers et assimilés';

  @override
  String get assignmentSupervision => 'Encadrement du secteur';

  @override
  String get assignmentCircuit => 'Circuit';

  @override
  String assignmentCircuitLine(String circuit) {
    return 'Circuit $circuit';
  }

  @override
  String get assignmentVehicle => 'Chariot ou véhicule';

  @override
  String get assignmentReadRfid => 'Lire le tag RFID du chariot ou du véhicule';

  @override
  String get assignmentRfidHint =>
      'Approchez le lecteur du tag RFID du chariot ou du véhicule';

  @override
  String get assignmentSave => 'Valider';

  @override
  String get assignmentChanged => 'Affectation modifiée';

  @override
  String get doneArrival => 'Arrivée pointée';

  @override
  String get doneExit => 'Sortie pointée';

  @override
  String get doneManualSuffix => '(manuel)';

  @override
  String get doneSaved => 'Enregistré et transmis au module RH.';

  @override
  String get doneSavedOffline =>
      'Enregistré sur le téléphone. Envoi au module RH dès le retour du réseau.';

  @override
  String get doneNext => 'Pointer la personne suivante';

  @override
  String get doneBack => 'Retour à l\'équipe';

  @override
  String get loadErrorTitle => 'Impossible de charger les données';

  @override
  String get loadRetry => 'Réessayer';

  @override
  String get kioskTitle => 'Pointage';

  @override
  String get kioskLoading => 'Chargement des visages…';

  @override
  String get kioskSending => 'Enregistrement du pointage…';

  @override
  String get kioskNotRecognised => 'Visage non reconnu, réessayez';

  @override
  String get kioskNoFaces => 'Aucun visage enregistré pour ce dépôt.';

  @override
  String get kioskArrival => 'Arrivée pointée';

  @override
  String get kioskExit => 'Sortie pointée';

  @override
  String get kioskFarFromDepot => 'Pointé en dehors du dépôt';
}
