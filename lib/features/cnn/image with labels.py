# -*- coding: utf-8 -*-
"""
Created on Mon Oct 30 20:00:12 2017

@author: lenovo
"""

from pandas import *
import os
import numpy as np
import shutil

os.chdir("C:/Users/lenovo/Desktop/ads/proj3/")

labels = read_csv("data/label_train.csv")

labels.columns = ["image", "label"]
labels.head()


root_train = 'data/train/'
root_val = 'data/val/'
root_test = 'data/test/'

root_total = 'data/image_test/'
root_image = 'data/images/'

total_images = os.listdir(root_total)
total_images[1:] = 
len(total_images)

for i in range(len(labels)): 
    labels["image"][i] = "img_" + str(0)*(4 - len(str(labels["image"][i]))) + str(labels["image"][i])  + ".jpg"

labels = ['0', '1', '2']

for label in labels:
    if label not in os.listdir(root_val):
         os.mkdir(os.path.join(root_val, label))
         
for label in labels:
    if label not in os.listdir(root_train):
         os.mkdir(os.path.join(root_train, label))

         
for label in labels:
    if label not in os.listdir(root_test):
         os.mkdir(os.path.join(root_test, label))
         
for label in labels:
    if label not in os.listdir(root_total):
         os.mkdir(os.path.join(root_total, label))
         
for i in range(len(os.listdir(root_total))):
    newName = str(labels["label"][i]) + str(labels["image"][i])
    os.rename(os.listdir(root_total)[i], newName)
    
for i in range(len(os.listdir(root_image))):
    img = os.listdir(root_image)[i]
    label = str(labels["label"][i])
    source = os.path.join(root_image, img)
    target = os.path.join(root_total, label, img)
    shutil.copy(source, target)




labels["image"][1] = "img_" + 
len(str(labels["image"][1]))
str(0)*(4 - len(str(labels["image"][1])))
"img_" + str(0)*(4 - len(str(labels["image"][0]))) + str(labels["image"][0])  + ".jpg"

os.listdir(root_total)[:5]
