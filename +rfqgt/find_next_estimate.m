function [new_theta, d] = find_next_estimate(min_pt, d, y_prev)  

    p = [-1, -2*(d.H-d.alpha_x/2)*d.gamma_n+2*(d.H-d.alpha_x/2)*(d.mu-d.eta), 2*(d.H-d.alpha_x/2)*d.gamma_n];
    alpha_n_cands = roots(p);
    root_ind = find(alpha_n_cands > 0);
    if (length(root_ind) > 1)
        err;
    end
    if (abs(imag(alpha_n_cands(1))) > 0)
        err;
    end
    d.alpha_n = alpha_n_cands(root_ind);
    
    gamma_n1 = (1-d.alpha_n)*d.gamma_n+d.alpha_n*(d.mu-d.eta);   
    
    xn = 1/(d.gamma_n+d.alpha_n*(d.mu-d.eta))*(d.alpha_n*d.gamma_n*d.v_n+gamma_n1*d.theta_n );
    
    d.gamma_n = gamma_n1;
    
    delta = zeros(d.q,1);
    delta_abs_value = 1/sqrt(10);
    for i=1:d.q
        if (binornd(1, 0.5) == 0)
            delta(i) = -delta_abs_value;
        else
            delta(i) = delta_abs_value;
        end 
    end
    d.delta_n = delta;
    
    y_plus = d.Y(xn + d.delta_n*d.beta, min_pt);
    y_minus = y_prev(xn - d.delta_n*d.beta, min_pt);
    
    y1 = d.delta_n' * ((y_plus - y_minus) / (2 * d.beta)) ;
    
    new_theta = xn - d.h * y1;
    
    d.v_n = 1/d.gamma_n*((1-d.alpha_n)*d.gamma_n*d.v_n + d.alpha_n*(d.mu-d.eta)*xn-d.alpha_n*y1 +d.alpha_n*d.L*d.beta); 
    
    d.theta_n = new_theta;
    
    d.alpha_hist = [d.alpha_hist; d.alpha_n];
    d.gamma_hist = [d.gamma_hist; d.gamma_n];
     
end