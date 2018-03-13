%function to extract relevant information for a specifc tag during a specific 
%time interval from ATLAS SQLite file with or without covariance matrices. 
%Returns NaN if covariance matrices are unavailable.
%code by Ingo Schiffner
function [TIME,X,Y,VARX,VARY,COVXY] = ATLAS_SQLite_GetTagTime(fname,tag,time_min,time_max)
    conn = sqlite(fname,'readonly');
    %get time and position from database
    TIME = cell2mat(fetch (conn, ['SELECT TIME FROM LOCALIZATIONS WHERE TAG = ',char(tag),' AND TIME >= ',num2str(time_min),' AND TIME <= ',num2str(time_max),' ORDER BY TIME']));
    X = cell2mat(fetch(conn,['SELECT X FROM LOCALIZATIONS WHERE TAG = ',char(tag),' AND TIME >= ',num2str(time_min),' AND TIME <= ',num2str(time_max),' ORDER BY TIME']));
    Y = cell2mat(fetch(conn,['SELECT Y FROM LOCALIZATIONS WHERE TAG = ',char(tag),' AND TIME >= ',num2str(time_min),' AND TIME <= ',num2str(time_max),' ORDER BY TIME']));
    %try to get covariance matrix from database
    try
        VARX = cell2mat(fetch (conn, ['SELECT VARX FROM LOCALIZATIONS WHERE TAG = ',char(tag),' AND TIME >= ',num2str(time_min),' AND TIME <= ',num2str(time_max),' ORDER BY TIME']));
        VARY = cell2mat(fetch (conn, ['SELECT VARY FROM LOCALIZATIONS WHERE TAG = ',char(tag),' AND TIME >= ',num2str(time_min),' AND TIME <= ',num2str(time_max),' ORDER BY TIME']));
        COVXY = cell2mat(fetch (conn, ['SELECT COVXY FROM LOCALIZATIONS WHERE TAG = ',char(tag),' AND TIME >= ',num2str(time_min),' AND TIME <= ',num2str(time_max),' ORDER BY TIME']));
    catch
        VARX = NaN;
        VARY = NaN;
        COVXY = NaN;
    end
    close(conn);
end
