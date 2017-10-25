

function plot_article_b(data_struct, trials_data, fig_count, bl_save_figures)



%% Constants
load_constants;
x_lim_vec = [x_min, x_max];
lambdas_array = [0, 0.5, 1];

% Subplot params
rows = 2;
cols = 2;
SH = 0.08;
SV = 0.125;
ML = 0.07;
MR = 0.0125;
MT = 0.04;
MB = 0.075;

% Label params
sublabel_x = 0.015;
sublabel_y = 1.11;
output_filename = 'b.pdf';

% Other plot parameters
bin_plot_step = 1;	% 3
lambda_type_for_gradient_plot = enum_lambda_Stratonovich;
x_tick_increment = 0.1;

% Constants for bias integral calculations (taken from D_func.m)
D0 =  1e-2;		% um^2/s
w = 10.0;		% 1/um
a0 = 10 / gamma_drag;	% um/s

% Define plot colors
load_color_scheme;
color_sequence = [standard_colors(1).DeepBlue; my_colors(5).Green; my_colors(1).Orange; my_colors(1).WarmBrown];


%% == Calculations ==
%% Calculate the average value expected in each bin (simple averaging in space)
bins_number = data_struct.x_bins_number;
bins_centers = data_struct.x_bins_centers';
bins_borders = [1; 1] * data_struct.x_bins_centers' + [-1/2; 1/2] * data_struct.x_bins_widths';

% Anti-derivative of D at the borders
[~, ~, ~, D_true_antider] = D_func(selected_D_case, bins_borders, L);

% Calculate true average D
D_true_avg = (D_true_antider(2, :) - D_true_antider(1, :)) ./ (bins_borders(2, :) - bins_borders(1, :));

% Averate b is calculated as a sqaure root of average D
b_true_avg = sqrt(2 * D_true_avg);



%% Make an analytical estimation of estimate bias due to (i) evolution following Fokker-Planck equation and (ii) averaging over bin size

