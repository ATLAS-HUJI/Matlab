%function to extract all relevant information for a specifc tag from ATLAS 
%SQLite file with or without covariance matrices. Returns NaN if covariance
%matrices are unavailable.
%code by Ingo Schiffner
function [TIME,X,Y,VARX,VARY,COVXY] = ATLAS_SQLite_GetTag(fname,tag)
    conn = sqlite(fname,'readonly');
    %get time and position from database
    TIME = cell2mat(fetch (conn, ['SELECT TIME FROM LOCALIZATIONS WHERE TAG = ',char(tag)]));
    X = cell2mat(fetch(conn,['SELECT X FROM LOCALIZATIONS WHERE TAG = ',char(tag)]));
    Y = cell2mat(fetch(conn,['SELECT Y FROM LOCALIZATIONS WHERE TAG = ',char(tag)]));
    %try to get covariance matrix from database
    try
        VARX = cell2mat(fetch (conn, ['SELECT VARX FROM LOCALIZATIONS WHERE TAG = ',char(tag)]));
        VARY = cell2mat(fetch (conn, ['SELECT VARY FROM LOCALIZATIONS WHERE TAG = ',char(tag)]));
        COVXY = cell2mat(fetch (conn, ['SELECT COVXY FROM LOCALIZATIONS WHERE TAG = ',char(tag)]));
    catch
        VARX = NaN;
        VARY = NaN;
        COVXY = NaN;
    end
    close(conn);
end
