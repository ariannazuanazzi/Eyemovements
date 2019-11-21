%function eyelink = asc2parsedmat

% first the .edf files need to be converted into .asc (EDF2ASC filename.edf -e in command window)

% Converts .asc file to a parsed .mat file and a header with info
% can covert both .asc with all samples or only events
% main info of events are at the end of the event

% columns:
% 1: trial number
% 2: trial stage 
% 3: event type
% 4: timestamp from beginning in ms
% 5: eye xposition / average xposition for fixation
% 6: eye yposition / average yposition for fixation
% 7: average pupil size
% 8: duration
% 9: amplitude
% 10: peak velocity

% Basic info

clc; clear all;
filename = input('current file name --> ');
current_filename = sprintf('%s%s', filename, '.asc');
varnames = {'trial' 'stage' 'info' 'event' 'timestamp' 'xposition' 'yposition' 'pupil' 'duration' 'amplitude' 'peakvel'};
infotrial = {'^ALoc*', '^VLoc*', '^Report*', '^Pressed*'};
col_header = 6; %columns in header
end_fixation = 'EFIX';
start_saccade = 'SSACC';
end_saccade = 'ESACC';
end_blink = 'EBLINK';
message = 'MSG';
start_recording = '!MODE RECORD';
trial_n = '0'; %to start

i=0; %to chage index in the loop

% Data processing 
% Opens a file, imports the data to 'c' 
    fid = fopen(current_filename); %opens the current file
    fmt=repmat('%s',1,6); %its acutally only 4 columns, but i got a buffer here
    c=textscan(fid,fmt,'delimiter','\t','collectoutput',true);
    fid=fclose(fid); %closes the file
%     clear('fid','fmt')
    items = size(c{:});
 
% Finds the first data recorded
    line_start = 1;
        while 1
            value = (c{:}{line_start,2});
%             [~, isNumeric] = str2num(value);
            start = line_start;
%             if isNumeric
            if any(regexp(value, start_recording))
                break
            else line_start = line_start+1;
            end
            
        end
line_start = line_start+1; %line start is actually the line after the start_recording message    

% Creates the data header
for hdr1 = 1:line_start-1
    for hdr2 = 1:col_header
    header{hdr1,hdr2} = (c{:}{hdr1,hdr2});
    end
end

