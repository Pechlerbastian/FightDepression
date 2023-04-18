# projektmodul

### Fight Depression 
The Fight Depression App is a mobile application that is designed to help people struggling with depression. The app is built using Flutter and uses reapprasial statements to improve the user's mood. A daily Depression Training program can be done, which is analysed by a predictive deeplearning model that uses regression to estimate the user's depressive score.

## Features
### Depression Training
The Depression Training program is a daily activity that helps users confront negative thoughts and emotions. Each day, the user is presented with five statements -- one after another -- that are designed to trigger negative thoughts or emotions. The user is then given several reappraisals for each statement, which are positive or neutral statements that can help the user reframe their thinking.

The user selects a reappraisal for each statement and then records themselves reading the reappraisal three times. The app uses a deep learning model to predict the user's depressive score based on the recordings.

### Predictive Model
The app features a predictive model that uses deep learning to estimate the user's depressive score. The model analyzes the user's recordings and uses machine learning algorithms to predict the user's level of depression on a scale from 0 to 10. The app tracks the user's daily scores and displays them in a graph that can be viewed on the main screen.

### Monthly Overview
The user can also view a graph of all their monthly scores by selecting a month on the monthly overview screen. This allows the user to track their progress over time and identify patterns in their mood. On this screen, the first and last daily score is displayed, for every day on the month for which a record exists. 

## Technologies

### Flutter
The Fight Depression App is built using Flutter, a popular mobile app development framework that allows for the creation of native apps for iOS and Android using a single codebase.

### Deeplearning model
The predictive model used in the Depression Recognition App was trained using a dataset of audio files from various individuals in different groups. Group 1 consisted of acutely depressed patients, Group 2 was the control group with individuals without depression, and Group 3 comprised individuals who had been diagnosed with depression but were currently not in a depressive phase. The model was trained using the Python package "DeepspectrumLite," created by (c) 2020-2022 Shahin Amiriparian, Tobias Hübner, Vincent Karas, Maurice Gerczuk, Sandra Ottl, Björn Schuller: University of Augsburg Published under GPLv3. The training process utilized different folds and base models, which were compared to find the best suited data fold. 

The data was created by recording the patients/ people from the control group. A second person labeled the perceived depression status between 0 and 10.

To enable training with the sigmoid activation function in the model layers, the labels were set to a range of values between 0 and 1.
For training, the following hyperparameters were used:



    "label_parser":     ["/data/eihw-gpu1/pechleba/DataParser.py:DataParser"],
    "model_name":       ["TransferBaseModel"],
    "prediction_type":  ["regression"],
    "basemodel_name":   ["densenet201", "squeezenet_v1", "mobilenet_v2"],
    "weights":          ["imagenet"],
    "tb_experiment":    ["results"],
    "tb_run_id":        ["results"],
    "num_units":        [1],
    "dropout":          [0.25],
    "optimizer":        ["adam"],
    "learning_rate":    [0.0005],
    "fine_learning_rate": [0.00005],
    "finetune_layer":   [0.7],
    "loss":             ["mse"],
    "activation":       ["arelu"],
    "output_activation": ["sigmoid"],
    "pre_epochs":       [100],
    "epochs":           [400],
    "batch_size":       [160],

    "sample_rate":      [16000],

    "chunk_size":       [4.0],
    "chunk_hop_size":   [2.0],
    "normalize_audio":  [false],

    "stft_window_size": [0.128],
    "stft_hop_size":    [0.064],
    "stft_fft_length":  [0.128],

    "mel_scale":        [true],
    "lower_edge_hertz": [0.0],
    "upper_edge_hertz": [8000.0],
    "num_mel_bins":     [128],
    "num_mfccs":        [0],
    "cep_lifter":       [0],
    "db_scale":         [false],
    "use_plot_images":  [true],
    "color_map":        ["viridis"],
    "image_width":      [224],
    "image_height":     [224],
    "resize_method":    ["nearest"],
    "anti_alias":       [false],

    "sap_aug_a":        [0.5],
    "sap_aug_s":        [10],
    "augment_cutmix":   [false],
    "augment_specaug":  [false],
    "da_prob_min":      [0.1],
    "da_prob_max":      [0.5],
    "cutmix_min":       [0.075],
    "cutmix_max":       [0.25],
    "specaug_freq_min": [0.1],
    "specaug_freq_max": [0.3],
    "specaug_time_min": [0.1],
    "specaug_time_max": [0.3],
    "specaug_freq_mask_num": [1],
    "specaug_time_mask_num": [1]

    
    
<table>
  <tr>
    <th rowspan="2">Fold</th>
    <th colspan="3">Mean (all)</th>
    <th colspan="2">Densenet</th>
    <th colspan="2">Mobilenet</th>
    <th colspan="2">Squeezenet</th>
  </tr>
  <tr>
    <th>Train</th>
    <th>Dev</th>
    <th>Test</th>
    <th>MAE</th>
    <th>MSE</th>
    <th>MAE</th>
    <th>MSE</th>
    <th>MAE</th>
    <th>MSE</th>
  </tr>
  <tr>
    <td>0</td>
    <td>0.6335</td>
    <td>0.6379</td>
    <td>0.6552</td>
    <td>0.1481</td>
    <td>0.1845</td>
    <td>0.1506</td>
    <td>0.1868</td>
    <td>0.1615</td>
    <td>0.2053</td>
  </tr>
  <tr>
    <td>1</td>
    <td>0.6483</td>
    <td>0.6688</td>
    <td>0.5905</td>
    <td>0.1696</td>
    <td>0.2129</td>
    <td>0.3632</td>
    <td>0.4398</td>
    <td>0.1899</td>
    <td>0.2414</td>
  </tr>
  <tr>
    <td>2</td>
    <td>0.6115</td>
    <td>0.7404</td>
    <td>0.6443</td>
    <td>0.1748</td>
    <td>0.2144</td>
    <td>0.1726</td>
    <td>0.2129</td>
    <td>0.1840</td>
    <td>0.2303</td>
  </tr>
  <tr>
    <td>3</td>
    <td>0.6308</td>
    <td>0.6585</td>
    <td>0.6473</td>
    <td>0.1573</td>
    <td>0.1977</td>
    <td>0.1806</td>
    <td>0.2231</td>
    <td>0.1871</td>
    <td>0.2355</td>
  </tr>
  <tr>
    <td>4</td>
    <td>0.6402</td>
    <td>0.6030</td>
    <td>0.6645</td>
    <td>0.1701</td>
    <td>0.2136</td>
    <td>0.1759</td>
    <td>0.2175</td>
    <td>0.1857</td>
    <td>0.2345</td>
  </tr>
</table>

The best performance was determined for fold 3 with densenet201 as base model. For this model, a Spearman coefficient of 0.2143 and a Pearson coefficient of 0.1765 were reached. 

## Getting Started
To get started with the Fight Depression App you have to:
- clone this repository
- install flutter
- use the command flutter pub get in app root
- start a emulator or plug in a mobile phone
- run with the command flutter run or start a debugging session
This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

Once the app runs, follow the on-screen instructions to set up your account and begin using the Depression Training program.

## License
The Mood Improvement App is released under the GPLv3 License.
