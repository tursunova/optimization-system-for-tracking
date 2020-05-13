function opt_pars = get_opt_pars(problem, StepNum, TrialNum)    

    for hit = 1:10        
        h = 1/problem.L*(hit)/10;     
        errs = fg.make_one_exp(problem, StepNum, TrialNum, h);
        costvol(hit) = mean(errs);                
    end
    [m, ind] = min(costvol(:));
    [hit] = ind2sub(size(costvol), ind);    
    h = 1/problem.L*(hit)/10;
    
    opt_pars.h = h;
    opt_pars.eta = 0;
    opt_pars.alphax = 0;
    
%     fname = sprintf('%s_%s_%3.3f_%3.3f.mat', fg.method_name(), problem.name, problem.noise_scale, problem.d);
%     save(fname, 'h');

end
function bnd = alphax_lbnd(L, mu, h, eta)
    H = h - h^2*L/2;
    bnd = sqrt(H*2*(mu-eta));
end

