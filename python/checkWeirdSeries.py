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
project["assessorStyle"] = {"type": "AIM", "format": "DCM"}
project["roiObjectLabelFilter"] = ''
project["paramFileName"] = '/Users/morton/Dicom Files/RADSARC_R/Params.yaml'
project["outputPath"] = os.path.join(project["inputPath"], 'roiThumbnails')

assessors = glob.glob(os.path.join(project["inputPath"],'assessors', 'assessors_2022.07.20_09.51.14', 'lesion', '*.dcm'))
assessors.sort()

thumbnailFiles = []
warningMessages = []

for n, assessor in enumerate(assessors):
    patientScanInfo = os.path.split(assessor)[1].split('__II__')[0:2]
    patientScanFolder = os.path.join(project["inputPath"], 'referencedScans', patientScanInfo[0]+'__II__'+patientScanInfo[1])
    if not os.path.exists(patientScanFolder):
        raise Exception("Scan folder not found!")
    try:
        _, _, instanceNumDict, sopInst2instanceNumberDict, sopInstDictWarningMessages = getSopInstDict(patientScanFolder)
        print('OK  ' + patientScanFolder)
    except:
        print('BAD ' + patientScanFolder)