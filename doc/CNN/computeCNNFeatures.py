from keras.models import load_model, Model
import os
from keras.preprocessing.image import ImageDataGenerator
import numpy as np
from time import time
import pandas as pd
import sys

def computeCnnFeatures(image_dir='data/images/',save_dir='output/orig_test_cnn_features.csv'):
    # set parameters
    os.environ["CUDA_VISIBLE_DEVICES"] = "0"
    weights_path = 'output/weights.h5'
    img_width = 299
    img_height = 299
    batch_size = 30
    
    #load model
    start_loading = time()
    print('Loading model and weights from training process ...')
    InceptionV3_model = load_model(weights_path)
    end_loading = time()
    print('Loading model uses %.4gs' % (end_loading - start_loading))
    InceptionV3_model = Model(InceptionV3_model.input, InceptionV3_model.layers[-2].output)
    datagen = ImageDataGenerator()
    data_generator = datagen.flow_from_directory(
            image_dir,
            target_size=(img_width, img_height),
            batch_size=batch_size,
            shuffle = False, # Important !!!
            seed = 59,
            classes = None,
            class_mode = None)

    image_list = data_generator.filenames
    image_list = [x.split('/')[1].split('.')[0] for x in image_list]

    # compute cnn features
    start_train = time() 
    features = InceptionV3_model.predict_generator(data_generator, data_generator.samples)
    end_train = time()
    
    # save features to a csv
    features = pd.DataFrame(features).transpose()
    features.columns = image_list
    features.to_csv(save_dir,index=False)
    print('computing CNN features uses for %.4gs, result is saved.' % (end_train-start_train))
    # computing CNN features for 2000 images uses 166.2 s
    # GPU is p2.x4large


if __name__ == '__main__':
    print('Make sure your test dir contains sub directory: data/test/test/ and your keras is tensorflow backened.')
    try:
        img_dir,save_dir = sys.argv[1:3]
        computeCnnFeatures(img_dir,sav_dir)
    except: 
        computeCnnFeatures()

    
    
    






















