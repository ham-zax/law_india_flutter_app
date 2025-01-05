import 'package:flutter/material.dart';
import 'package:flutter/material.dart' show NavigationDrawer, NavigationDrawerDestination;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'documents/document_detail_view.dart';
import 'data/models/document_model.dart';

import 'sample_feature/sample_item_details_view.dart';
import 'sample_feature/sample_item_list_view.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';
import 'documents/document_list_view.dart';
import 'documents/document_detail_view.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.
          restorationScopeId: 'app',

          // Provide the generated AppLocalizations to the MaterialApp. This
          // allows descendant Widgets to display the correct translations
          // depending on the user's locale.
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],

          // Use AppLocalizations to configure the correct application title
          // depending on the user's locale.
          //
          // The appTitle is defined in .arb files found in the localization
          // directory.
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue.shade800,
              brightness: Brightness.light,
            ),
            typography: Typography.material2021(platform: TargetPlatform.android),
            textTheme: TextTheme(
              displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400),
              displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
              displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
              headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w400),
              headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
              headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
              titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
              titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
            navigationDrawerTheme: NavigationDrawerThemeData(
              backgroundColor: Colors.white,
              indicatorColor: Colors.blue.shade800,
              labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    );
                  }
                  return const TextStyle(
                    fontSize: 14,
                  );
                },
              ),
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: ZoomPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
            cardTheme: CardTheme(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              margin: EdgeInsets.zero,
            ),
            chipTheme: ChipThemeData(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              labelStyle: Theme.of(context).textTheme.labelLarge,
              side: BorderSide.none,
              shape: StadiumBorder(
                side: BorderSide.none,
              ),
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue.shade300,
              brightness: Brightness.dark,
            ),
            navigationDrawerTheme: NavigationDrawerThemeData(
              backgroundColor: Colors.grey.shade900,
              indicatorColor: Colors.blue.shade300,
              labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    );
                  }
                  return const TextStyle(
                    fontSize: 14,
                  );
                },
              ),
            ),
            cardTheme: CardTheme(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Colors.grey.shade700,
                  width: 1,
                ),
              ),
              margin: EdgeInsets.zero,
            ),
            chipTheme: ChipThemeData(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              labelStyle: Theme.of(context).textTheme.labelLarge,
              side: BorderSide.none,
              shape: StadiumBorder(
                side: BorderSide.none,
              ),
            ),
          ),
          themeMode: settingsController.themeMode,

          // Set DocumentListView as the default home route
          initialRoute: DocumentListView.routeName,
          
          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);
                  case DocumentListView.routeName:
                    return const DocumentListView();
                  case DocumentDetailView.routeName:
                    if (routeSettings.arguments is Document) {
                      return DocumentDetailView(document: routeSettings.arguments as Document);
                    } else {
                      return DocumentDetailView(chapter: routeSettings.arguments as DocumentChapter);
                    }
                  default:
                    // Redirect any unknown routes to the document list
                    return const DocumentListView();
                }
              },
            );
          },
        );
      },
    );
  }
}
