import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../util/shared_preferences.dart';

final settingsPageViewModel = StateNotifierProvider.autoDispose<SettingsPageViewModel, SettingsPageState>(
  (ref) => SettingsPageViewModel(ref)
);


class SettingsPageViewModel extends StateNotifier<SettingsPageState>{
  final StateNotifierProviderRef ref;
  late final apiKeyController = TextEditingController(text: ref.watch(sharedPrefsRepo).openAiApiKey);
  late final sysRoleMsgController = TextEditingController(text: ref.watch(sharedPrefsRepo).systemMessage);
  late final templetureController = TextEditingController(text: ref.watch(sharedPrefsRepo).gptTempleture.toString());
  late final maxTokensController = TextEditingController(text: ref.watch(sharedPrefsRepo).maxTokens.toString());

  

  SettingsPageViewModel(this.ref):super( SettingsPageState() );

  Future<void> save() async {
    await ref.watch(sharedPrefsRepo.notifier).setConfig(
      openAiApiKey: apiKeyController.text, 
      systemMessage: sysRoleMsgController.text,
      gptTempleture: double.tryParse(templetureController.text),
      maxTokens: int.tryParse(maxTokensController.text),
    );
  }
}

class SettingsPageState{
}