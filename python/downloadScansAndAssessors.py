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
roiCollectionLabelFilter = ''

xu = xnatDownloader(serverURL = serverURL,
                    projectStr=projectStr,
                    downloadPath=downloadPath,
                    removeSecondaryAndSnapshots=True,
                    assessorStyle=assessorStyle,
                    roiCollectionLabelFilter=roiCollectionLabelFilter)

assessorFolder = 'assessors_' + strftime("%Y.%m.%d_%H.%M.%S", localtime())

#xu.getProjectDigest()

# subjectList = ['RMH_RSRC165'] #, 'RMH_RSRC122', 'RMH_RSRC148', 'RMH_RSRC149', 'RMH_RSRC158', 'RMH_RSRC161', 'RMH_RSRC165', 'RMH_RSRC167', 'RMH_RSRC171', 'RMH_RSRC180', 'RMH_RSRC183']

roiCollectionLabelFilter = 'dediff'
xu.roiCollectionLabelFilter = roiCollectionLabelFilter
xu.downloadAssessors_Project(destinFolder=os.path.join('assessors',assessorFolder, roiCollectionLabelFilter)) #, subjectList=subjectList)

roiCollectionLabelFilter = 'lesion'
xu.roiCollectionLabelFilter = roiCollectionLabelFilter
xu.downloadAssessors_Project(destinFolder=os.path.join('assessors',assessorFolder, roiCollectionLabelFilter)) #, subjectList=subjectList)


xu.downloadImagesReferencedByAssessors(keepEntireScan=True)

