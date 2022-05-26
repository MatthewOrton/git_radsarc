clear all
close all

rootFolder = '/Users/morton/Dicom Files/RADSARC_R/XNAT';

quickLoadMap = fullfile(rootFolder, 'sopInstanceMap.mat');
if exist(quickLoadMap,'file')
    load(quickLoadMap)
else
    maps = sopInstanceMap(fullfile(rootFolder, 'referencedScans'));
    save(quickLoadMap, 'maps')
end


sourceFolder = fullfile('assessors', 'assessors_2022.04.27_20.25.16');
rtsFiles = dir(fullfile(rootFolder, sourceFolder, '*.dcm'));

thumbFolder = fullfile(rootFolder,'highLowEnhancingAnalysis',['outputs_' datestr(datetime('now'),'yyyymmdd_HHMM')]);
if ~exist(thumbFolder,'dir')
    mkdir(thumbFolder)
    mkdir(fullfile(thumbFolder,'pdf'))
    mkdir(fullfile(thumbFolder,'fig'))
    mkdir(fullfile(thumbFolder,'mat'))
end

for n = 24 %1 %:length(rtsFiles) %[15 19] %2 5
    
    try
        
        patID = strsplit(rtsFiles(n).name,'__II__');
        patID = patID{1};
        
        disp(rtsFiles(n).name)
        
        destinFolder = strrep(sourceFolder, 'assessors', 'segs');
        result = highLowEnhancingFilter(rtsFiles(n), maps.sopInstMap, sourceFolder, destinFolder);
        
        sgtitle(strrep(strrep(rtsFiles(n).name,'__II__','   '),'.dcm',''),'FontSize',18,'Interpreter','none')
        
        drawnow
        exportPdf(gcf,fullfile(thumbFolder, 'pdf', strrep(rtsFiles(n).name,'dcm','pdf')))
        saveas(gcf,fullfile(thumbFolder, 'fig', strrep(rtsFiles(n).name,'dcm','fig')))
        save(fullfile(thumbFolder, 'mat', strrep(rtsFiles(n).name,'dcm','mat')),'result')
        close

    catch
        disp(['Error : ' num2str(n) ' ' rtsFiles(n).name ])
    end
end

