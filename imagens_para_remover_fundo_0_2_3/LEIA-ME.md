# Imagens para remover o fundo — pacote 0.2.3

Este pacote cobre lacunas percebidas no playtest da versão 0.2.2.

| Arquivo | Uso planejado |
|---|---|
| `01_hud_personalizado.png` | painéis, vida, munição, Cabaça, boss bar e ornamentos |
| `02_props_preenchimento_rua.png` | pedras, vegetação, caixas, cercas, entulho e silhuetas de foreground |
| `03_transicoes_e_limites.png` | portais, paredes, escadas, beirais e cobertura de emendas entre salas |
| `04_vfx_ocupacao_e_tiros.png` | fogo, fumaça, poeira, flashes e impactos animados |
| `05_nilo_animacoes_de_tiro.png` | seis poses de revólver e seis poses de espingarda |

## Como devolver

- Remova somente o verde.
- Exporte como PNG RGBA com transparência real.
- Preserve exatamente o nome e as dimensões de cada canvas.
- Não recorte automaticamente nem reposicione os elementos.
- Remova halos verdes sem apagar contornos escuros, fogo ou detalhes internos.
- Deixe os cinco arquivos corrigidos nesta pasta e avise quando terminar.

O jogo ainda não consome esses PNGs. Isso evita que o chroma verde apareça na build. Depois da devolução, os assets serão recortados por `AtlasTexture` ou convertidos em spritesheets com células consistentes.

## Dimensões e amostras do verde

| Arquivo | Canvas | Verde no canto superior esquerdo |
|---|---:|---:|
| `01_hud_personalizado.png` | 1536x1024 | `#12F20F` |
| `02_props_preenchimento_rua.png` | 1536x1024 | `#10F10D` |
| `03_transicoes_e_limites.png` | 1536x1024 | `#10F20C` |
| `04_vfx_ocupacao_e_tiros.png` | 1536x1024 | `#10F00E` |
| `05_nilo_animacoes_de_tiro.png` | 1771x888 | `#23F01D` |

O ImageGen produziu tons verdes muito próximos, mas não um `#00FF00` matematicamente exato. Use seleção por faixa/tolerância e confira as bordas do fogo, dos cactos e da roupa antes de apagar.
