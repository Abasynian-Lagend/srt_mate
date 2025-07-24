class ToneService {
  static String detectTone(String text){
    final lower = text.toLowerCase();

    if (lower.contains('love') || lower.contains('happy')) return "😊 Happy";
    if (lower.contains('angry') || lower.contains('hate')) return "😠 Angry";
    if (lower.contains('cry') || lower.contains('sad')) return "😢 Sad";
    if (lower.contains('fear') || lower.contains('scared')) return "😨 Fear";

    return "😐 Neutral";
  }
}