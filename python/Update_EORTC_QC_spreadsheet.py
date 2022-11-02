import sys, os, shutil
sys.path.append('/Users/morton/Documents/git/git_icrpythonradiomics')
from xnatDownloader import xnatDownloader
import glob
import pygit2
import pandas as pd
from time import strftime, localtime
import numpy as np
import copy

serverURL = 'https://xnatanon.icr.ac.uk/'

projectStr = 'RADSARC-R'
downloadPath = '/Users/morton/Dicom Files/RADSARC_R/XNAT'
assessorStyle = {"type": "AIM", "format": "DCM"}
roiCollectionLabelFilter = 'Lesion'

xu = xnatDownloader(serverURL = serverURL,
                    projectStr=projectStr,
                    downloadPath=downloadPath,
                    removeSecondaryAndSnapshots=True,
                    assessorStyle=assessorStyle,
                    roiCollectionLabelFilter=roiCollectionLabelFilter)

# get list of all assessors (including SEG and RTS) currently on XNAT
subjectList = xu.getSubjectList_Project()
subjectList = [subject for subject in subjectList if 'EORTC' in subject]

#experimentList = xu.getExperimentList_Project()
#assessorList = xu.getAssessorList_experimentList(experimentList)
assessorList = xu.getAssessorList_subjectList(subjectList)

# remove any that are SEG files
assessorList = [x for x in assessorList if 'AIM' in x['assessor']]

# get list of thumbnail files in most recent run of thumbnail generation (need to update folder name)
thumbnailPath = os.path.join(downloadPath, 'roiThumbnails', 'roiThumbnailsV2_2022.10.20_18.50.40')
thumbnailFiles = glob.glob(os.path.join(thumbnailPath, 'subjects', '*.pdf'))

# loop over assessors found and see if there is a corresponding thumbnail file, and store the file name if there is
for assessor in assessorList:
    thumbMatch = []
    for thumbnailFile in thumbnailFiles:
        if (assessor['subject'] in thumbnailFile) and (assessor['experiment'] in thumbnailFile) and (assessor['assessor'] in thumbnailFile):
            thumbMatch.append(os.path.split(thumbnailFile)[1])
    if len(thumbMatch)==1:
        assessor['thumbFile'] = thumbMatch[0]
    if len(thumbMatch)==0:
        assessor['thumbFile'] = ''
    if len(thumbMatch)>1:
        print('ERROR: More than one thumbnail match!')

# make a data frame from assessorList
info = zip([x['subject'] for x in assessorList],
           [x['experiment'] for x in assessorList],
           [x['assessor'] for x in assessorList],
           [x['thumbFile'] for x in assessorList])
df = pd.DataFrame(list(info), columns = ['SubjectID', 'ExperimentID', 'AssessorID', 'ThumbnailFile'])
df = df.sort_values(by=['SubjectID', 'ExperimentID', 'AssessorID'])
df['Checked'] = ''

# read existing dataFrame, which will contain information about whether the thumbnail has been checked
dfMaster = pd.read_excel(os.path.join(downloadPath, 'roiThumbnails', 'Thumbnail_EORTC_QC_master.xlsx'))

# copy Checked status from Master for any matching rows
for _, row in df.iterrows():
    for _, rowMaster in dfMaster.iterrows():

        # # this should only be needed for one update because the old files included the lesion name, but the new ones do not
        # thisMasterThumb = copy.deepcopy(rowMaster['ThumbnailFile'])
        # if isinstance(thisMasterThumb, str):
        #     idx = thisMasterThumb.lower().find('_lesion')
        #     thisMasterThumb = thisMasterThumb[0:idx] + '.pdf'

        if row['SubjectID']==rowMaster['SubjectID'] and \
                row['ExperimentID']==rowMaster['ExperimentID'] and \
                row['AssessorID'] == rowMaster['AssessorID'] and \
                row['ThumbnailFile']==rowMaster['ThumbnailFile']:
                    row['Checked'] = rowMaster['Checked']

# write new QC file
df = df.fillna('')
df.to_excel(os.path.join(thumbnailPath, 'Thumbnail_EORTC_QC.xlsx'), index=False)