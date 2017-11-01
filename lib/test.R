gbm_test <- function(model_fit,dat_test){
  pred <- predict(model_fit, newdata=dat_test, 
                  n.trees=model_fit$n.trees, type="response")
  pred <- data.frame(pred[,,1])
  colnames(pred) <- c('0','1','2')
  pred_label <- apply(pred,1,function(x){return(which.max(x)-1)})
  return(pred_label)
}


xgb_test <- function(model,dat_test, label_test){
  pred_label <- predict(model, data.matrix(dat_test))
  #return(mean(pred_label==label_test))
  return(pred_label)
}

