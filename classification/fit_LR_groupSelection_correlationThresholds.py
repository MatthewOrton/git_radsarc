import numpy as np
import pandas as pd
from sklearn.linear_model import LogisticRegressionCV, LogisticRegression
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import roc_auc_score, make_scorer, confusion_matrix
from sklearn.pipeline import Pipeline
from sklearn.model_selection import KFold, StratifiedKFold, RepeatedStratifiedKFold, GridSearchCV
from sklearn.model_selection import cross_validate
import os, warnings, copy, sys
import matplotlib.pyplot as plt
import dill

user = os.path.expanduser("~")

sys.path.append(os.path.join(user, 'Documents/git/git_icrpythonradiomics/machineLearning'))
from featureSelection import featureSelection_correlation, featureSelection_groupName, StandardScalerDf

# function to make group strings easier to read
def groupStrsDisp(strGroups):

    def tidyGroup(strGroup):
        if strGroup == '':
            strGroup = 'all'
        strGroup = strGroup.replace('glcm|gldm|glszm|glrlm|ngtdm','texture')
        strGroup = strGroup.replace('firstorder|histogram','firstorder')
        return strGroup

    if isinstance(strGroups, str):
        return tidyGroup(strGroups)

    if isinstance(strGroups, list):
        return [tidyGroup(x) for x in strGroups]


def fit_LR_groupSelection_correlationThresholds(df, target, settings={}):

    textureStr = 'glcm|gldm|glszm|glrlm|ngtdm'

    if 'correlationHierarchy' in settings:
        correlationHierarchy = settings['correlationHierarchy']
    else:
        correlationHierarchy = ['VolumeFraction', 'shape', 'firstorder']
        settings['correlationHierarchy'] = correlationHierarchy

    if 'groupHierarchy' in settings:
        groupHierarchy = settings['groupHierarchy']
    else:
        groupHierarchy = ['VolumeFraction',
                          'shape',
                          'firstorder',
                          textureStr,
                          'VolumeFraction|shape',
                          'VolumeFraction|firstorder',
                          'VolumeFraction|' + textureStr,
                          'shape|firstorder',
                          'shape|' + textureStr,
                          'firstorder|' + textureStr,
                          '']
        settings['groupHierarchy'] = groupHierarchy

    if 'thresholds' in settings:
        thresholds = settings['thresholds']
    else:
        thresholds = np.round(np.arange(0.6, 1.001, 0.05), 2)
        settings['thresholds'] = thresholds

    if 'n_splits' in settings:
        n_splits = settings['n_splits']
    else:
        n_splits = 10
        settings['n_splits'] = n_splits

    if 'n_repeats' in settings:
        n_repeats = settings['n_repeats']
    else:
        n_repeats = 1
        settings['n_repeats'] = n_repeats

    if 'n_jobs' in settings:
        n_jobs = settings['n_jobs']
    else:
        n_jobs = -1
        settings['n_jobs'] = n_jobs

    if 'resultsFile' in settings:
        resultsFile = settings['resultsFile']
    else:
        resultsFile = None
        settings['resultsFile'] = resultsFile

    # extract data
    X = df.drop(target, axis=1)
    y = df[target]

    inner_pipeline = Pipeline([('groupSelector', featureSelection_groupName()),
                               ('lr', LogisticRegression(solver="liblinear", max_iter=10000, penalty='l2'))])

    inner_p_grid = {'groupSelector__groupFilter': groupHierarchy,
                    'lr__C': np.logspace(np.log10(0.05), np.log10(50), 10)}

    inner_model = GridSearchCV(estimator=inner_pipeline,
                               param_grid=inner_p_grid,
                               cv=StratifiedKFold(n_splits=5),
                               refit=True,
                               verbose=0,
                               scoring='neg_log_loss',
                               n_jobs=1)


    model = Pipeline([('correlationSelector', featureSelection_correlation(threshold=0.9,
                                                                            exact=False,
                                                                            featureGroupHierarchy=correlationHierarchy)),
                         ('scaler', StandardScalerDf()),
                         ('model', inner_model)])

    experiments = []

    for threshold in thresholds:

        model.steps[0][1].threshold = threshold

        random_state = 42
        np.random.seed(random_state)

        model.fit(X, y)

        print('Threshold = ' + str(threshold))
        print(groupStrsDisp(model.steps[2][1].best_estimator_.steps[0][1].groupFilter))

        validation = RepeatedStratifiedKFold(n_splits=n_splits, n_repeats=n_repeats)

        # supress warnings for cross_validate
        warnings.simplefilter("ignore")
        os.environ["PYTHONWARNINGS"] = "ignore"
        #
        cv_result = cross_validate(model, X, y, cv=validation, scoring='roc_auc', return_estimator=True, n_jobs=n_jobs)
        #
        warnings.simplefilter('default')
        os.environ["PYTHONWARNINGS"] = 'default'

        experiments.append({'threshold':threshold, 'model':copy.deepcopy(model), 'cv_result':copy.deepcopy(cv_result)})

        cv_mean = np.round(np.mean(cv_result['test_score']),3)
        cv_std  = np.round(np.std(cv_result['test_score']),4)

        print('AUROC = ' + str(cv_mean) + ' \u00B1 ' + str(cv_std) + '\n')
        

    return {'experiments':experiments,
            'settings':settings,
            'df':df,
            'target':target,
            'model':model}