%% Define analytical functions calculated in Mathematica in "b bias analysis.nb"
% Jump variance, order 2 in t_step
var_over_t_func = @(D0, w, a0, lambda, t_step, x0) D0.*(2 + sin(pi.*w.*x0)) + (1./4).*(t_step).* (2.*D0.*pi.*w.*cos(pi.*w.*x0).*(a0 + (1./2).*D0.*lambda.*pi.*w.* cos(pi.*w.*x0)) - D0.^2.*pi.^2.*w.^2.*sin(pi.*w.*x0).* (2 + sin(pi.*w.*x0)) + 4.*D0.*(2 + sin(pi.*w.*x0)).* ((D0.*lambda.*pi.^2.*w.^2.*cos(pi.*w.*x0).^2)./ (4.*(2 + sin(pi.*w.*x0))) + lambda.*sqrt(D0.*(2 + sin(pi.*w.*x0))).* (-((D0.^2.*pi.^2.*w.^2.*cos(pi.*w.*x0).^2)./ (4.*(D0.*(2 + sin(pi.*w.*x0))).^(3./2))) - (D0.*pi.^2.*w.^2.*sin(pi.*w.*x0))./ (2.*sqrt(D0.*(2 + sin(pi.*w.*x0)))))));
% Jump variance, order 2 in t_step, average over bin
var_over_t_avg_func = @(D0, w, a0, lambda, t_step, x1, x2) (1./(1024.*(x1 - x2).^2)).*(-2048.*D0.*x1.*(-x1 + x2) + 2048.*D0.*x2.*(-x1 + x2) + (1024.*D0.*(-x1 + x2).* cos(pi.*w.*x1))./(pi.*w) - (1024.*D0.*(-x1 + x2).*cos(pi.*w.*x2))./(pi.*w)) + (1./(1024.*(x1 - x2).^2)).*((t_step).*(-1024.*a0.^2.*x1.^2 + 2048.*a0.^2.*x1.*x2 - 1024.*a0.^2.*x2.^2 - 1024.*a0.^2.*x1.*(-x1 + x2) + 128.*D0.^2.*pi.^2.*w.^2.*x1.* (-x1 + x2) + 128.*D0.^2.*lambda.*pi.^2.*w.^2.*x1.* (-x1 + x2) - 128.*D0.^2.*lambda.^2.*pi.^2.*w.^2.*x1.* (-x1 + x2) + 1024.*a0.^2.*x2.*(-x1 + x2) - 128.*D0.^2.*pi.^2.*w.^2.*x2.*(-x1 + x2) - 128.*D0.^2.*lambda.*pi.^2.*w.^2.*x2.*(-x1 + x2) + 128.*D0.^2.*lambda.^2.*pi.^2.*w.^2.*x2.*(-x1 + x2) - 512.*D0.^2.*(1 + 2.*lambda).*pi.*w.*(-x1 + x2).* cos(pi.*w.*x1) + 512.*D0.^2.*(1 + 2.*lambda).*pi.*w.* (-x1 + x2).*cos(pi.*w.*x2) - 512.*a0.*D0.*(1 + 2.*lambda).* (-x1 + x2).*sin(pi.*w.*x1) - 64.*D0.^2.*(1 + 3.*lambda + lambda.^2).*pi.*w.*(-x1 + x2).* sin(2.*pi.*w.*x1) - 1024.*a0.*D0.*lambda.*x1.* (sin(pi.*w.*x1) - sin(pi.*w.*x2)) + 1024.*a0.*D0.*lambda.*x2.* (sin(pi.*w.*x1) - sin(pi.*w.*x2)) - 256.*D0.^2.*lambda.^2.* (sin(pi.*w.*x1) - sin(pi.*w.*x2)).^2 + 512.*a0.*D0.*(-x1 + x2).*sin(pi.*w.*x2) + 1024.*a0.*D0.*lambda.*(-x1 + x2).*sin(pi.*w.*x2) + 64.*D0.^2.*pi.*w.*(-x1 + x2).*sin(2.*pi.*w.*x2) + 192.*D0.^2.*lambda.*pi.*w.*(-x1 + x2).*sin(2.*pi.*w.*x2) + 64.*D0.^2.*lambda.^2.*pi.*w.*(-x1 + x2).*sin(2.*pi.*w.*x2)));

%% Evaluate jump variance for each lambda
var_over_t = zeros(3, bins_number);
var_overt_t_avg = zeros(3, bins_number);
for lambda_ind = 1:lambda_types_count-1
	lambda = lambdas_array(lambda_ind);
	var_over_t(lambda_ind, :) = var_over_t_func(D0, w, a0, lambda, t_step, bins_centers);
	var_overt_t_avg(lambda_ind, :) = var_over_t_avg_func(D0, w, a0, lambda, t_step, bins_borders(1, :), bins_borders(2, :));
end;

% The expected b is the square root of variance over t
b_estimate_avg = sqrt(var_overt_t_avg);
b_estimate_avg_bias = b_estimate_avg - b_true_avg;



%% Calculate diffusivity gradient D' = bb' from MAP b using a finite difference scheme

% Choose one lambda and load corresponding data
tmp_data_struct = trials_data{data_struct.trial_first_simulation_type_index(lambda_type_for_gradient_plot)};

% Calculate distance between bins centers
x_bins_steps = tmp_data_struct.x_bins_centers(2:end) - tmp_data_struct.x_bins_centers(1:end - 1);

% Calculate bb' equal to D'
% % % b_squared_over_2 = tmp_data_struct.MAP_b.^2 / 2;
MAP_D = tmp_data_struct.MAP_D;
FD_bb_prime = (MAP_D(2:end, 1) - MAP_D(1:end-1, 1)) ./ x_bins_steps;
x_grad_mesh = tmp_data_struct.x_grad_mesh;



%% Initialize figure
h_fig = figure(fig_count);
set_article_figure_size(h_fig, rows, 2, 1);
clf;



%% == (A): Plot diffusivity profile ==
% Constants
y_lim_vec_A = [0.095, 0.18];

