%function to collect summary data from ATLAS SQLITE file
%code by Ingo Schiffner 
function [ObsStart,ObsEnd,TimeDays,TagCount,TagList] = ATLAS_SQLITE_Summary(sqlfile,obs_start,obs_end)

%retrieve data from sqlite database
[tags,time,~,~,~,~,~] = ATLAS_SQLite_GetLoc(sqlfile);

%determine time range
time_rng = max(time)-min(time);
TimeDays = time_rng/1000/60/60/24;

%get start time create time bounds
min_time = double(min(time));
start_time = (min_time+3600*3) /(24*60*60*1000) + datenum('01-jan-1970');
time_tmp = datevec(start_time,'dd-mm-yy HH:MM:SS');

if time_tmp(4) < obs_start && obs_start > obs_end
    %wind back one day for night observations
    time_tmp = datevec(addtodate(datenum(time_tmp), -1, 'day'));
end

time_tmp(4)= obs_start; %observation start
time_tmp(5)= 0;
time_tmp(6)= 0;

ObsStart = time_tmp;
time_tmp(4)= obs_end; %observation end
if obs_start > obs_end
    %advance one day for night observations
    ObsEnd = datevec(addtodate(datenum(time_tmp), +1, 'day'));
end
    
%retrieve Taglist and TagCount
[TagCount, TagList] = histcounts(categorical(tags));
end