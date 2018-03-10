% Paige Saunders Kalman filter for data with known covariances
% For use/implementation see PSKF_Example.m
% Based on Paige CC, Saunders MA. Least squares estimation of discrete linear dynamic systems using orthogonal transformations. SIAM Journal on Numerical Analysis. 1977 Apr;14(2):180-93.
% Code by Sivan Toledo 2017
function estimates = PSKF(transition_matrix, transition_cov, observation_matrix, observations)

SDIM = size(transition_matrix,1);   %state dimensions
ODIM = size(observation_matrix,1);  %observed dimensions
L = invChol(transition_cov);        %doesnt do anything here
F = -L' * transition_matrix;
n = length(observations);
estimates = cell(n,1);
r = 1;
c = 1;
Bimo = zeros(SDIM,SDIM);
bimo = zeros(SDIM,1);

for i=1:n
    observation_cov = observations{i}.cov;
    if ~isnan(observation_cov(1,1))
        Ltilde = invChol( observation_cov );
        C = Ltilde' * observation_matrix;
        r = r + ODIM;

        % recursive/sparse formulation
        if i<n
            B = [ Bimo zeros(SDIM,SDIM) bimo ; C zeros(ODIM,SDIM) Ltilde'*observations{i}.y ; F L' zeros(SDIM,1) ];
            rhs_col = SDIM+SDIM+1;
        else
            B = [ Bimo bimo ; C Ltilde'*observations{i}.y ];
            rhs_col = SDIM+1;
        end 
    else
        if i<n
            B = [ Bimo zeros(SDIM,SDIM) bimo ; F L' zeros(SDIM,1) ];
            rhs_col = SDIM + SDIM+1;
        else
            B = [ Bimo bimo ];
            rhs_col = SDIM+1;
        end
    end
    
    c = c + SDIM;
    r = r + SDIM;
    
    % recursive/sparse formulation
    [~,R] = qr(B);
    estimates{i}.rhs = R(1:SDIM, rhs_col);
    estimates{i}.Rii = R(1:SDIM, 1:SDIM);
    if i<n
        bimo = R(1+SDIM:SDIM+SDIM, rhs_col);
        Bimo = R(1+SDIM:SDIM+SDIM, 1+SDIM:SDIM+SDIM);
        estimates{i}.Riipo = R(1:SDIM, 1+SDIM:SDIM+SDIM);
    end
end

n = i;

Rtildeii = estimates{n}.Rii;
for i=n:-1:1
    % compute the smoothed estimate
    rhs = estimates{i}.rhs;
    if i<n
        rhs = rhs - estimates{i}.Riipo * estimates{i+1}.estimate;  
    end
    
    s = estimates{i}.Rii \ rhs;
    estimates{i}.estimate = s;

    % Compute the covariance of the smoothed estimate
    estimates{i}.estimateCov = inv(Rtildeii' * Rtildeii);
    if i>1
        RBlockColSwap = [ estimates{i-1}.Riipo estimates{i-1}.Rii  ; Rtildeii zeros(SDIM,SDIM) ];
        % now what?
        [~,R] = qr(RBlockColSwap);
        %Rii = R(SDIM+1:SDIM+SDIM, SDIM+1:SDIM+SDIM);
        % for next iteration
        Rtildeii = R(SDIM+1:SDIM+SDIM, SDIM+1:SDIM+SDIM);
    end
end

    function L = invChol(C)
        try 
           invL = chol(C);
           L = inv(invL);
        catch e
            disp(e);
            disp('indefinite covariance matrix? using only diagonal');
            L = diag( diag(C).^-0.5 );
        end
    end

end % of main function
