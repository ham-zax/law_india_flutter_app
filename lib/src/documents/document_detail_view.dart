import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../bloc/document/document_bloc.dart';
import '../data/models/document_model.dart';
import '../settings/reading_settings.dart';
import '../widgets/favorite_button.dart';
import '../navigation/document_detail_arguments.dart';

// Simplified spacing constants
class Spacing {
  static const double xs = 4.0; // Micro spacing
  static const double sm = 8.0; // Default compact spacing
  static const double md = 12.0; // Standard spacing (reduced from 16)
  static const double lg = 16.0; // Section spacing (reduced from 24)

  // Optimized padding presets
  static const EdgeInsets contentPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  static const EdgeInsets cardPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm, // Reduced from md
  );

  static const EdgeInsets listItemSpacing = EdgeInsets.only(bottom: xs);
}

class EnhancedReadingView extends StatelessWidget {
  final String content;
  final ReadingSettings settings;

  const EnhancedReadingView({
    super.key,
    required this.content,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: settings.margins,
          vertical: Spacing.sm,
        ),
        child: Container(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight - (Spacing.sm * 2),
          ),
          alignment: Alignment.topLeft,
          child: SelectableText.rich(
            TextSpan(
              style: TextStyle(
                fontSize: settings.fontSize,
                height: settings.lineHeight,
                fontFamily: settings.fontFamily,
                color: theme.textTheme.bodyLarge?.color,
              ),
              children: [
                TextSpan(text: content),
              ],
            ),
            textAlign: TextAlign.justify,
            textScaler: MediaQuery.of(context).textScaler,
            selectionControls: MaterialTextSelectionControls(),
          ),
        ),
      );
    });
  }
}
class SectionContentView extends StatefulWidget {
  final String chapterNumber;
  final String sectionTitle;
  final String content;
  final ReadingSettings settings;
  final String sectionId;
  final bool isFavorited;

  const SectionContentView({
    super.key,
    required this.chapterNumber,
    required this.sectionTitle,
    required this.content,
    required this.settings,
    required this.sectionId,
    required this.isFavorited,
  });

  @override
  State<SectionContentView> createState() => _SectionContentViewState();
}
class _SectionContentViewState extends State<SectionContentView> {
  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Consumer<ReadingSettings>(
        builder: (context, settings, _) =>
            _buildSettingsSheet(context, settings),
      ),
    );
  }

