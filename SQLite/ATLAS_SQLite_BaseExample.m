%Example function to read ATLAS SQLite files
%code by Ingo Schiffner
function [] = ATLAS_SQLite_BaseExample(varargin)

%observational period - allows setting of obeservational period, example
%starts at 17.00 UTC and ends at 7.00 UTC (night active)
obs_start = 17;         % start hour of observational period
obs_end = 7;            % end hour of observational period
day_ms = 24*60*60*1000; % ms per day

%select sql file
[sql_file,sql_dir] = uigetfile('*.sqlite','Select sqlite file');
SQLFile = fullfile(sql_dir,sql_file);

%get tag list for sql file
[ObsStart,ObsEnd,TimeDays,TagCount,TagList] = ATLAS_SQLite_Summary(SQLFile,obs_start,obs_end);

%loop through every day
for i=1:TimeDays+1
    %loop through every tag
    for ii=1:TagCount
        
        %get data specific for tag and current day/night
        time_min = (datenum(ObsStart) - datenum('01-jan-1970')) * day_ms - 3600*3 + (day_ms*(i-1));
        time_max = (datenum(ObsEnd)- datenum('01-jan-1970')) * day_ms - 3600*3 + (day_ms*(i-1));
        [t,x,y,xvar,yvar,xycov] = ATLAS_SQLite_GetTagTime(SQLFile,TagList(ii),time_min,time_max);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % PUT YOUR CODE HERE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end
end