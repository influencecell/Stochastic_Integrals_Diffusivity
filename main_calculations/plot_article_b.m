

function plot_article_b(data_struct, trials_data, fig_count, bl_save_figures)


%% Constants
load_constants;
bin_plot_step = 1;	% 3
rows = 2;
cols = 2;
x_lim_vec = [x_min, x_max];

% Subplots params
SH = 0.08;
SV = 0.125;
ML = 0.08;
MR = 0.0125;
MT = 0.04;
MB = 0.075;

% Label params
sublabel_x = 0.015;
sublabel_y = 1.11;
output_filename = 'b.pdf';

% Other plot parameters
line_width_theor = line_width - 0.5;

% Constants for bias integral calculations
D0 =  1e-2;	% um^2/s
w = 10.0;		% 1/um
a0 = 10 / gamma_drag;	% um/s



%% Define plot colors
load_color_scheme;
color_sequence = [standard_colors(1).DeepBlue; my_colors(5).Green; my_colors(1).Orange; my_colors(1).WarmBrown];



%% Calculate
% % Filter indices from one best period
% x_left = (1/2 + 2*1)/w;
% x_right = (1/2 + 2*2)/w;
% indices = data_struct.x_bins_centers >= x_left & data_struct.x_bins_centers <= x_right;



%% Calculate the mean theoretical values in bins
bins_centers = data_struct.x_bins_centers';
bins_borders = [1; 1] * data_struct.x_bins_centers' + [-1/2; 1/2] * data_struct.x_bins_widths';
bins_number = data_struct.x_bins_number;
% Calculate the theoretical anti-derivative of D at the borders
[~, ~, ~, D_antider_theor] = D_func(selected_D_case, bins_borders, L);
% Calculate theor mean D and b in bin
D_mean_theor = (D_antider_theor(2, :) - D_antider_theor(1, :)) ./ (bins_borders(2, :) - bins_borders(1, :));
% Mean b is calculated as a sqaure root of average D in a bin
b_mean_theor = sqrt(2 * D_mean_theor);
% % b_mean_theor = data_struct.b_theor_data(:, 1)';



%% Calculate the theoretically expected bias based on integral series
% Load values
% b and its first two derivatives in columns 1, 2, 3
% b_theor_data = data_struct.b_theor_data;
% a in column 1, and we assume it has no gradient (zeros in column 2)
% a_theor_data = data_struct.a_theor_data;
% a_theor_data = [a_theor_data, zeros(length(a_theor_data), 1)];



% % % %% Calculate
% % % % x variance over t
% % % lambda = 0;
% % % var_over_t = ...
% % % 			... % t-independent part
% % % 			b_theor_data(:, 1).^2 ...
% % % 			... % ~ (t * lambda) part
% % % 			+ t_step * lambda * (2 * b_theor_data(:, 1).^2 .* b_theor_data(:, 2).^2 + b_theor_data(:, 1).^3 .* b_theor_data(:, 3))...
% % % 			... % ~ (t) part
% % % 			+ t_step * (b_theor_data(:, 1).^2 .* a_theor_data(:, 2) + a_theor_data(:, 1) .* b_theor_data(:, 1) .* b_theor_data(:, 2)...
% % % 			+ 5/2 * b_theor_data(:, 1).^2 .* b_theor_data(:, 2).^2 + 3/2 * b_theor_data(:, 1).^3 .* b_theor_data(:, 2));
% % % b_theor_expected = sqrt(var_over_t);
% % % b_theor_bias = b_theor_expected - b_mean_theor';



%% Calculate the Fokker-Planck approximation averaged over one bin
% The sinusoid force profile is hard-coded into this expression
% var_over_t_antider = @(D0, w, a0, lambda, x) (1/(1536 * pi * w)) * D0^2 *  (pi * t_step * w * (pi * D0^2 * w * (12 * (42 * lambda+59) * sin(2 * pi * w * x) - 3 * (3 * lambda+4) * sin(4 * pi * w * x)...
% 	-8 * (14 * lambda+19) * cos(3 * pi * w * x))-96 * a0 * (cos(2 * pi * w * x)-8 * sin(pi * w * x)))-12 * (pi * w * x * (17 * pi^2 * D0^2 * (lambda+2) * t_step * w^2-144)...
% 	+8 * sin(2 * pi * w * x))+24 * cos(pi * w * x) * (pi^2 * D0^2 * (42 * lambda+65) * t_step * w^2-64));

