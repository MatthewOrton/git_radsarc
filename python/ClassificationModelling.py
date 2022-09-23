

import numpy as np
import pandas as pd
pd.set_option('display.max_columns', 500, 'display.max_rows', 500)
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegressionCV
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
from xgboost import XGBClassifier
from sklearn.metrics import roc_auc_score, make_scorer
from sklearn.pipeline import Pipeline
from sklearn.model_selection import KFold, StratifiedKFold, RepeatedStratifiedKFold
from sklearn.model_selection import cross_validate
import os, warnings, copy
import matplotlib.pyplot as plt
import sys

sys.path.append('/data/users/morton/git/icrpythonradiomics/machineLearning')
from featureSelection import featureSelection_correlation, featureSelection_groupName




# open clinical spreadsheet
clinicalSpreadsheet = '/Users/morton/Dicom Files/RADSARC_R/ClinicalData/Clinical data for analysis.xlsx'
dfClinical = pd.read_excel(clinicalSpreadsheet, sheet_name='220818_Completed segs', engine='openpyxl')
dfClinical = dfClinical[['Anon Code', 'Grade', 'subtype']]




# open radiomics data
dfRad = pd.read_csv('/Users/morton/Dicom Files/RADSARC_R/XNAT/extractions/extractions__20220910_1006_allRegions/radiomicFeatures/radiomicFeatures.csv')
dfRad.drop(list(dfRad.filter(regex = 'source')), axis = 1, inplace = True)
dfRad.drop(list(dfRad.filter(regex = 'diagnostic')), axis = 1, inplace = True)

featureSets = ['lesion_original_shape', 'lesion_original_firstorder']
# featureSets = ['lesion_original_firstorder']
# featureSets = ['lesion_original_shape_SurfaceVolumeRatio', 
#                'lesion_original_shape_Sphericity', 
#                'lesion_original_firstorder_Mean',
#               'lesion_original_firstorder_10Percentile']

dfRad = dfRad.filter(regex='|'.join(featureSets) + '|StudyPatientName')

dfRad.rename(lambda x:x.replace('lesion_original_',''), axis=1, inplace=True)

# for featureSet in featureSets:
#     dfRad.rename(lambda x:x.replace(featureSet+'_',''), axis=1, inplace=True)





df = dfClinical.merge(dfRad, left_on='Anon Code', right_on='StudyPatientName')
df.drop('Anon Code', axis=1, inplace=True)
df.drop('StudyPatientName', axis=1, inplace=True)
df.drop('Grade', axis=1, inplace=True)
target = 'subtype'



# add pair-wise interactions
# features = list(set(df.columns) - set([target]))
# for i in range(len(features)-1):
#     for j in range(i+1, len(features)):
#         df['interaction_' + features[i] + '_x_' + features[j]] = df[features[i]].multiply(df[features[j]])


random_state = 42
np.random.seed(random_state)

X = df.drop(target, axis=1)
y = df[target]

correlationHierarchy = ['shape_MeshVolume', 'shape', 'firstorder'] #, 'glcm_Correlation']
fsc = featureSelection_correlation(threshold=0.9, exact=True, featureGroupHierarchy=correlationHierarchy)

model = LogisticRegressionCV(penalty='l2', multi_class='multinomial', solver='saga', Cs=20, cv=5, random_state=random_state, max_iter=50000)

# ('fsc', fsc)
pipe = Pipeline(steps=[('scaler', StandardScaler()), 
                 ('classifier', model)])



fsc.fit(X)
#pipe.fit(X,y)





coef = pd.DataFrame({'Feature':list(X.columns), 'Coef':list(pipe.steps[1][1].coef_[0])})
coef = coef.sort_values(by='Coef', ascending=False, key=abs)


n_splits = 10
n_repeats = 1
validation = RepeatedStratifiedKFold(n_splits=n_splits, n_repeats=n_repeats)

# supress warnings for cross_validate
warnings.simplefilter("ignore")
os.environ["PYTHONWARNINGS"] = "ignore"
#
cv = cross_validate(pipe, X, y, cv=validation, scoring='roc_auc', n_jobs=-1)
#
warnings.simplefilter('default')
os.environ["PYTHONWARNINGS"] = 'default'

print('AUROC (CV) = ' + str(np.round(np.mean(cv['test_score']),5)))



# plt.scatter(X['lesion_original_firstorder_Mean'], X['lesion_original_shape_Sphericity'], c=y=='LPS', s=5, cmap='brg')





