import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/database_debug_utils.dart';

/// Database information page for debugging and development
/// Only available in debug builds
class DatabaseInfoPage extends StatefulWidget {
  const DatabaseInfoPage({super.key});

  @override
  State<DatabaseInfoPage> createState() => _DatabaseInfoPageState();
}

class _DatabaseInfoPageState extends State<DatabaseInfoPage> {
  Map<String, dynamic>? _databaseInfo;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDatabaseInfo();
  }

  Future<void> _loadDatabaseInfo() async {
    try {
      final info = await DatabaseDebugUtils.getDatabaseInfo();
      setState(() {
        _databaseInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _copyPathToClipboard() async {
    if (_databaseInfo?['path'] != null) {
      await Clipboard.setData(ClipboardData(text: _databaseInfo!['path']));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📋 Database path copied to clipboard'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Information'),
        backgroundColor: theme.colorScheme.surfaceVariant,
        actions: [
          if (_databaseInfo?['path'] != null)
            IconButton(
              onPressed: _copyPathToClipboard,
              icon: const Icon(Icons.copy),
              tooltip: 'Copy Database Path',
            ),
          IconButton(
            onPressed: _loadDatabaseInfo,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading database information...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading database information',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadDatabaseInfo,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDatabaseOverview(theme),
          const SizedBox(height: 24),
          if (_databaseInfo!['exists'])
            _buildTablesSection(theme),
          const SizedBox(height: 24),
          _buildDeveloperNotes(theme),
        ],
      ),
    );
  }

  Widget _buildDatabaseOverview(ThemeData theme) {
    final info = _databaseInfo!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Database Overview',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Path', info['path'], theme, isPath: true),
            const SizedBox(height: 12),
            _buildInfoRow('Exists', info['exists'] ? 'Yes' : 'No', theme),
            if (info['exists']) ...[
              const SizedBox(height: 12),
              _buildInfoRow('Size', '${info['size_mb']} MB', theme),
              const SizedBox(height: 12),
              _buildInfoRow('Tables', info['table_names'].length.toString(), theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme, {bool isPath = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: isPath
              ? SelectableText(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                )
              : Text(
                  value,
                  style: theme.textTheme.bodyMedium,
                ),
        ),
      ],
    );
  }

  Widget _buildTablesSection(ThemeData theme) {
    final tables = _databaseInfo!['table_names'] as List;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.table_chart,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Database Tables',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...tables.map((tableName) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.table_rows,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    tableName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperNotes(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.developer_mode,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Developer Notes',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '• Use DB Browser for SQLite to view the database\n'
              '• Copy the path above and open it in your database tool\n'
              '• Database is created on first app launch\n'
              '• This page is only available in debug builds\n'
              '• Check the DATABASE_LOCATION_GUIDE.md for more info',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This page helps developers locate and examine the SQLite database during development.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
