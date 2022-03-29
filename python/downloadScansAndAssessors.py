import sys, os, shutil
sys.path.append('/Users/morton/Documents/GitHub/icrpythonradiomics')
from xnatDownloader import xnatDownloader
import glob
import pygit2

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


#xu.downloadAssessors_Project()
xu.downloadImagesReferencedByAssessors(keepEntireScan=True)

