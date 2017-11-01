# gbm error
df1<-data.frame(x=c(150,250,300,500),y=rep(1,4)-c(0.271,0.255,0.25,0.228))
df2<-data.frame(x=c(150,250,300,500),y=rep(1,4)-c(0.203,0.199,0.206,0.191))

library(ggplot2)
ggplot(df1,aes(x,y))+geom_line(aes(color="0.01"))+
  geom_line(data=df2,aes(color="0.1"))+
  labs(color="shrinkage")+
  xlab('Number of trees')+
  ylab('Accuracy')+
  ggtitle('GBM cross validation')



df1<-data.frame(x=c(10,25,100,200),y=rep(1,4)-c(0.166,0.145,0.123,0.121))
df2<-data.frame(x=c(10,25,100,200),y=rep(1,4)-c(0.173,0.153,0.127,0.13))
df3<-data.frame(x=c(10,25,100,200),y=rep(1,4)-c(0.186,0.147,0.129,0.13))
df4<-data.frame(x=c(10,25,100,200),y=rep(1,4)-c(0.184,0.154,0.132,0.12))

ggplot(df1,aes(x,y))+geom_line(aes(color="5"))+
  geom_line(data=df2,aes(color="20"))+
  geom_line(data=df3,aes(color="50"))+
  geom_line(data=df4,aes(color="100"))+
  labs(color="max depth")+
  xlab('nround')+
  ylab('Accuracy')+
  ggtitle('XGBoost cross validation')



train_index <- sort(sample(1:length(label_train),0.7*length(label_train)))

xgb_fit <- xgb_train(feature_train[train_index,],label_train[train_index],run.cv=run.cv)
pred_label_xgb <- xgb_test(xgb_fit,feature_train[-train_index,])
mean(pred_label_xgb==label_train[-train_index])

df1<-data.frame(x=c(10,25,100,200),y=rep(1,4)-c(0.166,0.145,0.123,0.121))




