% created by Arianna Zuanazzi az1864@nyu.edu (Oct 2019)
% Connect Tobii, get data, disconnect

% ----------------Eyetracker Initialization----------------
% O_O O_O O_O O_O O_O Start eye tracker O_O O_O O_O O_O O_O 
% connect to EyeX Engine
myex('connect')
% fill eyetracker data matrix with nan
eye.trackingdata = nan(300,12,length(stim.trials_nreps));


for i = 1:ntrials % start loop of trials
    
    
% ----------------Eyetracker cleanup before recording ----
% O_O O_O O_O O_O O_O Clear buffer data O_O O_O O_O O_O O_O
myex('getdata'); %clears the buffer before recording


% ----------------Eyetracker record data -----------------
% O_O O_O O_O O_O O_O Get data for this trial O_O O_O O_O O_O O_O
currenttrialtrack = myex('getdata'); 
eye.trackingdata(1:size(currenttrialtrack,1),:,i) = currenttrialtrack; %fills the matrix with data so far, i is the number of the trial

end % end loop of trials

% ----------------Eyetracker stop ------------------------
% O_O O_O O_O O_O O_O Stop eyetracker O_O O_O O_O O_O O_O 
myex('disconnect');
     

