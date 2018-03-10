% Implementation of the Least Squares data filter using covariance matrices
% Code by Sivan Toledo 2017

%% YOUR DATA GOES HERE
dat=load('example_locs.txt','-ascii');

%column numbers in ascii file
TIME = 2;                                   
X = 7;
Y = 8;
VARX = 15;
VARY = 19;
COVXY = 16;
%% end

%% settings and parameters
%sort data
[~,perm] = sort(dat(:,TIME));               % check data sorting
n = ceil((dat(end,TIME)-t0)/dt);            % estimate matrix dimension
dat = dat(perm,:);                          % sort data
t0 = dat(1,TIME);                           % time at t0
dt = round(min(diff(dat(:,TIME))));         % determine sample rate
imax = size(dat,1);                         % no. samples

F = [ 1 0 1 0; 0 1 0 1; 0 0 1 0; 0 0 0 1 ]; % state tranistion matrix
A = [ 1 0 0 0; 0 1 0 0 ];                   % observation matrix
SDIM = size(F,1);                           % no. state dimensions
ODIM = size(A,1);                           % no. observation dimensions
stdThreshold = 10;                          % threshold for quality estimation (m)
%% end settings and parameters

%% compile matrices
tic;
nr = SDIM*(n-1)+(size(dat,1)-1)*ODIM;       % no. rows
nc = SDIM*(n-1);                            % no. columns
G = sparse(nr,nc);                          % transition matrix
C = sparse(nr,nr);                          % covariance matrix
O = zeros(nc,1);                            % observation vector

i = 1;                                      % counter
t = t0 - dt;                                % current time
r = 1;                                      % row counter
c = 1;                                      % column counter

while 1
    t = t + dt;
    if ( abs(t - dat(i,TIME)) < 0.5 )
        t = dat(i,TIME);
        G(r:r+ODIM-1,c:c+SDIM-1) = A;
        O(r:r+ODIM-1,1) = [dat(i,X) ; dat(i,Y)];
        C(r:r+ODIM-1,r:r+ODIM-1) = [ dat(i,VARX) dat(i,COVXY) ; dat(i,COVXY) dat(i,VARY) ];
        %calculate eigen values
        ev = eig(C(r:r+ODIM-1,r:r+ODIM-1));
        if (min(ev) < 0)
            % remove covariance
            C(r,r+ODIM-1) = 0;
            C(r+ODIM-1,r) = 0;
        end
        i=i+1;
        r = r + ODIM;
    end
    
    if (i > imax) break; end
 
    G(r:r+SDIM-1,c:c+SDIM-1) = -F;
    G(r:r+SDIM-1,c+SDIM:c+2*SDIM-1) = eye(SDIM);
    O(r:r+SDIM-1,1) = zeros(SDIM,1);
    C(r:r+SDIM-1,r:r+SDIM-1) = eye(SDIM);

    r = r + SDIM;
    c = c + SDIM;
end
buildTime = toc;
%% end compile matrices 

%% solve least squares 
tic; 
% least-squares solution in the presence of known covariance
[sln,stdx,mse,S] = lscov(G,O,C);
S = (1/mse) * S;
stdx = sqrt(1/mse) * stdx;
solveTime = toc;
%% end solve least squares

%% plot results
lsx = sln(1:4:end);
lsy = sln(2:4:end);
lsstd = sqrt(stdx(1:4:end).^2 + stdx(2:4:end).^2);
good = find(lsstd<=stdThreshold);
 
close all;
figure
subplot(2,1,1);
plot(dat(:,X),dat(:,Y),'kx');
hold on;
plot(lsx(good),lsy(good),'b-');
subplot(2,1,2);
semilogy(lsstd,'-');
disp(buildTime);
disp(solveTime);
%% end plot results