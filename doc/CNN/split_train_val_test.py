# code heavily adapted from https://github.com/pengpaiSH/Kaggle_NCFM
import os
import numpy as np
import shutil

np.random.seed(59)
os.chdir("C:/Users/lenovo/Desktop/ads/proj3/")

root_train = 'data/train/'
root_val = 'data/val/'
root_test = 'data/test/'

root_total = 'data/image_test/'

labels = ['0', '1', '2']

n_train_samples = 0
n_val_samples = 0
n_test_samples = 0

# Training proportion
split_proportion = (0.6,0.2,0.2) # make sure they sum up to 1.0

#for label in labels:
    #if label not in os.listdir(root_train):
        #os.mkdir(os.path.join(root_train, label))
        #os.system("sudo mkdir "+os.path.join(root_train, fish))

total_images = os.listdir(root_total)

n_train = int(len(total_images) * split_proportion[0])
n_val = int(len(total_images)*split_proportion[1])
    
np.random.shuffle(total_images)

train_images = total_images[:n_train]
val_images = total_images[n_train:(n_train+n_val)]
test_images = total_images[(n_train+n_val):]

for img in train_images:
    source = os.path.join(root_total, img)
    target = os.path.join(root_train, img)
    shutil.copy(source, target)
    n_train_samples += 1

    #if label not in os.listdir(root_val):
    #    os.mkdir(os.path.join(root_val, label))

for img in val_images:
    source = os.path.join(root_total, img)
    target = os.path.join(root_val, img)
    shutil.copy(source, target)
    n_val_samples += 1
    
    #if label not in os.listdir(root_test):
     #   os.mkdir(os.path.join(root_test, label))

for img in test_images:
    source = os.path.join(root_total, img)
    target = os.path.join(root_test, img)
    shutil.copy(source, target)
    n_test_samples += 1

print('Finish splitting train, val and test images!')
print('# training samples: {}, # val samples: {}, # test samples: {}'.format(n_train_samples, n_val_samples, n_test_samples))
