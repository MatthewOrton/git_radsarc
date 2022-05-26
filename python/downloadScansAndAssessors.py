import sys, os, shutil
sys.path.append('/Users/morton/Documents/GitHub/icrpythonradiomics')
from xnatDownloader import xnatDownloader
import glob
import pygit2
from time import strftime, localtime

serverURL = 'https://xnatanon.icr.ac.uk/'

projectStr = 'RADSARC-R'
downloadPath = '/Users/morton/Dicom Files/RADSARC_R/XNAT'
assessorStyle = {"type": "AIM", "format": "DCM"}
roiCollectionLabelFilter = '' #Lesion'

xu = xnatDownloader(serverURL = serverURL,
                    projectStr=projectStr,
                    downloadPath=downloadPath,
                    removeSecondaryAndSnapshots=True,
                    assessorStyle=assessorStyle,
                    roiCollectionLabelFilter=roiCollectionLabelFilter)

# xu.assessorFolder = 'assessors/assessors_2022.04.27_11.55.08'

#xu.getProjectDigest()

xu.downloadAssessors_Project(destinFolder='assessors/assessors_' + strftime("%Y.%m.%d_%H.%M.%S", localtime())) #, subjectList=['RMH_RSRC004', 'RMH_RSRC036', 'RMH_RSRC052'])
xu.downloadImagesReferencedByAssessors(keepEntireScan=True)

