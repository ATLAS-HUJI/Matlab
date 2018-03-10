% Simple implementation of the Paige Saunders Kalman filter for ATLAS data
% Code by Sivan Toledo 2017

%% YOUR DATA GOES HERE
dat=load('D:\GD\minerva_projects\kalman\locs.txt','-ascii');

%column numbers in ascii file
TIME = 2;
X = 7;
Y = 8;
VARX = 15;
VARY = 19;
COVXY = 16;
%%
%% settings and parameters

[~,perm] = sort(dat(:,TIME));               % check data sorting
dat = dat(perm,:);                          % sort data

t0 = dat(1,TIME);                           % time at t0
dt = round(min(diff(dat(:,TIME))));         % determine sample rate
imax = size(dat,1);                         % no. samples

F = [ 1 0 1 0; 0 1 0 1; 0 0 1 0; 0 0 0 1 ]; % state tranistion matrix
A = [ 1 0 0 0; 0 1 0 0 ];                   % observation matrix
SDIM = size(F,1);                           % no. state dimensions (x,y,.x,and.y)
ODIM = size(A,1);                           % no. observation dimensions (x and y)
stdThreshold = 10;                          % threshold for quality estimation (m)

%% build observation matrix
tic;                                        % performance measurement
n = ceil((dat(end,TIME)-t0)/dt);            % estimate matrix dimension
type = zeros(n,1);                          % for quality estimation
observations = cell(n,1);                   % observation matrix
j = 1;                                      % counter
i = 1;                                      % counter
t = t0 - dt;                                % current time
while 1
    t = t + dt;
    observations{j}.time = t;
    if ( abs(t - dat(i,TIME)) < 0.5 )
        t = dat(i,TIME);
        type(j) = 1; 
        observations{j}.y   = [ dat(i,X) ; dat(i,Y) ];
        observations{j}.cov = [ dat(i,VARX) dat(i,COVXY) ; dat(i,COVXY), dat(i,VARY) ];
        i = i+1;
    else
        observations{j}.y   = [ NaN ; NaN ];
        observations{j}.cov = [ NaN NaN ; NaN NaN ];        
    end
    j = j+1;
    if (i > imax) break; end
end
buildTime = toc;
%% end build observation matrix

%% kaman filter
tic;
estimates = PSKF(F, eye(SDIM), A, observations);
solveTime = toc;
%% end kalman filter

%% plot results
n = length(estimates);
kx = zeros(n,1);
ky = zeros(n,1);
stddev = zeros(n,1);
for i=1:n
    kx(i) = estimates{i}.estimate(1);
    ky(i) = estimates{i}.estimate(2);
    stddev(i) = sqrt(norm(estimates{i}.estimateCov(1:2,1:2))); % sqrt(estimates{i}.estimateCov(1,1) + estimates{i}.estimateCov(2,2));
end
presentGood = find((type==1) .* (stddev<=stdThreshold));
missingGood = find((type==0) .* (stddev<=stdThreshold));
good = find(stddev<=10); 
 
close all;
figure(2)
subplot(2,1,1);
plot(dat(:,X),dat(:,Y),'kx');
hold on;
plot(kx(good),ky(good),'b-');
plot(kx(presentGood),ky(presentGood),'g.' ...
    ,kx(missingGood),ky(missingGood),'r.' ...
    );
subplot(2,1,2);
semilogy(stddev,'-');
disp(buildTime);
disp(solveTime);
%% end plot results