import 'package:dart_openai/openai.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final openAiChat = StateNotifierProvider<OpenAiChat, OpenAiChatState>( (ref) => OpenAiChat() );

class OpenAiChat extends StateNotifier<OpenAiChatState>{

  OpenAiChat() : super( OpenAiChatState( apiKey: "" ) );

  void setConfig({
    String? apiKey,
    double? templeture,
    String? systemMessage,
    int? maxTokens,
  }){
    state = state.copyWith(
      apiKey: apiKey,
      templeture: templeture,
      systemMessage: systemMessage,
      maxTokens: maxTokens,
    );
  }
  

  Future< OpenAIChatCompletionChoiceMessageModel > createCompletion(
    List<OpenAIChatCompletionChoiceMessageModel> messages
  ) async {
    messages.insert(
      0, 
      OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: state.systemMessage
      ),
    );

    var completion = await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo", 
      messages: messages,
      temperature: state.templeture,
      maxTokens: state.maxTokens
    );

    var resMessage = completion.choices[0].message;

    return resMessage;
  }

  Stream<OpenAIStreamChatCompletionModel> createCompletionStream(
    List<OpenAIChatCompletionChoiceMessageModel> messages
  ){
    messages.insert(
      0, 
      OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: state.systemMessage
      ),
    );
    print(state.maxTokens);
    var stream = OpenAI.instance.chat.createStream(
      model: "gpt-3.5-turbo", 
      messages: messages,
      temperature: state.templeture,
      // maxTokens: state.maxTokens,
    );

    // return stream.map((event) => event.choices.first.delta);
    return stream.where((event) => event.choices.first.delta.content != null);
  }
}

class OpenAiChatState{
  final String apiKey;
  final double templeture;
  final String systemMessage;
  final int maxTokens;

  OpenAiChatState({
    required this.apiKey,
    this.templeture = 1.0,
    this.systemMessage = 'You are a helpful assistant.',
    this.maxTokens = 2048,
  }){
    print(apiKey);
    OpenAI.apiKey = apiKey;
  }

  OpenAiChatState copyWith({
    String? apiKey,
    double? templeture,
    String? systemMessage,
    int? maxTokens,
  }){
    return OpenAiChatState(
      apiKey: apiKey ?? this.apiKey,
      templeture: templeture ?? this.templeture,
      systemMessage: systemMessage ?? this.systemMessage,
      maxTokens: maxTokens ?? this.maxTokens,
    );
  }
}
