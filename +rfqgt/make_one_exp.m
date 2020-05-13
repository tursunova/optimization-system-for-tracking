function errs = make_one_exp(problem, StepNum, TrialNum, h, eta, alphax)
    opt_pars.h = h;
    opt_pars.eta = eta;
    opt_pars.alphax = alphax;
    
    errs = [];
    for ti = 1:TrialNum

        minpt_hist = problem.minpt_hist(StepNum, problem);
        
        method_data = rfqgt.init_data(problem, opt_pars);                     
        theta_hist = method_data.theta_n; 
        
        for si = 1:StepNum
            if (mod(si, 2) == 1)
                y1 = problem.f_xi;
            else
            	[new_theta, method_data] = rfqgt.find_next_estimate(minpt_hist(:, si), method_data, y1);
            	theta_hist = [theta_hist new_theta new_theta];
            end
        end        
        
        err_hist = theta_hist(:, 2:end)-minpt_hist;
        allerrs = [];
        for si = 1:StepNum 
            allerrs = [ allerrs norm(err_hist(:, si))];
        end

        errs(ti) = norm(err_hist(:, end))^2;  
    end
end
