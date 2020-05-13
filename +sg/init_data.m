function d = init_data(problem, opt_pars)
    
    d.q = problem.dim;
    
    d.h = opt_pars.h;
    
    d.Y = problem.gf;
    
    init_point = 7*ones(d.q,1);
    init_point([2:2:end]) = 3;

    d.theta_n = init_point;
end