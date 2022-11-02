import sys, glob, traceback, os
sys.path.append('/Users/morton/Documents/GitHub/icrpythonradiomics')

import numpy as np
from dataLoader import dataLoader
from saveThumbnail import saveThumbnail
from getSeriesUIDFolderDict import getSeriesUIDFolderDict
from joblib import Parallel, delayed

rtsFolder = '/Users/morton/Dicom Files/RADSARC_R/XNAT/assessors/assessors_2022.10.31_09.33.11'
rtsFiles = glob.glob(os.path.join(rtsFolder, 'lesion', '*.dcm'))
patientIDs = list(set([os.path.split(x)[1].split('__II__')[0] for x in rtsFiles]))
patientIDs.sort()

# dictionary to locate the images referenced by the rts files
seriesFolderDict = getSeriesUIDFolderDict('/Users/morton/Dicom Files/RADSARC_R/XNAT/referencedScans')

def processOnePatient(patientID, rtsFolder, seriesFolderDict, thumbnailFolder):

    printMessage = ['Processing ' + patientID]


    errorMessage = None

    try:

        lesionAssessors = glob.glob(os.path.join(rtsFolder, 'lesion', patientID + '*.dcm'))

        if len(lesionAssessors)>1:
            errorMessage = patientID + ' more than one lesion assessor found - quitting'
            printMessage.append(errorMessage)
            for line in printMessage:
                print(line)
            print('\n')
            return errorMessage

        dediffAssessors = glob.glob(os.path.join(rtsFolder, 'dediff', patientID + '*.dcm'))

        if len(dediffAssessors)>1:
            errorMessage  = patientID + ' more than one dediff assessor found - quitting'
            printMessage.append(errorMessage)
            for line in printMessage:
                print(line)
            print('\n')
            return errorMessage

        assessors = [lesionAssessors[0]]
        if len(dediffAssessors)>0:
            assessors.append(dediffAssessors[0])

        # get list of ROIs and remove any holes from masks
        rois = []

        for assessor in assessors:

            # some DICOM series have an extra coronal reformat image as part of the series that we will discard up to maxNonCompatibleInstances
            data = dataLoader(assessor, seriesFolderDict, maxNonCompatibleInstances=1)

            # don't process any legacy ROIs
            for roiName in data.seriesData['ROINames']:
                if 'legacy' in roiName:
                    errorMessage = patientID + 'Legacy ROI, terminating processing'
                    printMessage.append(errorMessage)
                    for line in printMessage:
                        print(line)
                    print('\n')
                    return errorMessage

            # special case(s)
            if patientID == 'RMH_RSRC080':
                # image data for this patient has missing slices, but have manually checked that these are not where the lesion is
                contiguousInstanceNumberCheck = False
                sliceSpacingUniformityThreshold = 0.2
            else:
                contiguousInstanceNumberCheck = True
                sliceSpacingUniformityThreshold = 0.01

            for roiName in data.seriesData['ROINames']:
                # get ROIs that are not holes
                if 'hole' not in roiName:
                    roiInfo = [roiName]
                    thisROI = data.getNamedROI(roiName, sliceSpacingUniformityThreshold=sliceSpacingUniformityThreshold, contiguousInstanceNumberCheck=contiguousInstanceNumberCheck)
                    # find any ROIs that are holes linked to the current ROI
                    for roiNameInner in data.seriesData['ROINames']:
                        if ('hole' in roiNameInner) and (roiName in roiNameInner):
                            roiInfo.append(roiNameInner)
                            thisHole = data.getNamedROI(roiNameInner)
                            thisROI['mask']['array'] = np.logical_and(thisROI['mask']['array'], np.logical_not(thisHole['mask']['array']))
                    rois.append(thisROI)
                    printMessage.append(roiInfo)

        # format title string
        titleStr = os.path.split(assessors[0])[1].split('__II__')
        titleStr = r'$\bf{' + titleStr[0].replace('_', '\_') + '}$   ' + '  '.join(titleStr[1:2])
        titleStr += '\n' + '  '.join([os.path.split(x)[1].split('__II__')[3] for x in assessors]) + '\n'

        # add warning to title if the lesion ROI has missing slices
        if any(['lesion' in x['ROIName'] and not x['maskContiguous'] for x in rois]):
            titleStr += r'$\bf{WARNING}$: contains volumes with missing slices'
            errorMessage = patientID + ' contains volumes with missing slices'

        # save one file per patient
        format = 'pdf'
        newFileName = os.path.join(thumbnailFolder, 'roiThumbnail__' + os.path.split(lesionAssessors[0])[1].replace('dcm', format))
        saveThumbnail(rois, newFileName, titleStr=titleStr, format=format, imageGrayLevelLimits=[-135, 215])
        printMessage.append('Written: ' + newFileName)

    except:

        printMessage.append(errorMessage)
        for line in printMessage:
            print(line)

        print('\033[1;31;48m'+'_'*50)
        traceback.print_exc(file=sys.stdout)
        print('_'*50 + '\033[0;30;48m')
        print('\n')

    if errorMessage is not None:
        printMessage.append(errorMessage)
    for line in printMessage:
        print(line)
    print('\n')

    return errorMessage

thumbnailFolder = os.path.join('/Users/morton/Dicom Files/RADSARC_R/XNAT/roiThumbnails', os.path.split(rtsFolder)[1].replace('assessors','roiThumbnailsV2'), 'subjects')
if not os.path.exists(thumbnailFolder):
    os.makedirs(thumbnailFolder)

# # single threaded for debugging
# errorMessages = []
# for patientID in patientIDs:
#     message = processOnePatient(patientID, rtsFolder, seriesFolderDict, thumbnailFolder)
#     errorMessages.append(message)

# multi-threaded for speed
errorMessages = Parallel(n_jobs=2)(delayed(processOnePatient)(patientID, rtsFolder, seriesFolderDict, thumbnailFolder) for patientID in patientIDs)

for errorMessage in errorMessages:
    if errorMessage is not None:
        print(errorMessage)