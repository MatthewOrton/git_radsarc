
import numpy as np
import pandas as pd
pd.set_option('display.max_columns', 500, 'display.max_rows', 500)
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegressionCV, LogisticRegression
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
from xgboost import XGBClassifier
from sklearn.metrics import roc_auc_score, make_scorer
from sklearn.pipeline import Pipeline
from sklearn.model_selection import KFold, StratifiedKFold, RepeatedStratifiedKFold, GridSearchCV
from sklearn.model_selection import cross_validate
import os, warnings, copy, sys
import matplotlib.pyplot as plt
import collections

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
dfRad.drop(list(dfRad.filter(regex = 'histogram')), axis = 1, inplace = True)

# featureSets = ['lesion_original_shape', 'lesion_original_firstorder']
# featureSets = ['lesion_original_firstorder']
# featureSets = ['lesion_original_shape_SurfaceVolumeRatio', 
#                'lesion_original_shape_Sphericity', 
#                'lesion_original_firstorder_Mean',
#               'lesion_original_firstorder_10Percentile']
featureSets = ['lesion_original']

dfRad = dfRad.filter(regex='|'.join(featureSets) + '|StudyPatientName')

dfRad.rename(lambda x:x.replace('lesion_original_',''), axis=1, inplace=True)




df = dfClinical.merge(dfRad, left_on='Anon Code', right_on='StudyPatientName')
df.drop('Anon Code', axis=1, inplace=True)
df.drop('StudyPatientName', axis=1, inplace=True)
df.drop('Grade', axis=1, inplace=True)
target = 'subtype'



random_state = 42
np.random.seed(random_state)

X = df.drop(target, axis=1)
y = df[target]

correlationHierarchy = ['shape_MeshVolume', 'shape', 'firstorder']

textureStr = 'glcm|gldm|glszm|glrlm|ngtdm'
groupHierarchy = ['MeshVolume', 'shape', 'firstorder|histogram', textureStr, 'shape|firstorder|histogram', 'shape|'+textureStr, 'firstorder|histogram|'+textureStr, '']

pipe = Pipeline([('correlationSelector', featureSelection_correlation(threshold=0.9, exact=False, featureGroupHierarchy=correlationHierarchy)),
                 ('groupSelector', featureSelection_groupName()),
                 ('scaler', StandardScaler()),
                 ('lr', LogisticRegression(solver="liblinear", max_iter=10000, penalty='l1'))])

p_grid = {"lr__C": np.hstack((np.logspace(-2, 0, 10), 100)),
          "groupSelector__groupFilter": groupHierarchy}



inner_cv = StratifiedKFold(n_splits=5)
model = GridSearchCV(estimator=pipe, param_grid=p_grid, cv=inner_cv, refit=True, verbose=0, scoring='neg_log_loss', n_jobs=-1)
_ = model.fit(X, y)


colMask0 = copy.deepcopy(model.best_estimator_.steps[0][1].mask_)
colMask1 = model.best_estimator_.steps[1][1].colMask_
colMask0[colMask0] = colMask1
bc = np.zeros((X.shape[1]))
bc[colMask0] = copy.deepcopy(model.best_estimator_._final_estimator.coef_).ravel()
coef = pd.DataFrame({'Feature':list(np.array(X.columns)[bc != 0]), 'Coef':list(bc[bc != 0])})
coef = coef.sort_values(by='Coef', ascending=False, key=abs)
coef = coef.loc[coef.Coef != 0,:]
print(coef)
print(model.best_estimator_.steps[1][1].groupFilter)


n_splits = 10
n_repeats = 2
validation = RepeatedStratifiedKFold(n_splits=n_splits, n_repeats=n_repeats)

# # supress warnings for cross_validate
warnings.simplefilter("ignore")
os.environ["PYTHONWARNINGS"] = "ignore"
#
cv_result = cross_validate(model, X, y, cv=validation, scoring='roc_auc', return_estimator=True, n_jobs=-1)
# #
warnings.simplefilter('default')
os.environ["PYTHONWARNINGS"] = 'default'

print('AUROC (CV) = ' + str(np.round(np.mean(cv_result['test_score']),5)))



for ecv in cv_result['estimator']:
    if ecv.best_estimator_.steps[1][1].groupFilter == '':
        ecv.best_estimator_.steps[1][1].groupFilter = 'all'
    ecv.best_estimator_.steps[1][1].groupFilter = ecv.best_estimator_.steps[1][1].groupFilter.replace('glcm|gldm|glszm|glrlm|ngtdm','texture')
    ecv.best_estimator_.steps[1][1].groupFilter = ecv.best_estimator_.steps[1][1].groupFilter.replace('firstorder|histogram','firstorder')

group_cv_counts = {}
for group in set([x.best_estimator_.steps[1][1].groupFilter for x in cv_result['estimator']]):
    group_cv_counts[group] = len([x for x in group_cv if x==group])
print(group_cv_counts)

for ecv in cv_result['estimator']:
    colMask0 = copy.deepcopy(ecv.best_estimator_.steps[0][1].mask_)
    colMask1 = ecv.best_estimator_.steps[1][1].colMask_
    colMask0[colMask0] = colMask1
    bc = np.zeros((X.shape[1]))
    bc[colMask0] = copy.deepcopy(ecv.best_estimator_._final_estimator.coef_).ravel()
    coef = pd.DataFrame({'Feature':list(np.array(X.columns)[bc != 0]), 'Coef':list(bc[bc != 0])})
    coef = coef.sort_values(by='Coef', ascending=False, key=abs)
    coef = coef.loc[coef.Coef != 0,:]
    print(ecv.best_estimator_.steps[1][1].groupFilter)
    print(coef)
    print('\n')