% Creates the data matrix   
    for l = line_start:items(1) %each line
        line = l+i; %make sure you skip the line after the ESACC
        i=0;
           %check if it is a number (data) or a string (event or message)
            value = (c{:}{line,1});
            [~, isNumeric] = str2num(value);
           
                if isNumeric
                    data{line, 2} = 's';
                    data{line, 5} = str2num(c{:}{line,1});
                    data{line, 6} = str2num(c{:}{line,2});
                    data{line, 7} = str2num(c{:}{line,3});
                    data{line, 8} = str2num(c{:}{line,4});
           
                elseif ~isNumeric
                    [event_type, remain] = strtok(value);           
                        
                       % if message about trial
                        if regexp(event_type, message)
                
                               new_value = sprintf('%s %s %s %s %s', (c{:}{line,:}));
                               [msg, remain] = strtok(new_value);
                               [start_time, remain] = strtok(remain);
                               [part_of_trial, remain] = strtok(remain);
                               [trial, remain] = strtok(remain);
                               [trial_n, remain] = strtok(remain);
                                
                                %adds info about trial   
                                data{line, 1} = str2num(trial_n); 
                                if ~isempty(cell2mat(regexp(part_of_trial, infotrial, 'once')))
                                    data{line, 2} = [];
                                    data{line, 3} = part_of_trial;
                                else
                                data{line, 2} = part_of_trial;
                                end
                                data{line, 5} = str2num(start_time);
                                
                        % if fixation
                        elseif regexp(event_type, end_fixation)
                            new_value = sprintf('%s %s %s %s %s %s %s %s', (c{:}{line,:}));
                                [event_type, remain] = strtok(new_value);
                                [eye, remain] = strtok(remain);
                                [start_time, remain] = strtok(remain);
                                [end_time, remain] = strtok(remain);
                                [dur, remain] = strtok(remain);
                                [axp, remain] = strtok(remain);
                                [ayp, remain] = strtok(remain);
                                [aps, remain] = strtok(remain);
                                
                                %adds info to end of fixation
                                data{line, 1} = str2num(trial_n);
                                data{line, 4} = [event_type, eye];  
                                data{line, 5} = str2num(end_time);
                                data{line, 6} = str2num(axp);
                                data{line, 7} = str2num(ayp);
                                data{line, 8} = str2num(aps);
                                data{line, 9} = str2num(dur);
                                
                                
                        % if saccade   
                        elseif regexp(event_type, end_saccade)
                            new_value = sprintf('%s %s %s %s %s %s %s %s %s %s %s %s %s %s', (c{:}{line,:}), (c{:}{line+1,:}));
                                [event_type, remain] = strtok(new_value);
                                [eye, remain] = strtok(remain);
                                [start_time, remain] = strtok(remain);
                                [end_time, remain] = strtok(remain);
                                [dur, remain] = strtok(remain);
                                [sxp, remain] = strtok(remain);
                                [syp, remain] = strtok(remain);
                                [exp, remain] = strtok(remain);
                                [eyp, remain] = strtok(remain);
                                [ampl, remain] = strtok(remain);
                                [pv, remain] = strtok(remain);
                                  
                                % finds beginning saccade and adds info
                                s_start = line;
                                                               
                                    while 1
                                    value = (c{:}{s_start,1});
                                        [saccade, remain] = strtok(value);
                                            if regexp(saccade, start_saccade)

                                            data{s_start, 6} = str2num(sxp);
                                            data{s_start, 7} = str2num(syp);    
                                            break
                                            else s_start = s_start-1;
                                            end
                                    end
                                        
                                %adds info to end saccade 
                                data{line, 1} = str2num(trial_n);
                                data{line, 4} = [event_type, eye];  
                                data{line, 5} = str2num(end_time);
                                data{line, 6} = str2num(exp);
                                data{line, 7} = str2num(eyp);
                                data{line, 9} = str2num(dur);
                                data{line, 10} = str2num(ampl);
                                data{line, 11} = str2num(pv);
                                data(line+1, :)= {''};
                                i = 1; %make sure you skip the line after the ESACC
                        
                        % if blink          
                        elseif regexp(event_type, end_blink)
                               new_value = sprintf('%s %s %s %s %s', (c{:}{line,:}));
                               [event_type, remain] = strtok(new_value);
                               [eye, remain] = strtok(remain);
                               [start_time, remain] = strtok(remain);
                               [end_time, remain] = strtok(remain);
                               [dur, remain] = strtok(remain);
                                
                                %adds info to end blink  
                                data{line, 1} = str2num(trial_n);
                                data{line, 4} = [event_type, eye];  
                                data{line, 5} = str2num(end_time);
                                data{line, 9} = str2num(dur);
                        
                        % if message about trial
                        elseif regexp(event_type, message)
                
                               new_value = sprintf('%s %s %s %s %s', (c{:}{line,:}));
                               [msg, remain] = strtok(new_value);
                               [start_time, remain] = strtok(remain);
                               [part_of_trial, remain] = strtok(remain);
                               [trial, remain] = strtok(remain);
                               [trial_n, remain] = strtok(remain);
                                
                                %adds info about trial   
                                data{line, 1} = str2num(trial_n);  
                                if ~isempty(cell2mat(regexp(part_of_trial, infotrial, 'once')))
                                    data{line, 2} = [];
                                    data{line, 3} = part_of_trial;
                                else
                                data{line, 2} = part_of_trial;
                                end
                                data{line, 5} = str2num(start_time);
                            
                            
                            
                        else
                            
                        % allocate the rest
                                [eye, remain] = strtok(remain);
                                [time, remain] = strtok(remain);
                                
                                data{line, 1} = str2num(trial_n);
                                data{line, 4} = [event_type, eye];  
                                data{line, 5} = str2num(time);
                                data{line, 9} = remain;
                        end
                        
                end
            
           
    end

% Clean empty lines 
for empty = 1:size(data,1)
   if all(cellfun(@isempty,data(empty,:)))
       line2delete(empty,:) = empty;
   end
end
line2delete(line2delete(:)==0)=[];
data(line2delete, :) = [];


% Trasforms cell in table
dataTable = cell2table(data);
% headerTable = cell2table(header);

% assigns names
dataTable.Properties.VariableNames = varnames;

% Data saving
    %fills empty with NaN
%     empties = cellfun('isempty',data);
%     data(empties) = {NaN};
    
    eyelink.header=header;
    eyelink.data=dataTable;
       
    save(sprintf('%s%s', filename, '.mat'), 'eyelink');
    
% Clear workspace
clc; clear all;

%end




