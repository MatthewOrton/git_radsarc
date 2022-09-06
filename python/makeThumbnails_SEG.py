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

project = {}
project["projectStr"] = 'RADSARC-R'
project["inputPath"] = '/Users/morton/Dicom Files/RADSARC_R/XNAT'
project["assessorStyle"] = {"type": "SEG", "format": "DCM"}
project["roiObjectLabelFilter"] = ''
project["paramFileName"] = '/Users/morton/Dicom Files/RADSARC_R/Params.yaml'
project["outputPath"] = os.path.join(project["inputPath"], 'roiThumbnails')

thumbnailPathStr = 'roiThumbnails_SEG_'+strftime("%Y.%m.%d_%H.%M.%S", localtime())

# sopInstDict, _, _, _, _ = getSopInstDict(os.path.join(project["inputPath"],'referencedScans'))

assessors = glob.glob(os.path.join(project["inputPath"],'assessors', 'assessors_SEG_2022.09.02_00.02.25', '*.dcm'))
assessors.sort()

thumbnailFiles = []
warningMessages = []

for n, assessor in enumerate(assessors):
    try:
        patientScanInfo = os.path.split(assessor)[1].split('__II__')[0:2]
        patientScanFolder = os.path.join(project["inputPath"], 'referencedScans', patientScanInfo[0]+'__II__'+patientScanInfo[1])
        if not os.path.exists(patientScanFolder):
            raise Exception("Scan folder not found!")

        radAn = radiomicAnalyser(project, assessor)

        sopInstDict, _, instanceNumDict, sopInst2instanceNumberDict, sopInstDictWarningMessages = getSopInstDict(patientScanFolder, reload=True)
        extraDictionaries = {'instanceNumDict':instanceNumDict, 'sopInst2instanceNumberDict':sopInst2instanceNumberDict}

        if len(sopInstDictWarningMessages)==0:
            sopInstDictWarning = ''
        if len(sopInstDictWarningMessages)==1:
            sopInstDictWarning = sopInstDictWarningMessages[0]
            warningMessages.append(sopInstDictWarning + assessor)


        radAn.sopInstDict = sopInstDict
        radAn.extraDictionaries = extraDictionaries
        for filter in ['lesion','high','mid','low']:

            radAn.roiObjectLabelFilter = filter
            warningMessage = radAn.loadImageData(includeContiguousEmptySlices=True)
            radAn.createMask()

            if np.sum(radAn.mask)>0:
                showMaskBoundary = True
                showContours = False
                showMaskHolesWithNewColour = True
                vmin = -135
                vmax = 215
                thumbnail = radAn.saveThumbnail(vmin=vmin, vmax=vmax, showMaskBoundary=showMaskBoundary, showHistogram=False, linewidth=0.04, pathStr=thumbnailPathStr, warningMessage=sopInstDictWarning)
                thumbnailFiles.append(thumbnail["fileName"])

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