import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animations/animations.dart';
import 'package:provider/provider.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'src/settings/reading_settings.dart';
import 'src/data/repositories/document_repository.dart';
import 'src/bloc/document/document_bloc.dart';

void main() async {
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  final documentRepository = LocalDocumentRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ReadingSettings(),
        ),
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<DocumentRepository>.value(value: documentRepository),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => DocumentBloc(
                  repository: RepositoryProvider.of<DocumentRepository>(context),
                )..add(LoadDocuments()),
              ),
            ],
            child: MyApp(settingsController: settingsController),
          ),
        ),
      ],
    ),
  );
}

class MyApp extends StatelessWidget {
  final SettingsController settingsController;

  const MyApp({super.key, required this.settingsController});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Document Viewer',
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case DocumentDetailView.routeName:
            return DocumentDetailView.route(settings);
          default:
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(child: Text('Page not found')),
              ),
            );
        }
      },
      home: const AppHome(),
    );
  }
}
