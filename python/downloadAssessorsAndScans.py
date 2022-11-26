import sys, os, shutil
sys.path.append('/Users/morton/Documents/GitHub/icrpythonradiomics')
from xnatDownloader import xnatDownloader
import glob

serverURL = 'https://xnatanon.icr.ac.uk/'

projectStr = 'RADSARC-R'
downloadPath = '/Users/morton/Dicom Files/RADSARC_R/XNATfinal'
assessorStyle = {"type": "SEG", "format": "DCM"}

xu = xnatDownloader(serverURL = serverURL,
                    projectStr=projectStr,
                    downloadPath=downloadPath,
                    removeSecondaryAndSnapshots=True,
                    assessorStyle=assessorStyle)

# separate downloads for RMH and EORTC data
subjectListRMH = [subject for subject in xu.getSubjectList_Project() if 'RMH_RSRC' in subject]
subjectListEORTC = [subject for subject in xu.getSubjectList_Project() if 'EORTC' in subject]

roiCollectionLabelFilter = 'lesion_four_subregions'
xu.roiCollectionLabelFilter = roiCollectionLabelFilter
xu.downloadAssessors_Project(destinFolder = os.path.join('assessors', 'EORTC', roiCollectionLabelFilter), subjectList=subjectListEORTC)
# xu.downloadImagesReferencedByAssessors(keepEntireScan=True)

roiCollectionLabelFilter = 'lesion_repro_four_subregions'
xu.roiCollectionLabelFilter = roiCollectionLabelFilter
xu.downloadAssessors_Project(destinFolder = os.path.join('assessors', 'RMH_RSRC', roiCollectionLabelFilter), subjectList = subjectListRMH)

roiCollectionLabelFilter = 'lesion_four_subregions'
xu.roiCollectionLabelFilter = roiCollectionLabelFilter
xu.downloadAssessors_Project(destinFolder = os.path.join('assessors', 'RMH_RSRC', roiCollectionLabelFilter), subjectList = subjectListRMH)
# xu.downloadImagesReferencedByAssessors(keepEntireScan=True)
