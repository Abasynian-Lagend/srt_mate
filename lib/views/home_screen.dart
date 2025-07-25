import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/subtitle_model.dart';
import '../services/file_parser_service.dart';
import '../services/translation_service.dart';
import '../services/summarizer_service.dart';
import '../widgets/subtitle_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Subtitle> subtitles = [];
  String selectedLang = 'ur';
  String summaryResult = '';
  bool isTranslating = false;

  List<String> languages = ['ur', 'es', 'fr', 'de', 'hi'];

  Future<void> pickSrtFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['srt']);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final parsed = FileParserService.parseSrt(content);
      setState(() => subtitles = parsed);
    }
  }

  Future<void> translateAllSubtitles() async {
    setState(() => isTranslating = true);
    List<Subtitle> translatedSubs = [];
    for (var sub in subtitles) {
      final translatedText = await TranslationService.translateText(sub.text, selectedLang);
      translatedSubs.add(Subtitle(sub.index, sub.startTime, sub.endTime, translatedText));
    }
    setState(() {
      subtitles = translatedSubs;
      isTranslating = false;
    });
  }

  void summarize() {
    final lines = subtitles.map((e) => e.text).toList();
    final result = SummarizerService.summarizeSubtitles(lines);
    setState(() => summaryResult = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SRTMate AI Viewer")),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: pickSrtFile,
                child: Text("Select .SRT File"),
              ),
              SizedBox(width: 10),
              DropdownButton<String>(
                value: selectedLang,
                items: languages.map((lang) => DropdownMenuItem(
                  value: lang,
                  child: Text(lang.toUpperCase()),
                )).toList(),
                onChanged: (val) => setState(() => selectedLang = val!),
              ),
              ElevatedButton(
                onPressed: translateAllSubtitles,
                child: Text("Translate"),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: summarize,
                child: Text("Summarize"),
              )
            ],
          ),
          if (isTranslating) CircularProgressIndicator(),
          if (summaryResult.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(10),
              child: Text("Summary:\n$summaryResult"),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: subtitles.length,
              itemBuilder: (_, i) => SubtitleCard(subtitle: subtitles[i]),
            ),
          )
        ],
      ),
    );
  }
}