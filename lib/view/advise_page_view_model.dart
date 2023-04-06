import 'package:flutter_gpt/util/openai_chat.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final breeds = [
  "トマト",
  "ナス",
  "キュウリ",
  "ラディッシュ",
  "ベビーリーフ",
  "バジル",
];

final contents = [
  "育て方",
  "栽培時期",
  "水やり方法",
  "病気と対策",
  "害虫と対策",
  "育てやすい品種",
];


final advisePageViewModel = StateNotifierProvider<AdvisePageViewModel, AdvisePageState>(
  (ref) => AdvisePageViewModel(ref),
);

class AdvisePageViewModel extends StateNotifier<AdvisePageState>{
  final StateNotifierProviderRef ref;

  AdvisePageViewModel(this.ref): super(
    AdvisePageState()
  );

  void onSelectBreed(String? str){
    state = state.copyWith(selectedBreed: str);
  }
  
  void onSelectContent(String? str){
    state = state.copyWith(selectedContent: str);
  }

  void submit(){
    if(state.isStreaming) return;
    if(state.selectedBreed == null) return;
    if(state.selectedContent == null) return;


    final prompt = "${state.selectedBreed}の${state.selectedContent}について教えてください";

    final stream = ref.read(openAiChat).createCompletionStream(
      [
        OpenAiCompletionMessage(role: MessageRole.user, content: prompt)
      ]
    ); 

    state = state.clearMessage();
    state = state.copyWith(isStreaming: true);
    stream.listen(
      (msg) {
        if(state.message == null){
          state = state.copyWith(message: msg);
        }else{
          state = state.copyWith(
            message: state.message! + msg
          );
        }
      },
      onDone: () => state = state.copyWith(isStreaming: false),
    );

  }
}

class AdvisePageState{
  final OpenAiCompletionMessage? message;
  final String? selectedBreed;
  final String? selectedContent;
  final bool isStreaming;

  AdvisePageState({this.message, this.selectedBreed, this.selectedContent, this.isStreaming = false});

  AdvisePageState clearMessage(){
    return AdvisePageState(
      message: null,
      selectedBreed: selectedBreed,
      selectedContent: selectedContent,
      isStreaming: isStreaming,
    );
  }

  AdvisePageState copyWith({
    OpenAiCompletionMessage? message,
    String? selectedBreed,
    String? selectedContent,
    bool? isStreaming,
  }){
    return AdvisePageState(
      message: message ?? this.message,
      selectedBreed: selectedBreed ?? this.selectedBreed,
      selectedContent: selectedContent ?? this.selectedContent,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}