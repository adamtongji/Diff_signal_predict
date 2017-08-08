#!/usr/bin/env python
# coding:utf-8
import numpy as np
import os
from scipy.stats.mstats import zscore

sh=os.system


class Diff_model(object):

    def __init__(self,expr_file, peak_file,enhancer=""):
        self.tissue = "input"
        self.enhancer = enhancer
        self.validate = ("cranioface_11.5_day","limb_11.5_day","forebrain_11.5_day","midbrain_11.5_day",
                         "hindbrain_11.5_day","neural_tube_11.5_day","liver_11.5_day","heart_11.5_day")
        self.expr_file = expr_file
        self.peak_file = peak_file
        print "Start differential signal recalibration."

    def search_db(self):
        myf = [i.rstrip().split("\t") for i in open(self.expr_file)]
        my_expr = myf[1:]
        my_tis = myf[0]
        my_expr_trans = map(list, zip(*my_expr))
        my_expr_db = my_expr_trans[1:]
        my_expr_input = my_expr_trans[0]
        for index, item in enumerate(my_expr_db):
            if my_expr_input == item:
                print "The input tissue is {}.".format(my_tis[index+1])
                self.tissue = my_tis[index+1]
                break
            else:
                print "The tissue is not found in our backend."

    def weight_fc(self):
        sh("Rscript $DIFF_PRED/weighted_fc.r {0} {1}".format(self.expr_file,self.peak_file))
        sh("sort -k 4gr,4gr {0}.weightfc.txt >{0}.weightfc.sorted.txt".format(self.peak_file))
        if self.tissue in self.validate:
            self.enhancer = "/db/enhancer/{}.txt".format(self.tissue)
        if self.enhancer:
            self._prauc_plot(self.peak_file, "{0}.weightfc.sorted.txt".format(self.peak_file))

    def weight_zscore(self):
        sh("Rscript $DIFF_PRED/weighted_zscore.r {0} {1}".format(self.expr_file, self.peak_file))
        sh("sort -k 4gr,4gr {0}.weightzscore.txt >{0}.weightzscore.sorted.txt".format(self.peak_file))
        if self.tissue in self.validate:
            self.enhancer = "/db/enhancer/{}.txt".format(self.tissue)
        if self.enhancer:
            self._prauc_plot(self.peak_file, "{0}.weightzscore.sorted.txt".format(self.peak_file))

    def _prauc_plot(self, peak_file, rerank_file):
        pass


















# python code for pca
def zeroMean(dataMat):
    meanVal=np.mean(dataMat,axis=0)
    newData=dataMat-meanVal
    return newData,meanVal

def percentage2n(eigVals,percentage):
    sortArray=np.sort(eigVals)   #升序
    sortArray=sortArray[-1::-1]  #逆转，即降序
    arraySum=sum(sortArray)
    tmpSum=0
    num=0
    for i in sortArray:
        tmpSum+=i
        num+=1
        if tmpSum>=arraySum*percentage:
            return num


def pca(dataMat,percentage=0.80):
    newData,meanVal=zeroMean(dataMat)
    covMat=np.cov(newData,rowvar=0)    #求协方差矩阵,return ndarray；若rowvar非0，一列代表一个样本，为0，一行代表一个样本
    eigVals,eigVects=np.linalg.eig(np.mat(covMat))#求特征值和特征向量,特征向量是按列放的，即一列代表一个特征向量
    n=percentage2n(eigVals,percentage)                 #要达到percent的方差百分比，需要前n个特征向量
    eigValIndice=np.argsort(eigVals)            #对特征值从小到大排序
    n_eigValIndice=eigValIndice[-1:-(n+1):-1]   #最大的n个特征值的下标
    n_eigVect=eigVects[:,n_eigValIndice]        #最大的n个特征值对应的特征向量
    lowDDataMat=newData*n_eigVect               #低维特征空间的数据
    reconMat=(lowDDataMat*n_eigVect.T)+meanVal  #重构数据
    return lowDDataMat,reconMat
