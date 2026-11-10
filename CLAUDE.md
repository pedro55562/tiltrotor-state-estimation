# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Course project (Robótica Probabilística, UFMG): compare EKF vs. scaled UKF accuracy when estimating the 16 states of a tilt-rotor UAV near hover. The plant and H∞ full-state controller are imported and validated; synthetic sensors (`sensors/`) are implemented (see `sensors/README.md`); an **attitude-only EKF** (φ, θ, ψ; gyro-driven prediction, accelerometer + magnetometer corrections, sympy-generated Jacobians) is implemented in `filters/ekf/` (see its README); the full 16-state EKF and the scaled UKF (`filters/ukf_scaled/`, placeholder README) are not implemented yet. The proposal `2_Entrega___Rob_prob.pdf` (untracked) specifies the planned experiment: IMU + horizontal GPS + barometer + tilt-mechanism measurements, additive zero-mean Gaussian independent noise (diagonal R), a nominal scenario and a temporary GPS-outage scenario, and per-state RMSE over a single trajectory generated once and shared by both filters. Read its Section 3 before implementing sensors/filters.

README and folder docs are written in pt-BR.

## Commands

Requires MATLAB + Simulink only (validated on R2025a). `simulation/hover.slx` is saved in R2025a format — saving it from a newer release breaks loading in R2025a; use Export Model to > Previous Version if needed. No toolboxes (Control System, YALMIP, etc.) are needed for the normal flow.

```matlab
runHover                          % 10 s hover, writes results/hover.mat and results/hover.csv (overwrites)
run('tests/verifyHover.m')        % integration checks against the real Simulink model
run('tests/verifySensors.m')      % measurement model, rates, noise statistics, seeding
meas = generateMeasurements(result, Seed=1);  % 16-channel synthetic data, writes results/measurements.mat
cfg = setupProject();             % paths + gain validation; returns config struct
result = simulateHover(Duration=12, InitialState=x0, OriginalWind=true, SaveResults=false);
run('experiments/runHelix.m')    % 30 s smooth climbing circle, writes results/helix.mat/.csv
run('experiments/runAttitudeEKF.m')  % attitude EKF on the helix, figures in results/figures/ekf/
run('tests/verifyAttitudeEKF.m')  % generated models vs measurementModel, Jacobians vs finite differences, EKF consistency
```

From a shell: `matlab -batch "runHover"` / `matlab -batch "run('tests/verifyHover.m')"`.

`Duration` must be a multiple of `Ts = 0.004` s; `InitialState` is a 16×1 column.

`filters/ekf/attitudeProcess.m` and `attitudeMeasurement.m` are generated — edit `filters/ekf/deriveAttitudeJacobians.py` and rerun `python3 filters/ekf/deriveAttitudeJacobians.py` (needs sympy; no Symbolic Math Toolbox is installed). The full plant cannot be differentiated symbolically (table lookups with `floor`, saturations, `abs` in `GetCoefV2`/`GetCtNew2`).

## Architecture

- `setupProject.m` adds an **explicit** list of folders to the path (never use `addpath(genpath(...))` — older plant/library versions may be mixed in), asserts the project plant isn't shadowed, runs `StartParameters` (loads aero tables/globals from `plant/`), loads `controller/hoverDesign.mat` (numeric A, B, q_eq, qp_eq, u_eq, Ts extracted from historical objects) and validates `controller/LMI_GAINS_D.txt` via `validateHoverGain`. When adding new folders (e.g. subfolders of `sensors/` or `filters/`), add them to that list.
- `simulation/simulateHover.m` builds a `Simulink.SimulationInput` for `simulation/hover.slx`, passing every parameter explicitly (no reliance on base workspace), runs fixed-step `ode1` at `Ts`, and asserts logged signals share timestamps, are finite and lie on the exact time grid. Returns/saves the `result` struct (`t`, `x_true`, `x_ref`, `trajectory`, `u`, `u_nominal`, `wind`, names/units, `x_eq`, `u_eq`, `K`, `Ts`, `validation`).
- Plant: `plant/TiltRotor4dot0Trim_Hover.m` takes `[q(8); qp(8); u(4); wind(3)]` (23 inputs) and returns `qdd`. `plant/TiltRotor4dot0Model.m` is the original 27-input interface — **not interchangeable** with the hover wrapper without reordering inputs. The state derivative used everywhere is `f(x,v) = [x(9:16); TiltRotor4dot0Trim_Hover([x;v])]` (see `validateHoverGain.m`), which is the natural process model for the filters.
- Control law (inside the SLX): `u_nominal = u_eq + K*(x - x_ref(t))` on **true** states, where `x_ref` comes from the `q_ref`/`qp_ref` From Workspace blocks built by `simulation/referenceTrajectory.m` (`"hover"` = constant `x_eq`, `"helix"` = smooth climbing circle; selected with `simulateHover(Trajectory=...)`), then saturation (rotors 0–100 rev/s, torques ±10 N·m). Filters are not in the loop; per the proposal they run offline on logged data.
- `validateHoverGain` checks trim residual, numerical Jacobians vs. saved A/B, feedback sign, and Euler discrete stability. `HINF_LMI_GAINS.txt` (continuous) must be rejected with `tiltrotor:UnstableGain` — the test relies on this.

## Conventions that matter

- State order: `alpha_R alpha_L phi theta psi x y z` then their time derivatives. Indices 4–5 of each block are Euler-angle **derivatives**, not body rates p, q, r.
- `u = [n_R, n_L, tau_R, tau_L]` (rev/s, N·m). Row k of state and input are at the same `t(k)`; with Euler, `u(k)` drives the step k→k+1.
- `rotx/roty/rotz` in `plant/` are the project's own (original sign convention) and shadow toolbox versions intentionally.
- Wind is off by default; `OriginalWind=true` enables the historical step (5 m/s in x at t = 10 s) baked into the SLX via `enableOriginalWind`.
- Don't change plant dynamics, gains, saturations or solver settings in `hover.slx`; the README and `results/validation.md` document exactly which edits were made relative to the original model.
- `results/` is tracked (simulation data and figures are versioned and pushed).
