import sys, os, shutil
sys.path.append('/Users/morton/Documents/GitHub/icrpythonradiomics')
import glob
import pandas as pd
import numpy as np
import pydicom

patFolders = glob.glob('/Users/morton/Dicom Files/RADSARC_R/XNAT/referencedScans/EORTC*')
patFolders = [x for x in patFolders if 'pickle' not in x]

patientID = []
patientAge = []
for patFolder in patFolders:
    dcmFiles = glob.glob(os.path.join(patFolder, '**', '*.dcm'), recursive=True)
    dcm = pydicom.read_file(dcmFiles[0])
    patientID.append(os.path.split(patFolder)[1].split('__II__')[0])
    if hasattr(dcm,'PatientAge'):
        patientAge.append(dcm.PatientAge)
    else:
        patientAge.append('')


