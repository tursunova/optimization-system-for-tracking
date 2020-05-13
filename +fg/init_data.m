function d = init_data(problem, opt_pars)
    d.q = problem.dim;
    d.mu = problem.mu;
    d.L = problem.L;
    d.Y = problem.gf;
    
    init_point = 7*ones(d.q, 1);
    init_point([2:2:end]) = 3;
    
    d.theta_n = init_point;   
    
    d.h = opt_pars.h;
    
    d.H = d.h - d.h^2*d.L/2;
    d.gamma_n = 2.0; 
    d.v_n = d.theta_n;
    
end