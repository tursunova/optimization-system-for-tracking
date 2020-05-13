function opt_pars = start_modeling(show_fig, problem, trial_number, step_number, trial_optpars, step_optpars, method_names, noise_model)
    disp(method_names)
    method_funs = {};
    method_calc_opt_pars = {};
    method_init_funs = {};
    colors = {};
    linestyles = {};
    
    for i = 1:numel(method_names)
        method_funs{i} = str2func("@"+method_names{i}+".find_next_estimate");
        method_calc_opt_pars{i} = str2func("@"+method_names{i}+".get_opt_pars");
        method_init_funs{i} = str2func("@"+method_names{i}+".init_data");
        if (method_names{i} == 'sg')
            linestyles{i} = '-.';
            colors{i} = 'green';
        elseif (method_names{i} == 'fg')
            linestyles{i} = '-.';
            colors{i} = 'blue';
        elseif (method_names{i} == 'sfgt')
            linestyles{i} = '-.';
            colors{i} = 'red';
        elseif (method_names{i} == 'rfqgt')
            linestyles{i} = '-';
            colors{i} = 'black';
        else
            linestyles{i} = '--';
            colors{i} = 'pink';
        end
        method_names{i} = upper(method_names{i});
    end  
    
    methods = struct('estimate', method_funs, 'name', method_names, 'init_data', method_init_funs, 'color', colors, 'linestyle', linestyles, 'calc_opt_pars', method_calc_opt_pars);
    
    opt_pars = [];
    for mind = 1:length(methods)
        opt_pars = [opt_pars methods(mind).calc_opt_pars(problem, step_optpars, trial_optpars)];
    end
    
    disp(opt_pars)

    for ti = 1:trial_number
        
        problem = problem.gen_new_model(noise_model, problem);
        minpt_hist = problem.minpt_hist(step_number, problem);
%         disp(minpt_hist)
        
        for mind = 1:length(methods)             
            
            method_data = methods(mind).init_data(problem, opt_pars(mind));         
            theta_hist = method_data.theta_n;  
            
            for si = 1:step_number
                if (strcmp(methods(mind).name, 'RFQGT'))
                    if (mod(si, 2) == 1)
                        y1 = problem.f_xi;
                    else
                        [new_theta, method_data] = methods(mind).estimate(minpt_hist(:, si), method_data, y1);
                        theta_hist = [theta_hist new_theta new_theta];
                    end
                else
                    [new_theta, method_data] = methods(mind).estimate(minpt_hist(:, si), method_data);
                    theta_hist = [theta_hist new_theta];
                end
            end

            err_hist = theta_hist(:, 2:end)-minpt_hist;
            methods(mind).errs(ti) = norm(err_hist(:, end));                    
            methods_results{mind} = theta_hist;
            for si = 1:step_number 
                methods(mind).allerrs(si, ti) = norm(err_hist(:, si));
            end            
        end        
        fprintf('trial %f\n', ti);
    end
    
    for mind = 1:length(methods)
        for i = 1:step_number            
            methods(mind).mean_err(i) = mean(methods(mind).allerrs(i, :));
        end
    end    
    
    if (show_fig)
        h = figure(1);
        cla(h);
        hold on;    
        mnames  = [];
        for mind = 1:length(methods)
            plot(methods(mind).mean_err, 'color', methods(mind).color,'LineWidth',2, 'LineStyle', methods(mind).linestyle);
            mnames{mind} = methods(mind).name;
        end
        hL = legend(mnames, 'Orientation','vertical');
        ylim([0 1.5]);
        xlim([1 step_number]);
        title('Estimation Error','FontSize',12, 'FontWeight', 'normal');
        lx = 'Step number';
        xlabel(lx,'FontSize',12);
        ly = 'Mean error norm';
        ylabel(ly,'FontSize',12);
        set(h,'Units','Inches');
        pos = get(h,'Position');
        set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
        print(h,'figures\track_theory.pdf','-dpdf','-r0')    
        hold off;
    else
        cla;
        hold on;    
        mnames  = [];
        for mind = 1:length(methods)
            plot(methods(mind).mean_err, 'color', methods(mind).color,'LineWidth',2, 'LineStyle', methods(mind).linestyle);
            mnames{mind} = methods(mind).name;
        end
        hL = legend(mnames, 'Orientation','vertical');
        ylim([0 7]);
        xlim([1 step_number]);
        title('Estimation Error','FontSize',12, 'FontWeight', 'normal');
        lx = 'Step number';
        xlabel(lx,'FontSize',12);
        ly = 'Mean error norm';
        ylabel(ly,'FontSize',12); 
        hold off;
    end

end