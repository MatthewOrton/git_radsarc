import sys, os, shutil
sys.path.append('/Users/morton/Documents/GitHub/icrpythonradiomics')
from xnatDownloader import xnatDownloader
import glob
import pygit2
from time import strftime, localtime

serverURL = 'https://xnatanon.icr.ac.uk/'

projectStr = 'RADSARC-R'
downloadPath = '/Users/morton/Dicom Files/RADSARC_R/XNAT/RMH_EORTC'

xu = xnatDownloader(serverURL = serverURL,
                    projectStr=projectStr,
                    downloadPath=downloadPath,
                    removeSecondaryAndSnapshots=True)

subjectList = [ 'RADSARC-R-113']
# 'RADSARC-R-100',
#                 'RADSARC-R-117',
#                 'RADSARC-R-123',
#                 'RADSARC-R-126',
#                 'RADSARC-R-129',
#                 'RADSARC-R-153',
#                 'RADSARC-R-170']
# 'RADSARC-R-015',
# 'RADSARC-R-017',
# 'RADSARC-R-020',
# 'RADSARC-R-040',
# 'RADSARC-R-042',
# 'RADSARC-R-054',
# 'RADSARC-R-058',
# 'RADSARC-R-061',
# 'RADSARC-R-087',

xu.subjectList_downloadExperiments(subjectList=subjectList)

