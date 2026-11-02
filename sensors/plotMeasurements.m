function figs = plotMeasurements(meas, options)
%PLOTMEASUREMENTS Plot noise-free truth h(x_true,u) against noisy measurements.
% figs = plotMeasurements(meas, OutputDir="") draws one figure per sensor
% group (gyro, accelerometer, magnetometer, position, tilt), one axes per
% channel. If OutputDir is given, each figure is saved there as PNG.
arguments
    meas (1,1) struct
    options.OutputDir (1,:) char = ''
    options.Visible (1,1) logical = true
end
groups = struct( ...
    'name',{'gyro','accelerometer','magnetometer','position','tilt'}, ...
    'title',{'Giroscópio (\omega^B)','Acelerômetro (força específica)', ...
        'Magnetômetro','Posição: GPS horizontal e barômetro', ...
        'Mecanismo de inclinação'}, ...
    'channels',{1:3,4:6,7:9,10:12,13:16}, ...
    'labels',{{'\omega_x','\omega_y','\omega_z'},{'a_x','a_y','a_z'}, ...
        {'m_x','m_y','m_z'},{'x (GPS)','y (GPS)','z (barômetro)'}, ...
        {'\alpha_R','\alpha_L','d\alpha_R/dt','d\alpha_L/dt'}}, ...
    'scale',{1,1,1e6,1,1}, ...
    'unit',{'rad/s','m/s^2','\muT','m',''});
measColor = [0.165 0.471 0.839];   % categorical slot 1 (blue)
truthColor = [0.922 0.408 0.204];  % categorical slot 2 (orange)
ink = [0.322 0.318 0.306];
figs = gobjects(numel(groups),1);
for g = 1:numel(groups)
    G = groups(g);
    n = numel(G.channels);
    cols = 1+(n==4);
    rows = n/cols;
    figs(g) = figure('Name',G.name,'Color','w', ...
        'Visible',matlab.lang.OnOffSwitchState(options.Visible), ...
        'Units','pixels','Position',[100 100 900*cols/1.2 260*rows]);
    theme(figs(g),'light');
    layout = tiledlayout(figs(g),rows,cols,'TileSpacing','compact','Padding','compact');
    title(layout,G.title,'FontWeight','bold','Color',[0.04 0.04 0.04]);
    for i = 1:n
        c = G.channels(i);
        unit = G.unit;
        if isempty(unit), unit = meas.channelUnits{c}; end
        k = meas.available(:,c);
        ax = nexttile(layout);
        hold(ax,'on');
        plot(ax,meas.t(k),meas.y(k,c)*G.scale,'.','Color',measColor,'MarkerSize',6);
        plot(ax,meas.t,meas.y_clean(:,c)*G.scale,'-','Color',truthColor,'LineWidth',2);
        hold(ax,'off');
        grid(ax,'on');
        set(ax,'GridColor',[0.85 0.85 0.85],'GridAlpha',1,'XColor',ink,'YColor',ink, ...
            'Box','off','TickLabelInterpreter','tex');
        ylabel(ax,sprintf('%s [%s]',G.labels{i},unit),'Interpreter','tex');
        title(ax,sprintf('%s — %g Hz, \\sigma = %g %s',G.labels{i}, ...
            meas.sensors.rateHz(c),meas.sensors.sigma(c)*G.scale,unit), ...
            'FontWeight','normal','Interpreter','tex');
        if i > n-cols
            xlabel(ax,'t [s]');
        end
        if i == 1
            legend(ax,{'medição','verdade h(x_{true},u)'},'Location','southeast', ...
                'Orientation','horizontal','TextColor',[0.04 0.04 0.04],'Color','w');
        end
    end
    if ~isempty(options.OutputDir)
        if ~isfolder(options.OutputDir), mkdir(options.OutputDir); end
        exportgraphics(figs(g),fullfile(options.OutputDir,[G.name '.png']),'Resolution',150);
    end
end
end
