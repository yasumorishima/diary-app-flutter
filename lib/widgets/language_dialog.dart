import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';

/// 言語選択ダイアログ（全画面共通）。
/// 選択肢は LocaleProvider.supportedLocales / localeNames を単一ソースとして
/// 動的生成する（画面ごとのハードコード重複で言語追加が取り残される事故を防ぐ）。
Future<void> showLanguageSelectDialog(BuildContext context) async {
  final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
  final l10n = AppLocalizations.of(context)!;

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(l10n.selectLanguage),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: LocaleProvider.supportedLocales.map((loc) {
                final selected =
                    localeProvider.locale?.languageCode == loc.languageCode;
                return ListTile(
                  title: Text(
                    LocaleProvider.localeNames[loc.languageCode] ??
                        loc.languageCode,
                    style: TextStyle(
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                      color: selected
                          ? Theme.of(dialogContext).colorScheme.primary
                          : null,
                    ),
                  ),
                  selected: selected,
                  trailing: selected
                      ? Icon(Icons.check,
                          color: Theme.of(dialogContext).colorScheme.primary)
                      : null,
                  onTap: () {
                    localeProvider.setLocale(loc);
                    Navigator.pop(dialogContext);
                  },
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
        ],
      );
    },
  );
}
