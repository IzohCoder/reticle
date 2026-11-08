import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/app_typography.dart';
import '../../../data/providers/database_provider.dart';
import '../../../data/database.dart';
import '../widgets/document_card.dart';
import '../widgets/folder_chip_bar.dart';

/// Provider for all documents, watched as a stream.
final documentsStreamProvider = StreamProvider<List<ScanDocument>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllDocuments();
});

/// Provider for all folders.
final foldersStreamProvider = StreamProvider<List<ScanFolder>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllFolders();
});

/// Provider for search results.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for the current view mode (grid/list).
final viewModeProvider = StateProvider<bool>((ref) => true); // true = grid

/// Provider for selected folder filter.
final selectedFolderProvider = StateProvider<int?>((ref) => null);

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGrid = ref.watch(viewModeProvider);
    final docsAsync = ref.watch(documentsStreamProvider);
    final foldersAsync = ref.watch(foldersStreamProvider);
    final selectedFolder = ref.watch(selectedFolderProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Search documents…',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                onChanged: (q) =>
                    ref.read(searchQueryProvider.notifier).state = q,
              )
            : Text(
                'Reticle',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: AppFonts.display,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching
                ? PhosphorIconsRegular.x
                : PhosphorIconsRegular.magnifyingGlass),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  ref.read(searchQueryProvider.notifier).state = '';
                }
              });
            },
          ),
          IconButton(
            icon: Icon(isGrid
                ? PhosphorIconsRegular.list
                : PhosphorIconsRegular.squaresFour),
            onPressed: () =>
                ref.read(viewModeProvider.notifier).state = !isGrid,
          ),
        ],
      ),
      body: Column(
        children: [
          // Folder chips
          foldersAsync.when(
            data: (folders) => folders.isEmpty
                ? const SizedBox.shrink()
                : FolderChipBar(
                    folders: folders,
                    selectedId: selectedFolder,
                    onSelected: (id) => ref
                        .read(selectedFolderProvider.notifier)
                        .state = id,
                  ),
            loading: () => const SizedBox(height: 48),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Document grid/list
          Expanded(
            child: docsAsync.when(
              data: (docs) {
                // Filter by folder
                var filtered = selectedFolder != null
                    ? docs
                        .where((d) => d.folderId == selectedFolder)
                        .toList()
                    : docs;

                // Filter by search (simple title match for now; M2 adds FTS)
                if (searchQuery.isNotEmpty) {
                  filtered = filtered
                      .where((d) => d.title
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()))
                      .toList();
                }

                if (filtered.isEmpty) {
                  return _buildEmptyState(
                      context, searchQuery.isNotEmpty);
                }

                if (isGrid) {
                  return _buildGrid(context, filtered);
                }
                return _buildList(context, filtered);
              },
              loading: () => const Center(
                  child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Failed to load documents',
                    style: theme.textTheme.bodyMedium),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isSearch) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearch
                  ? PhosphorIconsRegular.magnifyingGlass
                  : PhosphorIconsRegular.camera,
              size: 56,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(height: Spacing.md),
            Text(
              isSearch ? 'No results' : 'No documents yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              isSearch
                  ? 'Try a different search term'
                  : 'Tap the viewfinder to scan your first document',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<ScanDocument> docs) {
    return GridView.builder(
      padding: const EdgeInsets.all(Spacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: Spacing.md,
        crossAxisSpacing: Spacing.md,
        childAspectRatio: 0.75,
      ),
      itemCount: docs.length,
      itemBuilder: (context, index) => DocumentCard(
        document: docs[index],
        isGrid: true,
        onTap: () =>
            context.push('/library/${docs[index].id}'),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<ScanDocument> docs) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      itemCount: docs.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        indent: Spacing.md + 56 + Spacing.md,
      ),
      itemBuilder: (context, index) => DocumentCard(
        document: docs[index],
        isGrid: false,
        onTap: () =>
            context.push('/library/${docs[index].id}'),
      ),
    );
  }
}
