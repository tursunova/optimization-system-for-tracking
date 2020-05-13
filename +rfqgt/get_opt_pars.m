function opt_pars = get_opt_pars(problem, StepNum, TrialNum)    

    for hit = 1:5 
        h = 1/problem.L*(hit)/5;
        for etait = 1:9
            eta = problem.mu*etait/10;
            alpha_ub = alphax_lbnd(problem.L, problem.mu, h, eta);
            for alphait = 1:9
                alphax = alpha_ub/200*alphait;    
                errs = rfqgt.make_one_exp(problem, StepNum, TrialNum, h, eta, alphax);
                costvol(hit,etait,alphait) = mean(errs);                
            end
        end
    end
    [m,ind] = min(costvol(:));
    [hit,etait,alphait] = ind2sub(size(costvol), ind);
    h = 1/problem.L*(hit)/5;    
    eta = problem.mu*etait/10;
    alpha_ub = alphax_lbnd(problem.L,problem.mu,h,eta);
    alphax = alpha_ub/15*alphait;
    
    opt_pars.h = h;
    opt_pars.eta = eta;
    opt_pars.alphax = alphax;
    
%     fname = sprintf('%s_%s_%3.3f_%3.3f.mat', rfqgt.method_name(), problem.name, problem.noise_scale, problem.d);
%     save(fname, 'h', 'alphax', 'eta');

end
function bnd = alphax_lbnd(L, mu, h, eta)
    H = h - h^2*L/2;
    bnd = sqrt(H*2*(mu-eta));
end

