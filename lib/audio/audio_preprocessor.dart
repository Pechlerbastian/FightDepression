import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class AudioPreprocessor {
  late List<List<double>> sampleQueue;
  AudioPreprocessor(
      String filePath,
      int windowSize,
      int hopLength,
      int chunkLength,
      int chunkHopLength,
      int binCount,
      int numFFT) {
    windowSize = windowSize;
    hopLength = hopLength;
  }

  List<List<double>> getModelInput() {
    return sampleQueue;
  }

  Future<List<double>> _getAudioContent(String filePath) async {
      final bytes = File(filePath).readAsBytesSync();
    final byteData = ByteData.sublistView(bytes);
    final List<double> floatList = [];
    final int headerSize = 44;
    final int sampleRate = 16000;
    final int numChannels = 1;
    final int bitDepth = 16;
    final int bytesPerSample = bitDepth ~/ 8;
    for (var i = headerSize; i <= bytes.lengthInBytes - bytesPerSample; i += bytesPerSample) {
      if (bitDepth == 8) {
        floatList.add((byteData.getUint8(i) - 128) / 128);
      } else if (bitDepth == 16) {
        floatList.add(byteData.getInt16(i, Endian.little) / (pow(2, bitDepth - 1)));
      } else if (bitDepth == 24) {
        final int byte1 = byteData.getUint8(i);
        final int byte2 = byteData.getUint8(i + 1);
        final int byte3 = byteData.getUint8(i + 2);
        final int value = byte3 << 16 | byte2 << 8 | byte1;
        floatList.add(value / (pow(2, bitDepth - 1)));
      } else if (bitDepth == 32) {
        floatList.add(byteData.getFloat32(i, Endian.little));
      }
    }
    return floatList;
  }

  Future<void> readWAVFile(String fileName) async {
    List<List<double>> chunks = [];

    // Open the WAV file
    final audio = await _getAudioContent(fileName);
    const int chunkSize = 16000;
    for (int i = 0; i < audio.length; i += chunkSize) {
      final int end = (i + chunkSize < audio.length) ? i + chunkSize : audio.length;
      final List<double> chunk = audio.sublist(i, end);
      if (chunk.length < chunkSize) {
        chunk.addAll(List.filled(chunkSize - chunk.length, 0.0));
      }
      chunks.add(chunk);
    }  
    sampleQueue = chunks;
  }
  
}