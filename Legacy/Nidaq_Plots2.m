function [FigPhoto1,FigPhoto2,FigWheel]=Online_NidaqPlot(action,FigPhoto1,FigPhoto2,FigWheel,thisLicks)
global BpodSystem S

task=BpodSystem.GUIData.ProtocolName;

switch action
    case 'ini'
        FigPhoto1=[]; FigPhoto2=[]; FigWheel=[];
        if S.GUI.Photometry
        switch task
            case 'AuditoryTuning'
                    FigPhoto1=Online_AudTuningPlot('ini','AudTun1',S.TrialSequence,[],[],[],1);
                    if S.GUI.DbleFibers || S.GUI.Isobestic405 || S.GUI.RedChannel
                        FigPhoto2=Online_AudTuningPlot('ini','AudTun2',S.TrialSequence,[],[],[],2);
                    end
            otherwise
                FigPhoto1=Online_PhotoPlot2('ini','470-F1',[],[],[],1);
                if S.GUI.DbleFibers
                    FigPhoto2=Online_PhotoPlot2('ini','470-F2',[],[],[],2);
                end
                if S.GUI.Isobestic405 
                    FigPhoto2=Online_PhotoPlot2('ini','405-F1',[],[],[],2);
                end
                if S.GUI.RedChannel
                    FigPhoto2=Online_PhotoPlot2('ini','565-F1',[],[],[],2);
                end
        end
    end
if S.GUI.Wheel
    FigWheel=Online_WheelPlot('ini');
end

    case 'update'
if S.GUI.Photometry
    sampRate=S.GUI.NidaqSamplingRate;
    modData=BpodSystem.Data.NidaqData{end}(:,1); modFreq=S.GUI.LED1_Freq;
    if S.GUI.Modulation
        demodData=Online_Demodulation(modData,sampRate,modFreq); % Demodulation
    else
        demodData=modData;
    end
    [demodDataTW,modDataTW]=Online_Process_Photometry(demodData,modData);
    FigPhoto1=Online_PhotoPlot2('update',[],FigPhoto1,demodDataTW,modDataTW);
    
    if S.GUI.Isobestic405 || S.GUI.DbleFibers || S.GUI.RedChannel
        if S.GUI.Isobestic405
            modData2=BpodSystem.Data.NidaqData{end}(:,1); modFreq=S.GUI.LED2_Freq;
        elseif S.GUI.RedChannel3
            modData2=BpodSystem.Data.Nidaq2Data{end}(:,1); modFreq=S.GUI.LED2_Freq;
        elseif S.GUI.DbleFibers
            modData2=BpodSystem.Data.Nidaq2Data{end}(:,1); modFreq=S.GUI.LED1b_Freq;
        end
        if S.GUI.Modulation
            demodData2=Online_Demodulation(modData2,sampRate,modFreq);
        else
            demodData2=modData2;
        end

        [demodDataTW2,modDataTW2]=Online_Process_Photometry(demodData2,modData2);
        FigPhoto2=Online_PhotoPlot2('update',[],FigPhoto2,demodDataTW2,modDataTW2);
    end
end

if S.GUI.Wheel
        FigWheel=Online_WheelPlot('update',FigWheel,BpodSystem.Data.NidaqWheelData{end},S.Names.StateToZero{S.GUI.StateToZero},thisLicks);
end
end