% % % order 1 in t_step
% % var_over_t = @(D0, w, a0, lambda, t_step, x) (D0*(32*pi*w*x - 16*cos(pi*w*x)))/(16*pi*w) + (1/(16*pi*w))*(D0*(t_step)*(-2*D0*(2 + lambda)*pi^3*w^3*x...
% % 	+ 8*D0*(3 + 2*lambda)*pi^2*w^2*cos(pi*w*x) + 8*a0*pi*w*sin(pi*w*x) + D0*(4 + 3*lambda)*pi^2*w^2*sin(2*pi*w*x)));

% % order 2 in t_step (but calculations showed this is unnecessary)
% var_over_t_antider = @(D0, w, a0, lambda, t_step, x) (D0*(288*pi*w*x - 144*cos(pi*w*x)))/(144*pi*w) + (1/(144*pi*w))*(D0*(t_step)*(-18*D0*(2 + lambda)*pi^3*w^3*x...
% 	+ 72*D0*(3 + 2*lambda)*pi^2*w^2*cos(pi*w*x) + 72*a0*pi*w*sin(pi*w*x) + 9*D0*(4 + 3*lambda)*pi^2*w^2*sin(2*pi*w*x)))...
% 	+ (1/(144*pi*w))*(D0*(t_step)^2*(6*D0^2*(4 + 3*lambda)*pi^5*w^5*x + 24*a0^2*pi^2*w^2*cos(pi*w*x) - 3*D0^2*(51 + lambda*(43 + 2*lambda))*pi^4*w^4*cos(pi*w*x)...
% 	+ 9*a0*D0*(4 + 3*lambda)*pi^3*w^3*cos(2*pi*w*x) + D0^2*(17 + 3*lambda*(7 + 2*lambda))*pi^4*w^4*cos(3*pi*w*x) - 48*a0*D0*(3 + 2*lambda)*pi^3*w^3*sin(pi*w*x)...
% 	- 3*D0^2*(34 + lambda*(37 + 8*lambda))*pi^4*w^4*sin(2*pi*w*x)));

