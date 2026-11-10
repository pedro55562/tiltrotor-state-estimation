%RUNHELIX Simulate 30 s tracking a smooth climbing circle (see referenceTrajectory).
% Writes results/helix.mat and results/helix.csv (overwrites).
addpath(fileparts(fileparts(mfilename('fullpath'))));
setupProject();
helixResult = simulateHover(Duration=30,Trajectory="helix");
positionError = vecnorm(helixResult.x_true(:,6:8)-helixResult.x_ref(:,6:8),2,2);
fprintf('Helix: %d samples, %.3f s, max position tracking error %.3f m.\n', ...
    numel(helixResult.t),helixResult.t(end),max(positionError));
