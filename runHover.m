%RUNHOVER Simulate 10 seconds of nonlinear hover and export true states.
% Run from this folder. See simulateHover for duration/initial-state options.
setupProject();
hoverResult = simulateHover();
fprintf('Hover: %d samples, %.3f s. Results: %s\n', ...
    numel(hoverResult.t),hoverResult.t(end),fullfile(fileparts(mfilename('fullpath')),'results'));
