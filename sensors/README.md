# Sensores

Medições sintéticas da Seção 3.3 da proposta (eq. 24), geradas offline a partir do resultado de `simulateHover`:

$$y_k = h(x_k^{true}, u_k) + v_k,\qquad v_k \sim \mathcal{N}(0, R),\quad R = \mathrm{diag}(\sigma_1^2,\dots,\sigma_{16}^2)$$

Ruído branco gaussiano, de média zero, independente entre canais e instantes, sem bias.

| Canais | Sensor | Modelo | Unidade | Frequência | σ |
|---|---|---|---|---:|---|
| 1–3 | Giroscópio | $W_\eta(\phi,\theta)\dot\eta$ | rad/s | 250 Hz | 0,005 |
| 4–6 | Acelerômetro | $(R_B^I)^T(\ddot\xi - g^I)$ | m/s² | 250 Hz | 0,05 |
| 7–9 | Magnetômetro | $(R_B^I)^T m^I$ | T | 50 Hz | 5×10⁻⁷ |
| 10–11 | GPS horizontal | $[x,\ y]^T$ | m | 10 Hz | 1,0 |
| 12 | Barômetro | $z$ | m | 50 Hz | 0,2 |
| 13–14 | Inclinação | $[\alpha_R,\ \alpha_L]^T$ | rad | 250 Hz | 0,002 |
| 15–16 | Vel. de inclinação | $[\dot\alpha_R,\ \dot\alpha_L]^T$ | rad/s | 250 Hz | 0,02 |

Os desvios-padrão são parâmetros adotados na simulação, não especificações de um equipamento.

## Convenções

- $R_B^I = R_z(\psi)R_y(\theta)R_x(\phi)$, com as funções `rotx/roty/rotz` de `plant/`; $g^I = [0,\ 0,\ -9{,}8]^T$ m/s²; eixo $z$ para cima.
- $\ddot\xi$ vem de `TiltRotor4dot0Trim_Hover([x; u; vento])`, avaliado em $u_k$ e no vento do mesmo instante $t_k$.
- Campo magnético adotado: aproximação para Belo Horizonte (|m| ≈ 23 µT, inclinação ≈ −36°), com $x$ apontando para o norte magnético: $m^I = [18{,}6;\ 0;\ 13{,}5]\times10^{-6}$ T (componente vertical positiva porque, no Brasil, o campo aponta para cima).
- No pairado ($\theta \approx 0{,}137$ rad), o acelerômetro mede ≈ $[-1{,}34;\ 0;\ 9{,}71]$ m/s².

## Arquivos

- `sensorConfig.m`: nomes, unidades, σ, taxas, decimação em relação a `Ts`, `R`, `g_I`, `m_I`.
- `measurementModel.m`: $h(x, u, \text{vento})$ sem ruído (16×1); também será usado pelos filtros.
- `generateMeasurements.m`: gera as medições para toda a trajetória.
- `plotMeasurements.m`: gráficos de verdade $h(x^{true},u)$ × medição, uma figura por sensor (giroscópio, acelerômetro, magnetômetro, posição GPS/barômetro, inclinação).

## Uso

```matlab
result = simulateHover(SaveResults=false);
meas = generateMeasurements(result, Seed=1);   % grava results/measurements.mat
plotMeasurements(meas, OutputDir='results/figures');   % opcional: salva PNGs
```

Campos de `meas`: `t`, `y` (N×16, `NaN` onde não há amostra nova), `available` (máscara lógica N×16, base da matriz de seleção $A_k$), `y_clean`, `noise`, `seed`, `sensors`, `channelNames`, `channelUnits`.

A amostra $k$ de um canal com decimação $d$ está disponível quando $\bmod(k-1, d) = 0$; em $t = 0$ todos os canais estão disponíveis. O ruído é gerado para todos os instantes com um `RandStream` próprio (o `rng` global não é alterado), de modo que a realização não depende da disponibilidade: o cenário de interrupção do GPS altera apenas a máscara.

Testes: `run('tests/verifySensors.m')`.
