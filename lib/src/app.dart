import 'package:flutter/material.dart';
import 'package:flutter/material.dart'
    show NavigationDrawer, NavigationDrawerDestination;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'documents/document_detail_view.dart';
import 'data/models/document_model.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';
import 'documents/document_list_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          
          restorationScopeId: 'app',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
          ],
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,
          theme: ThemeData(useMaterial3: true),
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: settingsController.themeMode,
          initialRoute: DocumentListView.routeName,
          onGenerateRoute: (RouteSettings routeSettings) {
            switch (routeSettings.name) {
              case SettingsView.routeName:
                return MaterialPageRoute<void>(
                    settings: routeSettings,
                    builder: (BuildContext context) =>
                        SettingsView(controller: settingsController));
              case DocumentListView.routeName:
                return MaterialPageRoute<void>(
                    settings: routeSettings,
                    builder: (BuildContext context) =>
                        const DocumentListView());
              case DocumentDetailView.routeName:
                return DocumentDetailView.route(routeSettings);
              default:
                return MaterialPageRoute<void>(
                    settings: routeSettings,
                    builder: (BuildContext context) =>
                        const DocumentListView());
            }
          },
          onUnknownRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) => const DocumentListView(),
            );
          },
        );
      },
    );
  }
}
