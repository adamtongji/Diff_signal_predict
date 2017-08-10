library(DESeq2)

args = commandArgs(T)
expr_file = args[1]
peak_file = args[2]

test<-read.table(expr_file,sep='\t',header=TRUE)
condition=colnames(test)
countdata<-floor(test*10)+1
rownames(countdata)<-paste("peak_",c(1:nrow(countdata)),sep='')


coldata<- data.frame(row.names = colnames(countdata), condition)
dds <- DESeqDataSetFromMatrix(countData = countdata, colData = coldata, design = ~condition)
pca_dds <- estimateSizeFactors(dds)
se <- SummarizedExperiment(log2(counts(pca_dds, normalized=TRUE)),colData=colData(pca_dds))

mydat<-plotPCA( DESeqTransform(se),returnData =TRUE)
mydist<-as.matrix(dist(mydat[,c(1,2)]))

#following 2 are for DNase
#mycount<-t(t(countdata)/colSums(countdata)*mean(colSums(countdata)))
#mycount<-t(t(countdata)*dnase_norm)
# 下面这部就是取Log2 zscore
mycount<-scale(log2(countdata))
myfc<-mean(mydist[as.numeric(tissue_id),])*mycount[,1]-rowMeans(t(t(mycount)*mydist[1,]))
test2<-read.table(peak_file,sep='\t')
outtab<-cbind(test2,myfc)
outf<-paste(expr_file,".weightzscore.txt",sep='')
write.table(outtab,file=outf, row.names=F, col.names=F, quote=F, sep='\t')

