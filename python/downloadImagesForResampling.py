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
scanList.append(['20180125_094000_Aquilion', '3'])
scanList.append(['20180824_153000_Aquilion', '6'])
scanList.append(['20180205_100500_SOMATOM', '2'])
scanList.append(['20180910_093000_SOMATOM', '2'])
scanList.append(['20180914_120000_Brilliance', '5'])
scanList.append(['20181104_075000_Discovery', '3'])

xu.scanList_downloadScans(scanList, destinFolder='scans_' + strftime("%Y.%m.%d_%H.%M.%S", localtime()) + '/originals')

