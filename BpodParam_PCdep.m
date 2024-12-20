function Param=BpodParam_PCdep()

        Param.LED1_Freq=211;
        Param.LED2_Freq=531;
        Param.LED1b_Freq=531;

switch getenv('computername')
    case 'KEPECS-PHOTO01'
        Param.rig='Photometry1';
        Param.nidaqDev='Dev1';
        Param.LED1Amp=2;
        Param.LED2Amp=2.8;
        Param.LED1bAmp=2;
        Param.PPCOM='COM5';
        Param.BPPP_BNC=2;
        Param.Opto_TrialType=1;
    case 'KEPECS-PHOTO02'
        Param.rig='Photometry2';
        Param.nidaqDev='Dev2';
        Param.LED1Amp=2;
        Param.LED2Amp=2.5;
        Param.LED1bAmp=2;
        Param.PPCOM='COM6';
        Param.BPPP_BNC=2;
        Param.Opto_TrialType=2;
    case 'KEPECS-PHOTO03'
        Param.rig='Photometry3';
        Param.nidaqDev='Dev1';
        Param.LED1Amp=2;
        Param.LED2Amp=4;
        Param.LED1bAmp=2;
        Param.PPCOM='COM6';
        Param.BPPP_BNC=2;
        Param.Opto_TrialType=3;
	case 'TQ_TOP'
        Param.rig='Photometry4';
        Param.nidaqDev='Dev1';
        Param.LED1Amp=0.70;
        Param.LED2Amp=5;
        Param.LED1bAmp=2;
        Param.PPCOM='COM6';
        Param.BPPP_BNC=2;
        Param.Opto_TrialType=1;
    case 'TQ_MIDDLE'
        Param.rig='Photometry5';
        Param.nidaqDev='Dev2';
        Param.LED1Amp=0.7;
        Param.LED2Amp=5;
        Param.LED1bAmp=2;
        Param.PPCOM='COM6';
        Param.BPPP_BNC=2;
        Param.Opto_TrialType=2;
    case 'TQ_BOTTOM'
        Param.rig='Photometry6';
        Param.nidaqDev='Dev1';
        Param.LED1Amp=1.2;
        Param.LED2Amp=5;
        Param.LED1bAmp=2;
        Param.PPCOM='COM5';
        Param.BPPP_BNC=2;
        Param.Opto_TrialType=3;
    otherwise
        Param.rig='Unknown';
        Param.nidaqDev='Dev1';
        Param.LED1Amp=0;
        Param.LED2Amp=0;
        Param.LED1bAmp=0;
        Param.PPCOM='COM6';
        Param.BPPP_BNC=2;
        Param.Opto_TrialType=1;
        disp('Unrecognized computer - register possible in BpodParam_PCdep function')
end
end