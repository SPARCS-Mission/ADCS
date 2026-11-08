%% quaternions
% 1. Orbit to Body
t_1 = out.q_o2b.Time;     
q_1 = squeeze(out.q_o2b.Data)';   % [N × 4]

labels = {'$q_0$','$q_1$','$q_2$','$q_3$'};
colors = lines(4);

Fig1 = figure('Units','centimeters','Position',[5 5 16 12]);

for i = 1:4
    subplot(4,1,i);
    plot(t_1, q_1(:,i), 'LineWidth',1.5, 'Color', colors(i,:));
    ylabel(labels{i},'Interpreter','latex','FontSize',11);
    grid on; box on;
    ax = gca;
    ax.FontSize = 10;
    if i < 4
        set(gca,'XTickLabel',[]);
    else
        xlabel('Time [s]','Interpreter','latex','FontSize',11);
    end
end

sgtitle('Quaternion Components [Orbit to Body]','Interpreter','latex','FontSize',12);

% 2. ICRF to Body
t_2 = out.q_i2b.Time;     
q_2 = squeeze(out.q_i2b.Data)';   % [N × 4]

labels = {'$q_0$','$q_1$','$q_2$','$q_3$'};
colors = lines(4);

Fig2 = figure('Units','centimeters','Position',[5 5 16 12]);

for i = 1:4
    subplot(4,1,i);
    plot(t_2, q_2(:,i), 'LineWidth',1.5, 'Color', colors(i,:));
    ylabel(labels{i},'Interpreter','latex','FontSize',11);
    grid on; box on;
    ax = gca;
    ax.FontSize = 10;
    if i < 4
        set(gca,'XTickLabel',[]);
    else
        xlabel('Time [s]','Interpreter','latex','FontSize',11);
    end
end

sgtitle('Quaternion Components [ICRF to Body]','Interpreter','latex','FontSize',12);

