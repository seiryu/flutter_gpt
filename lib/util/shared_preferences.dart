import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPrefsRepo = Provider<SharedPrefsRepo>(
  (ref) => throw UnimplementedError()
);

class SharedPrefsRepo{
  final SharedPreferences prefs;

  SharedPrefsRepo({required this.prefs});

  String get openAiApiKey => prefs.getString("openAiApiKey") ?? "";
  double get gptTempleture => prefs.getDouble("gptTempleture") ?? 0.9;
  String get systemMessage => prefs.getString("gptSystemMessage") ?? "You are a helpful assistant.";
  int get maxTokens => prefs.getInt("gptMaxTokens") ?? 2048;

  Future<void> setConfig ({
    String? apiKey,
    double? templeture,
    String? systemMessage,
    int? maxTokens,
  }) async {
    if(apiKey != null)        await prefs.setString("openAiApiKey", apiKey);
    if(templeture != null)    await prefs.setDouble("gptTempleture", templeture);
    if(systemMessage != null) await prefs.setString("gptSystemMessage", systemMessage);
    if(maxTokens != null)     await prefs.setInt("gptMaxTokens", maxTokens);
  }

}