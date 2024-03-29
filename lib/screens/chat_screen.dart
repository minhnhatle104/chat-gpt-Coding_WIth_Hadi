import 'dart:developer';

import 'package:chat_gpt_demo/widgets/text_widget.dart';

import '../providers/chats_provider.dart';

import '../providers/models_provider.dart';
import 'package:provider/provider.dart';

import '../services/services.dart';

import '../constants/constants.dart';
import '../widgets/chat_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../services/assets_manager.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isTyping = false;
  late TextEditingController textEditingController;
  late ScrollController _listScrollController;
  late FocusNode focusNode;

  SpeechToText _speechToText = SpeechToText();
  var isListening = false;

  @override
  void initState() {
    _listScrollController = ScrollController();
    textEditingController = TextEditingController();
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  // List<ChatModel> chatList = [];

  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatsProvider = Provider.of<ChatsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AssetsManager.openaiLogo),
        ),
        title: const Text("ChatGPT"),
        actions: [
          IconButton(
            onPressed: () async {
              await Services.showModalSheet(context: context);
            },
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(children: [
          Flexible(
            child: ListView.builder(
              controller: _listScrollController,
              itemCount: chatsProvider.getChatList.length, //chatList.length
              itemBuilder: ((context, index) {
                return ChatWidget(
                  msg: chatsProvider
                      .getChatList[index].msg, //chatList[index].msg
                  chatIndex: chatsProvider
                      .getChatList[index].chatIndex, //chatList[index].chatIndex
                );
              }),
            ),
          ),
          if (_isTyping) ...[
            const SpinKitThreeBounce(
              color: Colors.white,
              size: 18,
            ),
          ],
          const SizedBox(
            height: 15,
          ),
          Material(
            color: cardColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      focusNode: focusNode,
                      style: const TextStyle(color: Colors.white),
                      controller: textEditingController,
                      onSubmitted: (value) async {
                        await sendMessageFCT(
                          modelsProvider: modelsProvider,
                          chatsProvider: chatsProvider,
                        );
                      },
                      decoration: const InputDecoration.collapsed(
                        hintText: "How can I help you ?",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      if (!isListening) {
                        var available =
                            await _speechToText.initialize(debugLogging: true);
                        if (available) {
                          setState(() {
                            isListening = true;
                            _speechToText.listen(
                              onResult: (result) {
                                setState(() {
                                  textEditingController.text =
                                      result.recognizedWords;
                                });
                              },
                            );
                          });
                        }
                      } else {
                        setState(() {
                          isListening = false;
                        });
                        _speechToText.stop();
                      }
                    },
                    icon: isListening
                        ? const Icon(
                            Icons.mic,
                            color: Colors.white,
                          )
                        : const Icon(
                            Icons.mic_off,
                            color: Colors.white,
                          ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await sendMessageFCT(
                        modelsProvider: modelsProvider,
                        chatsProvider: chatsProvider,
                      );
                    },
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void scrollListToEND() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.easeOut);
  }

  Future<void> sendMessageFCT(
      {required ModelsProvider modelsProvider,
      required ChatsProvider chatsProvider}) async {
    if (_isTyping) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: TextWidget(
          label: "You can't send multiple messages at a time",
        ),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (textEditingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: TextWidget(
          label: "Please type a message",
        ),
        backgroundColor: Colors.red,
      ));
      return;
    }
    try {
      String msg = textEditingController.text;
      setState(() {
        _isTyping = true;
        chatsProvider.addUserMessage(msg: msg);
        // chatList.add(ChatModel(msg: textEditingController.text, chatIndex: 0));
        textEditingController.clear();
        focusNode.unfocus();
      });
      await chatsProvider.sendMessageAndGetAnswers(
        msg: msg,
        chosenModelId: modelsProvider.getCurrentModel,
      );
      // chatList.addAll(await ApiService.sendMessage(
      //   message: textEditingController.text,
      //   modelId: modelsProvider.getCurrentModel,
      // ));
      setState(() {});
    } catch (error) {
      log("error $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: TextWidget(
          label: error.toString(),
        ),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        scrollListToEND();
        _isTyping = false;
      });
    }
  }
}
