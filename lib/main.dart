import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animations/animations.dart';

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
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Animation Test')),
        body: Center(
          child: OpenContainer(
            transitionDuration: const Duration(seconds: 1),
            closedBuilder: (_, openContainer) {
              return GestureDetector(
                onTap: openContainer,
                child: Container(
                  width: 200,
                  height: 100,
                  color: Colors.blue,
                  child: const Center(
                    child: Text(
                      'Tap Me',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              );
            },
            openBuilder: (_, __) {
              return Scaffold(
                appBar: AppBar(title: const Text('Expanded View')),
                body: const Center(
                  child: Text('This is the expanded view!'),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}