def plotResultExperiments(result, titleStr=None):

    groupHierarchy = groupStrsDisp(result['settings']['groupHierarchy'])

    colNames = groupStrsDisp(groupHierarchy)
    colNames.insert(0, 'threshold')
    groupFrequencyDf = pd.DataFrame(columns=colNames)
    featureCount = []

    for n, experiment in enumerate(result['experiments']):
        cv_result = experiment['cv_result']

        group_cv = [groupStrsDisp(x.steps[2][1].best_estimator_.steps[0][1].groupFilter) for x in cv_result['estimator']]
        groupCounts = [0] * len(groupHierarchy)
        for n, group in enumerate(groupStrsDisp(groupHierarchy)):
            groupCounts[n] = len([x for x in group_cv if x == group])
        groupCounts = [x / np.sum(groupCounts) for x in groupCounts]
        groupCounts.insert(0, experiment['threshold'])
        groupFrequencyDf = pd.concat([groupFrequencyDf, pd.DataFrame(data=[groupCounts], columns=colNames)])

        featureCount.append([np.sum(x._final_estimator.best_estimator_._final_estimator.coef_ != 0) for x in cv_result['estimator']])

    groupFrequencyDf = groupFrequencyDf.reset_index(drop=True)
    featureCount = np.array(featureCount)

    plt.rcParams['font.size'] = '14'
    f, a = plt.subplots(3, 1, figsize=(12, 12))

    for group in groupStrsDisp(groupHierarchy):
        a[0].plot(groupFrequencyDf['threshold'], 100 * groupFrequencyDf[group], label=group, marker='.')
    a[0].legend(fontsize=10, loc='upper left')
    a[0].set_xlabel('Correlation threshold')
    a[0].set_ylabel('Selection frequency / %')
    a[0].set_xlim([0.42, 1.04])
    a[0].set_xticks([0.6, 0.7, 0.8, 0.9, 1.0])
    if titleStr is not None:
        a[0].set_title(titleStr)

    cv_mean = [np.mean(experiment['cv_result']['test_score']) for experiment in result['experiments']]
    cv_std = [np.std(experiment['cv_result']['test_score']) for experiment in result['experiments']]

    thresholds = result['settings']['thresholds']

    a[1].plot(thresholds, cv_mean, marker='.')
    a[1].plot(thresholds, np.array(cv_mean) + np.array(cv_std), linestyle='--', color='C0')
    a[1].plot(thresholds, np.array(cv_mean) - np.array(cv_std), linestyle='--', color='C0')
    a[1].set_ylim([0.6, 1.05])
    a[1].set_xlim([0.42, 1.04])
    a[1].set_xticks([0.6, 0.7, 0.8, 0.9, 1.0])
    a[1].set_xlabel('Correlation threshold')
    a[1].set_ylabel('AUROC')

    a[2].plot(thresholds, np.median(featureCount, axis=1), marker='.')
    a[2].plot(thresholds, np.quantile(featureCount, 0.9, axis=1), linestyle='--', color='C0')
    a[2].plot(thresholds, np.quantile(featureCount, 0.1, axis=1), linestyle='--', color='C0')
    a[2].set_ylim([-2, 15])
    a[2].set_xlim([0.42, 1.04])
    a[2].set_xticks([0.6, 0.7, 0.8, 0.9, 1.0])
    a[2].set_xlabel('Correlation threshold')
    a[2].set_ylabel('Number of features')

    plt.show()

def displayOneExperiment(result, threshold=None):

    experiment = [x for x in result['experiments'] if x['threshold'] == threshold][0]
    model = experiment['model']
    cv_result = experiment['cv_result']

    print('AUROC (CV) = ' + str(np.round(np.mean(cv_result['test_score']), 5)) + '\n')

    print('Feature group = ' + groupStrsDisp(model.steps[2][1].best_estimator_.steps[0][1].groupFilter) + '\n')

    # Get the non-zero LR coefficients

    X = result['df'].drop(result['target'], axis=1)

    colMask0 = copy.deepcopy(model.best_estimator_.steps[0][1].mask_)
    colMask1 = model.best_estimator_.steps[1][1].colMask_
    colMask0[colMask0] = colMask1
    bc = np.zeros((X.shape[1]))
    bc[colMask0] = copy.deepcopy(model.best_estimator_._final_estimator.coef_).ravel()
    bestCoef = pd.DataFrame({'Feature': list(np.array(X.columns)[bc != 0]), 'Coef': list(bc[bc != 0])})
    bestCoef = bestCoef.sort_values(by='Coef', ascending=False, key=abs)
    bestCoef = bestCoef.loc[bestCoef.Coef != 0, :]

    # get frequency that each feature is selected

    bc = np.zeros((len(cv_result['estimator']), X.shape[1]))
    for n, ecv in enumerate(cv_result['estimator']):
        colMask0 = copy.deepcopy(ecv.best_estimator_.steps[0][1].mask_)
        colMask1 = ecv.best_estimator_.steps[1][1].colMask_
        colMask0[colMask0] = colMask1
        bc[n, colMask0] = copy.deepcopy(ecv.best_estimator_._final_estimator.coef_)
        coef = pd.DataFrame(
            {'Feature': list(np.array(X.columns)[bc[n, :].ravel() != 0]), 'Coef': list(bc[n, bc[n, :] != 0])})
        coef = coef.sort_values(by='Coef', ascending=False, key=abs)
        coef = coef.loc[coef.Coef != 0, :]

    n_splits = result['settings']['n_splits']
    n_repeats = result['settings']['n_repeats']
    pdFreq = pd.DataFrame({'Feature': X.columns, 'Frequency': np.sum(bc != 0, axis=0) / (n_splits * n_repeats) * 100})

    # add coeff values for best fit
    pdFreq['Coef'] = ''
    for _, row in bestCoef.iterrows():
        rowIndex = pdFreq.index[pdFreq.Feature == row.Feature].tolist()[0]
        pdFreq.loc[rowIndex, 'Coef'] = row.Coef

    pdFreq = pdFreq.loc[pdFreq.Frequency > 0, :].sort_values(by='Frequency', ascending=False, key=abs)

    return bestCoef, pdFreq
