# Imagens para remover o fundo

Estas são cópias de trabalho. As cinco correções já foram integradas ao jogo com transparência RGBA real.

Ao editar:

- exporte como PNG RGBA com transparência real;
- não recorte nem redimensione a tela;
- preserve exatamente a posição e a escala dos desenhos;
- remova somente o fundo claro/quadriculado;
- mantenha o mesmo nome do arquivo desta pasta.

## Destinos no projeto

| Arquivo desta pasta | Destino | Situação |
|---|---|---|
| `01_rua_village_mid_remover_fundo.png` | `assets/environments/rua_das_cinzas/source/rua_village_mid_source.png` | Integrado |
| `02_rua_foreground_remover_fundo.png` | `assets/environments/rua_das_cinzas/source/rua_foreground_source.png` | Integrado |
| `03_saqueador_folha.png` | — | Primeira tentativa descartada por ter sido recortada |
| `PENDENTE_03_saqueador_MANTER_1448x1086.png` | `assets/enemies/saqueador_concept_sheet.png` | Integrado em 1448x1086 |
| `04_pistoleiro_folha_remover_fundo.png` | `assets/enemies/pistoleiro_concept_sheet.png` | Integrado |
| `05_ze_tranca_folha_remover_fundo.png` | `assets/bosses/ze_tranca_concept_sheet.png` | Integrado |

As duas imagens da Rua das Cinzas foram reprocessadas em 640x360 com interpolação nearest-neighbor e alfa preservado.

Nenhum shader de remoção de fundo permanece ativo no jogo.
