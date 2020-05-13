function [new_theta, d] = find_next_estimate(min_pt, d)   
    
    p = [-1, -2*d.H*d.gamma_n+2*d.H*d.mu, 2*d.H*d.gamma_n];
    alpha_n_cands = roots(p);
    root_ind = find(alpha_n_cands > 0);
    if (length(root_ind) > 1)
        err;
    end
    if (abs(imag(alpha_n_cands(1))) > 0)
        err;
    end
    d.alpha_n = alpha_n_cands(root_ind);
    
    gamma_n1 = (1-d.alpha_n)*d.gamma_n+d.alpha_n*d.mu;  
           
    xn = 1/(d.gamma_n+d.alpha_n*d.mu)*(d.alpha_n*d.gamma_n*d.v_n+gamma_n1*d.theta_n);
    
    g = d.Y(xn, min_pt);
    new_theta = xn - d.h*g;
    
    d.v_n = 1/gamma_n1*((1-d.alpha_n)*d.gamma_n*d.v_n + d.alpha_n*d.mu*xn-d.alpha_n*g);    
    
    d.gamma_n = gamma_n1;  
    d.theta_n = new_theta;

end