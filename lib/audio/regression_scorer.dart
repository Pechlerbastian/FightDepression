import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// import 'package:librosa/librosa.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class RegressionScorer {
  static const String MODEL_FILE_NAME = 'model.tflite';
  static const String PREPROCESSOR_FILE_NAME = 'preprocessor.tflite';

  late Interpreter _interpreter;
  late Interpreter _preprocessor;
  late Directory tempDir;
  
  late String preprocessorName;
  late String modelName;

  RegressionScorer();

   Future<void> loadModel() async {
    try {
      tempDir = await getTemporaryDirectory();
      String dirPath = 'tensorflow_model/';
      modelName = dirPath + MODEL_FILE_NAME;
      preprocessorName = dirPath + PREPROCESSOR_FILE_NAME;
      // Load the preprocessor model
     _preprocessor = await Interpreter.fromAsset(preprocessorName);
      // Load the main model
      _interpreter = await Interpreter.fromAsset(modelName, );
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  Future<List<double>> predict(List<List<double>> input) async {
  // Get input and output tensors.
    var preprocessorInputDetails = _preprocessor.getInputTensors();
    var preprocessorOutputDetails = _preprocessor.getOutputTensors();
    var preprocessorInputShape = preprocessorInputDetails[0].shape;
    var preprocessorOutputShape = preprocessorOutputDetails[0].shape;

    // Get input and output tensors.
    var mainInputDetails = _interpreter.getInputTensors();
    var mainOutputDetails = _interpreter.getOutputTensors();
    var mainInputShape = mainInputDetails[0].shape;
    var mainOutputShape = mainOutputDetails[0].shape;

    // Load the audio file and process it in chunks of 16,000 samples
    List<double> outAll = [];
    // shape output preprocessor: (1, 224, 224, 3)
    List<List<List<List<double>>>> preprocessorOutput = [List.filled(preprocessorOutputShape[1], List.filled(preprocessorOutputShape[2], List.filled(3, 0.0)))];
    // shape output main interpreter: (1, 1)
    List<List<double>> mainOutput =  [List.filled(mainOutputShape[0], 0.0)];

    // input is divided in chunks of 16000 -> if sample is longer, prediction is done more than once
    for(List<double> chunk in input){
      _preprocessor.run([chunk], preprocessorOutput);
      _interpreter.run(preprocessorOutput, mainOutput);

      outAll.add(mainOutput[0][0]);

    }
    
    return outAll;
  }

}