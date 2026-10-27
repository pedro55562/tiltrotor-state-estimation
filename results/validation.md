# Validação executada

Executada via MATLAB MCP em 27/10/2026, MATLAB/Simulink R2026b.

- `runHover.m`: completou 10 s, com 2.501 amostras, 16 estados e 4 entradas aplicadas.
- Máximo desvio dos estados no hover sem perturbação: 1,81685e-10 (comparação componente a componente nas unidades originais).
- `tests/verifyHover.m`: executado e concluído com PASS para rejeição do ganho contínuo, equilíbrio, recuperação de rolagem de 1°, timestamps, finitude e limites dos atuadores.
- Norma euclidiana do desvio do estado no teste de rolagem: 0,0174533 inicialmente e 2,74608e-5 após 10 s. É uma métrica numérica com unidades mistas, usada apenas como regressão.
- Comparação de 10 s com o SLX histórico, usando a mesma perturbação, ganho e vento: máximo erro absoluto dos estados 7,92e-16; entradas aplicadas 2,14e-14.
- CSV relido: 2.501 linhas × 28 colunas; estados conferidos contra o resultado MATLAB com tolerância 1e-12.
- Caso de vento histórico: 12 s, 3.001 amostras; vento zero antes de 10 s e componente x igual a 5 m/s a partir desse instante. Asserções executadas com PASS.
- Execução com o SLX inicialmente fechado: 10 s completos.
- Portabilidade: cópia em outra pasta de /tmp, com resolução da planta e do SLX dessa cópia, executou 10 s completos.
- Referência histórica: 1.852 arquivos conferidos byte a byte; 44 arquivos da planta copiados sem alteração, com apenas os caminhos de StartParameters adaptados.
- Analisador de código MATLAB: sem ocorrências nos cinco arquivos novos de código executável.
- `model_check`: healthy, sem problemas de conectividade.
- Análise estática de dependências da execução e da planta completa: MATLAB e Simulink, sem arquivos externos ao projeto. A resolução por expressão do bloco interpretado foi conferida pela execução real.

Compatibilidade do ganho discreto original:

| Métrica | Valor |
| --- | ---: |
| Resíduo do equilíbrio (norma infinito) | 1,16985e-8 |
| Erro relativo de A por diferenças centrais | 1,08788e-10 |
| Erro relativo de B por diferenças centrais | 3,18719e-12 |
| Raio espectral do Euler com LMI_GAINS_D | 0,999318327 |
| Raio espectral do Euler com ganho contínuo | 2,70601586 |

O único aviso observado nas simulações foi a futura remoção da inicialização `Classic`. Não foi alterada a configuração histórica para silenciá-lo. A validação cobre hover local e uma pequena perturbação; não recertifica o desempenho H∞ e não testa toda a envoltória de voo.
