import 'dart:io';
import 'dart:typed_data';
import 'package:ai_image/Auth/login.dart';
import 'package:ai_image/Pages/UI_Components/sidebar.dart';
import 'package:ai_image/resources/colors.dart';
import 'package:ai_image/resources/strings.dart';
import 'package:ai_image/services/OpenAiService.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

class HomePage extends StatefulWidget {
  static String route = '/home';
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
  final OpenAIService openAIService = OpenAIService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController textSms = TextEditingController();
  ScreenshotController screenshotController = ScreenshotController();
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();

  late String chatId;
  String? prompt;
  String? generatedImageUrl;
  int start = 200;
  int delay = 200;

  String lastWords = '';
  bool isListening = false;

  checkUser() {
    if (_auth.currentUser?.email == null) {
      Get.offAll(LoginView());
    }
  }

  @override
  void initState() {
    super.initState();
    checkUser();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {
      isListening = true;
    });
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {
      isListening = false;
    });
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  downloadImg() async {
    var result = await Permission.storage.request();

    if (result.isGranted) {
      try {
        Uint8List? img = await screenshotController.capture(
          delay: const Duration(milliseconds: 100),
          pixelRatio: 1.0,
        );

        if (img != null) {
          final directory = await getApplicationDocumentsDirectory();
          final filename = "${prompt?.trimRight()}.png";
          final imgPath = File("${directory.path}/$filename");

          await imgPath.writeAsBytes(img);

          // Save to gallery
          await GallerySaver.saveImage(imgPath.path, albumName: "Ai Images");
        } else {
          print("Failed to take a screenshot");
        }
      } catch (e) {
        print("Error: $e");
        // Handle errors, such as permission issues or capture failures
      }
    } else {}
  }

  shareImage() async {
    await screenshotController
        .capture(delay: const Duration(milliseconds: 100), pixelRatio: 1.0)
        .then((Uint8List? img) async {
      if (img != null) {
        final directory = (await getApplicationDocumentsDirectory()).path;
        final filename = "${prompt?.trimRight()}.png";
        final imgPath = await File("$directory/$filename").create();
        await imgPath.writeAsBytes(img);

        Share.shareFiles([imgPath.path],
            text: "Ai Image by ITE Student FYP Project App");
      } else {
        print("Failed to take aa screenshot");
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  void toggleSidebar() {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      // If the drawer is open, close it
      _scaffoldKey.currentState?.openEndDrawer();
    } else {
      // If the drawer is closed, open it
      _scaffoldKey.currentState?.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: toggleSidebar,
          ),
          title: const Text(
            'Ai Image',
            style: TextStyle(color: Pallete.mainFontColor, fontSize: 30),
          ),
          actions: [
            //  IconButton(onPressed: (){}, icon: Icon(Icons.logout_rounded))
            Padding(
              padding: const EdgeInsets.only(
                right: 10,
              ),
              child: Image.asset(
                StringUtils.logo,
                width: 40,
                height: 40,
              ),
            )
          ],
        ),
        drawer: const DrawerMenu(),
        body: Container(
          height: Get.height - 80,
          width: Get.width,
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 60),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
            borderRadius: BorderRadius.circular(16.0),
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Visibility(
                  visible: generatedImageUrl == null,
                  child: Column(
                    children: [
                      SlideInLeft(
                        delay: Duration(milliseconds: start),
                        child: ChatBubble(
                          clipper: ChatBubbleClipper10(
                              type: BubbleType.receiverBubble),
                          backGroundColor: Pallete.thirdSuggestionBoxColor,
                          child: const Text('Ai Image Generator'),
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                      SlideInLeft(
                        delay: Duration(milliseconds: start),
                        child: ChatBubble(
                          clipper: ChatBubbleClipper10(
                              type: BubbleType.receiverBubble),
                          backGroundColor: Pallete.thirdSuggestionBoxColor,
                          child: Text(
                              'Get inspired and stay creative with your personal assistant powered Ai Image Generator'),
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                      SlideInLeft(
                        delay: Duration(milliseconds: start + 2 * delay),
                        child: ChatBubble(
                          clipper: ChatBubbleClipper10(
                              type: BubbleType.receiverBubble),
                          backGroundColor: Pallete.thirdSuggestionBoxColor,
                          child: const Text( 'Get the best of both worlds with a voice assistant Image Generator'),
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                    ],
                  ),
                ),
                generatedImageUrl != null
                    ? Column(
                        children: [
                          FadeInRight(
                            child: Visibility(
                              visible: prompt != null,
                              child: ChatBubble(
                                clipper: ChatBubbleClipper10(
                                    type: BubbleType.sendBubble),
                                backGroundColor: Pallete.mainFontColor,
                                child: Text(
                                  '$prompt',
                                  style: const TextStyle(
                                      color: Pallete.borderColor, fontSize: 16),
                                ),
                                alignment: Alignment.centerRight,
                              ),
                            ),
                          ),
                          SlideInLeft(
                            duration: const Duration(milliseconds: 500),
                            delay: const Duration(seconds: 1),
                            child: Container(
                              padding: const EdgeInsets.all(10.0),
                              margin: const EdgeInsets.only(top: 20),
                              child: FutureBuilder(
                                future: precacheImage(
                                    NetworkImage(generatedImageUrl!), context),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    _storeChatMessage(
                                      _auth.currentUser!.uid,
                                      Uuid().v4(),
                                      prompt!,
                                      generatedImageUrl!,
                                    );
                                    return Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Screenshot(
                                            controller: screenshotController,
                                            child: Image.network(
                                              generatedImageUrl!,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                downloadImg();
                                              },
                                              icon: const Icon(
                                                Icons.download_rounded,
                                                color: Pallete.blackColor,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                shareImage();
                                              },
                                              icon: const Icon(
                                                Icons.share_rounded,
                                                color: Pallete.blackColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  } else {
                                    return const Center(
                                        child: CircularProgressIndicator(
                                      color: Pallete.mainFontColor,
                                    )); // or any other loading indicator
                                  }
                                },
                              ),
                            ),
                          )
                        ],
                      )
                    : SizedBox.shrink()
              ],
            ),
          ),
        ),
        floatingActionButton: ZoomIn(
          delay: Duration(milliseconds: start + 3 * delay),
          child: Container(
            decoration: BoxDecoration(
              color: Pallete.mainFontColor,
              borderRadius: BorderRadius.circular(
                  10.0), // Adjust the corner radius as needed
              border: Border.all(color: Colors.grey), // Border color
            ),
            padding: const EdgeInsets.only(left: 20),
            margin: const EdgeInsets.only(left: 30),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: TextField(
                      controller: textSms,
                      style: const TextStyle(
                          color: Pallete
                              .borderColor), // Set the entered text color
                      cursorColor: Pallete.borderColor,
                      decoration: const InputDecoration(
                        labelStyle: TextStyle(color: Pallete.borderColor),
                        hintText: 'Enter your message',
                        hintStyle: TextStyle(color: Pallete.borderColor),
                        border: InputBorder
                            .none, // Hide the default border of TextField
                      ),
                      onChanged: (text) {
                        setState(() {});
                      },
                    ),
                  ),
                ),
                // Display mic icon when no text is entered
                Visibility(
                  visible: textSms.text.isEmpty,
                  child: IconButton(
                    icon: Icon(
                      isListening ? Icons.stop : Icons.mic,
                      color: Pallete.borderColor,
                    ),
                    onPressed: () async {
                      await VoiceSend();
                    },
                  ),
                ),
                // Display send icon when there is text entered
                Visibility(
                  visible: textSms.text.isNotEmpty,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Pallete.borderColor),
                    onPressed: () async {
                      await SendText();
                    },
                  ),
                ),
              ],
            ),
          ),
          //
        ));
  }

  Future<void> SendText() async {
    final speech = await openAIService.isArtPromptAPI(textSms.text);
    if (speech.contains('https')) {
      generatedImageUrl = speech;
      setState(() {
        if (textSms != '') {
          prompt = textSms.text;
          textSms.clear();
        }

        // Save the user's message to Firebase Firestore
      });
    }
  }

  Future<void> VoiceSend() async {
    if (await speechToText.hasPermission && speechToText.isNotListening) {
      await startListening();
    } else if (speechToText.isListening) {
      final speech = await openAIService.isArtPromptAPI(lastWords);
      if (speech.contains('https')) {
        generatedImageUrl = speech;
        setState(() {
          prompt = lastWords;
        });
      }
      await stopListening();
    } else {
      initSpeechToText();
    }
  }

  Future<void> _storeChatMessage(
    String userId,
    String uuid,
    String prompt,
    String imageUrl,
  ) async {
    try {
      // Create or get the user's collection
      CollectionReference userCollection =
          _firestore.collection('users').doc(userId).collection('chat');

      // Check if a chat collection already exists for this prompt
      QuerySnapshot promptSnapshot =
          await userCollection.where('prompt', isEqualTo: prompt).get();

      CollectionReference chatCollection;
      DocumentReference chatDocument;

      // Capture the screenshot and save it to Firebase Storage
      final screenshotImageBytes = await screenshotController.capture(
        delay: const Duration(milliseconds: 100),
        pixelRatio: 1.0,
      );

      final storageReference = FirebaseStorage.instance
          .ref()
          .child('chat_images')
          .child(_uuid.v4())
          .child('${prompt.toString().split(' ').first}.png');

      await storageReference.putData(screenshotImageBytes!);

      // Get the download URL of the uploaded image
      final downloadURL = await storageReference.getDownloadURL();
      if (promptSnapshot.docs.isNotEmpty) {
        // If a chat collection exists, use it
        chatDocument = userCollection.doc(promptSnapshot.docs.first.id);
        chatCollection = chatDocument.collection('messages');
      } else {
        // If no chat collection exists for this prompt, create a new one
        chatDocument = await userCollection.add({
          'uuid': uuid,
          'prompt': prompt,
          'content': downloadURL,
          'time': FieldValue.serverTimestamp(),
        });

        chatCollection = chatDocument.collection('messages');
      }
    } catch (e) {
      print('Error storing chat message: $e');
    }
  }
}
