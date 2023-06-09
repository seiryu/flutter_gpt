import 'package:flutter/material.dart';
import 'package:flutter_gpt/util/openai_chat.dart';
import 'package:flutter_gpt/view/advise_page_view_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:markdown_widget/markdown_widget.dart';

import '../util/shared_preferences.dart';

final vm = advisePageViewModel;

class AdvisePage extends HookConsumerWidget{
  const AdvisePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.watch(vm).message;

    return Scaffold(
      appBar: _buildAppBar(context, ref),
      body: ListView(
        children: [
          _buildForm(context, ref),
          if(message != null)
            // Expanded(
              // child: 
              _buildAdviseContent(context, ref, message),
            // ),
        ],
      ),
      bottomNavigationBar: ref.watch(vm).isStreaming
          ? const LinearProgressIndicator() : null,
    );
  }

  AppBar _buildAppBar(BuildContext context, WidgetRef ref){
    return AppBar(
      title: const Text("栽培相談"),
    );
  }

  Widget _buildForm(BuildContext context, WidgetRef ref){
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          DropdownButton<String>(
            value: ref.watch(vm).selectedBreed,
            items: [
              for(var breed in breeds)...{
                DropdownMenuItem(
                  alignment: AlignmentDirectional.center,
                  value: breed,
                  child: Container(
                    width: 120,
                    alignment: Alignment.center,
                    child: Text(breed),
                  ),
                )
              }
            ], 
            onChanged: (v) => ref.read(vm.notifier).onSelectBreed(v)
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: ref.watch(vm).selectedContent,
            items: [
              for(var content in contents)...{
                DropdownMenuItem(
                  alignment: AlignmentDirectional.center,
                  value: content,
                  child: Container(
                    width: 160,
                    alignment: Alignment.center,
                    child: Text(content),
                  ),
                )
              }
            ], 
            onChanged: (v) => ref.read(vm.notifier).onSelectContent(v)
          ),
          const SizedBox(width: 16),
          FilledButton(
            onPressed: () => ref.read(vm.notifier).submit(), 
            child: const Text("相談")
          ),
        ],
      ),
    );
  }

  Widget _buildAdviseContent(BuildContext context, WidgetRef ref, OpenAiCompletionMessage message){
    return Card(
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.all(12),
      semanticContainer: false,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MarkdownWidget(
              padding: const EdgeInsets.all(0),
              shrinkWrap: true,
              data: message.content,
              config: ref.watch(sharedPrefsRepo).themeMode == ThemeMode.dark
                  ? MarkdownConfig.darkConfig
                  : MarkdownConfig.defaultConfig,
            )
          ]
        ),
      ),
    );
  }

}