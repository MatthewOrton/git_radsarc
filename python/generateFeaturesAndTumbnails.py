import sys
sys.path.append('/Users/morton/Documents/GitHub/icrpythonradiomics')

import os, glob, shutil, inspect
from getSopInstDict import getSopInstDict
from radiomicAnalyser import radiomicAnalyser
from subprocess import call
import sys, traceback
import pygit2
import cv2
import matplotlib.pyplot as plt
import copy
import numpy as np
from PyPDF2 import PdfFileMerger
import pydicom
import re
from time import strftime, localtime

standardParamFile = '/Users/morton/Dicom Files/RADSARC_R/ParamsStandard.yaml'
calcificationParamFile = '/Users/morton/Dicom Files/RADSARC_R/ParamsCalcification.yaml'

project = {}
project["projectStr"] = 'RADSARC-R'
project["inputPath"] = '/Users/morton/Dicom Files/RADSARC_R/XNAT'
project["assessorStyle"] = {"type": "SEG", "format": "DCM"}
project["roiObjectLabelFilter"] = ''
project["paramFileName"] = standardParamFile
project["outputPath"] = os.path.join(project["inputPath"], 'extractions', 'extractions__' + strftime("%Y%m%d_%H%M", localtime()))

# copy all code including this file - N.B. add any more local modules to list if needed
os.makedirs(os.path.join(project["outputPath"],'code'))
modulesToCopy = [getSopInstDict, radiomicAnalyser]
[shutil.copyfile(inspect.getfile(x), os.path.join(project['outputPath'], 'code', os.path.split(inspect.getfile(x))[1])) for x in modulesToCopy]
shutil.copyfile(__file__, os.path.join(project["outputPath"], 'code', os.path.split(__file__)[1]))


thumbnailPathStr = 'roiThumbnails'

# all patients
# assessors = glob.glob(os.path.join(project["inputPath"],'assessors', 'assessors_SEG_2022.09.02_00.02.25', '*.dcm'))

# repro patients
assessors = glob.glob(os.path.join(project["inputPath"],'assessors', 'assessors_SEG_2022.09.06_21.24.49', '*.dcm'))

assessors.sort()

assessors = [assessors[11]]

thumbnailFiles = []
resultsFiles = []
warningMessages = []

saveThumbnails = False

