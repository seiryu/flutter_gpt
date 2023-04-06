import 'package:flutter/material.dart';
import 'package:flutter_gpt/util/openai_chat.dart';
import 'package:flutter_gpt/util/shared_preferences.dart';
import 'package:flutter_gpt/view/chat_page_view_model.dart';
import 'package:flutter_gpt/view/openai_apikey_dialog.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';


var vm = chatPageViewModel;

class ChatPage extends HookConsumerWidget{
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        appBar: _buildAppBar(context, ref),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildList(context, ref),
            ),
            if( ref.watch(vm).isStreaming )
              const LinearProgressIndicator(),
            _buildTextField(context, ref),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, WidgetRef ref){
    return AppBar(
      title: Text(ref.watch(vm).title),
      actions: [
        IconButton(
          onPressed: () async {
            if( await ref.read(vm.notifier).saveChatAsPng() ){
              // ignore: use_build_context_synchronously
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("保存が完了しました。"),
                  actions: [
                    TextButton(
                      child: const Text("OK"),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
            }
          },
          icon: const Icon(Icons.save),
        ),
        IconButton(
          onPressed: () => ref.read(vm.notifier).clear(),
          icon: const Icon(Icons.delete),
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref){
    return SingleChildScrollView(
      reverse: true,
      padding: const EdgeInsets.all(8),
      child: RepaintBoundary(
        key: ref.watch(vm).chatListKey,
        child: Container(
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
          child: Column(
            children: [
              for(var message in ref.watch(vm).messages) ...{
                 _buildListItem(context, ref, message)
              },
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, WidgetRef ref, OpenAiCompletionMessage message){
    return Card(
      color: message.role == MessageRole.assistant
          ? Theme.of(context).colorScheme.surface
          : Theme.of(context).colorScheme.tertiaryContainer,
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

  Widget _buildTextField(BuildContext context, WidgetRef ref){
    final bool canSendText = 
        !ref.watch(vm).isStreaming && !ref.watch(vm).isTextFieldTextEmpty();

    onSubmit() async {
      if(ref.read(sharedPrefsRepo).openAiApiKey.isEmpty){
        await showDialog(context: context, builder: (_) => const OpenAiApiKeyDialog());
      }else{
        ref.read(vm.notifier).onTextSent();
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextFormField(
              maxLines: 8,
              minLines: 1,
              autofocus: true,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              controller: ref.watch(vm.notifier).textController,
              onChanged: (str) => ref.read(vm.notifier).onTextFieldChanged(str),
              decoration: const InputDecoration(
                isCollapsed: true,
                hintText: "Ask me anything ...",
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(8)
              ),
            ),
          ),
          IconButton(
            color: Theme.of(context).colorScheme.primary,
            onPressed: canSendText ? () => onSubmit() : null,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}