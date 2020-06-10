function varargout = system(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @system_OpeningFcn, ...
                       'gui_OutputFcn',  @system_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end

function system_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);

    step_number = str2double(get(handles.steps, 'string'));

    hold on;    
    ylim([0 7]);
    xlim([1 step_number]);
    title('Estimation Error','FontSize',12, 'FontWeight', 'normal');
    lx = 'Step number';
    xlabel(lx,'FontSize',12);
    ly = 'Mean error norm';
    ylabel(ly,'FontSize',12);
    hold off;

function varargout = system_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;


function start_button_Callback(hObject, eventdata, handles)

    dim = str2double(get(handles.dim, 'string'));
    L = str2double(get(handles.lipsh, 'string'));
    mu = str2double(get(handles.mu, 'string'));

    trial_number = str2double(get(handles.iterations, 'string'));
    step_number = str2double(get(handles.steps, 'string'));

    trial_optpars = str2double(get(handles.iterations_pars, 'string'));
    step_optpars = str2double(get(handles.steps_pars, 'string'));

    f = str2func(get(handles.fun, 'string'));
    g = str2func(get(handles.grad, 'string'));

    is_sg = get(handles.sg, 'value');
    is_fg = get(handles.fg, 'value');
    is_sfgt = get(handles.sfgt, 'value');
    is_rfqgt = get(handles.rfqgt, 'value');
    is_custom_algo = get(handles.custom_algo, 'value');
    custom_algo = convertCharsToStrings(get(handles.algo, 'string'));

    noise_scale = str2double(get(handles.noise_scale, 'string'));

    rand_noise = get(handles.rand_noise, 'value');
    custom_noise = get(handles.custom_noise, 'value');
    noise_fun = str2func(get(handles.noise_model, 'string'));

    if (rand_noise)
        noise_model = "rand";
    elseif (custom_noise)
        noise_model = "custom";
    end

    drift_scale = str2double(get(handles.drift_scale, 'string'));
    init_point = str2num(get(handles.init_point, 'string'))';

    is_nodrift = get(handles.nodrift, 'value');
    is_linear = get(handles.linear, 'value');
    is_nonlinear = get(handles.nonlinear, 'value');
    is_rand = get(handles.rand, 'value');
    is_custom = get(handles.custom, 'value');

    custom_drift = str2func(get(handles.custom_drift, 'string'));

    if (is_nodrift)
        drift_name = "nodrift";
    elseif (is_linear)
        drift_name =  "linear";
    elseif (is_nonlinear)
        drift_name =  "nonlinear";
    elseif (is_rand)
        drift_name =  "rand";
    elseif (is_custom)
        drift_name =  "custom";
    end

    sep = strfind(custom_algo, "/");
    num_sep = size(sep); 
    num_sep = num_sep(2);
    sep_ind = sep(num_sep);

    algo_path = extractBetween(custom_algo, 2, (sep_ind-1));
    algo_name = extractBetween(custom_algo, (sep_ind+2), strlength(custom_algo)-1);

    i = 0;
    method_names = {};

    if (is_sg)
        i = i + 1;
        method_names{i} = "sg";
    end
    if (is_fg)
        i = i + 1;
        method_names{i} = "fg";
    end
    if (is_sfgt)
        i = i + 1;
        method_names{i} = "sfgt";
    end
    if (is_rfqgt)
        i = i + 1;
        method_names{i} = "rfqgt";
    end
    if (is_custom_algo)
        addpath(genpath(algo_path));
        i = i + 1;
        method_names{i} = algo_name;
    end

    problem = problems.setup_problem(drift_name, dim, f, g, L, mu, drift_scale, init_point, custom_drift, noise_scale, noise_model, noise_fun);
    opt_pars = start_modeling(problem, trial_number, step_number, trial_optpars, step_optpars, method_names, noise_model);

    optpars_table = [];
    pars_num = 1;
    if (is_sg)
        optpars_table = [optpars_table; opt_pars(pars_num).h, NaN, NaN];
        pars_num = pars_num + 1;
    else
        optpars_table = [optpars_table; NaN, NaN, NaN];
    end
    if (is_fg)
        optpars_table = [optpars_table; opt_pars(pars_num).h, NaN, NaN];
        pars_num = pars_num + 1;
    else
        optpars_table = [optpars_table; NaN, NaN, NaN];
    end
    if (is_sfgt)
        optpars_table = [optpars_table; opt_pars(pars_num).h, opt_pars(pars_num).eta, opt_pars(pars_num).alphax];
        pars_num = pars_num + 1;
    else
        optpars_table = [optpars_table; NaN, NaN, NaN];
    end
    if (is_rfqgt)
        optpars_table = [optpars_table; opt_pars(pars_num).h, opt_pars(pars_num).eta, opt_pars(pars_num).alphax];
        pars_num = pars_num + 1;
    else
        optpars_table = [optpars_table; NaN, NaN, NaN];
    end

    set(handles.pars_table, "Data", optpars_table);

    if (is_custom_algo)
        rmpath(algo_path)
    end


