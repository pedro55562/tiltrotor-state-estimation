function [qRef, qpRef] = referenceTrajectory(name, t, cfg)
%REFERENCETRAJECTORY Reference q_ref(t), qp_ref(t) (N-by-8 each) for the loop.
% "hover": constant equilibrium. "helix": smooth climbing circle starting at
% rest at the equilibrium; only x, y, z (and their rates) leave q_eq.
t = t(:);
N = numel(t);
qRef = repmat(cfg.q_eq',N,1);
qpRef = repmat(cfg.qp_eq',N,1);
switch name
    case "hover"
    case "helix"
        R = 1;          % circle radius, m
        omega = 0.5;    % final angular rate, rad/s (speed R*omega = 0.5 m/s)
        Tr = 4;         % smooth spin-up of the angular rate, s
        H = 1;          % climb, m
        Tz = 20;        % climb duration, s
        tau = min(t/Tr,1);
        s = 10*tau.^3-15*tau.^4+6*tau.^5;                     % rate ramp 0 -> 1
        intS = Tr*(2.5*tau.^4-3*tau.^5+tau.^6)+max(t-Tr,0);  % integral of s
        phi = omega*intS;
        dphi = omega*s;
        tz = min(t/Tz,1);
        qRef(:,6) = qRef(:,6)+R*sin(phi);
        qRef(:,7) = qRef(:,7)+R*(1-cos(phi));
        qRef(:,8) = qRef(:,8)+H*(10*tz.^3-15*tz.^4+6*tz.^5);
        qpRef(:,6) = R*cos(phi).*dphi;
        qpRef(:,7) = R*sin(phi).*dphi;
        qpRef(:,8) = H/Tz*(30*tz.^2-60*tz.^3+30*tz.^4);
    otherwise
        error('tiltrotor:UnknownTrajectory','Unknown trajectory "%s".',name);
end
end
