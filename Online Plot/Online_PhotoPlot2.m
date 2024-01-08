function figData=Online_PhotoPlot2(action,phototitle,figData,demodDataTW,modDataTW,figID)
global BpodSystem S
%% general ploting parameters
labelx='Time (sec)'; labely='DF/F'; 
minx=S.GUI.TimeMin; maxx=S.GUI.TimeMax;  xstep=1;    xtickvalues=minx:xstep:maxx;
miny=S.GUI.NidaqMin; maxy=S.GUI.NidaqMax;
MeanThickness=2;
ttNb=S.NumTrialTypes;
rowP=ceil(ttNb/2)+1;

switch action
    case 'ini'
%% Close pre-existing plot and test parameters
figtitle=sprintf('Photometry %s',phototitle);
try
    close(figtitle)
end

%% Create Figure
ScrSze=get(0,'ScreenSize');
switch figID
    case 1
FigSze=[ScrSze(3)*1/3 ScrSze(2)+40 ScrSze(3)*1/3 ScrSze(4)-120];
    case 2
FigSze=[ScrSze(3)*2/3 ScrSze(2)+40 ScrSze(3)*1/3 ScrSze(4)-120];
end
figPlot=figure('Name',figtitle,'Position',FigSze, 'numbertitle','off');
hold on
try
ProtoSummary=sprintf('%s : %s -- %s - %s',...
    date, BpodSystem.GUIData.SubjectName, ...
    BpodSystem.GUIData.ProtocolName, S.Names.Phase{S.GUI.Phase});
catch
    ProtoSummary=sprintf('%s : %s -- %s - %s',...
    date, BpodSystem.GUIData.SubjectName, ...
    BpodSystem.GUIData.ProtocolName); 
end
ProtoLegend=uicontrol('style','text');
set(ProtoLegend,'String',ProtoSummary); 
set(ProtoLegend,'Position',[10,1,400,20]);

%% Current Nidaq plot
iniTW=[-5 5];
lastsubplot=subplot(rowP,2,[1 2]);
hold on
title('Nidaq recording');
xlabel(labelx); ylabel('Voltage');
ylim auto;
set(lastsubplot,'XLim',[minx maxx],'XTick',xtickvalues);%'YLim',[miny maxy]
yyaxis("left");
lastplotRaw=plot(iniTW,[0 0],'-k');
yyaxis("right");
lastplot470=plot(iniTW,[0 0],'-g','LineWidth',MeanThickness);
hold off

%% Plot previous recordings
for i=1:ttNb
    photosubplot(i)=subplot(rowP,2,i+2);
    hold on
    try
        title(S.TrialsNames{i});
        % title(sprintf('%s - cue # %.0d',S.TrialsNames{i},S.TrialsMatrix(i,3)));
    catch
        title(sprintf('TrialType %.0d',i));
    end
    ylim auto;
    set(photosubplot(i),'XLim',[minx maxx],'XTick',xtickvalues,'YLim',[miny maxy]);
	rewplot(i)=plot([0 0],[-1,1],'-b');
	meanplot(i)=plot(iniTW,[0 0],'-r');
    if mod(i,2)
        ylabel(labely);
    end
    if i>=ttNb-1
        xlabel(labelx);
    end
    hold off
end

%Save the figure properties
figData.fig=figPlot;
figData.lastsubplot=lastsubplot;
figData.lastplotRaw=lastplotRaw;
figData.lastplot470=lastplot470;
figData.photosubplot=photosubplot;
figData.meanplot=meanplot;

    case 'update'
currentTrialType=BpodSystem.Data.TrialTypes(end);
%% Update last recording plot
set(figData.lastplotRaw, 'Xdata',modDataTW(:,1),'YData',modDataTW(:,2));
set(figData.lastplot470, 'Xdata',demodDataTW(:,1),'YData',demodDataTW(:,2));

%% Compute new average trace
allData=get(figData.photosubplot(currentTrialType), 'UserData');
dataSize=size(allData,2);
allData(:,dataSize+1)=demodDataTW(:,2);
set(figData.photosubplot(currentTrialType), 'UserData', allData);
meanData=mean(allData,2);

curSubplot=figData.photosubplot(currentTrialType);
set(figData.meanplot(currentTrialType), 'Xdata',demodDataTW(:,1),'YData',meanData,'LineWidth',MeanThickness);
set(curSubplot,'NextPlot','add');
plot(demodDataTW(:,1),demodDataTW(:,2),'-k','parent',curSubplot);
uistack(figData.meanplot(currentTrialType), 'top');
hold off
%% Update GUI plot parameters
 set(figData.photosubplot(currentTrialType),'XLim',[minx maxx],'XTick',xtickvalues,'YLim',[miny maxy])
end
end