% order 2 in t_step, with averaging over bin
var_over_t_avg = @(D0, w, a0, lambda, t_step, x1, x2) (1./(1024.*(x1 - x2).^2)).*(-2048.*D0.*x1.*(-x1 + x2) + 2048.*D0.*x2.*(-x1 + x2) + (1024.*D0.*(-x1 + x2).* cos(pi.*w.*x1))./(pi.*w) - (1024.*D0.*(-x1 + x2).*cos(pi.*w.*x2))./(pi.*w)) + (1./(1024.*(x1 - x2).^2)).*((t_step).*(-1024.*a0.^2.*x1.^2 + 2048.*a0.^2.*x1.*x2 - 1024.*a0.^2.*x2.^2 - 1024.*a0.^2.*x1.*(-x1 + x2) + 128.*D0.^2.*pi.^2.*w.^2.*x1.* (-x1 + x2) + 128.*D0.^2.*lambda.*pi.^2.*w.^2.*x1.* (-x1 + x2) - 128.*D0.^2.*lambda.^2.*pi.^2.*w.^2.*x1.* (-x1 + x2) + 1024.*a0.^2.*x2.*(-x1 + x2) - 128.*D0.^2.*pi.^2.*w.^2.*x2.*(-x1 + x2) - 128.*D0.^2.*lambda.*pi.^2.*w.^2.*x2.*(-x1 + x2) + 128.*D0.^2.*lambda.^2.*pi.^2.*w.^2.*x2.*(-x1 + x2) - 512.*D0.^2.*(1 + 2.*lambda).*pi.*w.*(-x1 + x2).* cos(pi.*w.*x1) + 512.*D0.^2.*(1 + 2.*lambda).*pi.*w.* (-x1 + x2).*cos(pi.*w.*x2) - 512.*a0.*D0.*(1 + 2.*lambda).* (-x1 + x2).*sin(pi.*w.*x1) - 64.*D0.^2.*(1 + 3.*lambda + lambda.^2).*pi.*w.*(-x1 + x2).* sin(2.*pi.*w.*x1) - 1024.*a0.*D0.*lambda.*x1.* (sin(pi.*w.*x1) - sin(pi.*w.*x2)) + 1024.*a0.*D0.*lambda.*x2.* (sin(pi.*w.*x1) - sin(pi.*w.*x2)) - 256.*D0.^2.*lambda.^2.* (sin(pi.*w.*x1) - sin(pi.*w.*x2)).^2 + 512.*a0.*D0.*(-x1 + x2).*sin(pi.*w.*x2) + 1024.*a0.*D0.*lambda.*(-x1 + x2).*sin(pi.*w.*x2) + 64.*D0.^2.*pi.*w.*(-x1 + x2).*sin(2.*pi.*w.*x2) + 192.*D0.^2.*lambda.*pi.*w.*(-x1 + x2).*sin(2.*pi.*w.*x2) + 64.*D0.^2.*lambda.^2.*pi.*w.*(-x1 + x2).*sin(2.*pi.*w.*x2)));
% same, but with no spatial averaging
var_over_t = @(D0, w, a0, lambda, t_step, x0) D0.*(2 + sin(pi.*w.*x0)) + (1./4).*(t_step).* (2.*D0.*pi.*w.*cos(pi.*w.*x0).*(a0 + (1./2).*D0.*lambda.*pi.*w.* cos(pi.*w.*x0)) - D0.^2.*pi.^2.*w.^2.*sin(pi.*w.*x0).* (2 + sin(pi.*w.*x0)) + 4.*D0.*(2 + sin(pi.*w.*x0)).* ((D0.*lambda.*pi.^2.*w.^2.*cos(pi.*w.*x0).^2)./ (4.*(2 + sin(pi.*w.*x0))) + lambda.*sqrt(D0.*(2 + sin(pi.*w.*x0))).* (-((D0.^2.*pi.^2.*w.^2.*cos(pi.*w.*x0).^2)./ (4.*(D0.*(2 + sin(pi.*w.*x0))).^(3./2))) - (D0.*pi.^2.*w.^2.*sin(pi.*w.*x0))./ (2.*sqrt(D0.*(2 + sin(pi.*w.*x0)))))));



lambda = 1;
% Use a correction to lambda that I cannot explain yet
% lambda_prime = lambda-1;
var_theor_expected_avg = zeros(3, bins_number);
var_theor_expected = zeros(3, bins_number);
lambdas_array = [0, 0.5, 1];

for lambda_ind = 1:lambda_types_count-1
	lambda = lambdas_array(lambda_ind);
	var_theor_expected_avg(lambda_ind, :) = var_over_t_avg(D0, w, a0, lambda, t_step, bins_borders(1, :), bins_borders(2, :));
	var_theor_expected(lambda_ind, :) = var_over_t(D0, w, a0, lambda, t_step, bins_centers);
end;

% D_theor_expected_avg = var_theor_expected_avg/2;
% % % % Normalize to bin width
% % % var_theor_expected_avg = var_theor_expected_avg ./ (bins_borders(2, :) - bins_borders(1, :));
b_theor_expected_avg = sqrt(var_theor_expected_avg);
% b_theor_expected = sqrt(var_theor_expected);
b_theor_expected_avg_bias = b_theor_expected_avg - b_mean_theor;
% b_theor_expected_bias = b_theor_expected' - b_mean_theor';
% b_theor_expected';
% bins_borders;



