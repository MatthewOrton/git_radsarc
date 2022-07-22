import sys, os, shutil
sys.path.append('/Users/morton/Documents/GitHub/icrpythonradiomics')
from xnatDownloader import xnatDownloader
import glob
import pygit2
import pandas as pd
from time import strftime, localtime
import numpy as np

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
experimentList = xu.getExperimentList_Project()
assessorList = xu.getAssessorList_experimentList(experimentList)

# remove any that are SEG files
assessorList = [x for x in assessorList if 'AIM' in x['assessor']]

# remove any that match local version of dediff ROIs
assessorsDediff = glob.glob(os.path.join(downloadPath, 'assessors', 'assessors_2022.07.20_09.51.14', 'dediff', '*.dcm'))
for assessorDediff in assessorsDediff:
    name = assessorDediff.split('__II__')[3].replace('.dcm','')
    idx = np.where(np.array([x['assessor'] == name for x in assessorList]))[0]
    if len(idx)>0:
        assessorList.pop(idx[0])


# get list of thumbnail files in most recent run of thumbnail generation (need to update folder name)
thumbnailPath = os.path.join(downloadPath, 'roiThumbnails', 'roiThumbnails_2022.07.21_21.26.28')
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
dfMaster = pd.read_excel(os.path.join(downloadPath, 'roiThumbnails', 'Thumbnail_QC_master.xlsx'))

# copy Checked status from Master for any matching rows
for _, row in df.iterrows():
    for _, rowMaster in dfMaster.iterrows():
        if row['SubjectID']==rowMaster['SubjectID'] and \
                row['ExperimentID']==rowMaster['ExperimentID'] and \
                row['AssessorID'] == rowMaster['AssessorID'] and \
                row['ThumbnailFile']==rowMaster['ThumbnailFile']:
                    row['Checked'] = rowMaster['Checked']

# write new QC file
df = df.fillna('')
df.to_excel(os.path.join(thumbnailPath, 'Thumbnail_QC.xlsx'), index=False)