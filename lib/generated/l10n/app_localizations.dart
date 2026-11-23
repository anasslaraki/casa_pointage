import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In fr, this message translates to:
  /// **'Casa Pointage'**
  String get appName;

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageArabic.
  ///
  /// In fr, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @loginHeroSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Espace superviseur · personnel des délégataires'**
  String get loginHeroSubtitle;

  /// No description provided for @loginHeroTagline.
  ///
  /// In fr, this message translates to:
  /// **'Pointage du personnel\npar reconnaissance faciale.'**
  String get loginHeroTagline;

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get loginTitle;

  /// No description provided for @loginIdLabel.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant'**
  String get loginIdLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get loginPasswordLabel;

  /// No description provided for @loginShowPassword.
  ///
  /// In fr, this message translates to:
  /// **'Afficher le mot de passe'**
  String get loginShowPassword;

  /// No description provided for @loginHidePassword.
  ///
  /// In fr, this message translates to:
  /// **'Masquer le mot de passe'**
  String get loginHidePassword;

  /// No description provided for @loginSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get loginSubmit;

  /// No description provided for @loginLoading.
  ///
  /// In fr, this message translates to:
  /// **'Connexion…'**
  String get loginLoading;

  /// No description provided for @loginFooter.
  ///
  /// In fr, this message translates to:
  /// **'Application réservée aux superviseurs des délégataires.\nMot de passe oublié ? Contactez le service RH de votre délégataire.'**
  String get loginFooter;

  /// No description provided for @loginErrorBoth.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez votre identifiant et votre mot de passe.'**
  String get loginErrorBoth;

  /// No description provided for @loginErrorId.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez votre identifiant.'**
  String get loginErrorId;

  /// No description provided for @loginErrorPassword.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez votre mot de passe.'**
  String get loginErrorPassword;

  /// No description provided for @loginErrorInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant ou mot de passe incorrect.'**
  String get loginErrorInvalid;

  /// No description provided for @faceRecognized.
  ///
  /// In fr, this message translates to:
  /// **'Visage reconnu'**
  String get faceRecognized;

  /// No description provided for @arrivalAt.
  ///
  /// In fr, this message translates to:
  /// **'Arrivée {time}'**
  String arrivalAt(String time);

  /// No description provided for @tabsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Navigation principale'**
  String get tabsLabel;

  /// No description provided for @tabTeam.
  ///
  /// In fr, this message translates to:
  /// **'Équipe'**
  String get tabTeam;

  /// No description provided for @tabEnrolment.
  ///
  /// In fr, this message translates to:
  /// **'Enrôlement'**
  String get tabEnrolment;

  /// No description provided for @tabHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get tabHistory;

  /// No description provided for @tabProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get tabProfile;

  /// No description provided for @tabClockIn.
  ///
  /// In fr, this message translates to:
  /// **'Pointer'**
  String get tabClockIn;

  /// No description provided for @tabClockInSemantic.
  ///
  /// In fr, this message translates to:
  /// **'Pointer une personne'**
  String get tabClockInSemantic;

  /// No description provided for @shiftMorning.
  ///
  /// In fr, this message translates to:
  /// **'Poste du matin'**
  String get shiftMorning;

  /// No description provided for @shiftAfternoon.
  ///
  /// In fr, this message translates to:
  /// **'Poste de l\'après-midi'**
  String get shiftAfternoon;

  /// No description provided for @shiftNight.
  ///
  /// In fr, this message translates to:
  /// **'Poste de nuit'**
  String get shiftNight;

  /// No description provided for @functionSupervisor.
  ///
  /// In fr, this message translates to:
  /// **'Superviseur'**
  String get functionSupervisor;

  /// No description provided for @functionSweeperMale.
  ///
  /// In fr, this message translates to:
  /// **'Balayeur'**
  String get functionSweeperMale;

  /// No description provided for @functionSweeperFemale.
  ///
  /// In fr, this message translates to:
  /// **'Balayeuse'**
  String get functionSweeperFemale;

  /// No description provided for @functionDriver.
  ///
  /// In fr, this message translates to:
  /// **'Chauffeur'**
  String get functionDriver;

  /// No description provided for @functionLoader.
  ///
  /// In fr, this message translates to:
  /// **'Ripeur'**
  String get functionLoader;

  /// No description provided for @functionSweeperDriver.
  ///
  /// In fr, this message translates to:
  /// **'Conducteur de balayeuse'**
  String get functionSweeperDriver;

  /// No description provided for @functionTeamLead.
  ///
  /// In fr, this message translates to:
  /// **'Chef d\'équipe'**
  String get functionTeamLead;

  /// No description provided for @syncOffline.
  ///
  /// In fr, this message translates to:
  /// **'Hors connexion'**
  String get syncOffline;

  /// No description provided for @syncOfflinePending.
  ///
  /// In fr, this message translates to:
  /// **'Hors connexion · {count}'**
  String syncOfflinePending(int count);

  /// No description provided for @syncPending.
  ///
  /// In fr, this message translates to:
  /// **'{count} en attente'**
  String syncPending(int count);

  /// No description provided for @syncDone.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisé RH'**
  String get syncDone;

  /// No description provided for @teamPeopleClockedIn.
  ///
  /// In fr, this message translates to:
  /// **'personnes pointées'**
  String get teamPeopleClockedIn;

  /// No description provided for @teamClockMe.
  ///
  /// In fr, this message translates to:
  /// **'Me pointer'**
  String get teamClockMe;

  /// No description provided for @teamClockMyExit.
  ///
  /// In fr, this message translates to:
  /// **'Ma sortie'**
  String get teamClockMyExit;

  /// No description provided for @teamMeClockedIn.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes pointé'**
  String get teamMeClockedIn;

  /// No description provided for @teamMeNotClockedIn.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas encore pointé'**
  String get teamMeNotClockedIn;

  /// No description provided for @teamMeClockBeforeTeam.
  ///
  /// In fr, this message translates to:
  /// **'Pointez-vous avant votre équipe'**
  String get teamMeClockBeforeTeam;

  /// No description provided for @teamMeEnrolFirst.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrez d\'abord votre visage'**
  String get teamMeEnrolFirst;

  /// No description provided for @teamMeSupervisorDaily.
  ///
  /// In fr, this message translates to:
  /// **'Le superviseur pointe aussi chaque jour'**
  String get teamMeSupervisorDaily;

  /// No description provided for @teamMeArrival.
  ///
  /// In fr, this message translates to:
  /// **'Arrivée à {time}'**
  String teamMeArrival(String time);

  /// No description provided for @teamMeExit.
  ///
  /// In fr, this message translates to:
  /// **'sortie à {time}'**
  String teamMeExit(String time);

  /// No description provided for @teamSearchLabel.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une personne'**
  String get teamSearchLabel;

  /// No description provided for @teamSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Nom, matricule, fonction'**
  String get teamSearchHint;

  /// No description provided for @teamEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune personne ne correspond.'**
  String get teamEmpty;

  /// No description provided for @teamArrivedAt.
  ///
  /// In fr, this message translates to:
  /// **'Arrivé à {time}'**
  String teamArrivedAt(String time);

  /// No description provided for @teamManualTag.
  ///
  /// In fr, this message translates to:
  /// **'manuel'**
  String get teamManualTag;

  /// No description provided for @filterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get filterAll;

  /// No description provided for @filterNotClocked.
  ///
  /// In fr, this message translates to:
  /// **'Non pointés'**
  String get filterNotClocked;

  /// No description provided for @filterPresent.
  ///
  /// In fr, this message translates to:
  /// **'Présents'**
  String get filterPresent;

  /// No description provided for @filterLate.
  ///
  /// In fr, this message translates to:
  /// **'Retards'**
  String get filterLate;

  /// No description provided for @filterAbsent.
  ///
  /// In fr, this message translates to:
  /// **'Absents'**
  String get filterAbsent;

  /// No description provided for @filterOut.
  ///
  /// In fr, this message translates to:
  /// **'Sortis'**
  String get filterOut;

  /// No description provided for @filterNotEnrolled.
  ///
  /// In fr, this message translates to:
  /// **'Non enrôlés'**
  String get filterNotEnrolled;

  /// No description provided for @statusPresent.
  ///
  /// In fr, this message translates to:
  /// **'Présent'**
  String get statusPresent;

  /// No description provided for @statusOut.
  ///
  /// In fr, this message translates to:
  /// **'Sorti'**
  String get statusOut;

  /// No description provided for @statusLate.
  ///
  /// In fr, this message translates to:
  /// **'En retard'**
  String get statusLate;

  /// No description provided for @statusAbsentJustified.
  ///
  /// In fr, this message translates to:
  /// **'Absent justifié'**
  String get statusAbsentJustified;

  /// No description provided for @statusNotClocked.
  ///
  /// In fr, this message translates to:
  /// **'Non pointé'**
  String get statusNotClocked;

  /// No description provided for @statusNotEnrolled.
  ///
  /// In fr, this message translates to:
  /// **'Visage non enrôlé'**
  String get statusNotEnrolled;

  /// No description provided for @statusPendingSync.
  ///
  /// In fr, this message translates to:
  /// **'En attente d\'envoi'**
  String get statusPendingSync;

  /// No description provided for @absenceSickness.
  ///
  /// In fr, this message translates to:
  /// **'Maladie'**
  String get absenceSickness;

  /// No description provided for @absenceLeave.
  ///
  /// In fr, this message translates to:
  /// **'Congé'**
  String get absenceLeave;

  /// No description provided for @absenceFamilyEvent.
  ///
  /// In fr, this message translates to:
  /// **'Événement familial'**
  String get absenceFamilyEvent;

  /// No description provided for @absenceOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get absenceOther;

  /// No description provided for @comingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt disponible'**
  String get comingSoon;

  /// No description provided for @scanTitleTeam.
  ///
  /// In fr, this message translates to:
  /// **'Pointer une personne'**
  String get scanTitleTeam;

  /// No description provided for @scanClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get scanClose;

  /// No description provided for @scanFlipCamera.
  ///
  /// In fr, this message translates to:
  /// **'Changer de caméra'**
  String get scanFlipCamera;

  /// No description provided for @faceHintMultiple.
  ///
  /// In fr, this message translates to:
  /// **'Un seul visage dans le cadre'**
  String get faceHintMultiple;

  /// No description provided for @faceHintTooFar.
  ///
  /// In fr, this message translates to:
  /// **'Rapprochez-vous'**
  String get faceHintTooFar;

  /// No description provided for @faceHintTooClose.
  ///
  /// In fr, this message translates to:
  /// **'Éloignez-vous un peu'**
  String get faceHintTooClose;

  /// No description provided for @faceHintCenter.
  ///
  /// In fr, this message translates to:
  /// **'Centrez le visage dans l\'ovale'**
  String get faceHintCenter;

  /// No description provided for @faceHintStraight.
  ///
  /// In fr, this message translates to:
  /// **'Regardez droit devant'**
  String get faceHintStraight;

  /// No description provided for @faceHintLight.
  ///
  /// In fr, this message translates to:
  /// **'Il faut plus de lumière'**
  String get faceHintLight;

  /// No description provided for @scanDetectTitle.
  ///
  /// In fr, this message translates to:
  /// **'Placez le visage dans le cadre'**
  String get scanDetectTitle;

  /// No description provided for @scanDetectHint.
  ///
  /// In fr, this message translates to:
  /// **'Bonne lumière, sans casquette ni lunettes de soleil'**
  String get scanDetectHint;

  /// No description provided for @scanAnalyseTitle.
  ///
  /// In fr, this message translates to:
  /// **'Analyse du visage…'**
  String get scanAnalyseTitle;

  /// No description provided for @scanAnalyseHint.
  ///
  /// In fr, this message translates to:
  /// **'Ne bougez pas'**
  String get scanAnalyseHint;

  /// No description provided for @scanLiveTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérification de présence réelle'**
  String get scanLiveTitle;

  /// No description provided for @scanTurnFirst.
  ///
  /// In fr, this message translates to:
  /// **'Tournez la tête d\'un côté'**
  String get scanTurnFirst;

  /// No description provided for @scanTurnSecond.
  ///
  /// In fr, this message translates to:
  /// **'Maintenant de l\'autre côté'**
  String get scanTurnSecond;

  /// No description provided for @scanFailedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Visage non reconnu'**
  String get scanFailedTitle;

  /// No description provided for @scanFailedHint.
  ///
  /// In fr, this message translates to:
  /// **'Réessayez ou utilisez le pointage manuel'**
  String get scanFailedHint;

  /// No description provided for @scanMatchScore.
  ///
  /// In fr, this message translates to:
  /// **'Correspondance {score} %'**
  String scanMatchScore(int score);

  /// No description provided for @scanAtDepot.
  ///
  /// In fr, this message translates to:
  /// **'Au {depot}'**
  String scanAtDepot(String depot);

  /// No description provided for @scanOutsideDepot.
  ///
  /// In fr, this message translates to:
  /// **'Hors du dépôt'**
  String get scanOutsideDepot;

  /// No description provided for @scanAssignment.
  ///
  /// In fr, this message translates to:
  /// **'Affectation du jour'**
  String get scanAssignment;

  /// No description provided for @scanEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get scanEdit;

  /// No description provided for @scanLateBy.
  ///
  /// In fr, this message translates to:
  /// **'Retard de {amount} · motif facultatif'**
  String scanLateBy(String amount);

  /// No description provided for @unitHour.
  ///
  /// In fr, this message translates to:
  /// **'h'**
  String get unitHour;

  /// No description provided for @lateAmount.
  ///
  /// In fr, this message translates to:
  /// **'{minutes} min · {hours}'**
  String lateAmount(int minutes, String hours);

  /// No description provided for @personLateBy.
  ///
  /// In fr, this message translates to:
  /// **'Retard : {amount}'**
  String personLateBy(String amount);

  /// No description provided for @teamArrivedLate.
  ///
  /// In fr, this message translates to:
  /// **'Arrivé à {time} · retard {amount}'**
  String teamArrivedLate(String time, String amount);

  /// No description provided for @personShiftStart.
  ///
  /// In fr, this message translates to:
  /// **'Heure début circuit'**
  String get personShiftStart;

  /// No description provided for @personShiftEnd.
  ///
  /// In fr, this message translates to:
  /// **'Heure fin circuit'**
  String get personShiftEnd;

  /// No description provided for @lateReasonTransport.
  ///
  /// In fr, this message translates to:
  /// **'Transport'**
  String get lateReasonTransport;

  /// No description provided for @lateReasonPersonal.
  ///
  /// In fr, this message translates to:
  /// **'Raison personnelle'**
  String get lateReasonPersonal;

  /// No description provided for @lateReasonMedical.
  ///
  /// In fr, this message translates to:
  /// **'Raison médicale'**
  String get lateReasonMedical;

  /// No description provided for @lateReasonOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get lateReasonOther;

  /// No description provided for @scanConfirmArrival.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer l\'arrivée à {time}'**
  String scanConfirmArrival(String time);

  /// No description provided for @scanConfirmExit.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer la sortie à {time}'**
  String scanConfirmExit(String time);

  /// No description provided for @scanNotThisPerson.
  ///
  /// In fr, this message translates to:
  /// **'Ce n\'est pas la bonne personne'**
  String get scanNotThisPerson;

  /// No description provided for @scanRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get scanRetry;

  /// No description provided for @scanManual.
  ///
  /// In fr, this message translates to:
  /// **'Pointage manuel'**
  String get scanManual;

  /// No description provided for @scanManualLink.
  ///
  /// In fr, this message translates to:
  /// **'Visage non reconnu ? Pointage manuel'**
  String get scanManualLink;

  /// No description provided for @personToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get personToday;

  /// No description provided for @personArrival.
  ///
  /// In fr, this message translates to:
  /// **'Arrivée'**
  String get personArrival;

  /// No description provided for @personExit.
  ///
  /// In fr, this message translates to:
  /// **'Sortie'**
  String get personExit;

  /// No description provided for @personNotYet.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore'**
  String get personNotYet;

  /// No description provided for @personAssignment.
  ///
  /// In fr, this message translates to:
  /// **'Affectation'**
  String get personAssignment;

  /// No description provided for @personLateReason.
  ///
  /// In fr, this message translates to:
  /// **'Motif du retard'**
  String get personLateReason;

  /// No description provided for @personAbsence.
  ///
  /// In fr, this message translates to:
  /// **'Absence'**
  String get personAbsence;

  /// No description provided for @personMethodFace.
  ///
  /// In fr, this message translates to:
  /// **'Visage {score} %'**
  String personMethodFace(int score);

  /// No description provided for @personMethodManual.
  ///
  /// In fr, this message translates to:
  /// **'Manuel · {reason}'**
  String personMethodManual(String reason);

  /// No description provided for @personManualArrival.
  ///
  /// In fr, this message translates to:
  /// **'Pointer manuellement'**
  String get personManualArrival;

  /// No description provided for @personManualExit.
  ///
  /// In fr, this message translates to:
  /// **'Pointer la sortie manuellement'**
  String get personManualExit;

  /// No description provided for @personEnrol.
  ///
  /// In fr, this message translates to:
  /// **'Enrôler le visage'**
  String get personEnrol;

  /// No description provided for @personDeclareAbsence.
  ///
  /// In fr, this message translates to:
  /// **'Déclarer une absence'**
  String get personDeclareAbsence;

  /// No description provided for @personReportAnomaly.
  ///
  /// In fr, this message translates to:
  /// **'Signaler une anomalie'**
  String get personReportAnomaly;

  /// No description provided for @personNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Personne introuvable'**
  String get personNotFound;

  /// No description provided for @personClockArrival.
  ///
  /// In fr, this message translates to:
  /// **'Pointer l\'arrivée'**
  String get personClockArrival;

  /// No description provided for @personClockExit.
  ///
  /// In fr, this message translates to:
  /// **'Pointer la sortie'**
  String get personClockExit;

  /// No description provided for @personFaceEnrolled.
  ///
  /// In fr, this message translates to:
  /// **'Visage enregistré'**
  String get personFaceEnrolled;

  /// No description provided for @personFaceMissing.
  ///
  /// In fr, this message translates to:
  /// **'Visage non enregistré'**
  String get personFaceMissing;

  /// No description provided for @personFaceRedo.
  ///
  /// In fr, this message translates to:
  /// **'Refaire'**
  String get personFaceRedo;

  /// No description provided for @personFaceDo.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get personFaceDo;

  /// No description provided for @personHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get personHistory;

  /// No description provided for @personHistoryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Historique des 14 derniers jours'**
  String get personHistoryTitle;

  /// No description provided for @personRest.
  ///
  /// In fr, this message translates to:
  /// **'Repos'**
  String get personRest;

  /// No description provided for @paginationPrevious.
  ///
  /// In fr, this message translates to:
  /// **'Page précédente'**
  String get paginationPrevious;

  /// No description provided for @paginationNext.
  ///
  /// In fr, this message translates to:
  /// **'Page suivante'**
  String get paginationNext;

  /// No description provided for @paginationPage.
  ///
  /// In fr, this message translates to:
  /// **'Page {page}'**
  String paginationPage(int page);

  /// No description provided for @paginationRange.
  ///
  /// In fr, this message translates to:
  /// **'{from}–{to} sur {total}'**
  String paginationRange(int from, int to, int total);

  /// No description provided for @teamSearchClear.
  ///
  /// In fr, this message translates to:
  /// **'Effacer la recherche'**
  String get teamSearchClear;

  /// No description provided for @teamRefresh.
  ///
  /// In fr, this message translates to:
  /// **'Rafraîchir'**
  String get teamRefresh;

  /// No description provided for @syncScreenTitle.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation'**
  String get syncScreenTitle;

  /// No description provided for @syncConnected.
  ///
  /// In fr, this message translates to:
  /// **'Connecté au réseau'**
  String get syncConnected;

  /// No description provided for @syncOfflineTitle.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get syncOfflineTitle;

  /// No description provided for @syncOfflineHint.
  ///
  /// In fr, this message translates to:
  /// **'Les données restent sur le téléphone et partent dès le retour du réseau.'**
  String get syncOfflineHint;

  /// No description provided for @syncListTitle.
  ///
  /// In fr, this message translates to:
  /// **'En attente d\'envoi'**
  String get syncListTitle;

  /// No description provided for @syncEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Tout est envoyé au module RH'**
  String get syncEmpty;

  /// No description provided for @syncNow.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer maintenant'**
  String get syncNow;

  /// No description provided for @syncSent.
  ///
  /// In fr, this message translates to:
  /// **'Envoi terminé'**
  String get syncSent;

  /// No description provided for @syncItemArrival.
  ///
  /// In fr, this message translates to:
  /// **'Arrivée {time}'**
  String syncItemArrival(String time);

  /// No description provided for @syncItemExit.
  ///
  /// In fr, this message translates to:
  /// **'Sortie {time}'**
  String syncItemExit(String time);

  /// No description provided for @syncItemAbsence.
  ///
  /// In fr, this message translates to:
  /// **'Absence · {reason}'**
  String syncItemAbsence(String reason);

  /// No description provided for @syncItemAnomaly.
  ///
  /// In fr, this message translates to:
  /// **'Anomalie · {kind}'**
  String syncItemAnomaly(String kind);

  /// No description provided for @profileSector.
  ///
  /// In fr, this message translates to:
  /// **'Secteur'**
  String get profileSector;

  /// No description provided for @profileDelegate.
  ///
  /// In fr, this message translates to:
  /// **'Délégataire'**
  String get profileDelegate;

  /// No description provided for @profileDepot.
  ///
  /// In fr, this message translates to:
  /// **'Lieu de pointage'**
  String get profileDepot;

  /// No description provided for @profileLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get profileLanguage;

  /// No description provided for @profileLanguageValue.
  ///
  /// In fr, this message translates to:
  /// **'Langue : {language}'**
  String profileLanguageValue(String language);

  /// No description provided for @profileTeam.
  ///
  /// In fr, this message translates to:
  /// **'Équipe'**
  String get profileTeam;

  /// No description provided for @profileTeamCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} personnes'**
  String profileTeamCount(int count);

  /// No description provided for @profileSynced.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisé avec le module RH'**
  String get profileSynced;

  /// No description provided for @profileSyncedHint.
  ///
  /// In fr, this message translates to:
  /// **'Enrôlements et pointages transmis.'**
  String get profileSyncedHint;

  /// No description provided for @profileOffline.
  ///
  /// In fr, this message translates to:
  /// **'Hors connexion'**
  String get profileOffline;

  /// No description provided for @profileOfflineHint.
  ///
  /// In fr, this message translates to:
  /// **'Les pointages restent sur le téléphone jusqu\'au retour du réseau.'**
  String get profileOfflineHint;

  /// No description provided for @profilePending.
  ///
  /// In fr, this message translates to:
  /// **'{count} élément(s) en attente'**
  String profilePending(int count);

  /// No description provided for @profilePendingHint.
  ///
  /// In fr, this message translates to:
  /// **'Envoi automatique en cours.'**
  String get profilePendingHint;

  /// No description provided for @profileSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get profileSend;

  /// No description provided for @profileHelp.
  ///
  /// In fr, this message translates to:
  /// **'Aide'**
  String get profileHelp;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get profileLogoutConfirm;

  /// No description provided for @profileLogoutPending.
  ///
  /// In fr, this message translates to:
  /// **'Attention : {count} élément(s) ne sont pas encore envoyés.'**
  String profileLogoutPending(int count);

  /// No description provided for @helpEnrolLead.
  ///
  /// In fr, this message translates to:
  /// **'1. Enregistrer les visages :'**
  String get helpEnrolLead;

  /// No description provided for @helpEnrolText.
  ///
  /// In fr, this message translates to:
  /// **'une seule fois par personne, avec son accord, depuis l\'onglet Enrôlement.'**
  String get helpEnrolText;

  /// No description provided for @helpClockLead.
  ///
  /// In fr, this message translates to:
  /// **'2. Pointer :'**
  String get helpClockLead;

  /// No description provided for @helpClockText.
  ///
  /// In fr, this message translates to:
  /// **'chaque jour, la personne se présente à vous. Touchez « Pointer » et placez son visage dans le cadre. L\'arrivée ou la sortie est détectée automatiquement.'**
  String get helpClockText;

  /// No description provided for @helpSelfLead.
  ///
  /// In fr, this message translates to:
  /// **'3. Vous aussi :'**
  String get helpSelfLead;

  /// No description provided for @helpSelfText.
  ///
  /// In fr, this message translates to:
  /// **'pointez-vous avec « Me pointer ».'**
  String get helpSelfText;

  /// No description provided for @helpFailedLead.
  ///
  /// In fr, this message translates to:
  /// **'Visage non reconnu :'**
  String get helpFailedLead;

  /// No description provided for @helpFailedText.
  ///
  /// In fr, this message translates to:
  /// **'réessayez avec une meilleure lumière, sinon utilisez le pointage manuel (photo et motif obligatoires).'**
  String get helpFailedText;

  /// No description provided for @profileVersion.
  ///
  /// In fr, this message translates to:
  /// **'Casa Pointage · version {version}'**
  String profileVersion(String version);

  /// No description provided for @profileLogout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get profileLogout;

  /// No description provided for @profileLogoutTitle.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter ?'**
  String get profileLogoutTitle;

  /// No description provided for @profileLogoutBody.
  ///
  /// In fr, this message translates to:
  /// **'Vous devrez saisir à nouveau votre identifiant et votre mot de passe.'**
  String get profileLogoutBody;

  /// No description provided for @profileCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get profileCancel;

  /// No description provided for @historyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Historique des pointages'**
  String get historyTitle;

  /// No description provided for @historyTodayShort.
  ///
  /// In fr, this message translates to:
  /// **'Auj.'**
  String get historyTodayShort;

  /// No description provided for @historyFilterManual.
  ///
  /// In fr, this message translates to:
  /// **'Manuels'**
  String get historyFilterManual;

  /// No description provided for @historyLateWord.
  ///
  /// In fr, this message translates to:
  /// **'en retard'**
  String get historyLateWord;

  /// No description provided for @historyFace.
  ///
  /// In fr, this message translates to:
  /// **'visage'**
  String get historyFace;

  /// No description provided for @historyToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get historyToday;

  /// No description provided for @historyYesterday.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get historyYesterday;

  /// No description provided for @historyPresentCount.
  ///
  /// In fr, this message translates to:
  /// **'{present} / {total} présents'**
  String historyPresentCount(int present, int total);

  /// No description provided for @historyLate.
  ///
  /// In fr, this message translates to:
  /// **'{count} en retard'**
  String historyLate(int count);

  /// No description provided for @historyAbsent.
  ///
  /// In fr, this message translates to:
  /// **'{count} absents'**
  String historyAbsent(int count);

  /// No description provided for @historyMissing.
  ///
  /// In fr, this message translates to:
  /// **'{count} non pointés'**
  String historyMissing(int count);

  /// No description provided for @historySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'7 derniers jours'**
  String get historySubtitle;

  /// No description provided for @enrolTitle.
  ///
  /// In fr, this message translates to:
  /// **'Enrôlement des visages'**
  String get enrolTitle;

  /// No description provided for @enrolProgress.
  ///
  /// In fr, this message translates to:
  /// **'{done} / {total} personnes enregistrées'**
  String enrolProgress(int done, int total);

  /// No description provided for @enrolSectionTodo.
  ///
  /// In fr, this message translates to:
  /// **'À enregistrer'**
  String get enrolSectionTodo;

  /// No description provided for @enrolSectionDone.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrés'**
  String get enrolSectionDone;

  /// No description provided for @enrolAction.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get enrolAction;

  /// No description provided for @enrolYou.
  ///
  /// In fr, this message translates to:
  /// **'(vous)'**
  String get enrolYou;

  /// No description provided for @enrolRegistered.
  ///
  /// In fr, this message translates to:
  /// **'enregistré'**
  String get enrolRegistered;

  /// No description provided for @enrolRegisteredOn.
  ///
  /// In fr, this message translates to:
  /// **'enregistré le {date}'**
  String enrolRegisteredOn(String date);

  /// No description provided for @personFaceDate.
  ///
  /// In fr, this message translates to:
  /// **'le {date}'**
  String personFaceDate(String date);

  /// No description provided for @enrolAllDone.
  ///
  /// In fr, this message translates to:
  /// **'Toute l\'équipe est enregistrée.'**
  String get enrolAllDone;

  /// No description provided for @faceEnrolTitle.
  ///
  /// In fr, this message translates to:
  /// **'Enrôler le visage'**
  String get faceEnrolTitle;

  /// No description provided for @enrolConsentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement du visage'**
  String get enrolConsentTitle;

  /// No description provided for @enrolConsentFace.
  ///
  /// In fr, this message translates to:
  /// **'Le visage est enregistré une seule fois, puis reconnu à chaque pointage.'**
  String get enrolConsentFace;

  /// No description provided for @enrolConsentShield.
  ///
  /// In fr, this message translates to:
  /// **'Seul un gabarit chiffré est conservé dans le module RH, pas de photo.'**
  String get enrolConsentShield;

  /// No description provided for @enrolConsentLock.
  ///
  /// In fr, this message translates to:
  /// **'Il sert uniquement au pointage de présence.'**
  String get enrolConsentLock;

  /// No description provided for @enrolConsentSelf.
  ///
  /// In fr, this message translates to:
  /// **'J\'accepte l\'enregistrement de mon visage pour le pointage.'**
  String get enrolConsentSelf;

  /// No description provided for @enrolConsentTeam.
  ///
  /// In fr, this message translates to:
  /// **'La personne a été informée et accepte l\'enregistrement de son visage pour le pointage.'**
  String get enrolConsentTeam;

  /// No description provided for @enrolConsentRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le consentement de la personne est obligatoire.'**
  String get enrolConsentRequired;

  /// No description provided for @enrolBegin.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get enrolBegin;

  /// No description provided for @enrolScanMove.
  ///
  /// In fr, this message translates to:
  /// **'Bougez lentement la tête'**
  String get enrolScanMove;

  /// No description provided for @enrolScanCircle.
  ///
  /// In fr, this message translates to:
  /// **'pour compléter le cercle'**
  String get enrolScanCircle;

  /// No description provided for @enrolScanCircleAgain.
  ///
  /// In fr, this message translates to:
  /// **'pour compléter le cercle une seconde fois'**
  String get enrolScanCircleAgain;

  /// No description provided for @enrolScanFirstDone.
  ///
  /// In fr, this message translates to:
  /// **'Premier scan terminé'**
  String get enrolScanFirstDone;

  /// No description provided for @enrolScanOneMore.
  ///
  /// In fr, this message translates to:
  /// **'Encore un tour pour finaliser'**
  String get enrolScanOneMore;

  /// No description provided for @enrolSaving.
  ///
  /// In fr, this message translates to:
  /// **'Envoi au module RH…'**
  String get enrolSaving;

  /// No description provided for @enrolSaved.
  ///
  /// In fr, this message translates to:
  /// **'Visage enregistré'**
  String get enrolSaved;

  /// No description provided for @enrolSentHr.
  ///
  /// In fr, this message translates to:
  /// **'Envoyé au module RH'**
  String get enrolSentHr;

  /// No description provided for @enrolQualityLow.
  ///
  /// In fr, this message translates to:
  /// **'Capture insuffisante, recommencez le scan.'**
  String get enrolQualityLow;

  /// No description provided for @enrolPoseFront.
  ///
  /// In fr, this message translates to:
  /// **'Regardez droit devant'**
  String get enrolPoseFront;

  /// No description provided for @enrolPoseLeft.
  ///
  /// In fr, this message translates to:
  /// **'Tournez doucement la tête à gauche'**
  String get enrolPoseLeft;

  /// No description provided for @enrolPoseRight.
  ///
  /// In fr, this message translates to:
  /// **'Tournez doucement la tête à droite'**
  String get enrolPoseRight;

  /// No description provided for @enrolStep.
  ///
  /// In fr, this message translates to:
  /// **'Étape {current} sur {total}'**
  String enrolStep(int current, int total);

  /// No description provided for @enrolDone.
  ///
  /// In fr, this message translates to:
  /// **'Visage enrôlé'**
  String get enrolDone;

  /// No description provided for @enrolDoneHint.
  ///
  /// In fr, this message translates to:
  /// **'{name} peut maintenant pointer par reconnaissance faciale.'**
  String enrolDoneHint(String name);

  /// No description provided for @enrolFinish.
  ///
  /// In fr, this message translates to:
  /// **'Terminer'**
  String get enrolFinish;

  /// No description provided for @anomalyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Signaler une anomalie'**
  String get anomalyTitle;

  /// No description provided for @anomalyStepKind.
  ///
  /// In fr, this message translates to:
  /// **'1. Type d\'anomalie'**
  String get anomalyStepKind;

  /// No description provided for @anomalyStepComment.
  ///
  /// In fr, this message translates to:
  /// **'Commentaire'**
  String get anomalyStepComment;

  /// No description provided for @anomalyDay.
  ///
  /// In fr, this message translates to:
  /// **'Jour concerné'**
  String get anomalyDay;

  /// No description provided for @anomalyTime.
  ///
  /// In fr, this message translates to:
  /// **'Heure correcte'**
  String get anomalyTime;

  /// No description provided for @anomalyClockError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de pointage'**
  String get anomalyClockError;

  /// No description provided for @anomalyWrongAssignment.
  ///
  /// In fr, this message translates to:
  /// **'Mauvaise affectation'**
  String get anomalyWrongAssignment;

  /// No description provided for @anomalyEquipment.
  ///
  /// In fr, this message translates to:
  /// **'Matériel défectueux'**
  String get anomalyEquipment;

  /// No description provided for @anomalyIncident.
  ///
  /// In fr, this message translates to:
  /// **'Accident ou incident'**
  String get anomalyIncident;

  /// No description provided for @anomalyOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get anomalyOther;

  /// No description provided for @anomalyCommentHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. a oublié de pointer sa sortie hier'**
  String get anomalyCommentHint;

  /// No description provided for @anomalySubmit.
  ///
  /// In fr, this message translates to:
  /// **'Transmettre au module RH'**
  String get anomalySubmit;

  /// No description provided for @anomalyIncomplete.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez le type d\'anomalie'**
  String get anomalyIncomplete;

  /// No description provided for @anomalyIncompleteComment.
  ///
  /// In fr, this message translates to:
  /// **'Décrivez l\'anomalie'**
  String get anomalyIncompleteComment;

  /// No description provided for @anomalySaved.
  ///
  /// In fr, this message translates to:
  /// **'Anomalie signalée'**
  String get anomalySaved;

  /// No description provided for @personAnomalies.
  ///
  /// In fr, this message translates to:
  /// **'Anomalie signalée'**
  String get personAnomalies;

  /// No description provided for @absenceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Déclarer une absence'**
  String get absenceTitle;

  /// No description provided for @absenceStepReason.
  ///
  /// In fr, this message translates to:
  /// **'1. Motif'**
  String get absenceStepReason;

  /// No description provided for @absenceStepDates.
  ///
  /// In fr, this message translates to:
  /// **'2. Période'**
  String get absenceStepDates;

  /// No description provided for @absenceStepComment.
  ///
  /// In fr, this message translates to:
  /// **'3. Commentaire (facultatif)'**
  String get absenceStepComment;

  /// No description provided for @absenceFrom.
  ///
  /// In fr, this message translates to:
  /// **'Du'**
  String get absenceFrom;

  /// No description provided for @absenceTo.
  ///
  /// In fr, this message translates to:
  /// **'Au'**
  String get absenceTo;

  /// No description provided for @absenceCommentHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. certificat médical remis'**
  String get absenceCommentHint;

  /// No description provided for @absenceSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Transmettre au module RH'**
  String get absenceSubmit;

  /// No description provided for @absenceIncomplete.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un motif'**
  String get absenceIncomplete;

  /// No description provided for @absenceSaved.
  ///
  /// In fr, this message translates to:
  /// **'Absence déclarée'**
  String get absenceSaved;

  /// No description provided for @manualTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pointage manuel'**
  String get manualTitle;

  /// No description provided for @manualSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Exception · contrôlée par le service RH'**
  String get manualSubtitle;

  /// No description provided for @manualWarning.
  ///
  /// In fr, this message translates to:
  /// **'À utiliser seulement si la reconnaissance échoue. Une photo et un motif sont obligatoires.'**
  String get manualWarning;

  /// No description provided for @manualLabelPerson.
  ///
  /// In fr, this message translates to:
  /// **'Personne'**
  String get manualLabelPerson;

  /// No description provided for @manualLabelReason.
  ///
  /// In fr, this message translates to:
  /// **'Motif'**
  String get manualLabelReason;

  /// No description provided for @manualLabelPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Photo de la personne'**
  String get manualLabelPhoto;

  /// No description provided for @manualPhotoAdded.
  ///
  /// In fr, this message translates to:
  /// **'Photo ajoutée'**
  String get manualPhotoAdded;

  /// No description provided for @manualPhotoRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer la photo'**
  String get manualPhotoRemove;

  /// No description provided for @manualKindArrival.
  ///
  /// In fr, this message translates to:
  /// **'arrivée'**
  String get manualKindArrival;

  /// No description provided for @manualKindExit.
  ///
  /// In fr, this message translates to:
  /// **'sortie'**
  String get manualKindExit;

  /// No description provided for @manualErrorPerson.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez la personne.'**
  String get manualErrorPerson;

  /// No description provided for @manualErrorReason.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un motif.'**
  String get manualErrorReason;

  /// No description provided for @manualErrorPhoto.
  ///
  /// In fr, this message translates to:
  /// **'La photo est obligatoire pour un pointage manuel.'**
  String get manualErrorPhoto;

  /// No description provided for @manualConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer le pointage à {time}'**
  String manualConfirm(String time);

  /// No description provided for @manualStepPerson.
  ///
  /// In fr, this message translates to:
  /// **'1. Personne'**
  String get manualStepPerson;

  /// No description provided for @manualStepReason.
  ///
  /// In fr, this message translates to:
  /// **'2. Motif du pointage manuel'**
  String get manualStepReason;

  /// No description provided for @manualStepPhoto.
  ///
  /// In fr, this message translates to:
  /// **'3. Photo de preuve'**
  String get manualStepPhoto;

  /// No description provided for @manualChange.
  ///
  /// In fr, this message translates to:
  /// **'Changer'**
  String get manualChange;

  /// No description provided for @manualNoResult.
  ///
  /// In fr, this message translates to:
  /// **'Aucune personne trouvée'**
  String get manualNoResult;

  /// No description provided for @manualReasonFaceFailed.
  ///
  /// In fr, this message translates to:
  /// **'Visage non reconnu'**
  String get manualReasonFaceFailed;

  /// No description provided for @manualReasonNotEnrolled.
  ///
  /// In fr, this message translates to:
  /// **'Visage non enrôlé'**
  String get manualReasonNotEnrolled;

  /// No description provided for @manualReasonCamera.
  ///
  /// In fr, this message translates to:
  /// **'Problème de caméra'**
  String get manualReasonCamera;

  /// No description provided for @manualReasonOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get manualReasonOther;

  /// No description provided for @manualPhotoHint.
  ///
  /// In fr, this message translates to:
  /// **'Photographiez la personne : la photo justifie le pointage manuel.'**
  String get manualPhotoHint;

  /// No description provided for @manualPhotoTake.
  ///
  /// In fr, this message translates to:
  /// **'Prendre la photo'**
  String get manualPhotoTake;

  /// No description provided for @manualPhotoRetake.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre la photo'**
  String get manualPhotoRetake;

  /// No description provided for @manualPhotoError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'ouvrir l\'appareil photo'**
  String get manualPhotoError;

  /// No description provided for @manualIncomplete.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez la personne, le motif et prenez la photo'**
  String get manualIncomplete;

  /// No description provided for @assignmentManualSweeping.
  ///
  /// In fr, this message translates to:
  /// **'Balayage manuel'**
  String get assignmentManualSweeping;

  /// No description provided for @assignmentMechanicalSweeping.
  ///
  /// In fr, this message translates to:
  /// **'Balayage mécanique'**
  String get assignmentMechanicalSweeping;

  /// No description provided for @assignmentCollection.
  ///
  /// In fr, this message translates to:
  /// **'Collecte des déchets ménagers et assimilés'**
  String get assignmentCollection;

  /// No description provided for @assignmentSupervision.
  ///
  /// In fr, this message translates to:
  /// **'Encadrement du secteur'**
  String get assignmentSupervision;

  /// No description provided for @assignmentCircuit.
  ///
  /// In fr, this message translates to:
  /// **'Circuit'**
  String get assignmentCircuit;

  /// No description provided for @assignmentCircuitLine.
  ///
  /// In fr, this message translates to:
  /// **'Circuit {circuit}'**
  String assignmentCircuitLine(String circuit);

  /// No description provided for @assignmentVehicle.
  ///
  /// In fr, this message translates to:
  /// **'Chariot ou véhicule'**
  String get assignmentVehicle;

  /// No description provided for @assignmentReadRfid.
  ///
  /// In fr, this message translates to:
  /// **'Lire le tag RFID du chariot ou du véhicule'**
  String get assignmentReadRfid;

  /// No description provided for @assignmentRfidHint.
  ///
  /// In fr, this message translates to:
  /// **'Approchez le lecteur du tag RFID du chariot ou du véhicule'**
  String get assignmentRfidHint;

  /// No description provided for @assignmentSave.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get assignmentSave;

  /// No description provided for @assignmentChanged.
  ///
  /// In fr, this message translates to:
  /// **'Affectation modifiée'**
  String get assignmentChanged;

  /// No description provided for @doneArrival.
  ///
  /// In fr, this message translates to:
  /// **'Arrivée pointée'**
  String get doneArrival;

  /// No description provided for @doneExit.
  ///
  /// In fr, this message translates to:
  /// **'Sortie pointée'**
  String get doneExit;

  /// No description provided for @doneManualSuffix.
  ///
  /// In fr, this message translates to:
  /// **'(manuel)'**
  String get doneManualSuffix;

  /// No description provided for @doneSaved.
  ///
  /// In fr, this message translates to:
  /// **'Enregistré et transmis au module RH.'**
  String get doneSaved;

  /// No description provided for @doneSavedOffline.
  ///
  /// In fr, this message translates to:
  /// **'Enregistré sur le téléphone. Envoi au module RH dès le retour du réseau.'**
  String get doneSavedOffline;

  /// No description provided for @doneNext.
  ///
  /// In fr, this message translates to:
  /// **'Pointer la personne suivante'**
  String get doneNext;

  /// No description provided for @doneBack.
  ///
  /// In fr, this message translates to:
  /// **'Retour à l\'équipe'**
  String get doneBack;

  /// No description provided for @loadErrorTitle.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les données'**
  String get loadErrorTitle;

  /// No description provided for @loadRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get loadRetry;

  /// No description provided for @kioskTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pointage'**
  String get kioskTitle;

  /// No description provided for @kioskLoading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement des visages…'**
  String get kioskLoading;

  /// No description provided for @kioskSending.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement du pointage…'**
  String get kioskSending;

  /// No description provided for @kioskNotRecognised.
  ///
  /// In fr, this message translates to:
  /// **'Visage non reconnu, réessayez'**
  String get kioskNotRecognised;

  /// No description provided for @kioskNoFaces.
  ///
  /// In fr, this message translates to:
  /// **'Aucun visage enregistré pour ce dépôt.'**
  String get kioskNoFaces;

  /// No description provided for @kioskArrival.
  ///
  /// In fr, this message translates to:
  /// **'Arrivée pointée'**
  String get kioskArrival;

  /// No description provided for @kioskExit.
  ///
  /// In fr, this message translates to:
  /// **'Sortie pointée'**
  String get kioskExit;

  /// No description provided for @kioskFarFromDepot.
  ///
  /// In fr, this message translates to:
  /// **'Pointé en dehors du dépôt'**
  String get kioskFarFromDepot;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
