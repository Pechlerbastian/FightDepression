// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'audio_preprocessor.dart';
// import 'result.dart';

// class RegressionScorer {
  
//   static const String MODEL_FILE_NAME = 'model.tflite';
//   late Interpreter _interpreter;
//   late Directory tempDir;
//   late String modelName;

//   RegressionScorer();

//   Future<void> loadModel() async {
//     try {
//       tempDir = await getTemporaryDirectory();
//       String dirPath = 'tensorflow_model/';
//       String modelFile = dirPath + MODEL_FILE_NAME;

//       _interpreter = await Interpreter.fromAsset(modelFile);
//     } catch (e) {
//       print('Error loading model: $e');
//     }
//   }

//   double predict() {
//     double prediction = _interpreter.run(input, output);
//     // TODO: call interpreter 

//     return prection;

//   void close() {
//     _interpreter.close();
//   }
// }

//   List<List<double>> extractFeatures(File wavFile) {
//     // Load the WAV file data
//     final wavData = wavFile.readAsBytesSync();

//     // Split the WAV data into chunks
//     final sampleRate = 16000; // Set the sample rate based on the hyperparameters
//     final chunkSizeSeconds = 2.0; // Set the chunk size based on the hyperparameters
//     final chunkHopSizeSeconds = 1.0; // Set the chunk hop size based on the hyperparameters
//     final chunkSizeSamples = (chunkSizeSeconds * sampleRate).floor();
//     final chunkHopSizeSamples = (chunkHopSizeSeconds * sampleRate).floor();
//     final chunks = splitIntoChunks(wavData, chunkSizeSamples, chunkHopSizeSamples);

//     // Extract features for each chunk
//     List<List<double>> features = [];
//     for (final chunk in chunks) {
//     // TODO: preprocess chunks
//     }
//     return features;
//   }

//   List<List<double>> splitIntoChunks(List<int> data, int chunkSize, int hopSize) {
//     List<List<double>> chunks = [];
//     var i = 0;
//     while (i + chunkSize <= data.length) {
//       chunks.add(data.sublist(i, i + chunkSize).map((x) => x.toDouble()).toList());
//       i += hopSize;
//     }
//     return chunks;
//   }
// }


// // // import 'dart:async';
// // // import 'dart:io';
// // // import 'package:flutter/services.dart';
// // // import 'package:path_provider/path_provider.dart';
// // // import 'package:tflite_flutter/tflite_flutter.dart';

// // // class RegressionScorer {
// // //   static const String MODEL_FILE_NAME = 'model.tflite';

// // //   late Interpreter _interpreter;
// // //   late Directory tempDir;
// // //   late String modelName;

// // //   RegressionScorer();

// // //   Future<void> loadModel() async {
// // //     try {
// // //       tempDir = await getTemporaryDirectory();
// // //       String dirPath = 'tensorflow_model/';
// // //       String modelFile = dirPath + MODEL_FILE_NAME;

// // //       _interpreter = await Interpreter.fromAsset(modelFile);
// // //     } catch (e) {
// // //       print('Error loading model: $e');
// // //     }
// // //   }

// // //   double predict(List<List<double>> modelInput) {
// // //     // List<List<double>> output = [List.filled(5, 0.0)];
// // //     // List<List<List<List<double>>>> input = [[modelInput]];
// // //     // _interpreter.run(input, output);
// // //     // double prediction = output[0][0];
// // //     List<double> output = List.filled(1, 0);
// // //     List<List<List<List<double>>>> input = [List.filled(3, modelInput)];
// // //     _interpreter.run(input, output);
// // //     double prediction = output[0];
// // //     return prediction;
// // //   }


// // //   List<List<double>> splitIntoChunks(List<int> data, int chunkSize, int hopSize) {
// // //     List<List<double>> chunks = [];
// // //     var i = 0;
// // //     while (i + chunkSize <= data.length) {
// // //       chunks.add(data.sublist(i, i + chunkSize).map((x) => x.toDouble()).toList());
// // //       i += hopSize;
// // //     }
// // //     return chunks;
// // //   }

// // //   void close() {
// // //     _interpreter.close();
// // //   }
// // // }

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
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