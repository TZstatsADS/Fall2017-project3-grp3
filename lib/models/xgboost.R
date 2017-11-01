

xgb_train <- function(dat_train, label_train, max.depth = 5, nround = 100,run.cv=F){
  library(xgboost)
  
  train_df <- data.matrix(dat_train)
  label <- label_train
  #train_df$label <- label_train
  #train_df <- data.matrix(train_df)
  if(run.cv){
    list_max.depth <- c(5,20,50,100)
    #list_max.depth <- c(5,10)
    #list_eta <-  c()
    #list_nround <- c(10,20)
    list_nround <- c(10,25,100,200)
    
    errors <- matrix(NA,nrow=length(list_max.depth),ncol = length(list_nround))
    
    for(j in 1:length(list_max.depth)){
      for(k in 1:length(list_nround)){
        errors[j,k] <- xgb.cv.f(train_df, label,list_max.depth[j],list_nround[k])
      }
    }
    
    row_index <- which(errors == min(errors), arr.ind = TRUE)[1]
    col_index <- which(errors == min(errors), arr.ind = TRUE)[2]
    
    best.max.depth <- list_max.depth[row_index]
    best.nround <- list_nround[col_index]
    
    print(errors)
    cat('best number of max depth is: ',best.max.depth)
    cat('\n')
    cat('best number of nround is: ', best.nround)

  } else{
    best.max.depth <- max.depth
    best.nround <- nround
    
  }
  
  
  
  
  
  
  best_xgb_fit <- xgboost(data = train_df, 
                          label = label_train, 
                          max.depth = best.max.depth, 
                          eta = 0.3, 
                          nround = best.nround,
                          objective = "multi:softmax",
                          num_class=3,
                          verbose = 0)

  return(best_xgb_fit)
  
}

xgb.cv.f <- function(train_df, train_label,max.depth, nround,K=5){
  
  n <- dim(train_df)[1]
  n.fold <- floor(n/K)
  s <- sample(rep(1:K, c(rep(n.fold, K-1), n-(K-1)*n.fold)))  
  cv.error <- rep(NA, K)
  
  for (i in 1:K){
    train.data <- train_df[s != i,]
    train.label <- train_label[s != i]
    test.data <- train_df[s == i,]
    test.label <- train_label[s == i]
    
    max.depth <- max.depth
    nround <- nround
    
    
    fit <- xgboost(data = data.matrix(train.data), 
                   label = train.label, 
                   max.depth = max.depth, 
                   eta = 0.3, 
                   nround = nround,
                   objective = "multi:softmax",
                   num_class=3,
                   verbose = 0)
    
    
    pred_label <- predict(fit, data.matrix(test.data))
    cv.error[i] <- mean(pred_label != test.label) 
    
  }			
  return(mean(cv.error))
  
}

xgb_test <- function(model,dat_test, label_test){
  pred_label <- predict(model, data.matrix(dat_test))
  #return(mean(pred_label==label_test))
  return(pred_label)
}




xgb.cv.f(data.matrix(HOG_features[train_index,]),label_train[train_index],20,25)

########## Apply xgb on SIFT ##########

sift_train <- read.csv('../training_set/sift_train.csv',as.is = T)[,-1]
label_train <- as.vector(read.csv('../training_set/label_train.csv',as.is = T)[,2])

load('../output/train_index')

# train and save model
xgb_sift_fit_subset <- xgb_train(sift_train[train_index,],label_train[train_index],run.cv = F)
save(xgb_sift_fit_subset,file='../output/xgb_sift_fit_subset')

load('../output/xgb_sift_fit_subset')

# test 
tm <- system.time(pred_label <- xgb_test(xgb_sift_fit_subset,sift_train[-train_index,]))
mean(pred_label==label_train[-train_index])
## 0.822
tm[3]
## 0.436



########## Apply xgb on HOG ##########
load('../output/HOG_features_train.RData')
#HOG_features <- read.csv('../output/HOG_features_train')
xgb_hog_fit_subset <- xgb_train(HOG_features[train_index,],label_train[train_index],run.cv=F)
save(xgb_hog_fit_subset,file='../output/xgb_hog_fit_subset')

