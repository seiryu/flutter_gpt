import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPrefsRepo = StateNotifierProvider<SharedPrefsRepo, SharedPrefsRepoState>(
  (ref) => throw UnimplementedError()
);

class SharedPrefsRepo extends StateNotifier<SharedPrefsRepoState>{
  final SharedPreferences prefs;

  SharedPrefsRepo({required this.prefs}): super(
    SharedPrefsRepoState(
      openAiApiKey: prefs.getString("openAiApiKey") ?? "", 
      gptTempleture: prefs.getDouble("gptTempleture") ?? 0.9, 
      systemMessage: prefs.getString("gptSystemMessage") ?? "You are a helpful assistant.", 
      maxTokens: prefs.getInt("gptMaxTokens") ?? 2048,
      themeMode: ThemeMode.values[prefs.getInt("themeMode") ?? ThemeMode.light.index],
    )
  );

  Future<void> setConfig ({
    String? openAiApiKey,
    double? gptTempleture,
    String? systemMessage,
    int? maxTokens,
    ThemeMode? themeMode,
  }) async {
    if(openAiApiKey != null) await prefs.setString("openAiApiKey", openAiApiKey);
    if(gptTempleture != null) await prefs.setDouble("gptTempleture", gptTempleture);
    if(systemMessage != null) await prefs.setString("gptSystemMessage", systemMessage);
    if(maxTokens != null) await prefs.setInt("gptMaxTokens", maxTokens);
    if(themeMode != null) await prefs.setInt("themeMode", themeMode.index);

    state = state.copyWith(
      openAiApiKey: openAiApiKey,
      gptTempleture: gptTempleture,
      systemMessage: systemMessage,
      maxTokens: maxTokens,
      themeMode: themeMode,
    );
  }
}

class SharedPrefsRepoState{
  final String openAiApiKey;
  final double gptTempleture;
  final String systemMessage;
  final int maxTokens;
  final ThemeMode themeMode;

  SharedPrefsRepoState({
    required this.openAiApiKey, 
    required this.gptTempleture, 
    required this.systemMessage, 
    required this.maxTokens,
    required this.themeMode,
  });

  SharedPrefsRepoState copyWith({
    String? openAiApiKey,
    double? gptTempleture,
    String? systemMessage,
    int? maxTokens,
    ThemeMode? themeMode,
  }){
    return SharedPrefsRepoState(
      openAiApiKey: openAiApiKey ?? this.openAiApiKey,
      gptTempleture: gptTempleture ?? this.gptTempleture,
      systemMessage: systemMessage ?? this.systemMessage,
      maxTokens: maxTokens ?? this.maxTokens,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}