function thisGUI=Bpod_GUI_StimPairing(thisGUI,thisProtocol)

    switch thisProtocol
        case 'AuditoryTuning'
            thisGUI.Repetition=20;
            thisGUI.PureTones=0;
            thisGUI.WhiteNoise=0;
        case 'VisualTuning'
            thisGUI.Repetition=20;
    end
end