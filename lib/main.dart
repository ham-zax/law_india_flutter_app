import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animations/animations.dart';
import 'package:provider/provider.dart';

import 'src/app.dart';
import 'src/documents/document_detail_view.dart';
import 'src/documents/document_list_view.dart';
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