% % % %% Check Delta_x mean predictions in bins
% % % dx_mean_theor_func = @(D0, w, a0, lambda, t_step, x1, x2) (1./(32.*(-x1 + x2))).*((t_step).^2.* (-8.*a0.*D0.*pi.*w.*(cos(pi.*w.*x1) - cos(pi.*w.*x2)) - 8.*a0.*D0.*lambda.*pi.*w.*(cos(pi.*w.*x1) - cos(pi.*w.*x2)) - 2.*D0.^2.*pi.^2.*w.^2.*(cos(2.*pi.*w.*x1) - cos(2.*pi.*w.*x2)) - 3.*D0.^2.*lambda.*pi.^2.*w.^2.*(cos(2.*pi.*w.*x1) - cos(2.*pi.*w.*x2)) - D0.^2.*lambda.^2.*pi.^2.*w.^2.* (cos(2.*pi.*w.*x1) - cos(2.*pi.*w.*x2)) + 8.*D0.^2.*pi.^2.*w.^2.*(sin(pi.*w.*x1) - sin(pi.*w.*x2)) + 8.*D0.^2.*lambda.*pi.^2.*w.^2.*(sin(pi.*w.*x1) - sin(pi.*w.*x2)))) + (1./(32.*(-x1 + x2))).* ((t_step).*(-32.*a0.*x1 + 32.*a0.*x2 + 16.*D0.*(-sin(pi.*w.*x1) + sin(pi.*w.*x2)) + 16.*D0.*lambda.*(-sin(pi.*w.*x1) + sin(pi.*w.*x2))));
% % % % Calculate
% % % dx_mean_theor = dx_mean_theor_func(D0, w, a0, lambda, t_step, bins_borders(1, :), bins_borders(2, :));
% % % % Compare with data
% % % [data_struct.dx_mean_in_bins; dx_mean_theor]


%% == (A): Plot diffusivity profile ==
% Initialize
y_lim_vec_A = [0.095, 0.18];
h_fig = figure(fig_count);
set_article_figure_size(h_fig, rows, 2, 1);
clf;
h_sub = subaxis(rows, cols, 1, 'SH', SH, 'SV', SV, 'ML', ML, 'MR', MR, 'MT', MT, 'MB', MB);
hold on;
% Plot
str_legend = {};
for lambda_type = 1:lambda_types_count
    plot(data_struct.x_bins_centers(1:bin_plot_step:end),  data_struct.MAP_b_mean(lambda_type, 1:bin_plot_step:end, 1),...
        strcat('-', markers_list{lambda_type}), 'color', color_sequence(lambda_type, :),  'LineWidth', line_width, 'markers', marker_size);
    str_legend{end + 1} = lambda_types_names{lambda_type};
end;
%% Theory
% Values in center
h_theor_center = plot(data_struct.x_fine_mesh, data_struct.b_theor_fine_data, '-k', 'LineWidth', line_width_theor);
% Mean values in bins
h_mean_theor = plot(data_struct.x_bins_centers, b_mean_theor, '--k', 'LineWidth', line_width_theor);
% % The expected b due to Fokker-Planck equation
% plot(data_struct.x_bins_centers, b_theor_expected_avg, '-m', 'LineWidth', line_width);

% Adjust
xlim(x_lim_vec);
ylim(y_lim_vec_A);
box on;
xlabel('$x$, $\mu \mathrm{m}$', 'interpreter', 'latex');
ylabel('$\langle b \rangle$, $\mu\mathrm{m \cdot s^{-1/2}}$', 'interpreter', 'latex');
title('Average diffusivity profile', 'interpreter', 'latex');
% Subplot label
text(sublabel_x, sublabel_y, 'A', 'Units', 'Normalized', 'VerticalAlignment', 'Top', 'FontSize', subplot_label_font_size);
% Legend
% str_legend = lambda_types_names;
h_leg = legend(str_legend, 'location', 'west', 'FontSize', legend_font_size);
legend boxon;
grid on;
% Send theoretical curve back
uistack([h_theor_center, h_mean_theor], 'bottom');


%% == (B): Fail rate ==
subaxis(rows, cols, 2);
hold on;
y_lim_vec = [-2, 100];
str_legend = {};
for lambda_type = 1:lambda_types_count
    plot(data_struct.x_bins_centers,  (1 - data_struct.UR_b(lambda_type, :)) * 100,...
        strcat('-', markers_list{lambda_type}), 'color', color_sequence(lambda_type, :),  'LineWidth', line_width, 'markers', marker_size);
    str_legend{end + 1} = lambda_types_names{lambda_type};
