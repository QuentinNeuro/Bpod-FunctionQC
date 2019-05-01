function figData=Online_NidaqPlot(action,phototitle,figData,newData470,nidaqRaw)
global BpodSystem S
%% general ploting parameters
labelx='Time (sec)'; labely='DF/F'; 
minx=S.GUI.TimeMin; maxx=S.GUI.TimeMax;  xstep=1;    xtickvalues=minx:xstep:maxx;
miny=S.GUI.NidaqMin; maxy=S.GUI.NidaqMax;
MeanThickness=2;
nbOfTrialTypes=size(S.trialsMatrix,1);
nbOfPlotRows=1+ceil(nbOfTrialTypes/2);

switch action
    case 'ini'
%% Close pre-existing plot and test parameters
figtitle=sprintf('Photometry %s',phototitle);
try
    close(figtitle)
end

%% Create Figure
ScrSze=get(0,'ScreenSize');
FigSze=[ScrSze(3)*1/3 ScrSze(2)+40 ScrSze(3)*1/3 ScrSze(4)-120];
figPlot=figure('Name',figtitle,'Position',FigSze, 'numbertitle','off');
hold on
ProtoSummary=sprintf('%s : %s -- %s - %s',...
    date, BpodSystem.GUIData.SubjectName, ...
    BpodSystem.GUIData.ProtocolName, S.Names.Phase{S.GUI.Phase});
ProtoLegend=uicontrol('style','text');
set(ProtoLegend,'String',ProtoSummary); 
set(ProtoLegend,'Position',[10,1,400,20]);

%% Current Nidaq plot
lastsubplot=subplot(nbOfPlotRows,2,[1 2]);
hold on
title('Nidaq recording');
xlabel(labelx); ylabel('Voltage');
ylim auto;
set(lastsubplot,'XLim',[minx maxx],'XTick',xtickvalues);%'YLim',[miny maxy]
lastplotRaw=plot([-5 5],[0 0],'-k');
lastplot470=plot([-5 5],[0 0],'-g','LineWidth',MeanThickness);
hold off

%% Plot previous recordings
subplotTitles=S.TrialsNames;
for i=1:nbOfTrialTypes
    subplotTitles{i}=sprintf('%s - cue # %.0d',subplotTitles{i},S.TrialsMatrix(i,3));
end
%Subplot
for i=1:nbOfTrialTypes
    photosubplot(i)=subplot(nbOfPlotRows,2,i+2);
    hold on
    title(subplotTitles(i));
    ylim auto;
    set(photosubplot(i),'XLim',[minx maxx],'XTick',xtickvalues,'YLim',[miny maxy]);
    singleplot(i)=plot([-5 5],[0 0],'-k');
    rewplot(i)=plot([0 0],[-1,1],'-b');
    meanplot(i)=plot([-5 5],[0 0],'-r');
    hold off
end
%Making plot pretty
for i=1:2:nbOfTrialTypes
    set(photosubplot(i),'YLabel',labely);
end
set(photosubplot(end-1),'XLabel',labelx,'YLabel',labely);
set(photosubplot(end),'YLabel',labely);
%Save the figure properties
figData.fig=figPlot;
figData.lastsubplot=lastsubplot;
figData.lastplotRaw=lastplotRaw;
figData.lastplot470=lastplot470;
figData.photosubplot=photosubplot;
figData.singleplot=singleplot;
figData.meanplot=meanplot;
    case 'update'
currentTrialType=BpodSystem.Data.TrialTypes(end);
%% Update last recording plot
set(figData.lastplotRaw, 'Xdata',nidaqRaw(:,1),'YData',nidaqRaw(:,2));
set(figData.lastplot470, 'Xdata',newData470(:,1),'YData',newData470(:,2));
%% Add new trials
singledataX=get(figData.singleplot(currentTrialType),'Xdata');
singledataY=get(figData.singleplot(currentTrialType),'Ydata');
if size(singledataX,1)==1
    singledataX=newData470(:,1);
    singledataY=newData470(:,3);
else
    singledataX=[singledataX newData470(:,1)];
    singledataY=[singledataY newData470(:,3)];
end
set(figData.singleplot(currentTrialType), 'Xdata',singledataX,'YData',singledataY,'-k');
%% Compute new mean trace
meanData=mean(singledataY,2);
set(figData.meanplot(currentTrialType), 'Xdata',newData470(:,1),'YData',meanData,'LineWidth',MeanThickness);
uistack(figData.meanplot(currentTrialType), 'top');
%% Update GUI plot parameters
for i=1:nbOfTrialTypes
set(figData.photosubplot(i),'XLim',[minx maxx],'XTick',xtickvalues,'YLim',[miny maxy])
end
end
end