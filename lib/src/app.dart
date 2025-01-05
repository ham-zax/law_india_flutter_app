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
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade800,
              secondary: Colors.blue.shade600,
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
              selectedColor: Colors.blue.shade800,
              secondarySelectedColor: Colors.blue.shade800,
              disabledColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              labelStyle: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
              secondaryLabelStyle: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
              backgroundColor: Colors.grey.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide.none,
              ),
              checkmarkColor: Colors.transparent,
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
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
            colorScheme: ColorScheme.dark(
              primary: Colors.blue.shade300,
              secondary: Colors.blue.shade200,
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
              selectedColor: Colors.blue.shade300,
              secondarySelectedColor: Colors.blue.shade300,
              disabledColor: Colors.grey.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              labelStyle: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
              secondaryLabelStyle: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
              backgroundColor: Colors.grey.shade800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide.none,
              ),
              checkmarkColor: Colors.transparent,
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
                  case SampleItemDetailsView.routeName:
                    return const SampleItemDetailsView();
                  case SampleItemListView.routeName:
                    return const SampleItemListView();
                  case DocumentListView.routeName:
                    return const DocumentListView();
                  case DocumentDetailView.routeName:
                    final document = routeSettings.arguments as Document;
                    return DocumentDetailView(document: document);
                  default:
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
