import sys, os, shutil
sys.path.append('/Users/morton/Documents/GitHub/icrpythonradiomics')
from xnatDownloader import xnatDownloader
import glob
import pygit2
from time import strftime, localtime

serverURL = 'https://xnatanon.icr.ac.uk/'

projectStr = 'RADSARC-R'
downloadPath = '/Users/morton/Dicom Files/RADSARC_R/XNAT'
assessorStyle = {"type": "SEG", "format": "DCM"}
roiCollectionLabelFilter = 'lesion'

xu = xnatDownloader(serverURL = serverURL,
                    projectStr=projectStr,
                    downloadPath=downloadPath,
                    removeSecondaryAndSnapshots=True,
                    assessorStyle=assessorStyle,
                    roiCollectionLabelFilter=roiCollectionLabelFilter)

assessorFolder = 'assessors_SEG_' + strftime("%Y.%m.%d_%H.%M.%S", localtime())

xu.downloadAssessors_Project(destinFolder=os.path.join('assessors', assessorFolder), subjectList = ['RMH_RSRC179'])