// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => '📖 Diario Diario';

  @override
  String get appSubtitle => 'Registra tu vida diaria';

  @override
  String get previousDay => 'Anterior';

  @override
  String get nextDay => 'Siguiente';

  @override
  String get calendar => 'Calendario';

  @override
  String get writeDiary => 'Escribir';

  @override
  String get random => 'Aleatorio';

  @override
  String get search => 'Buscar';

  @override
  String get stats => 'Estadísticas';

  @override
  String get settings => 'Configuración';

  @override
  String get pastToday => 'Hoy en el Pasado';

  @override
  String get export => 'Exportar';

  @override
  String get tagView => 'Etiquetas';

  @override
  String get date => 'Fecha';

  @override
  String get selectFromCalendar => 'Seleccionar del calendario';

  @override
  String get pastFutureDateNote =>
      'Puedes seleccionar fechas pasadas o futuras';

  @override
  String get todayMood => 'Estado de Ánimo de Hoy';

  @override
  String get moodHappy => 'Feliz';

  @override
  String get moodSad => 'Triste';

  @override
  String get moodAngry => 'Enojado';

  @override
  String get moodSleepy => 'Somnoliento';

  @override
  String get moodThinking => 'Pensativo';

  @override
  String get moodCalm => 'Tranquilo';

  @override
  String get moodFun => 'Divertido';

  @override
  String get moodAnxious => 'Ansioso';

  @override
  String get diary => 'Diario';

  @override
  String get diaryPlaceholder => 'Escribe sobre tu día...';

  @override
  String get diaryValidationError =>
      'Por favor ingresa el contenido del diario';

  @override
  String get tags => 'Etiquetas';

  @override
  String get tagsPlaceholder => 'ej. trabajo, hobby, familia';

  @override
  String get tagsHelper => 'Separa múltiples etiquetas con comas';

  @override
  String get save => 'Guardar';

  @override
  String get saving => 'Guardando...';

  @override
  String get searching => 'Buscando...';

  @override
  String get clear => 'Borrar';

  @override
  String get keyword => 'Palabra clave';

  @override
  String get tag => 'Etiqueta';

  @override
  String get searchDiaryPlaceholder => 'Buscar contenido del diario...';

  @override
  String get searchTagPlaceholder => 'Ingresa nombre de etiqueta (ej. trabajo)';

  @override
  String get noTagsYet => 'Aún no hay etiquetas';

  @override
  String tagSuggestions(int count) {
    return 'Sugerencias de etiquetas ($count)';
  }

  @override
  String get searchKeywordOrTag => 'Buscar por palabra clave o etiqueta';

  @override
  String get noDiariesFound => 'No se encontraron diarios';

  @override
  String get tryDifferentKeyword => 'Prueba con otra palabra clave';

  @override
  String searchResults(int count) {
    return 'Resultados de búsqueda ($count)';
  }

  @override
  String get searchInputRequired =>
      'Por favor ingresa una palabra clave o etiqueta';

  @override
  String searchError(String error) {
    return 'Ocurrió un error: $error';
  }

  @override
  String get statsTitle => '📊 Estadísticas';

  @override
  String get recordStats => 'Estadísticas de Registro';

  @override
  String get totalDiaries => 'Total de Diarios';

  @override
  String get consecutiveRecords => 'Racha';

  @override
  String get averageLength => 'Long. Promedio';

  @override
  String get recordRate => 'Tasa de Registro';

  @override
  String get recordPeriod => 'Período';

  @override
  String get firstDiary => 'Primera Entrada';

  @override
  String get latestDiary => 'Última Entrada';

  @override
  String get periodLabel => 'Período';

  @override
  String get moodRecord => 'Registro de Estado de Ánimo';

  @override
  String get moodUnset => 'Sin establecer';

  @override
  String get noDiariesYet => 'Aún no hay diarios';

  @override
  String get statsWillAppear =>
      'Las estadísticas aparecerán cuando empieces a escribir';

  @override
  String statsLoadError(String error) {
    return 'Error al cargar estadísticas: $error';
  }

  @override
  String get settingsTitle => '⚙️ Configuración';

  @override
  String get displaySettings => 'Pantalla';

  @override
  String get theme => 'Tema';

  @override
  String get themeLight => 'Modo Claro';

  @override
  String get themeLightDesc => 'Usar siempre tema claro';

  @override
  String get themeDark => 'Modo Oscuro';

  @override
  String get themeDarkDesc => 'Usar siempre tema oscuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeSystemDesc => 'Seguir configuración del dispositivo';

  @override
  String get dataManagement => 'Gestión de Datos';

  @override
  String get dataExport => 'Exportar Datos';

  @override
  String get dataExportDesc =>
      'Guardar diarios en archivo (antes de migrar o desinstalar)';

  @override
  String get dataImport => 'Importar Datos';

  @override
  String get dataImportDesc => 'Restaurar diarios desde archivo guardado';

  @override
  String get deleteAllData => 'Eliminar Todos los Datos';

  @override
  String get deleteAllDataDesc =>
      'Eliminar todos los diarios (no se puede deshacer)';

  @override
  String get deviceMigration => 'Guía de Respaldo y Migración';

  @override
  String get dataLossWarning =>
      '⚠ Desinstalar la app eliminará todos los datos. Por favor, exporte sus datos antes.';

  @override
  String get migrationStep1 => 'Exportar datos en dispositivo antiguo';

  @override
  String get migrationStep1Desc => 'Se descargará el archivo';

  @override
  String get migrationStep2 => 'Transferir archivo a nuevo dispositivo';

  @override
  String get migrationStep2Desc =>
      'Vía correo electrónico, almacenamiento en la nube, etc.';

  @override
  String get migrationStep3 => 'Importar datos en nuevo dispositivo';

  @override
  String get migrationStep3Desc =>
      'Seleccionar archivo para completar restauración';

  @override
  String get appInfo => 'Información de la App';

  @override
  String get version => 'Versión';

  @override
  String get appName => 'Nombre de la App';

  @override
  String get noExportData => 'No hay diarios para exportar';

  @override
  String exportError(String error) {
    return 'Error al exportar: $error';
  }

  @override
  String get importDialogTitle => 'Importar Datos';

  @override
  String importError(String error) {
    return 'Error al importar: $error';
  }

  @override
  String get fileReadError => 'Error al leer el archivo';

  @override
  String get noValidData => 'No se encontraron datos válidos';

  @override
  String get cancel => 'Cancelar';

  @override
  String get import => 'Importar';

  @override
  String get deleteConfirmTitle => 'Eliminar Todos los Datos';

  @override
  String get deleteConfirmMessage =>
      'Todos los diarios serán eliminados. Esto no se puede deshacer.\n\n¿Estás seguro?';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteSuccess => 'Todos los datos han sido eliminados';

  @override
  String deleteError(String error) {
    return 'Error al eliminar: $error';
  }

  @override
  String get themeSelectTitle => 'Seleccionar Tema';

  @override
  String get selectYear => 'Seleccionar Año';

  @override
  String thisMonthDiaries(int count) {
    return 'Este Mes ($count)';
  }

  @override
  String calendarError(String error) {
    return 'Ocurrió un error\n$error';
  }

  @override
  String get pastTodayNote => 'Sigue escribiendo para ver recuerdos del pasado';

  @override
  String get edit => 'Editar';

  @override
  String get randomNoDiary => 'Aún no hay diarios';

  @override
  String randomError(String error) {
    return 'Ocurrió un error: $error';
  }

  @override
  String get randomTryAgain => 'Intentar de Nuevo';

  @override
  String get backToHome => 'Inicio';

  @override
  String get startWritingDiary => 'Empieza a escribir tu diario';

  @override
  String get saveSaved => '✅ ¡Guardado!';

  @override
  String saveError(String error) {
    return '❌ Ocurrió un error: $error';
  }

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String pastTodayTitle(String monthDay) {
    return 'Pasado hoy ($monthDay)';
  }

  @override
  String pastTodayNoPastEntries(String monthDay) {
    return 'No hay entradas pasadas el $monthDay';
  }

  @override
  String get pastTodayKeepWriting =>
      'Sigue escribiendo para construir recuerdos';

  @override
  String get searchEnterKeywordOrTag => 'Ingrese palabra clave o etiqueta';

  @override
  String get searchDiaryContent => 'Buscar contenido del diario';

  @override
  String get count => ' entradas';

  @override
  String get searchByKeywordOrTag => 'Buscar por palabra clave o etiqueta';

  @override
  String get searchNoResults => 'No se encontraron diarios';

  @override
  String get searchTryDifferentKeyword => 'Prueba con otra palabra clave';

  @override
  String get statsRecordStats => 'Estadísticas de registros';

  @override
  String get statsTotalEntries => 'Total de entradas';

  @override
  String get statsCurrentStreak => 'Racha actual';

  @override
  String get days => ' días';

  @override
  String get statsAvgChars => 'Longitud promedio';

  @override
  String get chars => ' caracteres';

  @override
  String get statsWriteRate => 'Tasa de registro';

  @override
  String get statsPeriod => 'Período';

  @override
  String get statsRecordingDays => 'Días registrados';

  @override
  String get statsFirstEntry => 'Primera entrada';

  @override
  String get statsLatestEntry => 'Última entrada';

  @override
  String get daysCount => ' días';

  @override
  String get statsMoodRecord => 'Registro de estado de ánimo';

  @override
  String get notSet => 'Sin configurar';

  @override
  String get times => ' veces';

  @override
  String thisMonthEntries(int count) {
    return 'Entradas de este mes ($count)';
  }

  @override
  String exportSuccess(int count) {
    return 'Se exportaron $count diarios';
  }

  @override
  String importConfirmMessage(int count) {
    return 'Se importarán $count diarios.\n\n¿Continuar?';
  }

  @override
  String importConflictMessage(int total, int newCount, int duplicateCount) {
    return 'Archivo contiene: $total entradas (Nuevas: $newCount, Duplicadas: $duplicateCount)\n\n¿Qué desea hacer con las entradas duplicadas?';
  }

  @override
  String get importSkipExisting => 'Mantener existentes';

  @override
  String get importOverwrite => 'Sobrescribir';

  @override
  String importSuccess(int count) {
    return 'Se importaron $count diarios';
  }

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get termsOfService => 'Términos de Servicio';

  @override
  String get urlOpenError => 'No se pudo abrir la URL';

  @override
  String get goToToday => 'Ir a hoy';

  @override
  String get reminderSection => 'Recordatorio';

  @override
  String get reminderDaily => 'Recordatorio diario';

  @override
  String get reminderDailyDesc =>
      'Recibe una notificación cada día a la hora elegida';

  @override
  String get reminderTime => 'Hora de notificación';

  @override
  String get reminderNotificationTitle => 'Diario de hoy';

  @override
  String get reminderNotificationBody => 'Escribe sobre tu día';

  @override
  String get reminderPermissionDenied =>
      'Las notificaciones no están permitidas. Actívalas en los ajustes del sistema';

  @override
  String get securitySection => 'Seguridad';

  @override
  String get appLock => 'Bloqueo de la app';

  @override
  String get appLockDesc =>
      'Protege la app con biometría o el bloqueo de pantalla';

  @override
  String get appLockUnavailable =>
      'Este dispositivo no tiene configurada la biometría ni el bloqueo de pantalla';

  @override
  String get appLockUnlock => 'Desbloquear';

  @override
  String get appLockReason => 'Autentícate para ver tu diario';

  @override
  String lastBackup(String date) {
    return 'Última copia: $date';
  }

  @override
  String get lastBackupNever => 'Aún no hay copia de seguridad';

  @override
  String get backupReminderTitle => 'Copia de seguridad recomendada';

  @override
  String get backupReminderMessage =>
      'Han pasado más de 30 días desde la última copia. Exporta tu diario para protegerlo';

  @override
  String get backupNow => 'Hacer copia ahora';

  @override
  String get later => 'Más tarde';

  @override
  String get statsEmotionTitle => 'Emociones';

  @override
  String get statsEmotionSubtitle =>
      'Analizado en tu dispositivo, sin enviar datos';

  @override
  String get statsTopWordsTitle => 'Palabras frecuentes de este mes';

  @override
  String get emotionPositive => 'Positivo';

  @override
  String get emotionNegative => 'Negativo';

  @override
  String get yearReview => 'Resumen del año';

  @override
  String get yearReviewEntries => 'Entradas escritas';

  @override
  String get yearReviewChars => 'Caracteres escritos';

  @override
  String get yearReviewMaxStreak => 'Racha más larga';

  @override
  String get yearReviewTopWords => 'Palabras frecuentes del año';

  @override
  String get yearReviewMonthlyMood => 'Estado de ánimo mensual';

  @override
  String get yearReviewShare => 'Compartir como imagen';

  @override
  String get yearReviewNoData => 'Aún no hay entradas';

  @override
  String get statsMeaningTitle => 'Palabras de reflexión';

  @override
  String get statsMeaningSubtitle =>
      'Densidad de palabras de comprensión y razonamiento por cada 100 caracteres';

  @override
  String get programs => 'Programas';

  @override
  String get pennebakerTitle => 'Escritura expresiva (curso de 4 días)';

  @override
  String get pennebakerDesc =>
      'Escribe 15 minutos sobre algo que te preocupa, sin corregir. Continúa el mismo tema durante 4 días';

  @override
  String get pennebakerCitation =>
      'Basado en Pennebaker & Beall (1986) y más de 200 estudios posteriores';

  @override
  String get tgtTitle => 'Tres cosas buenas';

  @override
  String get tgtDesc => 'Escribe tres cosas que salieron bien hoy y por qué';

  @override
  String get tgtCitation =>
      'Basado en la investigación de psicología positiva de Seligman et al. (2005)';

  @override
  String get programDisclaimer =>
      'Estas funciones te ayudan a practicar métodos de escritura estudiados en la investigación. No son un tratamiento médico ni garantizan resultados';

  @override
  String get startWriting => 'Empezar a escribir';

  @override
  String get continueWriting => 'Continuar';

  @override
  String get newCourse => 'Empezar un tema nuevo';

  @override
  String get themeLabel => 'Tu tema para estos 4 días';

  @override
  String get themeHint => 'p. ej. un conflicto, algo que te preocupa';

  @override
  String get timerKeepWriting => 'Sigue escribiendo sin detenerte a corregir';

  @override
  String get timerDone => 'Ya pasaron 15 minutos, termina tu idea y cierra';

  @override
  String get finishEarlyTitle => '¿Terminar antes?';

  @override
  String get finishEarlyMessage =>
      'Los estudios recomiendan escribir los 15 minutos completos';

  @override
  String get finishSession => 'Terminar y guardar';

  @override
  String get sessionSaved => 'Guardado (separado de tus entradas del diario)';

  @override
  String get goodThingLabel => 'Algo bueno';

  @override
  String get whyLabel => '¿Por qué fue bueno? (opcional)';

  @override
  String get tgtDoneToday => 'Hecho por hoy ✅';

  @override
  String get sessionHistory => 'Historial';

  @override
  String get tgtValidation => 'Escribe al menos una';

  @override
  String get pennebakerCompleted => '¡Curso de 4 días completado!';

  @override
  String get ok => 'Aceptar';

  @override
  String get themeValidation => 'Introduce tu tema';

  @override
  String homeStreakDays(int count) {
    return '¡$count días seguidos!';
  }

  @override
  String get homePromptLabel => 'Tema de hoy';

  @override
  String get homePromptSkip => 'Puedes saltarlo';

  @override
  String get writeTodayButton => 'Escribir hoy';

  @override
  String get reviewTitle => 'Recuerdos';

  @override
  String get stampsMenu => 'Sellos';

  @override
  String homeCollectedStamps(int count) {
    return '$count sellos reunidos';
  }

  @override
  String get moodGood => 'Bien';

  @override
  String get moodMeh => 'Normal';

  @override
  String writePromptHint(String prompt) {
    return 'Tema: $prompt — puedes saltarlo';
  }

  @override
  String get celebrateTitle => '¡Lo lograste!';

  @override
  String celebrateStreak(int count) {
    return '¡$count días seguidos! 🔥';
  }

  @override
  String celebrateStampGet(String name) {
    return '¡Sello «$name» conseguido!';
  }

  @override
  String get stampsTitle => 'Colección de sellos';

  @override
  String stampsCount(int count) {
    return '$count reunidos';
  }

  @override
  String get stampLockedHint => 'Aún es secreto';

  @override
  String get onboardSkip => 'Saltar';

  @override
  String get onboardNext => 'Siguiente';

  @override
  String get onboardStart => '¡Empezar!';

  @override
  String get onboard1Title => '¡Bienvenido!';

  @override
  String get onboard1Body => 'Un diario relajado para escribir en un momento';

  @override
  String get onboard2Title => 'Toca un ánimo y escribe';

  @override
  String get onboard2Body => 'También hay temas, puedes saltarlos';

  @override
  String get onboard3Title => 'Sigue y reúne sellos 🎈';

  @override
  String get onboard3Body => 'A tu propio ritmo, sin presión';

  @override
  String get howToUse => 'Ver cómo funciona otra vez';

  @override
  String get statsMoodShare => 'Distribución de ánimo';

  @override
  String get statsTopTags => 'Etiquetas más usadas';

  @override
  String get promptQuestion1 => '¿Qué te hizo reír más hoy? 😆';

  @override
  String get promptQuestion2 => '¿Lo más rico que comiste hoy? 🍰';

  @override
  String get promptQuestion3 => '¿Qué estás apoyando ahora? 📣';

  @override
  String get promptQuestion4 => '¿Quién te alegró el día hoy? 🙌';

  @override
  String get promptQuestion5 => '¿En qué andas metido últimamente? 🎮';

  @override
  String get promptQuestion6 => '¿Algún golpe de suerte hoy? 🍀';

  @override
  String get promptQuestion7 => '¿Qué esperas con ganas mañana? ✨';

  @override
  String get promptQuestion8 => '¿Hoy en una palabra? 💬';

  @override
  String get stampNameFirst => 'Primer paso';

  @override
  String get stampNameCount10 => '10 entradas';

  @override
  String get stampNameCount30 => '30 entradas';

  @override
  String get stampNameCount50 => '50 entradas';

  @override
  String get stampNameCount100 => '100 entradas';

  @override
  String get stampNameStreak3 => '3 días seguidos';

  @override
  String get stampNameStreak7 => '1 semana seguida';

  @override
  String get stampNameStreak14 => '2 semanas seguidas';

  @override
  String get stampNameStreak30 => '1 mes seguido';

  @override
  String get statsThisMonth => 'Este mes';
}
