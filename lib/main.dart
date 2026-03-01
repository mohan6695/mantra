import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/local/database.dart';

/// Global database provider - single instance for the entire app lifecycle.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      child: const MantraApp(),
    ),
  );
}

class MantraApp extends ConsumerWidget {
  const MantraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Mantra Counter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late final AppDatabase _db;

  @override
  void initState() {
    super.initState();
    _db = ref.read(databaseProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mantra Dashboard'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<MantraConfigTableData>>(
        stream: _db.watchAllMantras(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final mantras = snapshot.data ?? [];
          if (mantras.isEmpty) {
            return const Center(child: Text('No mantras configured.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: mantras.length,
            itemBuilder: (context, index) {
              final mantra = mantras[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${mantra.targetCount}'),
                  ),
                  title: Text(mantra.name),
                  subtitle: Text(mantra.devanagari),
                  trailing: const Icon(Icons.play_arrow_rounded),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Start ${mantra.name} session')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to add/configure mantra screen
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Mantra'),
      ),
    );
  }
}
