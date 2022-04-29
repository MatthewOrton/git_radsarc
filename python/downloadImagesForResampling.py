import sys, os, shutil
sys.path.append('/Users/morton/Documents/GitHub/icrpythonradiomics')
from xnatDownloader import xnatDownloader
import glob
import pygit2
from time import strftime, localtime

serverURL = 'https://xnatanon.icr.ac.uk/'

projectStr = 'RADSARC-R'
downloadPath = '/Users/morton/Dicom Files/RADSARC_R/XNAT/scansForResampling'
assessorStyle = {"type": "AIM", "format": "DCM"}
roiCollectionLabelFilter = '' #Lesion'

xu = xnatDownloader(serverURL = serverURL,
                    projectStr=projectStr,
                    downloadPath=downloadPath,
                    removeSecondaryAndSnapshots=True,
                    assessorStyle=assessorStyle,
                    roiCollectionLabelFilter=roiCollectionLabelFilter)

scanList = []
scanList.append(['20180110_131500_Optima', '3'])

xu.scanList_downloadScans(scanList, destinFolder='scans_' + strftime("%Y.%m.%d_%H.%M.%S", localtime()) + '/originals')

