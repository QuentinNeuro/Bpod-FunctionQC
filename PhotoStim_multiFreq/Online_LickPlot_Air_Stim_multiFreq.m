function figData=Online_LickPlot_Air_Stim_multiFreq(action,trialSequence,trialMatrix,subPlotTitles,Phase,figData,currentTrial,outcome,trialType,newxdata)
%figData=OnlinePlot(action,trialSequence,trialMatrix,subPlotTitles,figData,currentTrial,outcome,trialType,newxdata)
%This function initializes ("ini") or updates ("update") a figure to monitor online the trial sequence and the lick events. 
%Initialization requiers the "trialSequence" and the parameters of the trials contained in the "trialMatrix". 
%Subplots are named according to "subPlotTitles". "Phase" is used for the figure legend
%"currenTrial" and "outcome" arguments are used to update the subplot for trials
%"trialType" and "newxdata" arguments are used to update the subplot for licks
%
%"outcome" and "newxdata" arguments are generated by "Online_LickEvents" function.
%
%The output structure is used to update the plot and contains :
%figData.figPlot        :handles the figure properties
%       .trialusbplot   :handles the subplot for trial (axes)
%       .curTrialplot   :handles the current trial plot (a line)
%       .trialsplot     :handles the plots for eachtrials (data)
%       .licksubplot    :handles the subplot for lick (axes)
%       .lickplot       :handles the plot for lick (data)
%
%function written by Quentin for CuedReinforcers bpod protocol

global BpodSystem S

plotSpan=20.5;  %plotting window
MS_trial=5;     %marker size for trial
MS_licks=2;     %marker size for lick
maxy=100;       %y axe for licks
ystep=25;       %y axe for licks

minx=S.GUI.TimeMin;
maxx=S.GUI.TimeMax;
xstep=1;    xtickvalues=minx:xstep:maxx;

switch action
    case 'ini'
%%Close pre-existing plot and test parameters
if size(trialSequence,1)==1
    trialSequence=trialSequence';
end
try
    close 'Air_Light_Pairing';
end
%% Create Figure
figPlot=figure('Name','Online Air_Light_Pairing Plot','Position', [800 400 600 700], 'numbertitle','off');
hold on
ProtoSummary=sprintf('%s : %s -- %s - %s',...
    date, BpodSystem.GUIData.SubjectName, ...
    BpodSystem.GUIData.ProtocolName, Phase);
MyBox = uicontrol('style','text');
set(MyBox,'String',ProtoSummary, 'Position',[10,1,400,20]);

%% Trial plot
trialsubplot=subplot(3,2,[1 2]);
hold on

%Specify legend and axes
plot(-20,-20,'ko','MarkerSize',MS_trial); %circle legend, ie reward
plot(-20,-20,'ks','MarkerSize',MS_trial); %square legend, ie omission
plot(-20,-20,'kd','MarkerSize',MS_trial); %diamond legend, ie Large
plot(-20,-20,'ko','MarkerFaceColor','g','MarkerSize',MS_trial); %green legend, ie hit
plot(-20,-20,'ko','MarkerFaceColor','r','MarkerSize',MS_trial); %red legend, ie missed
% legend(S.Names.Symbols{S.GUI.Circle},S.Names.Symbols{S.GUI.Square},S.Names.Symbols{S.GUI.Diamond},'Hit','Missed','Location','east');
legend('boxoff');
title('Trials outcome');
xlabel('Trial Number');
set(trialsubplot,'XLim',[3-plotSpan 3+plotSpan],'YLim',[0 5],'YTick',[1 2 3 4],...
                        'YTickLabel',{'20Hz','60Hz',...
            '100Hz','Baseline'},'YTickLabelRotation', 45 );

%Generates and handles plots for each trials and a current trial plot
curTrialplot=plot([1 1],[0 4],'-b');
for i=1:size(trialSequence)
    for TrialType=1:size(trialSequence,1)
        if trialSequence(i)==TrialType
            trialsPlot(i)=plot(i,trialMatrix(TrialType,1),'LineStyle','none','marker',char(trialMatrix(TrialType,6)),'MarkerFaceColor','b', 'MarkerEdgeColor','k','MarkerSize',MS_trial);
        end
    end
end
hold off

%% Lick plot
%PlotParameters
labely='Trial number';
miny=0;                             
ytickvalues=miny:ystep:maxy;
labelx='Time from reward / cue (sec)';

%Subplot
for i=1:4
    licksubplot(i)=subplot(3,2,i+2);
    hold on
    rewplot(i)=plot([0 0],[-5,500],'-r');
    lickplot(i)=plot([0 0],[1,500],'sk','MarkerSize',MS_licks,'MarkerFaceColor','k');
    set(lickplot(i), 'XData',[],'YData',[]);
    title(subPlotTitles(i));
    xlabel(labelx); 
    ylabel(labely);
    set(licksubplot(i),'XLim',[minx maxx],'XTick',xtickvalues,'YLim',[miny maxy],'YTick',ytickvalues,'YDir', 'reverse');
end

set(licksubplot(1),'XLabel',[]);
set(licksubplot(2),'XLabel',[],'YLabel',[]);
set(licksubplot(3),'XLabel',[]);
set(licksubplot(4),'XLabel',[],'YLabel',[])
%set(licksubplot(5),'XLabel',labelx,'YLabel',labely);
% set(licksubplot(6),'YLabel',[]);

%Save the figure properties
figData.fig=figPlot;
figData.trialsubplot=trialsubplot;
figData.trialsplot=trialsPlot;
figData.curTrialplot=curTrialplot;
figData.licksubplot=licksubplot;
figData.lickplot=lickplot;

    case 'update'
%% Trial Plot
%Change color of the last trial marker according to the oucome
set(figData.trialsplot(currentTrial),'MarkerFaceColor',outcome);
%Move the current trial plot and the plotting window
set(figData.trialsubplot, 'XLim',[currentTrial-plotSpan+2 currentTrial+plotSpan+2]);
set(figData.curTrialplot,'Xdata', [currentTrial+1 currentTrial+1]);
        if trialType<=4
%% LickPlot
%Extract the previous data from the plot
previous_xdata=get(figData.lickplot(trialType),'XData'); %lick time
previous_ydata=get(figData.lickplot(trialType),'YData'); %trial number

%initialize the first raster
if isempty(previous_ydata)==1
    trialTypeCount=1; 
else
    trialTypeCount=max(previous_ydata)+1;
end 
% 
% %Update the figure with the new licking data
updated_xdata=[previous_xdata newxdata];
newydata=linspace(trialTypeCount,trialTypeCount,size(newxdata,2));
updated_ydata=[previous_ydata newydata];
set(figData.lickplot(trialType),'XData',updated_xdata,'YData',updated_ydata);
        end
% %% Update GUI plot parameters
for i=1:4       
        set(figData.licksubplot(i),'XLim',[minx maxx],'XTick',xtickvalues);
end
end
end