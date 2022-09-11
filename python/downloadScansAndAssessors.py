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
roiCollectionLabelFilterExclude = 'legacy'

xu = xnatDownloader(serverURL = serverURL,
                    projectStr=projectStr,
                    downloadPath=downloadPath,
                    removeSecondaryAndSnapshots=True,
                    assessorStyle=assessorStyle,
                    roiCollectionLabelFilter=roiCollectionLabelFilter,
                    roiCollectionLabelFilterExclude=roiCollectionLabelFilterExclude)

assessorFolder = 'assessors_' + strftime("%Y.%m.%d_%H.%M.%S", localtime())

# xu.getProjectDigest()


# # roiCollectionLabelFilter = 'dediff'
# # xu.roiCollectionLabelFilter = roiCollectionLabelFilter
# # xu.downloadAssessors_Project(destinFolder=os.path.join('assessors',assessorFolder, roiCollectionLabelFilter))
# #
# # # this is a special case where there may be an assessor for patID = 145 which has been excluded, so delete here
# # assessorDelete = glob.glob(os.path.join(downloadPath, 'assessors', assessorFolder, roiCollectionLabelFilter, 'RMH_RSRC145*.dcm'))
# # if len(assessorDelete)==1:
# #     os.remove(assessorDelete[0])
# #
# after downloading this section the repro assessors will be in the same folder, so delete repro assessors from lesion folder after completing download
roiCollectionLabelFilter = 'lesion'
xu.roiCollectionLabelFilter = roiCollectionLabelFilter
xu.downloadAssessors_Project(destinFolder=os.path.join('assessors',assessorFolder, roiCollectionLabelFilter), subjectList=['RMH_RSRC179'])
#
# # this is a special case where there may be an assessor for patID = 145 which has been excluded, so delete here
# assessorDelete = glob.glob(os.path.join(downloadPath, 'assessors', assessorFolder, roiCollectionLabelFilter, 'RMH_RSRC145*.dcm'))
# if len(assessorDelete)==1:
#     os.remove(assessorDelete[0])
#
# roiCollectionLabelFilter = 'repro'
# xu.roiCollectionLabelFilter = roiCollectionLabelFilter
# xu.downloadAssessors_Project(destinFolder=os.path.join('assessors',assessorFolder, roiCollectionLabelFilter))
#


# xu.downloadImagesReferencedByAssessors(keepEntireScan=True)

