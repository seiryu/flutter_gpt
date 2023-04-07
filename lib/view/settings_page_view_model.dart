import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../util/shared_preferences.dart';

final settingsPageViewModel = StateNotifierProvider<SettingsPageViewModel, SettingsPageState>(
  (ref) => SettingsPageViewModel(ref)
);


class SettingsPageViewModel extends StateNotifier<SettingsPageState>{
  final StateNotifierProviderRef ref;
  late final apiKeyController = TextEditingController(text: ref.watch(sharedPrefsRepo).openAiApiKey);
  late final sysRoleMsgController = TextEditingController(text: ref.watch(sharedPrefsRepo).systemMessage);
  late final templetureController = TextEditingController(text: ref.watch(sharedPrefsRepo).gptTempleture.toString());
  late final maxTokensController = TextEditingController(text: ref.watch(sharedPrefsRepo).maxTokens.toString());

  

  SettingsPageViewModel(this.ref):super(
    SettingsPageState(
      themeMode: ref.read(sharedPrefsRepo).themeMode,
      openAiApiKey: ref.watch(sharedPrefsRepo).openAiApiKey,
      systemMessage: ref.watch(sharedPrefsRepo).systemMessage,
      gptTempleture: ref.watch(sharedPrefsRepo).gptTempleture,
      maxTokens: ref.watch(sharedPrefsRepo).maxTokens,
    )
  );

  Future<void> save() async {
    await ref.read(sharedPrefsRepo.notifier).setConfig(
      themeMode: state.themeMode,
      // openAiApiKey: apiKeyController.text, 
      openAiApiKey: state.openAiApiKey, 
      systemMessage: sysRoleMsgController.text,
      gptTempleture: double.tryParse(templetureController.text),
      maxTokens: int.tryParse(maxTokensController.text),
    );
  }

  void onFieldValueChanged({
      ThemeMode? themeMode,
      String? openAiApiKey,
      double? gptTempleture,
      int? maxTokens,
      String? systemMessage,
  }){
    state = state.copyWith(
      themeMode: themeMode,
      openAiApiKey: openAiApiKey,
      gptTempleture: gptTempleture,
      maxTokens: maxTokens,
      systemMessage: systemMessage,
    );
  }

  void onThemeModeChanged(ThemeMode mode){
    state = state.copyWith(themeMode: mode);
  }
}

class SettingsPageState{
  final ThemeMode themeMode;
  final String openAiApiKey;
  final String systemMessage;
  final double gptTempleture;
  final int maxTokens;

  SettingsPageState({
    required this.themeMode,
    required this.openAiApiKey,
    required this.systemMessage,
    required this.gptTempleture,
    required this.maxTokens,
  });


  SettingsPageState copyWith({
    ThemeMode? themeMode,
    String? openAiApiKey,
    String? systemMessage,
    double? gptTempleture,
    int? maxTokens,
  }){
    return SettingsPageState(
      themeMode: themeMode ?? this.themeMode, 
      openAiApiKey: openAiApiKey ?? this.openAiApiKey, 
      systemMessage: systemMessage ?? this.systemMessage, 
      gptTempleture: gptTempleture ?? this.gptTempleture, 
      maxTokens: maxTokens ?? this.maxTokens,
    );
  }
}