end;
% Plot the used confidence level
h_conf = plot(x_lim_vec, [1, 1] * CONF_LEVEL * 100, 'k--', 'linewidth', line_width_theor);
% Adjust
xlim(x_lim_vec);
ylim(y_lim_vec);
box on;
grid on;
xlabel('$x$, $\mu \mathrm{m}$', 'interpreter', 'latex');
ylabel('Posterior overlap, \%', 'interpreter', 'latex');
title('Posterior overlap', 'interpreter', 'latex');
% Legend
% str_legend = lambda_types_names;

legend(str_legend, 'location', 'southwest', 'FontSize', legend_font_size);
legend boxon;
% Subplot label
text(sublabel_x, sublabel_y, 'B', 'Units', 'Normalized', 'VerticalAlignment', 'Top', 'FontSize', subplot_label_font_size);
% Send confidence level back
uistack(h_conf, 'bottom');



%% == (C): b bias ==





% % % Calculate
% % s0_theor_data = b_theor_data(:,1).^2;
% % s2_theor_data = -2 * (b_theor_data(:, 2).^2 + b_theor_data(:, 1) .* b_theor_data(:, 3));
% % lambda = 1;
% % b_theor_expected = sqrt(s0_theor_data .* (1 - (t_step / 2) * s2_theor_data * (1 + 4 * lambda)/4) );	%  + (t_step / 2)^2 * s2_theor_data.^2 * lambda^2 / 2
% % b_theor_bias = b_theor_expected - b_mean_theor';
% % % % b_theor_bias = b_theor_expected - b_theor_data(:, 1);
% % 1;


