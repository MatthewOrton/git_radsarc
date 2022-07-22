clear all
close all


matFiles = dir('/Users/morton/Dicom Files/RADSARC_R/XNAT/subsegmentationAnalysis/outputs_20220621_0108_withCorrections/mat/*.mat');

fig1 = figure('position',[1    76  2560  1261]) %, 'Visible', 'off');
fig2 = figure('position',[1    76  2560  1261]) %, 'Visible', 'off');

x = linspace(-200,500,500);


CO = get(gca,'ColorOrder');

bandWidth = [2 2 2 10];

for n = 1:length(matFiles)

    patID = strsplit(matFiles(n).name,'__II__');
    patID = strrep(patID{1}, 'RMH_RSRC', '');

    load(fullfile(matFiles(n).folder, matFiles(n).name)); 
    for m = 1:4
        if nnz(masks(:,:,:,m))>10
            y{m} = nnz(masks(:,:,:,m))*ksdensity(im(masks(:,:,:,m)), x, 'Bandwidth', bandWidth(m));
        else
            y{m} = NaN(size(x));
        end
    end

    for m = 1:3
        pixels = im(masks(:,:,:,m));
        meanStats(m,n) = mean(pixels);
        stdStats(m,n) = std(pixels);
    end


    set(0, 'CurrentFigure', fig1)

    subplot(5,1,1)
    for m = 1:4
        plot(x, y{m}/sum(y{m}), 'color', CO(m,:))
        hold on
    end
    
    for m = 1:4
        subplot(5,1,m+1)
        plot(x, y{m}/sum(y{m}), 'color', CO(m,:))
        [~,idx] = max(y{m});
        hold on
        text(x(idx), y{m}(idx), patID, 'HorizontalAlignment','center', 'VerticalAlignment','middle')
    end

    set(0, 'CurrentFigure', fig2)

    subplot(7,9,n)
    titleStr = [patID ':  '];
    for m = 1:4
        plot(x, y{m}/max(y{m}), 'color', CO(m,:))
        [~,idx] = max(y{m});
        titleStr = [titleStr num2str(nnz(masks(:,:,:,m))/nnz(masks), 2) ',  '];
        xlim([-150 200])
        hold on
    end
    title([titleStr num2str(nnz(masks(:,:,:,m)))])


    drawnow
end

set(fig1, 'Visible', 'on')
set(fig2, 'Visible', 'on')