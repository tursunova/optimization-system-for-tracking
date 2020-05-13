function errs = make_one_exp(problem, StepNum, TrialNum, h)
    opt_pars.h = h;
    errs = [];
    for ti = 1:TrialNum

        minpt_hist = problem.minpt_hist(StepNum, problem);
        
        method_data = fg.init_data(problem, opt_pars);                     
        theta_hist = method_data.theta_n; 
        
        for si = 1:StepNum
            [new_theta, method_data] = fg.find_next_estimate(minpt_hist(:, si), method_data);
            theta_hist = [theta_hist new_theta];
        end        
        
        err_hist = theta_hist(:, 2:end)-minpt_hist;
        allerrs = [];
        for si = 1:StepNum 
            allerrs = [ allerrs norm(err_hist(:, si))];
        end

        errs(ti) = norm(err_hist(:, end))^2;  
    end
end
