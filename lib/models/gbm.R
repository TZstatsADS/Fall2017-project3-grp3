######## Try baseline: GBM model with SIFT feature ###########


gbm_train <- function(dat_train, label_train, n.trees=250,n.shrinkage=0.1,run.cv=F){
  library('gbm')
  
  train_df <- dat_train
  train_df$label <- label_train
  if(run.cv){
    list_ntrees <- c(150,250,300,500)
    list_shrinkage = c(0.01,0.1)
    
    errors <- matrix(NA,nrow=length(list_ntrees),ncol = length(list_shrinkage))
    
    for(j in 1:length(list_ntrees)){
      for(k in 1:length(list_shrinkage)){
        errors[j,k] <- cv.f(train_df, list_ntrees[j],list_shrinkage[k])
        }
      }
    
    row_index <- which(errors == min(errors), arr.ind = TRUE)[1]
    col_index <- which(errors == min(errors), arr.ind = TRUE)[2]
    
    best.n.trees <- list_ntrees[row_index]
    best.shrinkage <- list_shrinkage[col_index]
    
    print(errors)

    cat('best number of tress is: ',best.n.trees)
    cat('best number of shrinkage is: ', best.shrinkage)
  } else{
    best.n.trees <- n.trees
    best.shrinkage <- n.shrinkage
    
  }
  
  
  
  
  best_gbm_fit <- gbm(label~ ., 
                      data = train_df,
                      interaction.depth = 1,
                      distribution="multinomial",
                      n.trees = best.n.trees, 
                      shrinkage = best.shrinkage)
  return(best_gbm_fit)
  
}


cv.f <- function(train_df, n.trees, shrinkage,K=5){
  
  n <- dim(train_df)[1]
  n.fold <- floor(n/K)
  s <- sample(rep(1:K, c(rep(n.fold, K-1), n-(K-1)*n.fold)))  
  cv.error <- rep(NA, K)
  
  for (i in 1:K){
    train.data <- train_df[s != i,]
    train.label <- train_df$label[s != i]
    test.data <- train_df[s == i,]
    test.label <- train_df$label[s == i]
    
    n.trees <- n.trees
    shrinkage <- shrinkage
    
    fit <- gbm(label~ ., 
               data = train.data,
               interaction.depth = 1,
               distribution="multinomial",
               n.trees = n.trees, 
               shrinkage = shrinkage)
    
    pred <- predict(fit, 
                    newdata = test.data, 
                    n.trees = fit$n.trees, 
                    type="response")
    
    pred <- data.frame(pred[,,1])
    colnames(pred) <- c('0','1','2')
    pred_label <- apply(pred,1,function(x){return(which.max(x)-1)})
    cv.error[i] <- mean(pred_label != test.label) 
    
  }			
  return(mean(cv.error))
  
}



gbm_test <- function(model_fit,dat_test){
  pred <- predict(model_fit, newdata=dat_test, 
                  n.trees=model_fit$n.trees, type="response")
  pred <- data.frame(pred[,,1])
  colnames(pred) <- c('0','1','2')
  pred_label <- apply(pred,1,function(x){return(which.max(x)-1)})
  return(pred_label)
}


########## Apply GBM on SIFT ##########
sift_train <- read.csv('../training_set/sift_train.csv',as.is = T)[,-1]
label_train <- as.vector(read.csv('../training_set/label_train.csv',as.is = T)[,2])


######### set 70% sift_train_data as training data #############
#train_index <- sort(sample(1:length(label_train),0.7*length(label_train)))
#train_index
# 
#save(train_index,file='../output/train_index.RData')


load('../output/train_index')

train_df <- data.frame(sift_train[train_index,])
train_df$label <- label_train[train_index]
test_df <- data.frame(sift_train[-train_index,])
test_df$label <- label_train[-train_index]

gbm_sift_fit_subset <- gbm_train(train_df[,-5001],train_df$label,run.cv = F)
save(gbm_sift_fit_subset,file = '../output/gbm_sift_fit_subset.RData')
load('../output/gbm_sift_fit_subset.RData')
tm_gbm_predict <- system.time(pred_label <- gbm_test(gbm_sift_fit_subset,test_df[,-5001]))

mean(test_df$label == pred_label) 
## 0.811
tm_gbm_predict[3]
## 7.367

########### Apply GBM on HOG ###########
load('../output/HOG_features_train.RData')

gbm_hob_fit_subset <- gbm_train(HOG_features[train_index,],label_train[train_index],run.cv = F)
save(gbm_hob_fit_subset,file='../output/gbm_hog_fit_subset.RData')
load('../output/gbm_hog_fit_subset.RData')
tm_gbm_hog_predict <- system.time(pred_label <- gbm_test(gbm_hob_fit_subset,HOG_features[-train_index,]))
mean(label_train[-train_index] == pred_label)

## 0.8033

tm_gbm_hog_predict[3]
## 0.065


########### Apply GBM on SIFT_PCA ###########
load('../output/SIFT_train_pca.RData')
gbm_sift_pca_fit_subset <- gbm_train(as.data.frame(feat.pca)[train_index,],label_train[train_index],run.cv = F)
save(gbm_sift_pca_fit_subset,file='../output/gbm_sift_pca_fit_subset.RData')
load('../output/gbm_sift_pca_fit_subset.RData')
tm_gbm_sift_pca_predict <- 
  system.time(pred_label <- gbm_test(gbm_sift_pca_fit_subset,as.data.frame(feat.pca)[-train_index,]))
mean(label_train[-train_index] == pred_label)
## 0.8267
tm_gbm_sift_pca_predict[3]
## 0.538




########### Apply GBM on SIFT_PCA + HOG ###########
load('../output/feature_sift_pca_hog.RData')
gbm_sift_pca_hog_fit_subset <- gbm_train(sift_pca_hog[train_index,],label_train[train_index],run.cv = F)
save(gbm_sift_pca_hog_fit_subset,file='../output/gbm_sift_pca_hog_fit_subset.RData')
load('../output/gbm_sift_pca_hog_fit_subset.RData')
tm_gbm_sift_pca_hog_predict <- 
  system.time(pred_label <- gbm_test(gbm_sift_pca_hog_fit_subset,sift_pca_hog[-train_index,]))
mean(label_train[-train_index] == pred_label)
## 0.8633
tm_gbm_sift_pca_hog_predict[3]
## 0.837


########### Apply GBM on SIFT_PCA + HOG + LBP ###########
sift_pca_hog_lbp_feature <- get(load('../output/siftpca_hog_lbp.RData'))
gbm_sift_pca_hog_lbp_fit_subset <- gbm_train(sift_pca_hog_lbp_feature[train_index,],label_train[train_index],run.cv = F)
tm <- 
  system.time(pred_label <- gbm_test(gbm_sift_pca_hog_lbp_fit_subset,sift_pca_hog_lbp_feature[-train_index,]))
mean(label_train[-train_index] == pred_label)

gbm_fit <- gbm_train(sift_pca_hog_lbp_feature,label_train)
pred_label <- gbm_test(gbm_fit,sift_pca_hog_lbp_feature)
