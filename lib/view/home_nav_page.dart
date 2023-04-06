import 'package:flutter/material.dart';
import 'package:flutter_gpt/view/advise_page.dart';
import 'package:flutter_gpt/view/chat_page.dart';
import 'package:flutter_gpt/view/home_nav_page_view_model.dart';
import 'package:flutter_gpt/view/settings_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final pages =  [
  const ChatPage(),
  const AdvisePage(),
  const SettingsPage(),
];

final vm = homeNavPageViewModel;

class HomeNavPage extends HookConsumerWidget{
  const HomeNavPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: pages[ ref.watch(vm).selectedIndex ],
      bottomNavigationBar: _buildBottomNav(context, ref),
    );
  }

  Widget _buildBottomNav(BuildContext context, WidgetRef ref){
    return BottomNavigationBar(
      currentIndex: ref.watch(vm).selectedIndex,
      onTap: (i) => ref.read(vm.notifier).onTap(i),
      items: const [
        BottomNavigationBarItem(
          label: "チャット",
          icon: Icon(Icons.chat),
        ),
        BottomNavigationBarItem(
          label: "栽培相談",
          icon: Icon(Icons.contact_support),
        ),
        BottomNavigationBarItem(
          label: "設定",
          icon: Icon(Icons.settings),
        ),
      ],
    );
  }

}