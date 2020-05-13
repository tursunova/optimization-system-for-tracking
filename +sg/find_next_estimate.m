function [new_theta, d] = find_next_estimate(min_pt, d)
    g = d.Y(d.theta_n, min_pt);
    new_theta = d.theta_n - d.h*g;
    d.theta_n = new_theta;
end