% % x_mesh = data_struct.x_bins_centers;
% % bin_sizes = data_struct.x_bins_widths;
% % 
% % mean_jumps = data_struct.mean_jump_bins_all_trials';
% % 
% % % b' part
% % lambdas = [0, 0.5, 1];
% % b_mean_series = 2 * b_theor_data(:, 2).^2 .* (bin_sizes / 2).^2 ./ 6 ./ b_theor_data(:, 1);
% % b_mean_series = b_mean_series * (2 * lambdas - 2);
% % 
% % % b'' part
% % b_mean_series = b_mean_series + b_theor_data(:, 3) .* (bin_sizes / 2).^2 / 6 * [1, 1, 1];
% % 
% % % Add the central value and subtract the theoretical mean
% % b_theor_bias = b_mean_series + (data_struct.b_theor_data(:, 1) - b_mean_theor') * [1, 1, 1];
% % 
% % %% Alternatively calculate the exact value of the mean integral without series
% % lambda = 0;
% % b_theor_exact_bias = b_theor_bias_func(bins_borders, lambda, b_mean_theor');

%% Initialize
subaxis(rows, cols, 3);
hold on;
% x_lim_vec_C = [-0.19,0.16];
scale = 1e-3;
y_lim_vec = [-1, 1] * 6e-3 / scale;
str_legend = {};

%% Plot
for lambda_type = 1:lambda_types_count
    plot(data_struct.x_bins_centers,...
        (data_struct.MAP_b_mean(lambda_type, :, 1) - b_mean_theor) / scale, strcat(markers_list{lambda_type}),...
        'markers', marker_size, 'LineWidth', line_width, 'color', color_sequence(lambda_type, :));
    str_legend{end + 1} = lambda_types_names{lambda_type};
end;

%% Legend
legend(str_legend, 'location', 'southwest', 'FontSize', legend_font_size);
legend boxon;

%% Theory
%for lambda_ind =  1:length(lambdas)
% lambda_ind = 3;
% plot(data_struct.x_bins_centers, b_theor_bias(:, 1), 'k');
for lambda_ind = 1:lambda_types_count-1
	plot(data_struct.x_bins_centers, b_theor_expected_avg_bias(lambda_ind, :) / scale, 'LineWidth', line_width, 'color', color_sequence(lambda_ind, :)); 
end;
% plot(data_struct.x_bins_centers, b_theor_expected_bias / scale, 'g'); 
% end;
%h_conf = plot(x_lim_vec, [1, 1] * (1 - CONF_LEVEL) * 100, 'k--', 'linewidth', line_width);

%% Plot zero bias line
h_theor_0 = plot(x_lim_vec, 0 * x_lim_vec, 'k--', 'LineWidth', line_width_theor);

% %% Plot exact bias
% plot(data_struct.x_bins_centers, b_theor_bias, '--k');


%% Adjust
xlim(x_lim_vec);
ylim(y_lim_vec);
xlabel('$x$, $\mu \mathrm{m}$', 'interpreter', 'latex');
ylabel('$\langle \delta b \rangle$, $10^{-3}\mu\mathrm{m \cdot s^{-1/2}}$', 'interpreter', 'latex');
text(sublabel_x, sublabel_y, 'C', 'Units', 'Normalized', 'VerticalAlignment', 'Top', 'FontSize', subplot_label_font_size);
title('Average diffusivity bias', 'interpreter', 'latex');
grid on;
% Reorder curves
uistack([h_theor_0], 'bottom');


% % % %% == (D): D profile (temporarily) ==
% % % subaxis(rows, cols, 4);
% % % hold on;
% % % for lambda_type = 1:lambda_types_count
% % %     plot(data_struct.x_bins_centers(1:bin_plot_step:end),  data_struct.MAP_D_mean(lambda_type, 1:bin_plot_step:end, 1),...
% % %         strcat('-', markers_list{lambda_type}), 'color', color_sequence(lambda_type, :),  'LineWidth', line_width, 'markers', marker_size);
% % % %     str_legend{end + 1} = lambda_types_names{lambda_type};
% % % end;
% % % % Theory
% % % h_theor_center = plot(data_struct.x_fine_mesh, data_struct.D_theor_fine_data, '-k', 'LineWidth', line_width);
% % % % The expected D due to Fokker-Planck equation
% % % plot(data_struct.x_bins_centers, D_theor_expected_avg, '-m', 'LineWidth', line_width);


%% == (D): D' profile ==
%% Initialize
subaxis(rows, cols, 4);
hold on;
y_lim_vec = [-1, 1] * 0.18;
%% Calculate
% Calculate simple bb' with MAP b using a finite elements scheme
% Choose one lambda and corresponding data_struct
tmp_data_struct = trials_data{data_struct.trial_first_simulation_type_index(enum_lambda_Stratonovich)};
x_bins_steps = tmp_data_struct.x_bins_centers(2:end) - tmp_data_struct.x_bins_centers(1:end - 1);
b_squared_over_2 = tmp_data_struct.MAP_b.^2 / 2;
simple_bb_prime = (b_squared_over_2(2:end, 1) - b_squared_over_2(1:end-1, 1)) ./ x_bins_steps;
x_grad_mesh = tmp_data_struct.x_grad_mesh;
%% Plot
% Simple difference
plot(x_grad_mesh, simple_bb_prime, markers_list{1}, 'color', color_sequence(1, :), 'LineWidth', line_width, 'markers', marker_size);
% Regularized gradient
plot(x_grad_mesh, tmp_data_struct.MAP_bb_prime_regular,  markers_list{2}, 'color', color_sequence(2, :), 'LineWidth', line_width, 'markers', marker_size);
% Regularized interpolated gradient
plot(tmp_data_struct.x_bins_centers, tmp_data_struct.MAP_bb_prime_regular_interp, 'color', color_sequence(3, :), 'LineWidth', line_width, 'markers', marker_size);
% Theory
h_theor = plot(tmp_data_struct.x_fine_mesh, tmp_data_struct.bb_prime_theor_fine_data, 'k--', 'LineWidth', line_width_theor);
% Adjust
xlabel('$x$, $\mu \mathrm{m}$', 'interpreter', 'latex');
ylabel('$bb''$, $\mu \mathrm{m/s}$', 'interpreter', 'latex');
xlim(x_lim_vec);
ylim(y_lim_vec);
box on;
grid on;
title(sprintf('Diffusivity gradient profile for $\\lambda^* = %.2f$', tmp_data_struct.lambda), 'interpreter', 'latex');
% Sublabel
text(sublabel_x, sublabel_y, 'D', 'Units', 'Normalized', 'VerticalAlignment', 'Top', 'FontSize', subplot_label_font_size);
% Legend
str_legend_local = {'FD', 'R', 'RI'};
legend(str_legend_local, 'location', 'southwest', 'interpreter', 'latex', 'FontSize', legend_font_size);
% Send theoretical curve back
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













