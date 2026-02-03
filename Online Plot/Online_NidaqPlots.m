function [figPhoto1,figPhoto2,FigWheel]=Online_NidaqPlots(action,figPhoto1,figPhoto2,FigWheel,thisLicks)
global BpodSystem S nidaq

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
                if S.GUI.Wheel
                    FigWheel=Online_WheelPlot('ini');
                end
        end
        end

%% %%%%%%%% Demodulate and update figures %%%%%%%%%% %%
    case 'update'
sampRate=S.GUI.NidaqSamplingRate;

if S.GUI.Photometry
    %% Demodulation channel 1
    modData=nidaq.rec.ai_data(:,1);
    modFreq=S.GUI.LED1_Freq;
    modPhase=S.GUI.modPhase;
    if S.GUI.Modulation
        demodData=Online_Demodulation(modData,sampRate,modFreq,15,modPhase); % Demodulation
    else
        demodData=modData;
    end
    [demodDataTW,modDataTW]=Online_Process_Photometry(demodData,modData);

     %% Demodulation channel 1
    if S.GUI.Isobestic405 || S.GUI.DbleFibers || S.GUI.RedChannel
    modFreq=S.GUI.LED2_Freq;
    if S.GUI.Isobestic405
        modData2=nidaq.rec.ai_data(:,1);
    end
    if xor(S.GUI.RedChannel,S.GUI.DbleFibers)
        modData2=nidaq.rec.ai_data(:,2);
    end
    if and(S.GUI.RedChannel,S.GUI.DbleFibers)
        modData2=nidaq.rec.ai_data(:,3);
    end

    if S.GUI.Modulation
        demodData2=Online_Demodulation(modData2,sampRate,modFreq,15,modPhase);
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
            if S.GUI.Wheel
                FigWheel=Online_WheelPlot('update',FigWheel,BpodSystem.Data.NidaqWheelData{end},S.Names.StateToZero{S.GUI.StateToZero},thisLicks);
            end
    end
    
end
end
end