% 3. Error Quaternion
t_3 = out.pointing_q_error.Time;     
q_3 = squeeze(out.pointing_q_error.Data')';   % [N × 4]

labels = {'$q_0$','$q_1$','$q_2$','$q_3$'};
colors = lines(4);

Fig3 = figure('Units','centimeters','Position',[5 5 16 12]);

for i = 1:4
    subplot(4,1,i);
    plot(t_3, q_3(:,i), 'LineWidth',1.5, 'Color', colors(i,:));
    ylabel(labels{i},'Interpreter','latex','FontSize',11);
    grid on; box on;
    ax = gca;
    ax.FontSize = 10;
    if i < 4
        set(gca,'XTickLabel',[]);
    else
        xlabel('Time [s]','Interpreter','latex','FontSize',11);
    end
end

sgtitle('Quaternion Components [Error Quaternion]','Interpreter','latex','FontSize',12);

%% Nadir Pointing General Stuff
% 1. Nadir Pointing Error (deg)
Fig4 = figure('Units','centimeters','Position',[5 5 18 12]);
colors = lines(3);
set(gca,'ColorOrder',colors);
cla;
plot(out.pointing_err_nadir,'LineWidth',1.4);
grid on
grid minor
xlabel('Time (s)');
ylabel('Pointing Error (deg)','Interpreter','latex','FontSize',12);
title('')

% 2. Angular Velocity (deg/s)

Fig5 = figure('Units','centimeters','Position',[5 5 18 12]);
colors = lines(3);
set(gca,'ColorOrder',colors);
cla;
plot(out.omega_i2b,'LineWidth',1.4);
grid on
grid minor
xlabel('Time (s)');
ylabel('Angular Velocity (deg/s)','Interpreter','latex','FontSize',12);
legend({'$\omega_x$','$\omega_y$','$\omega_z$'}, ...
       'Interpreter','latex','FontSize',11,'Location','best');
title('')

% 3. Toque Command (N.m)

Fig6 = figure('Units','centimeters','Position',[5 5 18 12]);
colors = lines(3);
set(gca,'ColorOrder',colors);
cla;
plot(out.Torque_Command,'LineWidth',1.4);
grid on
grid minor
xlabel('Time (s)');
ylabel('Torque Command (N.m)','Interpreter','latex','FontSize',12);
legend({'$T_x$','$T_y$','$T_z$'}, ...
       'Interpreter','latex','FontSize',11,'Location','best');
title('')

%% RW and SOC
% 1. SOC
Fig7 = figure('Units','centimeters','Position',[5 5 18 12]); % fixed size in cm
colors = lines(3);
set(gca,'ColorOrder',colors);
cla;
plot(out.SOC,'LineWidth',1.0);
grid on
grid minor
xlabel('Time (s)');
ylabel('Battery SOC','Interpreter','latex','FontSize',12);
title('')

% 2. RW Torque

Fig8 = figure('Units','centimeters','Position',[5 5 18 12]); % fixed size in cm
colors = lines(3);
set(gca,'ColorOrder',colors);
cla;
plot(out.RW_Torque,'LineWidth',1.0);
grid on
grid minor
xlabel('Time (s)');
ylabel('Actual Torque (N.m)','Interpreter','latex','FontSize',12);
title('')
legend({'$T_x$','$T_y$','$T_z$'}, ...
       'Interpreter','latex','FontSize',11,'Location','best');

% 3. RW RPM

Fig9 = figure('Units','centimeters','Position',[5 5 18 12]); % fixed size in cm
colors = lines(3);
set(gca,'ColorOrder',colors);
cla;
plot(out.RW_angvel,'LineWidth',1.0);
grid on
grid minor
xlabel('Time (s)');
ylabel('RWs Angular Velocity (RPM)','Interpreter','latex','FontSize',12);
title('')
legend({'$RW_x$','$RW_y$','$RW_z$'}, ...
       'Interpreter','latex','FontSize',11,'Location','best');

%% Attitude Determination and Estimation
% 1. RSME Error
Fig10 = figure('Units','centimeters','Position',[5 5 18 12]); % fixed size in cm
colors = lines(3);
set(gca,'ColorOrder',colors);
cla;
plot(out.Quest_RSME,'LineWidth',1.0);
grid on
grid minor
xlabel('Time (s)');
ylabel('RMSE (deg)','Interpreter','latex','FontSize',12);
title('')
% 2. Error
Fig11 = figure('Units','centimeters','Position',[5 5 18 12]); % fixed size in cm
colors = lines(3);
set(gca,'ColorOrder',colors);
cla;
plot(out.Quest_Error,'LineWidth',1.0);
grid on
grid minor
xlabel('Time (s)');
ylabel('Angular Error (deg)','Interpreter','latex','FontSize',12);
title('')

% 3. QUEST with Real
% ICRF to Body quaternions [Truth]
t_2;     
q_2;
% ICRF to Body quaternions [Quest]
t_4 = out.Quest_q_i2b.Time;    
q_4 = squeeze(out.Quest_q_i2b.Data)';   % [N × 4]

labels = {'$q_0$','$q_1$','$q_2$','$q_3$'};
color_true = [0, 0.4470, 0.7410];
color_quest = [0.8500, 0.3250, 0.0980];

Fig1 = figure('Units','centimeters','Position',[5 5 18 14]);

for i = 1:4
    
    subplot(4,1,i);
    plot(t_1, q_1(:,i), 'LineWidth', 1.5, 'Color', color_true, 'DisplayName', 'True');
    hold on;
    plot(t_4, q_4(:,i), '--', 'LineWidth', 1.5, 'Color', color_quest, 'DisplayName', 'QUEST');
    hold off;
    % ---------------------------
    ylabel(labels{i},'Interpreter','latex','FontSize',11);
    grid on; box on;
    ax = gca;
    ax.FontSize = 10;

    if i == 1
        legend('show', 'Location', 'best', 'Interpreter', 'latex');
    end

    if i < 4
        set(gca,'XTickLabel',[]);
    else
        xlabel('Time [s]','Interpreter','latex','FontSize',11);
    end
end

sgtitle('Quaternion Components: QUEST vs. Truth','Interpreter','latex','FontSize',12);


%%%%%%%%%%%%%%%%%%%%%%

% Fig12 = figure('Units','centimeters','Position',[5 5 18 12]); % fixed size in cm
% hold on;
% 
% % Draw Shaded Eclipse Regions
% eclipse_ends_idx   = find(diff([eclipse_data; 0]) == -1);
% for i = 1:length(eclipse_starts_idx)
%     start_time = eclipse_time(eclipse_starts_idx(i));
%     end_time   = eclipse_time(eclipse_ends_idx(i));
%     x_coords = [start_time, end_time, end_time, start_time];
%     y_coords = [y_limits(1), y_limits(1), y_limits(2), y_limits(2)];
%     patch(x_coords, y_coords, 'k', ...
%           'FaceAlpha', 0.15, ...
%           'EdgeColor', 'none', ...
%           'DisplayName', 'Eclipse');
% end
% 
% % Plot Data
% 
% plot(out.dist_norm_RP, 'LineWidth', 1.5, 'DisplayName', 'Rediation Pressure');
% plot(out.dist_norm_Aero, 'LineWidth', 1.5, 'DisplayName', 'Aerodynamic Drag');
% plot(out.dist_norm_Magnetic, 'LineWidth', 1.5, 'DisplayName', 'Magnetic');
% plot(out.dist_norm_GG, 'LineWidth', 1.5, 'DisplayName', 'Gravity Gradient');
% 
% for i = 1:4
%     subplot(4,1,1);
%     plot(out.dist_norm_GG, 'LineWidth',1.5);
%     title('Gravity Gradient');
%     ylabel('N.m');
% 
%     subplot(4,1,2);
%     plot(out.dist_norm_Aero, 'LineWidth',1.5);
%     title('Aerodynamic Drag');
%     ylabel('N.m');
% 
%     subplot(4,1,3);
%     plot(out.dist_norm_Magnetic, 'LineWidth',1.5);
%     title('Magnetic');
%     ylabel('N.m');
% 
%     subplot(4,1,4);
%     plot(out.dist_norm_RP, 'LineWidth',1.5);
%     title('Rediation Pressure');
%     ylabel('N.m');
% 
% 
% 
% end
% 
% data = {out.dist_norm_GG, out.dist_norm_Aero, out.dist_norm_Magnetic, out.dist_norm_RP};
% titles = {'Gravity Gradient','Aerodynamic Drag','Magnetic Residual','Radiation Pressure'};
% 
% figure('Units','centimeters','Position',[5 5 16 18]);
% 
% for i = 1:4
%     subplot(4,1,i); hold on;
%     plot(data{i},'LineWidth',1.5);
%     title(titles{i},'FontSize',11,'Interpreter','latex');
%     ylabel('N·m','Interpreter','latex');
%     grid on; box on;
% 
%     y_limits = ylim;
% 
%     for k = 1:length(eclipse_starts_idx)
%         start_time = eclipse_time(eclipse_starts_idx(k));
%         end_time   = eclipse_time(eclipse_ends_idx(k));
%         x_coords = [start_time, end_time, end_time, start_time];
%         y_coords = [y_limits(1), y_limits(1), y_limits(2), y_limits(2)];
% 
%         patch(x_coords, y_coords, [0.5 0.5 0.5], ...
%               'FaceAlpha', 0.35, ...
%               'EdgeColor', 'none');
%     end
% 
%     if i < 4
%         set(gca,'XTickLabel',[]);
%     else
%         xlabel('Time [s]','Interpreter','latex');
%     end
% end
% 
% sgtitle('Disturbance Torques with Eclipse Shading','Interpreter','latex','FontSize',12);
% 
% 
% Section 3: Final Plot Formatting
% 
% grid on;
% ax = gca;
% ax.FontSize = 12;
% ax.Box = 'on';
% 
% xlabel('Time (s)', 'FontSize', 12, 'FontWeight', 'bold');
% ylabel('Magnetic Disturbance Torque Magnitude (N.m)', 'FontSize', 12, 'FontWeight', 'bold');
% 
% xlim([eclipse_time(1), eclipse_time(end)]);
% ylim(y_limits);
% 
% legend('Location', 'northeast', 'FontSize', 10);
% hold off;


