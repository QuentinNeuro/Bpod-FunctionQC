function [trialsNames, trialsMatrix]=Air_Stim_multiFreq_Phase(PhaseName)

switch PhaseName
	case 'Licking_training' 
        trialsNames={'LickTraining','Light_Sound2',...
            'Sound1','Sound2'};
        trialsMatrix=[...
        %  1.type, 2.proba, 3.sound, 4.Valve,   5.Light,                       6.Marker
            1,     1,       0,       0,         0,                             double('o');...   
            2,     0,       0,       0,         0,                             double('s');...   
            3,     0,       0,       0,         0,                             double('d');...   
            4,     0,       0,       0,         0,                             double('s')];...    
    
    case 'Habituation' 
        trialsNames={'Light_Sound1','Light_Sound2',...
            'Sound1_hab','Sound2_hab'};
        trialsMatrix=[...
        %  1.type, 2.proba, 3.sound, 4.Valve,   5.Light,                6.Marker
            1,     0,       1,       2,         2,                      double('o');...   
            2,     0,       2,       0,         2,                      double('s');...   
            3,     0.5,     1,       0,         0,                      double('d');...   
            4,     0.5,     2,       0,         0,                      double('s')];...   
            
    case 'Conditioning' 
        trialsNames={'2s constant only', 'puff only', '2s constant+puff','3s_17hz_puff'};
        trialsMatrix=[...
        %  1.type, 2.proba, 3.sound, 4.Valve,   5.Light,             	6.Marker
            1,     0.2,     1,       2,         2,                      double('o');...   
            2,     0.3,     2,       0,         2,                      double('s');...   
            3,     0.2,     1,       2,         0,                      double('d');...   
            4,     0.3,     2,       0,         0,                      double('s')];...   
       
	case 'Testing' 
        trialsNames={'20Hz','60Hz',...
            '100Hz','Baseline'};
        trialsMatrix=[...
        %  1.type, 2.proba, 3.sound, 4.Valve,   5.Light,               6.Marker
            1,     0.25,       1,       0,         2,                     double('o');...   
            2,     0.25,       2,       0,         2,                     double('s');...   
            3,     0.25,       1,       0,         0,                     double('d');...   
            4,     0.25,       2,       0,         0,                     double('s')];...   
end     
end