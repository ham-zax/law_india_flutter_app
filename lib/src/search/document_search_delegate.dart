import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/document/document_bloc.dart';
import '../documents/document_detail_view.dart';

class DocumentSearchDelegate extends SearchDelegate<void> {
  final DocumentBloc bloc;

  DocumentSearchDelegate(this.bloc);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    bloc.add(SearchDocuments(query));
    return BlocBuilder<DocumentBloc, DocumentState>(
      builder: (context, state) {
        if (state is DocumentSearchResults) {
          return ListView.builder(
            itemCount: state.documents.length,
            itemBuilder: (context, index) {
              final doc = state.documents[index];
              return ListTile(
                title: Text(doc.title),
                subtitle: Text('${doc.category} • ${doc.chapters.length} Chapters'),
                onTap: () {
                  Navigator.pushNamed(
                    context, 
                    DocumentDetailView.routeName,
                    arguments: doc,
                  );
                },
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(); // Empty suggestions for now
  }
}
