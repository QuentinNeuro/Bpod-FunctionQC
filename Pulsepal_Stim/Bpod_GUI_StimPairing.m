function thisGUI=Bpod_GUI_StimPairing(thisGUI,thisProtocol)

    switch thisProtocol
        case 'AuditoryTuning'
            thisGUI.Repetition=50;
            thisGUI.PureTones=0;
            thisGUI.WhiteNoise=0;
        case 'VisualTuning'
            thisGUI.Repetition=50;
    end
end