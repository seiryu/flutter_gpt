import 'package:hooks_riverpod/hooks_riverpod.dart';

final homeNavPageViewModel = StateNotifierProvider<HomeNavPageViewModel, HomeNavPageState>(
  (ref) => HomeNavPageViewModel(ref),
);


class HomeNavPageViewModel extends StateNotifier<HomeNavPageState>{
  final StateNotifierProviderRef ref;

  HomeNavPageViewModel(this.ref): super(
    HomeNavPageState(0)
  );

  void onTap(int index){
    state = state.copyWith(index);
  }
}

class HomeNavPageState{
  final int selectedIndex;

  HomeNavPageState(this.selectedIndex); 

  HomeNavPageState copyWith(int selectedIndex){
    return HomeNavPageState(selectedIndex);
  }
}