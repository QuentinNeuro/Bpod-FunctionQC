function output=Photometry_mod(amp,freq,phase,fs,duration,modulation)
%Generates a sin wave for LED amplitude modulation.

if modulation==0 || freq==0 || amp==0
    output=(amp/2)*ones(duration*fs,1);
else
dt=1/fs;
Time=0:dt:(duration-dt);
output=amp*(sin(2*pi*freq*Time+phase)+1)/2;
output=output';
end

end