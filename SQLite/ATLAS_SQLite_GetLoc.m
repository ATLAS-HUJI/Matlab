%function to extract all relevant information from ATLAS SQLite file with or
%without covariance matrices. Returns NaN if covariance matrices are unavailable.
%code by Ingo Schiffner
function [TAG,TIME,X,Y,VARX,VARY,COVXY] = ATLAS_SQLite_GetLoc(fname)
    conn = sqlite(fname,'readonly');
    %get time and position from database
    TAG = cell2mat(fetch (conn, 'SELECT TAG FROM LOCALIZATIONS ORDER BY TIME'));
    TIME = cell2mat(fetch (conn, 'SELECT TIME FROM LOCALIZATIONS ORDER BY TIME'));
    X = cell2mat(fetch(conn,'SELECT X FROM LOCALIZATIONS ORDER BY TIME'));
    Y = cell2mat(fetch(conn,'SELECT Y FROM LOCALIZATIONS ORDER BY TIME'));
    %try to get covariance matrix from database
    try
        VARX = cell2mat(fetch (conn, 'SELECT VARX FROM LOCALIZATIONS ORDER BY TIME'));
        VARY = cell2mat(fetch (conn, 'SELECT VARY FROM LOCALIZATIONS ORDER BY TIME'));
        COVXY = cell2mat(fetch (conn, 'SELECT COVXY FROM LOCALIZATIONS ORDER BY TIME'));
    catch
        VARX = NaN;
        VARY = NaN;
        COVXY = NaN;
    end
    close(conn);
end
