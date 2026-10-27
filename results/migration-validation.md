# Validação da migração

Data: 27/10/2026. MATLAB/Simulink R2026b.

- A versão funcional foi copiada para o repositório definitivo, com 64 arquivos conferidos por SHA-256 e estrutura preservada.
- O conteúdo anterior foi salvo antes de cada atualização em `.migration-backups/`, com arquivos TAR.GZ e manifestos. O backup original contém 1.852 arquivos e o backup da atualização contém 74 arquivos. Os backups permanecem locais, fora do versionamento.
- Os metadados Git do destino foram preservados durante a cópia; nenhum metadado Git da origem foi copiado.
- A pasta de origem foi novamente conferida por SHA-256 após os testes e permanece inalterada.
- Código e modelo sem caminhos absolutos antigos. A referência histórica do README foi ajustada para o backup local.
- `runHover`: PASS, 10 s, passo de 0,004 s, 2.501 amostras, 16 estados e 4 entradas. A resolução da planta e do modelo foi conferida no destino.
- `tests/verifyHover.m`: PASS para rejeição do ganho incompatível, equilíbrio, recuperação de rolagem, timestamps, finitude, limites dos atuadores e degrau de vento original.
- Exportação MAT/CSV: arquivos regenerados, CSV relido com 2.501 linhas e 28 colunas; tempo, estados, entradas aplicadas/nominais e vento conferidos contra o MAT com tolerância de 1e-12.
- Máximo desvio dos estados no hover: 1,81684547246e-10.
- Norma do erro no teste de rolagem: inicial 0,0174532925199; final 2,7460837009e-5 após 10 s. Essa métrica tem unidades mistas e é usada como regressão.
- Caso de vento: 12 s e 3.001 amostras, asserções aprovadas.
- Único aviso: futura remoção da inicialização `Classic` do Simulink, já conhecido na versão funcional.
- Nenhum filtro foi implementado.

O log completo desta execução está em `results/migration-validation.log`, gerado localmente e ignorado pelo Git. Os resultados MAT/CSV também são ignorados e podem ser regenerados com `runHover`. A validação histórica da versão funcional permanece em `results/validation.md`.
