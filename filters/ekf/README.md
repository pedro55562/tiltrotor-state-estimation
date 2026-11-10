# EKF

Primeira etapa: **EKF só de atitude** ($\eta = [\phi,\ \theta,\ \psi]^T$), com Jacobianas simbólicas. O EKF de 16 estados da proposta (Seção 3.4), com a planta completa como modelo de processo, ainda não foi implementado.

## Modelo do EKF de atitude

**Predição** (todo passo $T_s$, giroscópio como entrada, mesma regra de Euler da planta):

$$\eta_{k+1} = \eta_k + T_s\,W_\eta(\eta_k)^{-1}\tilde\omega_k,\qquad P_{k+1|k} = F P F^T + G\,\sigma_g^2 I\,G^T,$$

com $F = \partial\eta_{k+1}/\partial\eta$ e $G = T_s W_\eta^{-1}$. O ruído do giroscópio ($\sigma_g = 0{,}005$ rad/s) define $Q_k$.

**Correção**, só com amostras novas (`meas.available`), forma de Joseph:

| Canais | Modelo $h(\eta)$ | σ usado no filtro |
|---|---|---|
| 4–6 acelerômetro | $R_{IB}^T(-g^I)$ (supõe $\ddot\xi = 0$) | 2 m/s² |
| 7–9 magnetômetro | $R_{IB}^T m^I$ | o de `sensorConfig` (5×10⁻⁷ T) |

O σ do acelerômetro no filtro é bem maior que o do sensor (0,05 m/s²). A aceleração ignorada, de até 0,375 m/s² na hélice, é um erro correlacionado no tempo, e não ruído branco. Varredura na hélice: com σ = 0,3 o NEES médio fica em ≈ 105 (filtro otimista demais); com 1, em ≈ 4,4; com 2, em ≈ 1,75, com o menor RMSE.

**Início:** $\hat\eta_0 = \eta_{true}(0) + [3°,\ -3°,\ 5°]$ e $P_0 = \mathrm{diag}(5°,\ 5°,\ 10°)^2$.

## Resultado na hélice (30 s, `Seed=1`)

RMSE: φ 0,26°, θ 0,07°, ψ 0,27°; após 5 s: 0,20°, 0,05°, 0,17°. NEES médio de 1,75 (n = 3), e 100 % das amostras dentro de ±3σ. O φ fica ligeiramente atrasado entre 3 e 10 s, por causa da aceleração lateral não modelada. Figuras em `results/figures/ekf/`:

- `attitude.png`: estimativa × verdade;
- `error_3sigma.png`: erro com o envelope ±3σ de $P$;
- `nees.png`: NEES com a banda de 95 % do χ²₃.

## Arquivos

- `deriveAttitudeJacobians.py`: deriva com sympy o modelo e as Jacobianas, e gera os dois arquivos abaixo. Depois de alterar o modelo, regenere com `python3 filters/ekf/deriveAttitudeJacobians.py`; o Python só é necessário para isso.
- `attitudeProcess.m` (gerado): `[eta1, F, G] = attitudeProcess(eta, omega, Ts)`.
- `attitudeMeasurement.m` (gerado): `[h, H] = attitudeMeasurement(eta, g_I, m_I)`, 6×1 e 6×3.
- `ekfAttitude.m`: `est = ekfAttitude(result, meas, AccelSigma=2, InitialError=..., P0=...)`. Retorna `x_hat`, `P` (3×3×N), `err`, `sigma`, `rmse`, `nees` e `neesMean`.
- `plotAttitudeEKF.m`: as três figuras acima, com `OutputDir` opcional.

## Uso

```matlab
run('experiments/runAttitudeEKF.m')   % hélice, figuras em results/figures/ekf/
run('tests/verifyAttitudeEKF.m')      % modelos, Jacobianas × diferenças finitas, consistência
```
