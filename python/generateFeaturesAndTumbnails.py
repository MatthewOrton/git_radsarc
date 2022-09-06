import sys
sys.path.append('/Users/morton/Documents/GitHub/icrpythonradiomics')

import os, glob
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
project["outputPath"] = os.path.join(project["inputPath"], 'roiThumbnails')

project["outputPath"] = os.path.join(project["inputPath"], 'extractions', 'extractions__' + strftime("%Y%m%d_%H%M", localtime()))

thumbnailPathStr = 'roiThumbnails'

assessors = glob.glob(os.path.join(project["inputPath"],'assessors', 'assessors_SEG_2022.09.02_00.02.25', '*.dcm'))
assessors.sort()

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

        # computation order is important:
        #       calcification first as we don't use any resampling and only compute shape/first-order features
        #       lesion last as this ROI always exists and the call to computeRadiomicsFeatures sets certain variables

        computeCalcification = False
        if computeCalcification:
            radAn.paramFileName = calcificationParamFile
            radAn.roiObjectLabelFilter = 'calcification'
            warningMessage = radAn.loadImageData(includeContiguousEmptySlices=True)
            radAn.createMask()
            if np.sum(radAn.mask)>0:
                radAn.computeRadiomicFeatures(featureKeyPrefixStr='calcification_')

        # set to the standard parameter file
        radAn.paramFileName = standardParamFile

        for subRegion in ['lesion']: #'high','mid','low',

            radAn.roiObjectLabelFilter = subRegion
            warningMessage = radAn.loadImageData(includeContiguousEmptySlices=True)
            radAn.createMask()

            if np.sum(radAn.mask)>0:

                if saveThumbnails:
                    showMaskBoundary = True
                    showContours = False
                    showMaskHolesWithNewColour = True
                    vmin = -135
                    vmax = 215
                    thumbnail = radAn.saveThumbnail(vmin=vmin, vmax=vmax, showMaskBoundary=showMaskBoundary, showHistogram=False, linewidth=0.04, pathStr=thumbnailPathStr, warningMessage=sopInstDictWarning)
                    thumbnailFiles.append(thumbnail["fileName"])

                featurePrefixStr = subRegion


                for spacing in [2.5]: #[1, 2.5, 5, 10]
                    radAn.computeRadiomicFeatures(resampledPixelSpacing=[spacing, spacing, spacing], featureKeyPrefixStr=featurePrefixStr + '_spacing' + str(spacing) + '_')
                                                  # binWidthOverRide=None, binCountOverRide=None, binEdgesOverRide=None,
                                                  # gldm_aOverRide=None, distancesOverRide=None,
                                                  # computeEntropyOfCounts=False

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
