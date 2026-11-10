# Experimentos

O caso base é executado por runHover.m na raiz. simulateHover aceita Duration, InitialState, OriginalWind, Trajectory e SaveResults. Novos experimentos poderão ser adicionados aqui sem alterar a dinâmica ou o controlador.

- `runHelix.m`: 30 s seguindo a hélice suave (`Trajectory="helix"`); grava `results/helix.mat` e `results/helix.csv`.
