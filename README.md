# Tilt-rotor: estimação de estados

Base para Robótica Probabilística: planta não linear original com 16 estados, controle H∞ existente e exportação de dados para futuros EKF e UKF escalonado. **Os filtros e os sensores ainda não estão implementados.**

## Executar

No MATLAB, abra esta pasta e execute:

```matlab
runHover
```

O script configura os paths, valida o ganho salvo e executa 10 s de hover sem vento, com Euler (ode1) e passo de 0,004 s. Gera `results/hover.mat` e `results/hover.csv`; uma nova execução sobrescreve esses dois resultados. Não é preciso executar síntese de controle.

Dependências de execução: **MATLAB e Simulink**. Validado no MATLAB/Simulink R2026b. As matrizes de projeto e o equilíbrio foram extraídos dos objetos históricos para arrays numéricos em `controller/hoverDesign.mat`, evitando exigir Control System Toolbox ou Simulink Control Design no uso cotidiano. YALMIP, SeDuMi, Optimization Toolbox e Robotics System Toolbox não são necessários para este fluxo.

Configuração e outros experimentos:

```matlab
cfg = setupProject();
result = simulateHover(Duration=20, SaveResults=false);

x0 = cfg.x_eq;
x0(3) = x0(3) + deg2rad(1);
result = simulateHover(Duration=10, InitialState=x0, SaveResults=false);

% Mantém os degraus de vento do modelo histórico (primeiro degrau em 10 s):
result = simulateHover(Duration=12, OriginalWind=true, SaveResults=false);
```

A duração deve ser múltipla de 0,004 s. `InitialState` é um vetor coluna 16×1. `SimulationInput` recebe explicitamente os parâmetros e condições iniciais, sem depender de variáveis anteriores do workspace.

## Estrutura

| Pasta/arquivo | Conteúdo |
| --- | --- |
| `plant/` | Dinâmica original, parâmetros físicos, rotações e tabelas aerodinâmicas |
| `controller/` | Ganhos históricos, projeto numérico do hover e validação de compatibilidade |
| `simulation/` | `hover.slx`, derivado do modelo original, e função de execução/exportação |
| `sensors/` | Reservada para modelos de medição e ruído |
| `filters/ekf/`, `filters/ukf_scaled/` | Reservadas; sem filtros implementados |
| `experiments/` | Reservada para configurações reproduzíveis |
| `results/` | MAT/CSV gerados e relatório da validação executada |
| `tests/` | Verificação de integração usando o Simulink real |
| `setupProject.m`, `runHover.m` | Inicialização e script principal |

Os paths são adicionados explicitamente. Não use `addpath(genpath(...))`: isso pode misturar outras versões dos modelos e bibliotecas históricas. As funções `rotx/roty/rotz` preservadas usam a convenção original do projeto.

## Planta e controlador preservados

O hover usa `TiltRotor4dot0Trim_Hover`: as oito coordenadas e oito derivadas entram na dinâmica original, com quatro comandos, vento e superfícies aerodinâmicas fixas em zero. `TiltRotor4dot0Model.m` também foi preservado; sua interface original de 27 entradas difere da interface de 23 entradas do wrapper de hover. Não são intercambiáveis sem adaptar a ordenação.

A lei de controle continua `u_nominal = u_eq + K*(x - x_eq)`, com realimentação dos estados reais e as saturações originais: rotores entre 0 e 100 rev/s e torques entre −10 e 10 N·m. Ainda não há estados estimados na malha.

O ganho reutilizado é `LMI_GAINS_D.txt` (4×16), sem alteração dos valores. A inicialização verifica dimensões, resíduo do equilíbrio, Jacobianos numéricos da planta, sinal da realimentação, polos contínuos e estabilidade com Euler no passo original. O ganho contínuo `HINF_LMI_GAINS.txt` permanece como referência e é rejeitado para este passo de integração. **Essa validação é local e não constitui nova certificação do limite H∞ nem garantia de estabilidade global.**

Alterações no modelo: renomeado para `hover.slx`; registros configurados para amostrar em `Ts`; amplitude dos degraus de vento parametrizada por `enableOriginalWind`; constante de torque direito corrigida de `tauL_eq` para `tauR_eq` (iguais no equilíbrio original). Topologia, dinâmica, lei de controle, saturações, integradores e solver foram preservados. O experimento padrão desativa temporariamente o vento por `SimulationInput`; os degraus históricos continuam no SLX. `StartParameters.m` mantém as mesmas tabelas/globais, carregadas relativamente à sua própria localização.

O aviso de futura remoção da inicialização `Classic` no Simulink é conhecido e não impediu a execução. A configuração histórica foi mantida.

## Dados para os futuros filtros

`load('results/hover.mat')` fornece a struct `result`:

| Campo | Formato e significado |
| --- | --- |
| `t` | N×1, segundos, incluindo 0 e o tempo final |
| `x_true` | N×16, estados reais |
| `u` | N×4, comandos efetivamente aplicados após saturação |
| `u_nominal` | N×4, comandos antes da saturação |
| `wind` | N×3, vento externo [x,y,z], m/s |
| `stateNames/stateUnits` | Nomes e unidades das colunas de estado |
| `inputNames/inputUnits` | Nomes e unidades dos comandos |
| `x_eq/u_eq/K/Ts` | Equilíbrio, ganho e passo utilizados |
| `validation` | Métricas da compatibilidade do ganho |

Ordem de `x_true`:

```text
alpha_R alpha_L phi theta psi x y z
dalpha_R dalpha_L dphi dtheta dpsi dx dy dz
```

Os cinco primeiros elementos de cada linha acima são ângulos (rad) ou suas derivadas (rad/s); os três últimos são posições (m) ou velocidades (m/s). As derivadas dos ângulos de Euler **não são** as velocidades angulares corporais p, q, r. As convenções de referência e sinais são as da planta original.

`u = [n_R, n_L, tau_R, tau_L]`, com n em rev/s e torque em N·m. Cada linha contém estado e entrada no mesmo instante `t(k)`. No Euler original, a entrada nesse instante determina a aceleração do passo seguinte. Os registros não são interpolados. Ainda não existe medição sintética `y` nem ruído. O CSV possui 28 colunas: tempo, 16 estados, 4 entradas aplicadas, 4 nominais e 3 componentes de vento.

## Verificar

```matlab
run('tests/verifyHover.m')
```

O script executa a planta real para verificar equilíbrio, recuperação de uma perturbação de 1° em rolagem, timestamps, finitude, limites dos atuadores, rejeição do ganho incompatível e um caso de 12 s com o degrau original de vento. Resultados efetivamente medidos, comparação com o modelo histórico e limites da validação estão em `results/validation.md`.

## Origem e referência histórica

Esta versão foi montada a partir de `ModeloDaniel-Hinf` do projeto `Trabalho-de-TCPI-main`. A pasta originalmente aberta continha o instalador do MATLAB; por isso a versão enxuta foi criada como pasta própria, dentro da área gravável, sem modificar a origem.

O conteúdo anterior do destino foi preservado localmente em **`.migration-backups/20261027-011311/destination-before-copy.tar.gz`**, com os modelos alternativos, scripts históricos e YALMIP. Novos backups de atualização e seus manifestos de integridade também ficam em `.migration-backups/`. Esses arquivos estão fora do path e do controle de versão; não são necessários para executar o projeto. O `.git` do destino foi preservado durante a cópia.

A versão de trabalho contém somente a cadeia de dependências necessária à planta, suas tabelas, um modelo Simulink e os ganhos/dados de hover. Nenhum filtro foi implementado.