load('../output/xgb_hog_fit_subset')
tm <- system.time(pred_label <- xgb_test(xgb_hog_fit_subset,HOG_features[-train_index,]))
mean(pred_label==label_train[-train_index])
## 0.8256
tm[3]
## 0.055



################ Apply xgb on SIFT_PCA #############
load('../output/SIFT_train_pca.RData')
xgb_sift_pca_fit_subset <- xgb_train(as.data.frame(feat.pca)[train_index,],label_train[train_index],run.cv=F)
save(xgb_sift_pca_fit_subset,file='../output/xgb_sift_pca_fit_subset')

load('../output/xgb_sift_pca_fit_subset')
tm <- system.time(pred_label <- xgb_test(xgb_sift_pca_fit_subset,data.matrix(as.data.frame(feat.pca)[-train_index,])))
mean(pred_label==label_train[-train_index])
## 0.8189
tm[3]
## 0.163



################ Apply xgb on SIFT_PCA + HOG #############
#sift_pca_hog <- cbind(HOG_features,feat.pca)
#save(sift_pca_hog,file='../output/feature_sift_pca_hog.RData')

load('../output/feature_sift_pca_hog.RData')

xgb_sift_pca_hog_fit_subset <- 
  xgb_train(sift_pca_hog[train_index,],label_train[train_index],run.cv=F)
save(xgb_sift_pca_hog_fit_subset,file='../output/xgb_sift_pca_hog_fit_subset')

load('../output/xgb_sift_pca_hog_fit_subset')
mean(predict(xgb_sift_pca_hog_fit_subset, data.matrix(sift_pca_hog[-train_index,]))==label_train[-train_index])
tm <- system.time(pred_label <- xgb_test(xgb_sift_pca_hog_fit_subset,data.matrix(sift_pca_hog[-train_index,])))
mean(pred_label==label_train[-train_index])
## 0.8667
tm[3]
##0.159


################ Apply xgb on SIFT_PCA + HOG + LBP #############
sift_pca_hog_lbp_feature <- get(load('../output/siftpca_hog_lbp.RData'))
xgb_sift_pca_hog_lbp_fit_subset <- 
  xgb_train(sift_pca_hog_lbp_feature[train_index,],label_train[train_index],run.cv = F)
tm <- system.time(pred_label <- xgb_test(xgb_sift_pca_hog_lbp_fit_subset,sift_pca_hog_lbp_feature[-train_index,]))
mean(pred_label==label_train[-train_index])
## 0.8755
tm[3]
## 0.157


########
##############
############### Apply xgb on SIFT+HOG PCA ##########

sift_hog <- cbind(sift_train,HOG_features)
sift_hog_pca <- feature.pca(sift_hog)
xgb_sift_hog_pca_fit_subset <- 
  xgb_train(sift_hog_pca[train_index,],label_train[train_index],run.cv=F)

mean(predict(xgb_sift_hog_pca_fit_subset, data.matrix(sift_hog_pca[-train_index,]))==label_train[-train_index])

## 0.8569


#######################################
xgb_fit <- xgboost(data = data.matrix(train_df[,-5001]), label = train_df$label, max.depth = 100, eta = 0.3, nround = 1000,
                objective = "multi:softmax",num_class=3)
save(xgb_fit,file='../output/xgb_fit')


load('../output/xgb_fit')
pred_label <- predict(xgb_fit, data.matrix(test_df[,-5001]))
1-mean(pred_label!=test_df$label)
## 0.80556

HOG_features <- read.csv('../output/HOG_features_train')
xgb_hog_fit <- xgboost(data = data.matrix(HOG_features), label = train_df$label, max.depth = 100, eta = 0.3, nround = 1000,
                       objective = "multi:softmax",num_class=3)
save(xgb_hog_fit,file='../output/xgb_hog_fit')
1-mean(predict(xgb_hog_fit, data.matrix(HOG_features[-train_index,]))!=test_df$label)
## 0.832

###########################  xgboost on SIFT pca #######
load('../output/SIFT_train_pca.RData')
xgb_pca_fit <- xgboost(data=data.matrix(feat.pca[train_index,]),
                       label=label_train[train_index],
                       max.depth=100,
                       eta=0.3,
                       nround=1000,
                       objective = "multi:softmax",
                       num_class=3)
1-mean(predict(xgb_pca_fit, data.matrix(feat.pca[-train_index,]))!=label_train[-train_index])