function dim_Callback(hObject, eventdata, handles)


function dim_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function fun_Callback(hObject, eventdata, handles)


function fun_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function grad_Callback(hObject, eventdata, handles)


function grad_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function lipsh_Callback(hObject, eventdata, handles)


function lipsh_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function mu_Callback(hObject, eventdata, handles)


function mu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function noise_scale_Callback(hObject, eventdata, handles)


function noise_scale_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function noise_model_Callback(hObject, eventdata, handles)


function noise_model_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function init_point_Callback(hObject, eventdata, handles)


function init_point_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function drift_scale_Callback(hObject, eventdata, handles)


function drift_scale_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function custom_drift_Callback(hObject, eventdata, handles)


function custom_drift_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function sg_Callback(hObject, eventdata, handles)


function fg_Callback(hObject, eventdata, handles)


function sfgt_Callback(hObject, eventdata, handles)


function rfqgt_Callback(hObject, eventdata, handles)


function custom_algo_Callback(hObject, eventdata, handles)


function algo_Callback(hObject, eventdata, handles)


function algo_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function steps_Callback(hObject, eventdata, handles)


function steps_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function iterations_Callback(hObject, eventdata, handles)


function iterations_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function steps_pars_Callback(hObject, eventdata, handles)


function steps_pars_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function iterations_pars_Callback(hObject, eventdata, handles)


function iterations_pars_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function save_pars_button_Callback(hObject, eventdata, handles)
    
    dim = str2double(get(handles.dim, 'string'));
    f = str2func(get(handles.fun, 'string'));

    is_sg = get(handles.sg, 'value');
    is_fg = get(handles.fg, 'value');
    is_sfgt = get(handles.sfgt, 'value');
    is_rfqgt = get(handles.rfqgt, 'value');
    is_custom = get(handles.custom_algo, 'value');
    custom_algo = get(handles.algo, 'string');

    noise_scale = str2double(get(handles.noise_scale, 'string'));

    rand_noise = get(handles.rand_noise, 'value');
    custom_noise = get(handles.custom_noise, 'value');
    noise_fun = str2func(get(handles.noise_model, 'string'));

    if (rand_noise)
        noise_model = "rand";
    elseif (custom_noise)
        noise_model = "custom";
    end

    drift_scale = str2double(get(handles.drift_scale, 'string'));
    init_point = str2num(get(handles.init_point, 'string'))';

    is_nodrift = get(handles.nodrift, 'value');
    is_linear = get(handles.linear, 'value');
    is_nonlinear = get(handles.nonlinear, 'value');
    is_rand = get(handles.rand, 'value');
    is_custom = get(handles.custom, 'value');

    custom_drift = str2func(get(handles.custom_drift, 'string'));

    if (is_nodrift)
        drift_name = "nodrift";
    elseif (is_linear)
        drift_name =  "linear";
    elseif (is_nonlinear)
        drift_name =  "nonlinear";
    elseif (is_rand)
        drift_name =  "rand";
    elseif (is_custom)
        drift_name =  "custom";
    end

    opt_pars = get(handles.pars_table, "Data");
    table_size = size(opt_pars);
    
    save_path=strcat('~', filesep, 'OSfT');
    if ( ~isfolder(save_path))
        mkdir(save_path);
    end
    save_filename=strcat(save_path, filesep, 'saved_parameters.mat');

    if (table_size(1) < 2)
        sg_h = opt_pars(1,1);
        save(save_filename, 'f', 'noise_model',  'noise_scale', 'drift_name', 'drift_scale', 'sg_h');
    elseif (table_size(1) < 3)
        sg_h = opt_pars(1,1);
        fg_h = opt_pars(2,1);
        save(save_filename, 'f', 'noise_model',  'noise_scale', 'drift_name', 'drift_scale', 'sg_h', 'fg_h');
    elseif (table_size(1) < 4)
        sg_h = opt_pars(1,1);
        fg_h = opt_pars(2,1);
        sfgt_h = opt_pars(3,1);
        sfgt_eta = opt_pars(3,2);
        sfgt_alphax = opt_pars(3,3);
        save(save_filename, 'f', 'noise_model',  'noise_scale', 'drift_name', 'drift_scale', 'sg_h', 'fg_h',  'sfgt_h', 'sfgt_eta','sfgt_alphax');
    elseif (table_size(1) == 4)
        sg_h = opt_pars(1,1);
        fg_h = opt_pars(2,1);
        sfgt_h = opt_pars(3,1);
        sfgt_eta = opt_pars(3,2);
        sfgt_alphax = opt_pars(3,3);
        rfqgt_h = opt_pars(4,1);
        rfqgt_eta = opt_pars(4,2);
        rfqgt_alphax = opt_pars(4,3);
        save(save_filename, 'f', 'noise_model',  'noise_scale', 'drift_name', 'drift_scale', 'sg_h', 'fg_h',  'sfgt_h', 'rfqgt_h', 'sfgt_eta', 'rfqgt_eta', 'sfgt_alphax', 'rfqgt_alphax');
    end
