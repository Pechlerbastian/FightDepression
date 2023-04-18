import tensorflow as tf


if __name__ == '__main__':
    preprocessor = tf.saved_model.load('C:/Users/Bastian/OneDrive/Desktop/results/3/densenet_lowSr_lowLr_noNorm/preprocessor')

    # Convert the model to TensorFlow Lite format
    converter = tf.lite.TFLiteConverter.from_saved_model('C:/Users/Bastian/OneDrive/Desktop/results/3/densenet_lowSr_lowLr_noNorm/preprocessor')
    tflite_model = converter.convert()

    # Save the converted model
    with open('C:/Users/Bastian/OneDrive/Desktop/results/3/densenet_lowSr_lowLr_noNorm/preprocessor.tflite', 'wb') as f:
        f.write(tflite_model)
    