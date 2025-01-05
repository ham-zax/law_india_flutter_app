import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'src/data/repositories/document_repository.dart';
import 'src/bloc/document/document_bloc.dart';

void main() async {
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  final documentRepository = LocalDocumentRepository();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: documentRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => DocumentBloc(
              repository: context.read<DocumentRepository>(),
            )..add(LoadDocuments()),
          ),
        ],
        child: MyApp(settingsController: settingsController),
      ),
    ),
  );
}
