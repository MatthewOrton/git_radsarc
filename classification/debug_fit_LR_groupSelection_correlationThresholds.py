import pickle
from fit_LR_groupSelection_correlationThresholds import fit_LR_groupSelection_correlationThresholds, plotResultExperiments, displayOneExperiment

with open('/Users/morton/Documents/git/git_radsarc/classification/debugVariables.pickle', 'rb') as handle:
    result = pickle.load(handle)
    df = result['df']
    target = result['target']
    settings = result['settings']

settings['thresholds'] = [0.6] #, 0.8, 1.0]
settings['n_jobs'] = 1

result = fit_LR_groupSelection_correlationThresholds(df, target, settings=settings)

# plotResultExperiments(result)

displayOneExperiment(result, threshold=0.6)