function d = init_data(problem, opt_pars)
    d.q = problem.dim;
    d.mu = problem.mu;
    d.L = problem.L;
    d.a = problem.a*2;
    d.c = problem.c*2;
    d.b = problem.b*2;
    d.Y = problem.f_xi;
    d.beta = 0.01;
    
    init_point = 7*ones(d.q,1);
    init_point([2:2:end]) = 3;

    d.theta_n = init_point;
    
    d.h = opt_pars.h;
    d.eta = opt_pars.eta;
    d.alpha_x = opt_pars.alphax;
    
    d.H = d.h - d.h^2*d.L/2;
    d.gamma_n = 2.0; 
    d.v_n = d.theta_n;
    
    d.alpha_hist = [];
    d.gamma_hist = [];
end