% created by Arianna Zuanazzi az1864@nyu.edu (Oct 2019)
% Initialize eyelink, set parameters, calibrate participant, send trigger
% to eyelink and message to researcher for relevant events, clean up

%% set whether eyedata should be recorded
eye.record_eye = 1; %want to record eyemovements?

%% ---- general parameters ----
%eye.screennumber = max(Screen('Screens')); %selects the screen number  
%stim.gray = %defines colour of background
%stim.white = %defines colour of instructions
%SubjectNumber = %number of subject for data saving
%ntrials = 100;
%----------------------------

%% Initialize eyetracker
if eye.record_eye == 1
        
%Settings
windowPtr=Screen('OpenWindow', eye.screennumber); %select screen for calibration
%display instructions for calibration
Screen(windowPtr, 'FillRect', stim.gray); 
DrawFormattedText(windowPtr, sprintf('%s', 'Eyetracking calibration: follow the dots with your eyes!'), 'center', 'center', stim.white);
Screen('Flip', windowPtr);
%eyetracking settings
eye.el = EyelinkInitDefaults(windowPtr);
WaitSecs(5); %wait before calibration
Screen('Close');

%Initialization of the connection with the eyetracker.
eye.online = EyelinkInit(0, 1);
if ~eye.online
   error('Eyelink Init aborted.\n');
   %cleanup routine: Shutdown Eyelink:
   Eyelink('Shutdown');
   eye.online = 0;
return;
end

%Calibrate the eyetracker
EyelinkDoTrackerSetup(eye.el);
    
%edf link
eye.edfFile = sprintf('%s.edf', num2str(SubjectNumber));
res = Eyelink('Openfile', eye.edfFile);
Eyelink('Command', 'add_file_preamble_text = "Experiment recording of participant %s', num2str(SubjectNumber));
if res~=0
   fprintf('Cannot create EDF file ''%s'' ', eye.edfFile);
   % Cleanup routine:Shutdown Eyelink
   Eyelink('Shutdown');
   eye.online = 0;
return;
end
    
%Make sure we're still connected.
if Eyelink('IsConnected')~=1
return;
end
    
%Eyetracker settings
%Use conservative online saccade detection (cognitive setting)
Eyelink('Command', 'recording_parse_type = GAZE');
Eyelink('Command', 'saccade_velocity_threshold = 30');
Eyelink('Command', 'saccade_acceleration_threshold = 9500');
Eyelink('Command', 'saccade_motion_threshold = 0.1');
Eyelink('Command', 'saccade_pursuit_fixup = 60');
Eyelink('Command', 'fixation_update_interval = 0');

%Other tracker configurations
Eyelink('Command', 'calibration_type = HV5');
Eyelink('Command', 'generate_default_targets = YES');
Eyelink('Command', 'enable_automatic_calibration = YES');
Eyelink('Command', 'automatic_calibration_pacing = 1000');
Eyelink('Command', 'screen_pixel_coords = 0 0 585 585'); %%% This has to be changed based on the size of the current screen
Eyelink('Command', 'binocular_enabled = NO');
Eyelink('Command', 'use_ellipse_fitter = NO');
Eyelink('Command', 'sample_rate = 2000');
Eyelink('Command', 'elcl_tt_power = %d', 3); % illumination, 1 = 100%, 2 = 75%, 3 = 50%

%Set edf data (what we want to save)
Eyelink('Command', 'file_event_filter = LEFT,FIXATION,SACCADE,BLINK,MESSAGE,INPUT');
Eyelink('Command', 'file_sample_data  = LEFT,GAZE,GAZERES,HREF,PUPIL,AREA,STATUS,INPUT');

%Set link data (can be used to react to events online)
Eyelink('Command', 'link_event_filter = LEFT,FIXATION,SACCADE,BLINK,MESSAGE,FIXUPDATE,INPUT');
Eyelink('Command', 'link_sample_data  = LEFT,GAZE,GAZERES,HREF,PUPIL,AREA,STATUS,INPUT');

%Starts recording and sends message to experimenter on eyelink monitor
Eyelink('Command', 'record_status_message "Start recording"');
Eyelink('Message', 'START RECORDING...');
Eyelink('StartRecording', [], [], [], 1);

end

%% Task
%Trigger to eyelink to start task

if eye.record_eye == 1
   Eyelink('Command', 'record_status_message "Task starts..."'); %message to experimenter
   Eyelink('Message', 'STARTTASK'); %codes for beginning of the task
end

% ---- task ----
for i = 1:ntrials
    
%for each trial
if eye.record_eye == 1
   Eyelink('Command', 'record_status_message "Trial n.%d"', i); %message to experimenter
   Eyelink('Message', 'TRIAL %d', i); %codes for beginning of the task
end

% trial

end

%---------------

%Trigger to eyelink to end task
if eye.record_eye == 1
   Eyelink('Command', 'record_status_message "Task ends..."'); %message to experimenter
   Eyelink('Message', 'ENDTASK'); %codes for end of the task
end

%% Cleanup

%Quit eyelink
if eye.record_eye == 1
   if eye.online      
   %Stop writing to edf
   disp('Stop Eyelink recording...')
   Eyelink('Command', 'set_idle_mode');  
   WaitSecs(0.5);
   Eyelink('CloseFile'); 
        
   %Shut down connection
   Eyelink('Shutdown'); 
   end
end