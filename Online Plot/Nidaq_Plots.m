function [FigPhoto1,FigPhoto2,FigWheel]=Nidaq_Plots(action,FigPhoto1,FigPhoto2,FigWheel,StateToOffset,thisLicks)
global BpodSystem nidaq S

switch action
    case 'ini'
        FigPhoto1=[]; FigPhoto2=[]; FigWheel=[];
if S.GUI.Photometry
    FigPhoto1=Online_PhotoPlot('ini','470-F1',[],[],[],1);
    if S.GUI.DbleFibers
        FigPhoto2=Online_PhotoPlot('ini','470-F2',[],[],[],2);
    end
    if S.GUI.Isobestic405 
        FigPhoto2=Online_PhotoPlot('ini','405-F1',[],[],[],2);
    end
    if S.GUI.RedChannel
        FigPhoto2=Online_PhotoPlot('ini','565-F1',[],[],[],2);
    end
end
if S.GUI.Wheel
    FigWheel=Online_WheelPlot('ini');
end

    case 'update'
if S.GUI.Photometry
    [currentNidaq1, rawNidaq1]=Photometry_demod(BpodSystem.Data.NidaqData{end}(:,1),nidaq.LED1,S.GUI.LED1_Freq,S.GUI.LED1_Amp,S.Names.StateToZero{S.GUI.StateToZero});
    currentNidaq1=Online_VariableITIAVG(currentNidaq1,StateToOffset);
    FigPhoto1=Online_PhotoPlot('update',[],FigPhoto1,currentNidaq1,rawNidaq1);
    
    if S.GUI.Isobestic405 || S.GUI.DbleFibers || S.GUI.RedChannel
        if S.GUI.Isobestic405
        [currentNidaq2, rawNidaq2]=Photometry_demod(BpodSystem.Data.NidaqData{end}(:,1),nidaq.LED2,S.GUI.LED2_Freq,S.GUI.LED2_Amp,S.Names.StateToZero{S.GUI.StateToZero});
        elseif S.GUI.RedChannel
        [currentNidaq2, rawNidaq2]=Photometry_demod(BpodSystem.Data.Nidaq2Data{end}(:,1),nidaq.LED2,S.GUI.LED2_Freq,S.GUI.LED2_Amp,S.Names.StateToZero{S.GUI.StateToZero});
        elseif S.GUI.DbleFibers
        [currentNidaq2, rawNidaq2]=Photometry_demod(BpodSystem.Data.Nidaq2Data{end}(:,1),nidaq.LED2,S.GUI.LED1b_Freq,S.GUI.LED1b_Amp,S.Names.StateToZero{S.GUI.StateToZero});
        end
        currentNidaq2=Online_VariableITIAVG(currentNidaq2,StateToOffset);
        FigPhoto2=Online_PhotoPlot('update',[],FigPhoto2,currentNidaq2,rawNidaq2);
    end
end

if S.GUI.Wheel
    FigWheel=Online_WheelPlot('update',FigWheel,BpodSystem.Data.NidaqWheelData{end},S.Names.StateToZero{S.GUI.StateToZero},thisLicks);
end
end