

%% Globals
% global selected_x_over_L_coordinates;

%% Constants
fD_steps = 1 + 2^10;

%% Choosing limits independently for each of the regimes
if D_case_number == 1 && f_case_number == 1
    fD_min = -0.6;
    fD_max = 0.8;
elseif D_case_number == 1 && f_case_number == 2
    fD_min = -1.5;
    fD_max = 1;
elseif D_case_number == 1 && f_case_number == 4
    fD_min = -0.4;
    fD_max = 0.6;  
elseif D_case_number == 1 && f_case_number == 5
    fD_min = -0.5;
    fD_max = 0.7;     
elseif D_case_number == 2 && f_case_number == 1
    fD_min = -1.2;
    fD_max = 1;
elseif D_case_number == 2 && f_case_number == 2
    fD_min = -0.4;
    fD_max = 1.5;    
elseif D_case_number == 2 && f_case_number == 3
    fD_min = -2;
    fD_max = 0.8;   
elseif D_case_number == 2 && f_case_number == 4
    fD_min = -0.6;
    fD_max = 1.5;
elseif D_case_number == 2 && f_case_number == 5
    fD_min = -1.5;
    fD_max = 0.8;
elseif D_case_number == 3 && f_case_number == 1
    fD_min = -0.4;
    fD_max = 0.2;
elseif D_case_number == 3 && f_case_number == 2
    fD_min = -0.15;
    fD_max = 0.25;
elseif D_case_number == 3 && f_case_number == 3
    fD_min = -0.1;
    fD_max = 0.25;
elseif D_case_number == 3 && f_case_number == 4
    fD_min = -0.2;
    fD_max = 0.1;
elseif D_case_number == 3 && f_case_number == 5
    fD_min = -0.3;
    fD_max = 0.15;
else
    val = 0.6;
    fD_min = -val;
    fD_max = val;
end;




%% Initialization
[selected_bins_indices, selected_bins_centers] = get_selected_bins_indices();


%% Preparing the mesh and data for plotting
% Mesh
fD_step = (fD_max - fD_min) / (fD_steps - 1);
fD_mesh = fD_min:fD_step:fD_max;
size1 = lambda_count;
size2 = fD_steps;
fD_pdf_plot_data = zeros(selected_bins_count, size1, size2);
% lambda_mesh = (1:lambda_count); %' * ones(1, s2);
% % % b_mesh = ones(s1, 1) * b_mesh;
% Evaluating
for i_bin = 1:selected_bins_count
    for lambda_ind = 1:lambda_count
        bin = selected_bins_indices(lambda_ind, i_bin);
        fD_pdf_plot_data(i_bin, lambda_ind, :) = bin_fD_pdf_func (lambda_ind, bin, fD_mesh);
    end;
end;


%% Plotting
fig_hand = figure(7);
set_my_fig_size (fig_hand);
clf;
hold all;
color_codes = get(gca,'colororder');
legends_str = cell(1, selected_bins_count);
% Solid lines (Ito)
for i_bin = 1:selected_bins_count
    lambda_ind = 1;
    plot(fD_mesh, squeeze(fD_pdf_plot_data(i_bin, lambda_ind, :)), '-',...
        'Color', color_codes(i_bin, :), 'LineWidth', 2);
    legends_str{i_bin} = sprintf('x/L = %.3f', selected_bins_centers(lambda_ind, i_bin)/L);
end;
legend(legends_str);
% Other lines
for i_bin = 1:selected_bins_count
    lambda_ind = 2;
    plot(fD_mesh, squeeze(fD_pdf_plot_data(i_bin, lambda_ind, :)), '--',...
        'Color', color_codes(i_bin, :), 'LineWidth', 2);
    lambda_ind = 3;
    plot(fD_mesh, squeeze(fD_pdf_plot_data(i_bin, lambda_ind, :)), ':',...
        'Color', color_codes(i_bin, :), 'LineWidth', 3);
end;

xlabel('f*D');
ylabel('PDF');
title('Posterior on f*D product in selected bins. \lambda=0 (solid), \lambda=0.5 (dashed), \lambda=1 (dotted)');
xlim([fD_min, fD_max]);
hold off;


%% Checking the PDF normalization
i_bin = 3;
lambda_ind = 1;
trapz(fD_mesh, fD_pdf_plot_data(i_bin, lambda_ind, :))

%% Saving
output_filename_png = sprintf('D%i_F%i_07_Posterior on force times diffusivity.png', D_case_number, f_case_number);
output_full_path_svg = strcat(output_figures_folder, output_filename_png);
% output_full_path_pdf = strcat(output_figures_folder, output_filename_pdf);
if bl_save_figures
    fig_hand.PaperPositionMode = 'auto';
    saveas(fig_hand, output_full_path_svg, 'png');
%     saveas(fig_hand, output_full_path_pdf, 'pdf');
    disp('Figure saved (force times diffusivity)');
end;








