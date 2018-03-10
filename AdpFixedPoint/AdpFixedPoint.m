%AdpFixedPoint is a function to perform track segmentation utilizing a 
%first-passage algorithm to determine fixed points were the agent/animal 
%has spent a minimum number of observations (obs_min) within a a certain 
%range (adp_rng) of a fixed point that is continuously reavaluated.
%Input:
%time: absolute time e.g. in ms (ATLAS timestamp) 
%x,y: projected latitude and longitude in meters
%adp_rng: adaptive range defining fixed points
%smp_rte: sampling rate e.g. in ms (ATLAS)
%obs_min: minimum nuber of observations defining a fixed position
%p_lim: point limit for leaving current fixed point
%Output:
%The function returns an array containing information about each fixed 
%point including (in order) start time, end time, duration, number of locations, 
%position quality, median x, median-y, lower x quantile, upper x quantile, lower y quantile, upper y quantile
%Code by Ingo Schiffner 2017

function [AFPList] = AdpFixedPoint(time,x,y,adp_rng,smp_rte,obs_min,p_lim)

si = find(~isnan(x),1,'first');
ei = find(~isnan(x),1,'last');
cfp = si;
cfp_i = 1;
l_cnt = 0;

%set startpoint as first point
AFPList(1,1) = time(si); %start time
AFPList(1,2) = time(si+1); %end time
AFPList(1,3) = 1; %duration
AFPList(1,4) = 2; %number of locations
AFPList(1,5) = 0; %position quality
AFPList(1,6) = x(si); %median x
AFPList(1,7) = y(si); %median-y
AFPList(1,8) = 0; %lower x quantile
AFPList(1,9) = 0; %upper x quantile
AFPList(1,10) = 0; %lower y quantile
AFPList(1,11) = 0; %upper y quantile

fp_cnt = 0; %fixed point counter

for i=si+1:ei
    
    if~isnan(x(i)) && ~isnan(y(i))
        
        %get distance from current fixed point
        x_dst = x(i) - x(cfp);
        y_dst = y(i) - y(cfp);
        e_dst = sqrt(x_dst^2 + y_dst^2);
        
        %leaving xurrent fixed point
        if e_dst > adp_rng
            %increase leaving counter 
            l_cnt = l_cnt + 1;
            if l_cnt >= p_lim
                if cfp_i >= obs_min
                    %evaluate fixed point
                    fp_cnt = fp_cnt + 1;
                    AFPList(fp_cnt,1) = cfp_t(1); %start time
                    AFPList(fp_cnt,2) = cfp_t(end); %end time
                    AFPList(fp_cnt,3) = cfp_t(end)-cfp_t(1); %duration
                    AFPList(fp_cnt,4) = cfp_i-1; %number of locations
                    AFPList(fp_cnt,5) = AFPList(fp_cnt,4)/AFPList(fp_cnt,3)/smp_rte; %position quality
                    AFPList(fp_cnt,6) = median(cfp_x); %median x
                    AFPList(fp_cnt,7) = median(cfp_y); %median-y
                    AFPList(fp_cnt,8) = AFPList(fp_cnt,6)-quantile(cfp_x,0.25); %lower x quantile
                    AFPList(fp_cnt,9) = quantile(cfp_x,0.75)-AFPList(fp_cnt,6); %upper x quantile
                    AFPList(fp_cnt,10) = AFPList(fp_cnt,7)-quantile(cfp_y,0.25); %lower y quantile
                    AFPList(fp_cnt,11) = quantile(cfp_y,0.75)-AFPList(fp_cnt,7); %upper y quantile
                end
                %set new fixed point
                cfp = i;
                cfp_i =1;
                
                %reset temp data
                clear cfp_x cfp_y cfp_t
                
            end
        else
            
            %add data to tmp fixed point list
            cfp_x(cfp_i) = x(i);
            cfp_y(cfp_i) = y(i);
            cfp_t(cfp_i) = time(i);
            cfp_i = cfp_i +1;
            
            %reset leaving counter
            l_cnt = 0;
            
        end
    end
end

%set end point
fp_cnt = fp_cnt + 1;
AFPList(fp_cnt,1) = time(ei-1); %start time
AFPList(fp_cnt,2) = time(ei); %end time
AFPList(fp_cnt,3) = 1; %duration
AFPList(fp_cnt,4) = 2; %number of locations
AFPList(fp_cnt,5) = 0; %position quality
AFPList(fp_cnt,6) = x(ei); %median x
AFPList(fp_cnt,7) = y(ei); %median-y
AFPList(fp_cnt,8) = 0; %lower x quantile
AFPList(fp_cnt,9) = 0; %upper x quantile
AFPList(fp_cnt,10) = 0; %lower y quantile
AFPList(fp_cnt,11) = 0; %upper y quantile

end