% Initialize subplot
h_sub = subaxis(rows, cols, 1, 'SH', SH, 'SV', SV, 'ML', ML, 'MR', MR, 'MT', MT, 'MB', MB);
hold on;

% Plot numerical data
str_legend = {};
for lambda_type = 1:lambda_types_count
    plot(data_struct.x_bins_centers(1:bin_plot_step:end),  data_struct.MAP_b_mean(lambda_type, 1:bin_plot_step:end, 1),...
        strcat('-', markers_list{lambda_type}), 'color', color_sequence(lambda_type, :),  'LineWidth', line_width, 'markers', marker_size);
    str_legend{end + 1} = lambda_types_names{lambda_type};
end;

% Legend
h_leg = legend(str_legend, 'location', 'west', 'FontSize', legend_font_size);
legend boxon;

% Plot theory
% Simulated profile
h_theor_center = plot(data_struct.x_fine_mesh, data_struct.b_theor_fine_data, '-k', 'LineWidth', line_width_theor);

% Average values
h_mean_theor = plot(data_struct.x_bins_centers, b_true_avg, '--k', 'LineWidth', line_width_theor);

% Adjust plot
xlim(x_lim_vec);
ylim(y_lim_vec_A);
box on;
grid on;
xlabel('$x$, $\mu \mathrm{m}$', 'interpreter', 'latex');
ylabel('$\langle \hat b \rangle$, $\mu\mathrm{m / s^{1/2}}$', 'interpreter', 'latex');
title('Average diffusivity profile', 'interpreter', 'latex');

% Send theoretical curves back
uistack([h_theor_center, h_mean_theor], 'bottom');

% Modify ticks
set(gca,'xtick', x_min:x_tick_increment:x_max);

% Subplot label
text(sublabel_x, sublabel_y, 'A', 'Units', 'Normalized', 'VerticalAlignment', 'Top', 'FontSize', subplot_label_font_size);



% Color bin borders
color_bins(bins_borders, ylim(), bin_color);





%% == (B): Posterior overlap (1 - fail_rate) ==
% Constants
y_lim_vec = [-2, 100];

% Initialize subplot
subaxis(rows, cols, 2);
hold on;

% Plot numerical data
str_legend = {};
for lambda_type = 1:lambda_types_count
    plot(data_struct.x_bins_centers,  (1 - data_struct.UR_b(lambda_type, :)) * 100,...
        strcat('-', markers_list{lambda_type}), 'color', color_sequence(lambda_type, :),  'LineWidth', line_width, 'markers', marker_size);
    str_legend{end + 1} = lambda_types_names{lambda_type};
end;

% Plot the optimal overlap level (confidence level)
h_conf = plot(x_lim_vec, [1, 1] * CONF_LEVEL * 100, 'k--', 'linewidth', line_width_theor);

% Adjust plot
xlim(x_lim_vec);
ylim(y_lim_vec);
box on;
grid on;
xlabel('$x$, $\mu \mathrm{m}$', 'interpreter', 'latex');
ylabel('Posterior overlap, \%', 'interpreter', 'latex');
title('Posterior overlap', 'interpreter', 'latex');

% Modify ticks
set(gca,'xtick', x_min:x_tick_increment:x_max);

% Legend
legend(str_legend, 'location', 'southwest', 'FontSize', legend_font_size);
legend boxon;

% Subplot label
text(sublabel_x, sublabel_y, 'B', 'Units', 'Normalized', 'VerticalAlignment', 'Top', 'FontSize', subplot_label_font_size);

% Send confidence level back
uistack(h_conf, 'bottom');



%% == (C): Average b bias ==
% Constants
scale = 1e-3;
y_lim_vec = [-1, 1] * 6e-3 / scale;

% Initialize subplot
subaxis(rows, cols, 3);
hold on;

