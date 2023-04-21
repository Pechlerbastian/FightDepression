import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:projektmodul/audio/audio_preprocessor.dart';
import 'package:projektmodul/current_state_util.dart';
import 'package:projektmodul/page.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:projektmodul/sentences_util.dart';

import '../audio/regression_scorer.dart';

class RecordingScreen extends InsertableElement {
  RecordingScreen(String title, bool initialized, {super.key}) : super(title, initialized);

  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> with SingleTickerProviderStateMixin {
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  final RegressionScorer depressionScorer = RegressionScorer();
  bool _isRecording = false;
  late AnimationController _animationController;
  bool isRecorderReady = false;
  CurrentStateUtil stateUtil = CurrentStateUtil();
  Sentences sentences = Sentences();
  int counter = 0;
  late double score = 0;  
  bool isLoading = false;
  late Color color = getAdjustedColor(context);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
          ..repeat();
    
    initResources();
    
  }

 

  Future initResources() async {
    try {
      var status = await Permission.microphone.request();
      if(status == PermissionStatus.granted){

        await _audioRecorder.openRecorder();
        isRecorderReady = true;
      }
      else{
        isRecorderReady = false;
      }
      await depressionScorer.loadModel(); 
    } catch (e) {
      log('Error requesting permissions: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {

      await _audioRecorder.stopRecorder();
      
      setState(() {
        _isRecording = false;
      });
      await Future.delayed(const Duration(milliseconds: 1500));
      double averageScore = await calculateScore();

      if (!stateUtil.dailyTrainDone){
        handleDailyTraining(averageScore);
      }
    } else {
      // Request microphone permission
      if (await Permission.microphone.isGranted) {
        // Start recording audio
        String filePath = await _getFilePath();
        await _audioRecorder.startRecorder(
          toFile: filePath,
          codec: Codec.pcm16WAV,
          numChannels: 1,
          sampleRate: 16000,
          bitRate: 256000,
        );
        setState(() {
          _isRecording = true;
        });
      }
    }
  }

  void handleDailyTraining(double averageScore) {
    if (stateUtil.predictions.isEmpty) {
      stateUtil.predictions[0] = [averageScore, 0, 0]; 
    } else if (!stateUtil.predictions.containsKey(stateUtil.amountTrained)) {
      stateUtil.predictions[stateUtil.amountTrained] = [averageScore, 0, 0];  
    } else {
      stateUtil.predictions[stateUtil.amountTrained]![stateUtil.trainStep] = averageScore;
    }

    stateUtil.trainStep += 1;
    
    if (stateUtil.trainStep > 2){
      stateUtil.amountTrained += 1;
      stateUtil.trainStep = 0;
      if (stateUtil.amountTrained > 4){
        setState(() {
          stateUtil.endDailyTraining();
        });
      }
      stateUtil.setPage("Session");
      stateUtil.persistData();
    }
  }

  Future<double> calculateScore() async {
    setState(() {
      isLoading = true;
    });
    String filePath = await _getFilePath();
    
    AudioPreprocessor audioPreprocessor = AudioPreprocessor(filePath, 1024, 512, 4096, 2048, 513, 2048);
    await audioPreprocessor.readWAVFile(filePath );
    List<List<double>> input = audioPreprocessor.getModelInput();
    List<double> scores = await (depressionScorer.predict(input));
    double sumScores = scores.reduce((a, b) => a + b);
    double averageScore = sumScores / scores.length * 10;
    setState(() {
      score = averageScore ;
      color = getAdjustedColor(context);
      isLoading = false;
    });
    return averageScore;
  }

  Future<String> _getFilePath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    String filePath = '${appDocumentsDirectory.path}/recording.wav';
    return filePath;
  }

  @override
  Widget build(BuildContext context) {
    return  isLoading 
    ? Center(child: Text("Loading...", style: Theme.of(context).textTheme.headline2,) )
    : Card(color: Theme.of(context).backgroundColor,
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    elevation: 4,
                    child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5),
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.all(16.0),
                              color: color,
                              child: Column(
                                children: [
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
                                  Text(textAlign: TextAlign.center,
                                      sentences.statements[stateUtil.selectedStatement]!,
                                      style: Theme.of(context).textTheme.headline1,
                                    ),
                                
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                ]),
                            ),
                          ),
                          const SizedBox(
                                height: 0.8, child: Divider(color: Colors.blueGrey)),
                          Text(
                            textAlign: TextAlign.left,
                            "Please read this sentence loudly to yourself without recording",
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          
                        ],
                      ),
                    
                  ),

                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    elevation: 4,
                    child: Column(
                      children: [
                        ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5),
                            ),
                            child:
                              Container(color: Theme.of(context).primaryColorDark, 
                                child: Column(
                                  children: [
                                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                    Container(padding: const EdgeInsets.all(16.0), 
                                      child: Text(
                                        textAlign: TextAlign.left,
                                        sentences.reappraisals[stateUtil.selectedStatement]![stateUtil.selectedAnswer],
                                        style: Theme.of(context).textTheme.headline2,
                                      ),
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      height: 1, child: const Divider(color: Colors.blueGrey, thickness: 0.4,)),
                                  ]
                                )
                              )
                        ),
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                          textAlign: TextAlign.left,
                          "Then you have to press the record button and read the selected reappraisal.",
                          style: Theme.of(context).textTheme.subtitle1,
                        )),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                stateUtil.dailyTrainDone ? 
                Card(
                    elevation: 4,
                    child:  Column(
                      children: [
                        ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5),
                            ),
                            child:
                              Container(color: Theme.of(context).primaryColorDark, 
                                child: Column(
                                  children: [SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                    Container(padding: const EdgeInsets.all(16.0), 
                                      child: Text(
                                          "Score: ${score.toStringAsFixed(2)}",
                                          style: Theme.of(context).textTheme.headline2,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      height: 1, child: const Divider(color: Colors.blueGrey, thickness: 0.4,)),
                                ])
                                )),
                                Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Text(
                                        textAlign: TextAlign.left,
                                        "You can train a bit more for yourself, but this value will not be stored.",
                                        style: Theme.of(context).textTheme.subtitle1,
                                    )), 
                      ])
                    )
                : const Text("")

              ],
            )
          ),
          SizedBox(
            height: MediaQuery.of(context).orientation == Orientation.portrait 
            ? MediaQuery.of(context).size.height * 0.15 
            : MediaQuery.of(context).size.height * 0.25,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: _isRecording ? Colors.grey[500] : Colors.grey[400],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: GestureDetector(
                    onLongPressStart: (details) {
                      _toggleRecording();
                    },
                    onLongPressEnd: (details) {
                      _toggleRecording();
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _isRecording
                            ? Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: CircularProgressIndicator(
                                  valueColor: _animationController.drive(
                                    ColorTween(
                                      begin: Theme.of(context).primaryColor,
                                      end: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  strokeWidth: 4,
                                ),
                              )
                            : const SizedBox.shrink(),
                        Icon(
                          Icons.mic,
                          color: _isRecording ? Colors.grey[900] : Colors.grey[800],
                          size: 48,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    );
    
  }
  

  Color getAdjustedColor(BuildContext context){
    double lightnessStep = 0.05;

    // Calculate the amount to increase the lightness by based on the score
    double lightnessIncrease = lightnessStep * score;
    HSLColor hslColor = HSLColor.fromColor(Theme.of(context).secondaryHeaderColor);
    double newLightness = (hslColor.lightness + lightnessIncrease).clamp(0.0, 1.0);
    hslColor = hslColor.withLightness(newLightness);
    return hslColor.toColor();
  }

}
