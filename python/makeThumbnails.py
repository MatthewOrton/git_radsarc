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

project = {}
project["projectStr"] = 'RADSARC-R'
project["inputPath"] = '/Users/morton/Dicom Files/RADSARC_R/XNAT'
project["assessorStyle"] = {"type": "AIM", "format": "DCM"}
project["roiObjectLabelFilter"] = ''
project["paramFileName"] = '/Users/morton/Dicom Files/RADSARC_R/Params.yaml'
project["outputPath"] = project["inputPath"]

sopInstDict, _, _, _ = getSopInstDict(os.path.join(project["inputPath"],'referencedScans'))

assessors = glob.glob(os.path.join(project["inputPath"],'assessors', '*.dcm'))
assessors.sort()
assessors = [assessors[5]]
thumbnailFiles = []

for n, assessor in enumerate(assessors):
    try:
        patientScanInfo = os.path.split(assessor)[1].split('__II__')[0:2]
        patientScanFolder = os.path.join(project["inputPath"], 'referencedScans', patientScanInfo[0]+'__II__'+patientScanInfo[1])
        if not os.path.exists(patientScanFolder):
            raise Exception("Scan folder not found!")

        _, _, instanceNumDict, sopInst2instanceNumberDict = getSopInstDict(patientScanFolder)
        extraDictionaries = {'instanceNumDict':instanceNumDict, 'sopInst2instanceNumberDict':sopInst2instanceNumberDict}

        radAn = radiomicAnalyser(project, assessor, sopInstDict=sopInstDict, extraDictionaries=extraDictionaries) #, roiShift=[-1, -1])

        # find all ROIs with names matching roiObjectLabelFilter
        rtsDcm = pydicom.dcmread(assessor)
        # separate lists with and without 'hole' in the name
        roiNames = []
        roiHoleNames = []
        for roiItem in rtsDcm.StructureSetROISequence._list:
            if project['roiObjectLabelFilter'] in roiItem.ROIName:
                if 'hole' in roiItem.ROIName:
                    roiHoleNames.append(roiItem.ROIName)
                else:
                    roiNames.append(roiItem.ROIName)

        # loop over roiNames (these are the ones without '_hole' in the name)
        for roiName in roiNames:

            radAn.roiObjectLabelFilter = '^' + roiName + '((?!(-|_)hole).)*$'  # this filter ensures the radiomicAnalyser will only select the ROI that matches roiName without the subscript '_hole' or '-hole'
            radAn.loadImageData(includeExtraTopAndBottomSlices=True)
            radAn.createMask()

            # grab lesion mask and contours for later
            maskLesion = copy.deepcopy(radAn.mask)
            contoursLesion = copy.deepcopy(radAn.contours)
            # see if there are any ROIs for holes
            roiHoleNamesLower = [x.lower() for x in roiHoleNames]    # sometimes the capitalisation is not consistent
            indHoleRoi = [i for i, x in enumerate([roiName.lower() in x for x in roiHoleNamesLower]) if x]
            if len(indHoleRoi)>1:
                raise Exception('More than one "hole" ROI matching ROI: '+roiName)

            if len(indHoleRoi)==1:
                radAn.roiObjectLabelFilter = roiHoleNames[indHoleRoi[0]]
                radAn.roiObjectLabelFilter = roiHoleNames[indHoleRoi[0]]
                # this is not an ideal way to do this, but we will change roiObjectLabelFound to be the one we want
                radAn.roiObjectLabelFound =  roiHoleNames[indHoleRoi[0]]
                radAn.createMask()
                # grab mask and contours
                maskHole = copy.deepcopy(radAn.mask)
                contoursHole = copy.deepcopy(radAn.contours)
                radAn.mask = maskLesion
                radAn.removeFromMask(maskHole)
                radAn.contours = contoursLesion
                radAn.contoursDelete = contoursHole

            showMaskBoundary = True
            showContours = False
            showMaskHolesWithNewColour = False
            vmin = -135
            vmax = 215
            thumbnail = radAn.saveThumbnail(vmin=vmin, vmax=vmax, showMaskBoundary=showMaskBoundary, showContours = showContours, showHistogram=False, linewidth=0.04, showMaskHolesWithNewColour=showMaskHolesWithNewColour) #, pathStr='roiThumbnailsNew')
            thumbnailFiles.append(thumbnail["fileName"])

    except:
        print('\033[1;31;48m'+'_'*50)
        traceback.print_exc(file=sys.stdout)
        print('_'*50 + '\033[0;30;48m')

# # combine thumbnail pdfs into one doc
# if len(thumbnailFiles) > 0:
#     thumbnailFiles.sort()
#     n = 0
#     m = 0
#     while n<len(thumbnailFiles):
#         if m==0:
#             startID = os.path.split(thumbnailFiles[n])[1].split('_')[5]
#             merger = PdfFileMerger()
#
#         merger.append(thumbnailFiles[n])
#
#         thisPatientName = os.path.split(thumbnailFiles[n])[1].split('__II__')[0]
#         isLastFile = n == (len(thumbnailFiles)-1)
#         if isLastFile or (m>=9 and thisPatientName != os.path.split(thumbnailFiles[n + 1])[1].split('__II__')[0]): # 39
#             endID = os.path.split(thumbnailFiles[n])[1].split('_')[5]
#             #combinedFile = os.path.join(project["outputPath"], 'roiThumbnails', 'roiThumbnails_' + startID + '-' + endID + '.pdf')
#             combinedFile = os.path.join('/Users/morton/Dicom Files/BRC_GCT/XNAT', 'roiThumbnails', 'roiThumbnails_' + startID + '-' + endID + '.pdf')
#             merger.write(combinedFile)
#             merger.close()
#             m = -1
#         n += 1
#         m += 1


