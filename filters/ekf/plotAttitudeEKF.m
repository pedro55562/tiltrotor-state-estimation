function figs = plotAttitudeEKF(est, options)
%PLOTATTITUDEEKF Plot attitude-EKF estimates, errors with +-3 sigma, and NEES.
% figs = plotAttitudeEKF(est, OutputDir="", Visible=true). Angles in degrees.
% With OutputDir, saves attitude.png, error_3sigma.png and nees.png there.
arguments
    est (1,1) struct
    options.OutputDir (1,:) char = ''
    options.Visible (1,1) logical = true
end
labels = {'\phi','\theta','\psi'};
vis = matlab.lang.OnOffSwitchState(options.Visible);
t = est.t;
d = rad2deg(1);
blue = [0.165 0.471 0.839];
orange = [0.922 0.408 0.204];

figs(1) = figure('Visible',vis,'Color','w','Position',[100 100 900 700]);
theme(figs(1),'light');
tl = tiledlayout(3,1,'TileSpacing','compact');
title(tl,'EKF de atitude: estimativa × verdade');
for i = 1:3
    nexttile;
    plot(t,d*est.x_true(:,i),'Color',orange,'LineWidth',2); hold on;
    plot(t,d*est.x_hat(:,i),'--','Color',blue,'LineWidth',1.2);
    grid on; ylabel([labels{i} ' [°]']);
    if i == 1, legend('verdade','EKF','Location','best'); end
end
xlabel('t [s]');

figs(2) = figure('Visible',vis,'Color','w','Position',[100 100 900 700]);
theme(figs(2),'light');
tl = tiledlayout(3,1,'TileSpacing','compact');
title(tl,'Erro de estimação e incerteza (±3\sigma)');
for i = 1:3
    nexttile;
    s = 3*d*est.sigma(:,i);
    fill([t;flipud(t)],[s;-flipud(s)],[0.82 0.88 0.97],'EdgeColor','none'); hold on;
    plot(t,d*est.err(:,i),'Color',blue,'LineWidth',1);
    grid on; ylabel(['erro ' labels{i} ' [°]']);
    title(sprintf('RMSE = %.3f°, dentro de ±3\\sigma: %.1f %%', d*est.rmse(i), ...
        100*mean(abs(est.err(:,i)) <= 3*est.sigma(:,i))),'FontWeight','normal');
    if i == 1, legend('±3\sigma','erro','Location','best'); end
end
xlabel('t [s]');

% Two-sided 95 % band of chi-square with 3 degrees of freedom.
chi2lo = 0.2158;
chi2hi = 9.3484;
figs(3) = figure('Visible',vis,'Color','w','Position',[100 100 900 350]);
theme(figs(3),'light');
semilogy(t,est.nees,'Color',blue,'LineWidth',0.8); hold on;
yline([chi2lo chi2hi],'--r');
grid on; xlabel('t [s]'); ylabel('NEES');
title(sprintf('NEES (n = 3), média = %.2f; banda de 95%% do \\chi^2_3', est.neesMean));

if ~isempty(options.OutputDir)
    if ~isfolder(options.OutputDir), mkdir(options.OutputDir); end
    names = {'attitude','error_3sigma','nees'};
    for i = 1:3
        exportgraphics(figs(i),fullfile(options.OutputDir,[names{i} '.png']),'Resolution',150);
    end
end
end