// In SectionContentView class:

  Widget _buildSettingsSheet(BuildContext context, ReadingSettings settings) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Reading Settings',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          // Preview text with Consumer
          Consumer<ReadingSettings>(
            builder: (context, settings, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Preview Text\nSecond line for testing line height',
                style: TextStyle(
                  fontSize: settings.fontSize,
                  height: settings.lineHeight,
                  fontFamily: settings.fontFamily,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Font Size Slider with Consumer
          Consumer<ReadingSettings>(
            builder: (context, settings, _) => _buildSettingSlider(
              context: context,
              title: 'Font Size',
              value: settings.fontSize,
              min: 12,
              max: 32,
              divisions: 20,
              onChanged: (value) {
                settings.updateFontSize(value);
              },
              valueLabel: '${settings.fontSize.round()}',
            ),
          ),

          // Line Height Slider with Consumer
          Consumer<ReadingSettings>(
            builder: (context, settings, _) => _buildSettingSlider(
              context: context,
              title: 'Line Height',
              value: settings.lineHeight,
              min: 1.0,
              max: 2.5,
              divisions: 15,
              onChanged: (value) {
                settings.updateLineHeight(value);
              },
              valueLabel: settings.lineHeight.toStringAsFixed(1),
            ),
          ),

          // Margins Slider with Consumer
          Consumer<ReadingSettings>(
            builder: (context, settings, _) => _buildSettingSlider(
              context: context,
              title: 'Margins',
              value: settings.margins,
              min: 8,
              max: 32,
              divisions: 12,
              onChanged: (value) {
                settings.updateMargins(value);
              },
              valueLabel: '${settings.margins.round()}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSlider({
    required BuildContext context,
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required String valueLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text(valueLabel),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    // Parse the chapter ID from sectionId
    final parts = widget.sectionId.split('_');
    final chapterId = '${parts[0]}_${parts[1]}_${parts[2]}';

    // Find the correct chapter
    if (context.read<DocumentBloc>().state is DocumentLoaded) {
      final state = context.read<DocumentBloc>().state as DocumentLoaded;
      final chapter = state.findChapterById(chapterId);

      if (chapter != null) {
        // Get the actual section number
        final sectionNumber = parts.last;
        // Find the correct section
        final section = chapter.sections.firstWhere(
          (s) => s.sectionNumber == sectionNumber,
          orElse: () => chapter.sections.first,
        );

        // Track the actual viewed section
        context.read<DocumentBloc>().add(
              SectionViewed(chapter, section),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Section ${widget.sectionId.split('_').last}'),
        actions: [
          Consumer<ReadingSettings>(
            builder: (context, settings, child) {
              return FavoriteButton(
                sectionId: widget.sectionId,
                isFavorited: settings.isSectionFavorite(widget.sectionId),
              );
            },
          ),
          Consumer<ReadingSettings>(
            builder: (context, settings, child) {
              return IconButton(
                icon: Icon(Icons.format_size),
                onPressed: () => _showSettingsBottomSheet(context),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                  width: 1.0,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: Text(
              // Remove section number prefix from title
              widget.sectionTitle.replaceFirst(
                RegExp(r'^\d+\.\s*'),
                '',
              ),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Consumer<ReadingSettings>(
              builder: (context, settings, _) => AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: EnhancedReadingView(
                  key: ValueKey(settings.hashCode),
                  content: widget.content,
                  settings: settings,
                ),
              ),
            ),
          ),
          Padding(
            padding: Spacing.contentPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FilledButton.icon(
                  onPressed: () => _navigateToPreviousSection(context),
                  icon: Icon(Icons.arrow_back, size: 20),
                  label: Text('Previous'),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    minimumSize: Size(120, 48),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => _navigateToNextSection(context),
                  icon: Icon(Icons.arrow_forward, size: 20),
                  label: Text('Next'),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    minimumSize: Size(120, 48),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToNextSection(BuildContext context) {
    final bloc = context.read<DocumentBloc>();
    final state = bloc.state;

    if (state is DocumentLoaded) {
      final parts = widget.sectionId.split('_');
      final chapterId = '${parts[0]}_${parts[1]}_${parts[2]}';
      final currentChapter = state.findChapterById(chapterId);

      if (currentChapter != null) {
        final currentSectionNumber = parts.last;
        final currentSectionIndex = currentChapter.sections.indexWhere(
          (s) => s.sectionNumber == currentSectionNumber,
        );

        if (currentSectionIndex < currentChapter.sections.length - 1) {
          // Get next section
          final nextSection = currentChapter.sections[currentSectionIndex + 1];
          final nextSectionId =
              '${currentChapter.id}_${nextSection.sectionNumber}';

          // Navigate to next section
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => SectionContentView(
                chapterNumber: currentChapter.chapterNumber,
                sectionTitle: nextSection.sectionTitle,
                content: nextSection.content,
                settings: widget.settings,
                sectionId: nextSectionId,
                isFavorited: widget.settings.isSectionFavorite(nextSectionId),
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return Material(
                  color: Theme.of(context).colorScheme.surface,
                  child: SharedAxisTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.horizontal,
                    child: child,
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        } else {
          // Show completion message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have completed all sections in this chapter'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  void _navigateToPreviousSection(BuildContext context) {
    final bloc = context.read<DocumentBloc>();
    final state = bloc.state;

    if (state is DocumentLoaded) {
      final parts = widget.sectionId.split('_');
      final chapterId = '${parts[0]}_${parts[1]}_${parts[2]}';
      final currentChapter = state.findChapterById(chapterId);

      if (currentChapter != null) {
        final currentSectionNumber = parts.last;
        final currentSectionIndex = currentChapter.sections.indexWhere(
          (s) => s.sectionNumber == currentSectionNumber,
        );

        if (currentSectionIndex > 0) {
          // Get previous section
          final previousSection =
              currentChapter.sections[currentSectionIndex - 1];
          final previousSectionId =
              '${currentChapter.id}_${previousSection.sectionNumber}';

          // Navigate to previous section
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => SectionContentView(
                chapterNumber: currentChapter.chapterNumber,
                sectionTitle: previousSection.sectionTitle,
                content: previousSection.content,
                settings: widget.settings,
                sectionId: previousSectionId,
                isFavorited: widget.settings.isSectionFavorite(previousSectionId),
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return Material(
                  color: Theme.of(context).colorScheme.surface,
                  child: SharedAxisTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.horizontal,
                    child: child,
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        } else {
          // Show start of chapter message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You are at the first section of this chapter'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }
}

class DocumentDetailView extends StatefulWidget {
  static const routeName = '/document-detail';
  final DocumentDetailArguments arguments;

  const DocumentDetailView({
    super.key,
    required this.arguments,
  });

  // Add static route method to handle navigation
  static Route<dynamic> route(RouteSettings settings) {
    final args = settings.arguments;
    DocumentDetailArguments arguments;

    // Handle different argument types
    if (args is DocumentDetailArguments) {
      arguments = args;
    } else if (args is Map<String, dynamic>) {
      arguments = DocumentDetailArguments.fromMap(args);
    } else if (args is Document) {
      arguments = DocumentDetailArguments(document: args);
    } else if (args is DocumentChapter) {
      arguments = DocumentDetailArguments(chapter: args);
    } else {
      throw ArgumentError('Invalid arguments for DocumentDetailView');
    }

    // Return MaterialPageRoute with proper arguments
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => DocumentDetailView(arguments: arguments),
    );
  }

  @override
  State<DocumentDetailView> createState() => _DocumentDetailViewState();
}

class _DocumentDetailViewState extends State<DocumentDetailView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentBloc, DocumentState>(
      builder: (context, state) {
        if (state is DocumentLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DocumentError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is DocumentLoaded) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                widget.arguments.chapter != null
                    ? 'Chapter ${widget.arguments.chapter?.chapterNumber}'
                    : (widget.arguments.document?.title ?? ''),
              ),
            ),
            body: SafeArea(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: Spacing.sm,
                ),
                itemCount: _getItemCount(),
                itemBuilder: (context, index) {
                  if (widget.arguments.document != null) {
                    final chapter = widget.arguments.document!.chapters[index];
                    return _buildChapterCard(context, chapter, index);
                  } else if (widget.arguments.chapter != null) {
                    final section = widget.arguments.chapter!.sections[index];
                    return _buildSectionCard(context, section);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          );
        }

        return const Center(child: Text('No document data available'));
      },
    );
  }
  int _getItemCount() {
    if (widget.arguments.document != null) {
      return widget.arguments.document!.chapters.length;
    } else if (widget.arguments.chapter != null) {
      return widget.arguments.chapter!.sections.length;
    }
    return 0;
  }

  Widget _buildChapterCard(
      BuildContext context, DocumentChapter chapter, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: Spacing.listItemSpacing,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToChapter(context, chapter),
        child: Padding(
          padding: Spacing.cardPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.secondaryContainer,
                child: Text(
                  chapter.chapterNumber,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapter.chapterTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      '${chapter.sections.length} sections',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, DocumentSection section) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settings = context.read<ReadingSettings>();

    return Card(
      elevation: 0,
      margin: Spacing.listItemSpacing,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.surfaceContainerHighest,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToSection(context, section),
        child: Padding(
          padding: Spacing.cardPadding,
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  section.sectionNumber,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.sectionTitle.replaceFirst(
                        RegExp(r'^\d+\.\s*'),
                        '',
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Container(), // Empty container to maintain spacing
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToChapter(BuildContext context, DocumentChapter chapter) {
    Navigator.pushNamed(
      context,
      DocumentDetailView.routeName,
      arguments: DocumentDetailArguments(chapter: chapter),
    );
  }

  void _navigateToSection(BuildContext context, DocumentSection section) {
    final settings = context.read<ReadingSettings>();
    final chapter = widget.arguments.chapter!;
    final sectionId = '${chapter.id}_${section.sectionNumber}';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SectionContentView(
          chapterNumber: chapter.chapterNumber,
          sectionTitle: section.sectionTitle,
          content: section.content,
          settings: settings,
          sectionId: sectionId,
          isFavorited: settings.isSectionFavorite(sectionId),
        ),
      ),
    );
  }
}
