import pandas as pd
import numpy as np
import librosa as lb


class DataParser:

    delimiter = None
    needed_columns = []
    target = []

    def __init__(self, file_path='FeedbackExperiment-folds/0_adjusted', delimiter=','):
        self.filename = file_path
        self.delimiter = delimiter
        return

    def generate_new_labels(self, fold_number=0):
        data_sets = {'dev': None, 'test': None, 'train': None}
        for data_set in data_sets.keys():
            df = pd.read_csv('FeedbackExperiment-folds/' + str(fold_number) + '/' + data_set + '.csv',
                             sep=self.delimiter, usecols=['filename', 'VoiceRating'])
            duration_frames = []
            labels_adjusted = []
            for file_name, label in zip(df['filename'], df['VoiceRating']):
                samples, sample_rate = lb.load('FeedbackExperiment/' + file_name, sr=16000)  # TODO use hyperparam
                duration = lb.get_duration(y=samples, sr=sample_rate)
                duration_frames.append(int(duration * 16000))
                labels_adjusted.append(label / 10)

            df['duration_frames'] = duration_frames
            df['filename'] = 'FeedbackExperiment/' + df['filename'].astype(str)
            df.rename(columns={'VoiceRating': 'label'}, inplace=True)
            df['label'] = labels_adjusted
            df.to_csv(
                path_or_buf='FeedbackExperiment-folds/' + str(fold_number) + '_adjusted/' + data_set + '_adjusted.csv')

            data_sets[data_set] = df['label'].mean()

        # create a new DataFrame for the means of all data sets
        means_df = pd.DataFrame.from_dict(data_sets, orient='index', columns=['label_mean'])
        means_df.to_csv(path_or_buf='FeedbackExperiment-folds/' + str(fold_number) + '_adjusted/label_means.csv')

        return

    def parse_labels(self):
        filename_dev = self.filename+'/dev_adjusted.csv'
        filename_test = self.filename+'/test_adjusted.csv'
        filename_train = self.filename+'/train_adjusted.csv'
        dev = pd.read_csv(filename_dev, sep=self.delimiter, usecols=['filename', 'label', 'duration_frames'])
        train = pd.read_csv(filename_train, sep=self.delimiter, usecols=['filename', 'label', 'duration_frames'])
        test = pd.read_csv(filename_test, sep=self.delimiter, usecols=['filename', 'label', 'duration_frames'])
        return train, dev, test

    def load_data(self):
        labels = pd.read_csv('FeedbackExperiment/labels.csv')
        header = np.asarray(labels.keys())
        indices_parameters = np.asarray([np.where(header == x) for x in self.needed_columns]).flatten()
        index_result = np.asarray([np.where(header == x) for x in self.target]).flatten()
        X = np.asarray(labels.iloc[:, indices_parameters].copy())
        y = np.asarray(labels.iloc[:, index_result].copy())

        return X, y



