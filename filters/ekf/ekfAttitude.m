function est = ekfAttitude(result, meas, options)
%EKFATTITUDE Attitude-only EKF for eta = [phi; theta; psi].
% est = ekfAttitude(result, meas, AccelSigma=2, InitialError=..., P0=...)
% Prediction integrates the gyro (channels 1-3) every step with the plant's
% Euler rule; corrections use only new accelerometer (4-6, assuming
% xi_dd = 0) and magnetometer (7-9) samples, with the Joseph update.
% AccelSigma (m/s^2) is inflated well above the sensor's 0.05 because the
% neglected acceleration is time-correlated, not white (helix sweep:
% 0.3 -> mean NEES ~105, 1 -> ~4.4, 2 -> ~1.75 with the lowest RMSE).
% result gives the truth (x_true columns 3-5) and Ts; meas comes from
% generateMeasurements.
arguments
    result (1,1) struct
    meas (1,1) struct
    options.AccelSigma (1,1) double {mustBePositive} = 2
    options.InitialError (3,1) double = deg2rad([3;-3;5])
    options.P0 (3,3) double = diag(deg2rad([5;5;10]).^2)
end
sensors = meas.sensors;
Ts = result.Ts;
N = numel(meas.t);
assert(all(meas.available(:,1:3),'all'), ...
    'tiltrotor:GyroRate','The gyro must be available at every step.');
Qgyro = diag(sensors.sigma(1:3).^2);
sigmaCorr = [repmat(options.AccelSigma,3,1);sensors.sigma(7:9)];
etaTrue = result.x_true(:,3:5);

x = etaTrue(1,:)'+options.InitialError;
P = options.P0;
est.x_hat = zeros(N,3);
est.P = zeros(3,3,N);
for k = 1:N
    if k > 1
        [x,F,G] = attitudeProcess(x,meas.y(k-1,1:3)',Ts);
        P = F*P*F'+G*Qgyro*G';
    end
    idx = find(meas.available(k,4:9));
    if ~isempty(idx)
        [h,H] = attitudeMeasurement(x,sensors.g_I,sensors.m_I);
        H = H(idx,:);
        Rk = diag(sigmaCorr(idx).^2);
        nu = meas.y(k,3+idx)'-h(idx);
        S = H*P*H'+Rk;
        K = (P*H')/S;
        x = x+K*nu;
        IKH = eye(3)-K*H;
        P = IKH*P*IKH'+K*Rk*K';
    end
    est.x_hat(k,:) = x';
    est.P(:,:,k) = P;
end

est.t = meas.t;
est.x_true = etaTrue;
est.stateNames = {'phi','theta','psi'};
est.err = mod(est.x_hat-etaTrue+pi,2*pi)-pi;
est.sigma = sqrt([squeeze(est.P(1,1,:)),squeeze(est.P(2,2,:)),squeeze(est.P(3,3,:))]);
est.nees = zeros(N,1);
for k = 1:N
    est.nees(k) = est.err(k,:)*(est.P(:,:,k)\est.err(k,:)');
end
est.rmse = sqrt(mean(est.err.^2,1));
est.neesMean = mean(est.nees);
est.options = options;
end