for n, assessor in enumerate(assessors):
    try:
        patientScanInfo = os.path.split(assessor)[1].split('__II__')[0:2]
        patientScanFolder = os.path.join(project["inputPath"], 'referencedScans', patientScanInfo[0]+'__II__'+patientScanInfo[1])
        if not os.path.exists(patientScanFolder):
            raise Exception("Scan folder not found!")

        sopInstDict, _, instanceNumDict, sopInst2instanceNumberDict, sopInstDictWarningMessages = getSopInstDict(patientScanFolder, reload=True)
        extraDictionaries = {'instanceNumDict':instanceNumDict, 'sopInst2instanceNumberDict':sopInst2instanceNumberDict}

        if len(sopInstDictWarningMessages)==0:
            sopInstDictWarning = ''
        if len(sopInstDictWarningMessages)==1:
            sopInstDictWarning = sopInstDictWarningMessages[0]
            warningMessages.append(sopInstDictWarning + assessor)

        radAn = radiomicAnalyser(project, assessor)
        radAn.sopInstDict = sopInstDict
        radAn.extraDictionaries = extraDictionaries

        radAn.roiObjectLabelFilter = 'lesion'
        radAn.loadImageData(includeContiguousEmptySlices=True)

        # 'lesion' should be last so that the radiomics features are computed from this
        regions = ['low enhancing', 'mid enhancing', 'high enhancing','calcification', 'vessels', 'lesion']
        masks = {}
        for region in regions:
            radAn.roiObjectLabelFilter = region
            # only one patient has 'vessels' ROI, so need to check it ROI exists first
            if len(radAn._radiomicAnalyser__getReferencedUIDs())>0:
                radAn.loadImageData(includeContiguousEmptySlices=True)
                radAn.createMask()
                masks[region] = copy.deepcopy(radAn.mask)

        # set to the standard parameter file
        radAn.paramFileName = standardParamFile

        # use all pixels
        radAn.computeRadiomicFeatures(featureKeyPrefixStr='lesion_')

        # features so we can make null dictionary when sub-region not present
        featureKeys = [key.replace('lesion_','') for key in radAn.featureVector.keys() if 'lesion_original' in key]

        # remove calcifications or vessels
        radAn.mask = np.logical_and(radAn.mask==1, np.logical_not(masks['calcification']==1)).astype(float)
        if 'vessels' in masks:
            radAn.mask = np.logical_and(radAn.mask==1, np.logical_not(masks['vessels']==1)).astype(float)
        radAn.computeRadiomicFeatures(featureKeyPrefixStr='lesion_calcificationDeleted_')

        for region in regions[0:-3]:
            radAn.mask = copy.deepcopy(masks[region])
            regionStr = region.replace(' ', '_')
            # PatientID 074 has one pixel in the low-enhancing mask and PatientID 099 has 3 pixels in the mid-enhancing mask.  If statement ensures we don't compute features for these cases.
            if np.sum(masks[region])>3:
                radAn.computeRadiomicFeatures(featureKeyPrefixStr=regionStr + '_')

                # remove the non-essential keys from this extraction.  This is because when a sub-region is not present
                # we still need to include the features in the output (but the feature values will be empty strings) so that
                # every patient has the same total list of features, irrespective of which sub-regions are present

                # get list of all keys associated with this region
                regionFeatureKeys = [key for key in radAn.featureVector.keys() if regionStr in key]
                # get the feature keys that we want to keep
                regionFeatureKeysKeep = [regionStr + '_' + x for x in featureKeys]
                regionFeatureKeysDelete = list(set(regionFeatureKeys) - set(regionFeatureKeysKeep))
                # remove the non-essential keys - the remaining keys should match what would be done with the default code below
                for key in regionFeatureKeysDelete:
                    radAn.featureVector.pop(key)

            else:
                # default, with empty strings
                for key in featureKeys:
                    radAn.featureVector[region.replace(' ','_') + '_' + key] = ''

        for region in regions[0:-2]:
            volumeFraction = np.sum(masks[region])/np.sum(masks['lesion'])
            radAn.featureVector['lesion_sarcomaFeature_' + region + 'VolumeFraction'] = volumeFraction

        resultsFiles.append(radAn.saveResult())

    except:
        print('\033[1;31;48m'+'_'*50)
        traceback.print_exc(file=sys.stdout)
        print('_'*50 + '\033[0;30;48m')


# combine thumbnail pdfs into one doc
if len(thumbnailFiles)>0:
    thumbnailFiles.sort()
    merger = PdfFileMerger()
    for pdf in thumbnailFiles:
        merger.append(pdf)
    merger.write(os.path.join(project["outputPath"], thumbnailPathStr, 'roiThumbnails.pdf'))
    merger.close()

print(' ')
print('_______________________')
print('Warning messages')
print(' ')
for warningMessage in warningMessages:
    print(warningMessage)


# combine separate .csv files into one
if len(resultsFiles)>0:
    resultsFiles.sort()
    csvList = []
    # get column headings from first file
    with open(resultsFiles[0]) as fo:
        s = fo.readlines()
        csvList.append(s[0])
    # data from each file
    for csvFile in resultsFiles:
        with open(csvFile) as fo:
            s = fo.readlines()
            csvList.append(s[1])
    # write combined .csv
    with open(os.path.join(project["outputPath"],'radiomicFeatures','radiomicFeatures.csv'), 'w') as file_handler:
        for item in csvList:
            file_handler.write("{}".format(item))
    print('')
    print('Combined results written to file '+file_handler.name)
