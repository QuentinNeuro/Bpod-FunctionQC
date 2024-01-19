function [newtrialsNames, newtrialsMatrix]=Phase_Add_Stim(trialsNames, trialsMatrix)
% Function to update trialsMatrix parameters and trialsNames for
% stimulation using the same parameters and a probability specified in
% the GUI
%
% QC 2019

global S
%% Parameters
stimprob=S.GUI.Opto_Proba;
nbOfTrialTypes=size(trialsMatrix,1);
trialsNames=trialsNames(1:nbOfTrialTypes);
%% precheck
if size(trialsMatrix,2)==8
    disp('Already Stim information in the TrialMatrix')
    disp('Phase_Add_Stim function abort')
    newtrialsNames=trialsNames;
    newtrialsMatrix=trialsMatrix;
else
%% Double trialNames cells and add Stim suffix
    newtrialsNames=trialsNames;
for i=1:nbOfTrialTypes
    thisindex=i+nbOfTrialTypes;
    newtrialsNames{thisindex}=[trialsNames{i} 'Stim'];
end
    %% Double trialMatrix, adjust proba and add stim vector
newtrialsMatrix=[trialsMatrix ; trialsMatrix];
newnbOfTrialTypes=size(newtrialsMatrix,1);
newtrialsMatrix(:,1)=1:newnbOfTrialTypes;
newtrialsMatrix(:,2)=[trialsMatrix(:,2)*(1-stimprob) ; trialsMatrix(:,2)*stimprob];
newtrialsMatrix(:,end+1)=[zeros(nbOfTrialTypes,1);ones(nbOfTrialTypes,1)];

   %% remove trials with 0% proba
   idx0=newtrialsMatrix(:,2)>0;
   newtrialsMatrix=newtrialsMatrix(idx0,:);
   newtrialsNames=newtrialsNames(idx0);
   for i=1:size(newtrialsMatrix,1)
       newtrialsMatrix(i,1)=i;
   end
end
end
