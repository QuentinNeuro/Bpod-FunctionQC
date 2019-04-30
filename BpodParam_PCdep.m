function Param=BpodParam_PCdep()

switch getenv('computername')
    case 'KEPECSPHOTO-01'
        Param.rig='Photometry1';
        Param.nidaqDev='Dev1';
        Param.LED1Amp=2;
        Param.LED2Amp=2.8;
        Param.LED1bAmp=2;
    case 'KEPECSPHOTO-02'
        Param.rig='Photometry2';
        Param.nidaqDev='Dev3';
        Param.LED1Amp=2;
        Param.LED2Amp=3.9;
        Param.LED1bAmp=2;
    case 'KEPECSPHOTO-03'
        Param.rig='Photometry3';
        Param.nidaqDev='Dev1';
        Param.LED1Amp=2;
        Param.LED2Amp=5;
        Param.LED1bAmp=2;
    case 'KEPECSPHOTO-05'
        Param.rig='Photometry5';
        Param.nidaqDev='Dev4';
        Param.LED1Amp=0.7;
        Param.LED2Amp=5;
        Param.LED1bAmp=2;
    case 'KEPECSPHOTO-06'
        Param.rig='Photometry6';
        Param.nidaqDev='Dev2';
        Param.LED1Amp=0.21;
        Param.LED2Amp=5;
        Param.LED1bAmp=2;
    otherwise
        Param.rig='Unknown';
        Param.nidaqDev='Dev1';
        Param.LED1Amp=0;
        Param.LED2Amp=0;
        Param.LED1bAmp=0;
        disp('Unrecognized computer - register possible in BpodParam_PCdep function')
end
end