import pickle
from fit_LR_groupSelection_correlationThresholds import fit_LR_groupSelection_correlationThresholds, plotResultExperiments, displayOneExperiment
import numpy as np

with open('/Users/morton/Documents/git/git_radsarc/classification/debugVariables.pickle', 'rb') as handle:
    result = pickle.load(handle)
    df = result['df']
    target = result['target']
    settings = result['settings']

settings['thresholds'] = [0.9] #, 0.8, 1.0]
settings['n_jobs'] = 1
settings['penalty'] = 'l1'
settings['n_splits'] = 5
settings['n_repeats'] = 1

# featuresToRemove = [x for x in df.columns if 'shape' not in x and 'firstorder' not in x and 'subtype' not in x and 'glcm' not in x]
featuresToRemove = [x for x in df.columns if 'ClusterProminence' in x]

clusterProminence = [x for x in df.columns if 'ClusterProminence' in x][0]

df[clusterProminence] = np.log(df[clusterProminence])

for f in featuresToRemove:
    df.drop(f, axis=1, inplace=True)

result = fit_LR_groupSelection_correlationThresholds(df, target, settings=settings)

# plotResultExperiments(result)

# bestCoef, pdFreq = displayOneExperiment(result, threshold=0.6)

