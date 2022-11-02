import glob, os, pydicom
import pandas as pd

patientFolders = glob.glob('/Users/morton/Dicom Files/RADSARC_R/XNAT/referencedScans/RMH*')
patientFolders.sort()
patientFolders = [x for x in patientFolders if 'pickle' not in x]

tags = ['InstanceCreationDate', 'ContentDate', 'SeriesDate', 'StudyDate', 'AcquisitionDate', 'PerformedProcedureStepStartDate']

cols = ['PatientID']
for tag in tags:
    cols.append(tag)
cols.append('uniqueCount')
cols.append('uniqueCount2')
df = pd.DataFrame(columns=cols)

for n, patientFolder in enumerate(patientFolders):
    thisFolderSearch = os.path.join(patientFolder, '**/*.dcm')
    dcmFiles = glob.glob(thisFolderSearch, recursive=True)
    dcm = pydicom.read_file(dcmFiles[0])
    df.loc[n,'PatientID'] = thisFolderSearch.split('/')[7].split('__II__')[0]
    for tag in tags:
        if hasattr(dcm, tag):
            df.loc[n,tag] = getattr(dcm, tag)
        else:
            df.loc[n, tag] = ''
    df.loc[n,'uniqueCount'] = len(set(df.iloc[n,1:7]) - set(['']))
    df.loc[n,'uniqueCount2'] = len(set(df.iloc[n,2:7]) - set(['']))

df2 = df[df.uniqueCount>1].copy()

dfSimple = df[['PatientID','InstanceCreationDate','StudyDate']].copy()
dfSimple['Pattern'] = (dfSimple.InstanceCreationDate != dfSimple.StudyDate).astype(int)
dfSimple.loc[dfSimple.InstanceCreationDate=='', 'Pattern'] = int(2)


dfSimple.to_csv('/Users/morton/Dicom Files/RADSARC_R/XNAT/RMH_ScanDateInfo_FindLocal_vs_RemoteScans.csv', index=False)