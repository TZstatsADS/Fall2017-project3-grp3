gbm.cv.f <- function(train_df, n.trees, shrinkage,K=K_folds){
  
  n <- dim(train_df)[1]
  n.fold <- floor(n/K)
  s <- sample(rep(1:K, c(rep(n.fold, K-1), n-(K-1)*n.fold)))  
  cv.error <- rep(NA, K)
  
  for (i in 1:K){
    train.data <- train_df[s != i,]
    train.label <- train_df$label[s != i]
    test.data <- train_df[s == i,]
    test.label <- train_df$label[s == i]
    
    #n.trees <- n.trees
    #shrinkage <- shrinkage
    
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




xgb.cv.f <- function(train_df, train_label,max.depth=5, nround=100,K=K_folds){
  
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




