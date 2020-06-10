function problem = setup_problem(name, dim, f, g, L, mu, drift_scale, init_point, custom_drift, noise_scale, noise_model, noise_fun)
    problem.name = name;
    problem.dim = dim;
    
    problem.noise_scale = noise_scale;  
    problem.drift_scale = drift_scale;

    problem.L = L;
    problem.mu = mu;
    problem.d = problem.drift_scale;
    problem.a = problem.d;
    problem.b = problem.L*problem.d^2;
    problem.c = problem.L*problem.d;
    
    problem.init_point = init_point;
    
    drift_dir = randn(problem.dim, 1);            
    drift_dir = drift_dir*problem.drift_scale;
    problem.drift_dir = drift_dir;
    
    drift_dir = randn(problem.dim,1);            
    drift_dir = drift_dir*problem.drift_scale;
    vel1 = drift_dir ;
    drift_dir = randn(problem.dim,1);            
    drift_dir = drift_dir*problem.drift_scale;
    vel2 = drift_dir ;
    problem.vel1 = vel1;
    problem.vel2 = vel2;
    
    problem.f = f;
    problem.g = g;
    
    problem.gen_new_model = @(noise_model, problem)generate_new_noise_model(noise_model, noise_fun, problem);
    
    if (noise_model == "rand")
        problem.noise = randn(problem.dim,1)*problem.noise_scale;
    elseif (noise_model == "custom")
        problem.noise = noise_fun(problem.dim)*problem.noise_scale;
    end
    problem.f_xi = @(x, minpt)problem.f(x, minpt) + problem.noise;
    problem.gf = @(x, minpt)problem.g(x, minpt) + problem.noise;
    
    if (name == "nodrift")
        problem.minpt_hist = @(StepNum, problem) nodrift_minpt_hist(StepNum, problem);
    elseif (name == "linear")
        problem.minpt_hist = @(StepNum, problem) linear_minpt_hist(StepNum, problem);
    elseif (name == "nonlinear")
        problem.minpt_hist = @(StepNum, problem) nonlinear_minpt_hist(StepNum, problem);
    elseif (name == "rand")
        problem.minpt_hist = @(StepNum, problem) rand_minpt_hist(StepNum, problem);
    elseif (name == "custom")
        problem.custom_drift = custom_drift;
        problem.minpt_hist = @(StepNum, problem) custom_minpt_hist(StepNum, problem, custom_drift);
    end    
        
end


function problem = generate_new_noise_model(noise_model, noise_fun, problem)
    if (noise_model == "rand")
        problem.noise = randn(problem.dim,1)*problem.noise_scale;
    elseif (noise_model == "custom")
        problem.noise = noise_fun(problem.dim)*problem.noise_scale;
    end
    problem.f_xi = @(x, minpt)problem.f(x, minpt) + problem.noise;
    problem.gf = @(x, minpt)problem.g(x, minpt) + problem.noise;
end


function minpt_hist = custom_minpt_hist(StepNum, problem, custom_drift)

    minpt = problem.init_point;
    minpt_hist = [];
    
    for si = 1:StepNum 
        minpt_hist = [minpt_hist minpt];
        minpt = custom_drift(minpt);
    end
    
end


function minpt_hist = nodrift_minpt_hist(StepNum, problem)

    minpt = problem.init_point;
    minpt_hist = [];
    
    for si = 1:StepNum 
        minpt_hist = [minpt_hist minpt];
    end
    
end


function minpt_hist = linear_minpt_hist(StepNum, problem)
    
    minpt = problem.init_point;
    minpt_hist = [];
    
    for si = 1:StepNum 
        minpt_hist = [minpt_hist minpt];
        minpt = minpt + problem.drift_dir;
    end
    
end


function minpt_hist = rand_minpt_hist(StepNum, problem)

    minpt = problem.init_point;
    minpt_hist = [];
    
    for si = 1:StepNum 
        minpt_hist = [minpt_hist minpt];
        drift_dir = randn(problem.dim,1);
        minpt = minpt + drift_dir * problem.drift_scale;
    end
    
end


function minpt_hist = nonlinear_minpt_hist(StepNum, problem)

    ind = 0;

    minpt = problem.init_point;
    minpt_hist = [];
    
    for si = 1:StepNum 
        minpt_hist = [minpt_hist minpt];
        
        ind = mod(ind+1, 100);
        vel = 0.01*ind*problem.vel1 + (1-0.01*ind)*problem.vel2;
        minpt = minpt + vel;
    end
    
end