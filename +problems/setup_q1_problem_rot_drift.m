function problem = setup_q1_problem_rand_drift(drift_scale, sigma_v)
    problem.name = 'rotdrift';
    problem.dim = 1;
    
    if (nargin == 0)
        problem.sigma_v = 0.01;  
        problem.drift_scale = 0.1;
    else
        problem.sigma_v = sigma_v;  
        problem.drift_scale = drift_scale;
    end
    problem.sigma_d = 0; 

    problem.L = 2;
    problem.mu = 2;
    problem.d = problem.drift_scale;
    problem.a = problem.d;
    problem.b = problem.L*problem.d^2;
    problem.c = problem.L*problem.d;
    
    evals = [1:problem.dim];
    Q = diag(evals);
    
    problem.f = @(x, minpt) 0.5*(x-minpt)'*Q*(x-minpt);
    problem.f_xi = @(x, minpt) 0.5*(x-minpt)'*Q*(x-minpt) + randn*problem.sigma_v/100;
    problem.gf = @(x, minpt) Q*(x-minpt) + randn(problem.dim,1)*problem.sigma_v;
    
    problem.minpt_hist = @(StepNum, problem) generate_minpt_hist(StepNum, problem);
end

function [minpt_hist, problem] = generate_minpt_hist(StepNum, problem)

    drift_dir = randn(problem.dim,1);            
    drift_dir = drift_dir*problem.drift_scale;
    vel1 = drift_dir ;
    drift_dir = randn(problem.dim,1);            
    drift_dir = drift_dir*problem.drift_scale;
    vel2 = drift_dir ;
    ind = 0;

    minpt = zeros(problem.dim,1);
    minpt_hist = [];
    
    for si = 1:StepNum 
        minpt_hist = [minpt_hist minpt];
        
        t = ind / 100;
        vel = t*vel1 + (1-t)*vel2;
        
        minpt = minpt + vel;
        
        ind = mod(ind+1, 100);
    end
    
end