% Plot numerical data
str_legend = {};
for lambda_type = 1:lambda_types_count
    plot(data_struct.x_bins_centers,...
        (data_struct.MAP_b_mean(lambda_type, :, 1) - b_true_avg) / scale, strcat(markers_list{lambda_type}),...
        'markers', marker_size, 'LineWidth', line_width, 'color', color_sequence(lambda_type, :));
    str_legend{end + 1} = lambda_types_names{lambda_type};
end;

% Plot the analytical bias estimate
for lambda_ind = 1:lambda_types_count-1
	plot(data_struct.x_bins_centers, b_estimate_avg_bias(lambda_ind, :) / scale, 'LineWidth', line_width, 'color', color_sequence(lambda_ind, :)); 
end;

% Plot zero bias line
h_theor_0 = plot(x_lim_vec, 0 * x_lim_vec, 'k--', 'LineWidth', line_width_theor);

% Adjust
xlim(x_lim_vec);
ylim(y_lim_vec);
xlabel('$x$, $\mu \mathrm{m}$', 'interpreter', 'latex');
ylabel('$\langle \delta b \rangle$, $10^{-3}\mu\mathrm{m / s^{1/2}}$', 'interpreter', 'latex');

% Modify ticks
set(gca,'xtick', x_min:x_tick_increment:x_max);

% Subplot label
text(sublabel_x, sublabel_y, 'C', 'Units', 'Normalized', 'VerticalAlignment', 'Top', 'FontSize', subplot_label_font_size);
title('Average diffusivity bias', 'interpreter', 'latex');
grid on;

% Legend
legend(str_legend, 'location', 'southwest', 'FontSize', legend_font_size);
legend boxon;

% Reorder curves
uistack(h_theor_0, 'bottom');



%% == (D): bb' profile ==
% Constants
y_lim_vec = [-1, 1] * 0.18;

% Initialize subplot
subaxis(rows, cols, 4);
hold on;



%% Plot
% Simple difference bb'
plot(x_grad_mesh, FD_bb_prime, markers_list{1}, 'color', color_sequence(1, :), 'LineWidth', line_width, 'markers', marker_size);

% Regularized gradient
plot(x_grad_mesh, tmp_data_struct.MAP_bb_prime_regular,  markers_list{2}, 'color', color_sequence(2, :), 'LineWidth', line_width, 'markers', marker_size);

% Regularized interpolated gradient
plot(tmp_data_struct.x_bins_centers, tmp_data_struct.MAP_bb_prime_regular_interp, 'color', color_sequence(3, :), 'LineWidth', line_width, 'markers', marker_size);

% True value
h_theor = plot(tmp_data_struct.x_fine_mesh, tmp_data_struct.bb_prime_theor_fine_data, 'k-', 'LineWidth', line_width_theor);

% Adjust subplot
xlabel('$x$, $\mu \mathrm{m}$', 'interpreter', 'latex');
ylabel('$bb''$, $\mu \mathrm{m/s}$', 'interpreter', 'latex');
xlim(x_lim_vec);
ylim(y_lim_vec);
box on;
grid on;
title(sprintf('Diffusivity gradient profile for $\\lambda^* = %.2f$', tmp_data_struct.lambda), 'interpreter', 'latex');

% Modify ticks
set(gca,'xtick', x_min:x_tick_increment:x_max);

% Subplot label
text(sublabel_x, sublabel_y, 'D', 'Units', 'Normalized', 'VerticalAlignment', 'Top', 'FontSize', subplot_label_font_size);

% Legend
str_legend_local = {'FD', 'R', 'RI'};
legend(str_legend_local, 'location', 'southwest', 'interpreter', 'latex', 'FontSize', legend_font_size);

% Send true profile back
uistack(h_theor, 'bottom');



%% Save figure
% Prepare printer
h_fig.PaperPositionMode = 'auto';
h_fig.Units = 'Inches';
fig_pos = h_fig.Position;
set(h_fig, 'PaperUnits','Inches','PaperSize', [fig_pos(3), fig_pos(4)]);

% Set filename
output_full_path = strcat(output_figures_folder, output_filename);
if bl_save_figures
    print(h_fig, output_full_path, '-dpdf', '-r0');
end;













