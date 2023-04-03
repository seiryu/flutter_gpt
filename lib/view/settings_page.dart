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
      leading: const CloseButton(),
    );
  }

  FloatingActionButton _buildFAB(BuildContext context, WidgetRef ref){
    return FloatingActionButton(
      onPressed: () => ref.watch(vm.notifier).save(),
      child: const Icon(Icons.save),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref){
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextFormField(
            controller: ref.watch(vm.notifier).apiKeyController,
            decoration: const InputDecoration(
              label: Text("API Key"),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height:24),
          TextFormField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [ FilteringTextInputFormatter.allow(RegExp('^\$|^(0|([1-9][0-9]{0,}))(\\.[0-9]{0,})?\$')) ],
            controller: ref.watch(vm.notifier).templetureController,
            decoration: const InputDecoration(
              label: Text("Templeture"),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height:24),
          // TextFormField(
          //   keyboardType: const TextInputType.numberWithOptions(),
          //   inputFormatters: [ FilteringTextInputFormatter.digitsOnly ],
          //   controller: ref.watch(vm.notifier).maxTokensController,
          //   decoration: const InputDecoration(
          //     label: Text("Max Tokens"),
          //     border: OutlineInputBorder(),
          //   ),
          // ),
          // const SizedBox(height:24),
          TextFormField(
            minLines: 5,
            maxLines: 20,
            controller: ref.watch(vm.notifier).sysRoleMsgController,
            decoration: const InputDecoration(
              label: Text("System Role Message"),
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
  // Widget
}