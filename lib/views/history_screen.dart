import 'package:flutter/material.dart';
import '../services/history_service.dart';
import 'dart:io';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryEntry> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final entries = await HistoryService.getHistory();
    setState(() => history = entries);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Subtitle History")),
      body: history.isEmpty
          ? const Center(child: Text("No history available."))
          : ListView.separated(
        itemCount: history.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (context, index) {
          final entry = history[index];
          final fileExists = File(entry.filePath).existsSync();

          return ListTile(
            title: Text(entry.filename),
            subtitle: Text("${entry.date} • ${fileExists ? 'Available' : 'Missing'}"),
            leading: const Icon(Icons.history),
            trailing: fileExists
                ? const Icon(Icons.arrow_forward_ios, size: 16)
                : const Icon(Icons.warning, size: 16, color: Colors.red),
            onTap: () {
              if (fileExists) {
                Navigator.pop(context, entry);
              }
            },
          );
        },
      ),
    );
  }
}
