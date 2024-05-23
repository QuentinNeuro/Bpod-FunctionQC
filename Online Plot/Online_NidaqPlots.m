function [figPhoto1,figPhoto2,FigWheel]=Online_NidaqPlots(action,figPhoto1,figPhoto2,FigWheel,thisLicks)
global BpodSystem S

task=BpodSystem.GUIData.ProtocolName;

%% %%%%%%%% INITIALIZE THE FIGURES %%%%%%%%%% %%
switch action
    case 'ini'
        figPhoto1=[]; figPhoto2=[]; FigWheel=[];
        if S.GUI.Photometry
        switch task
            case 'AuditoryTuning'
                figPhoto1=Online_AudTuningPlot2('ini','AudTun1',[],[],1);
                if S.GUI.DbleFibers || S.GUI.Isobestic405 || S.GUI.RedChannel
                    figPhoto2=Online_AudTuningPlot2('ini','AudTun2',[],[],2);
                end
            otherwise
                figPhoto1=Online_PhotoPlot2('ini','470-F1',[],[],[],1);
                if S.GUI.DbleFibers || S.GUI.Isobestic405 || S.GUI.RedChannel
                    figPhoto2=Online_PhotoPlot2('ini','F2',[],[],[],2);
                end
        end
        end
        if S.GUI.Wheel
            FigWheel=Online_WheelPlot('ini');
        end

%% %%%%%%%% Demodulate and update figures %%%%%%%%%% %%
    case 'update'
if S.GUI.Photometry
    %% demodulate the data
    sampRate=S.GUI.NidaqSamplingRate;
    modData=BpodSystem.Data.NidaqData{end}(:,1); modFreq=S.GUI.LED1_Freq;
    Phase=0;
    if isfield(S.GUI,'Phase')
        Phase=S.GUI.Phase;
    end
    if S.GUI.Modulation
        demodData=Online_Demodulation(modData,sampRate,modFreq,15,Phase); % Demodulation
    else
        demodData=modData;
    end
    [demodDataTW,modDataTW]=Online_Process_Photometry(demodData,modData);
    if S.GUI.Isobestic405 || S.GUI.DbleFibers || S.GUI.RedChannel
        if S.GUI.Isobestic405
            modData2=BpodSystem.Data.NidaqData{end}(:,1); modFreq=S.GUI.LED2_Freq;
        elseif S.GUI.RedChannel
            modData2=BpodSystem.Data.Nidaq2Data{end}(:,1); modFreq=S.GUI.LED2_Freq;
        elseif S.GUI.DbleFibers
            modData2=BpodSystem.Data.Nidaq2Data{end}(:,1); modFreq=S.GUI.LED1b_Freq;
        end
    if S.GUI.Modulation
        demodData2=Online_Demodulation(modData2,sampRate,modFreq,15,Phase);
    else
        demodData2=modData2;
    end
        [demodDataTW2,modDataTW2]=Online_Process_Photometry(demodData2,modData2);
    end
    %% update the figure
    switch task
            case 'AuditoryTuning'
                figPhoto1=Online_AudTuningPlot2('update',[],figPhoto1,demodDataTW,1);
            if S.GUI.Isobestic405 || S.GUI.DbleFibers || S.GUI.RedChannel
                figPhoto2=Online_AudTuningPlot2('update',[],figPhoto2,demodDataTW2,2);
            end
        otherwise
                figPhoto1=Online_PhotoPlot2('update',[],figPhoto1,demodDataTW,modDataTW);
            if S.GUI.Isobestic405 || S.GUI.DbleFibers || S.GUI.RedChannel
                figPhoto2=Online_PhotoPlot2('update',[],figPhoto2,demodDataTW2,modDataTW2);
            end
    end
    
end
if S.GUI.Wheel
        FigWheel=Online_WheelPlot('update',FigWheel,BpodSystem.Data.NidaqWheelData{end},S.Names.StateToZero{S.GUI.StateToZero},thisLicks);
end

end
end