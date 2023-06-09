import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gpt/view/settings_page_view_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final vm = settingsPageViewModel;

class SettingsPage extends HookConsumerWidget{
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: _buildAppBar(context, ref),
      floatingActionButton: _buildFAB(context, ref),
      body: _buildBody(context, ref),
    );
  }

  AppBar _buildAppBar(BuildContext context, WidgetRef ref){
    return AppBar(
      title: const Text("設定"),
    );
  }

  FloatingActionButton _buildFAB(BuildContext context, WidgetRef ref){
    return FloatingActionButton(
      onPressed: () => ref.watch(vm.notifier).save(),
      child: const Icon(Icons.save),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref){
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Text('テーマ'),
            const SizedBox(width: 16),
            SegmentedButton(
              segments: const [
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode),
                  label: Text("light")
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode),
                  label: Text("dark")
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.system,
                  icon: Icon(Icons.hdr_auto),
                  label: Text("system")
                ),
              ], 
              selected: {ref.watch(vm).themeMode},
              onSelectionChanged: (modes) => ref.read(vm.notifier).onFieldValueChanged(themeMode: modes.first),
            ),
          ],
        ),
        const SizedBox(height:24),
        TextFormField(
          initialValue: ref.watch(vm).openAiApiKey,
          onChanged: (str) => ref.read(vm.notifier).onFieldValueChanged(openAiApiKey: str),
          decoration: const InputDecoration(
            label: Text("API Key"),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height:24),
        TextFormField(
          initialValue: ref.watch(vm).gptTempleture.toString(),
          onChanged: (str) => ref.read(vm.notifier).onFieldValueChanged(gptTempleture: double.tryParse(str)),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [ FilteringTextInputFormatter.allow(RegExp('^\$|^(0|([1-9][0-9]{0,}))(\\.[0-9]{0,})?\$')) ],
          decoration: const InputDecoration(
            label: Text("Templeture"),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height:24),
        TextFormField(
          initialValue: ref.watch(vm).maxTokens.toString(),
          onChanged: (str) => ref.read(vm.notifier).onFieldValueChanged(maxTokens: int.tryParse(str)),
          keyboardType: const TextInputType.numberWithOptions(),
          inputFormatters: [ FilteringTextInputFormatter.digitsOnly ],
          decoration: const InputDecoration(
            label: Text("Max Tokens"),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height:24),
        TextFormField(
          initialValue: ref.watch(vm).systemMessage,
          onChanged: (str) => ref.read(vm.notifier).onFieldValueChanged(systemMessage: str),
          minLines: 10,
          maxLines: null,
          decoration: const InputDecoration(
            label: Text("System Role Message"),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
  // Widget
}