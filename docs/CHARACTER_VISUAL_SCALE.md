# Escala visual canônica dos personagens

## Referência de Nilo

A referência oficial foi medida diretamente nos PNGs importados, usando pixels com alfa igual ou superior a 128. O frame idle de Nilo possui 53 px úteis. Na escala-base histórica de `0.68`, sua altura aparente é:

```text
53 × 0,68 = 36,04 px
```

Portanto, `36,04 px` é o `target_visual_height` canônico desta build. O valor não foi arredondado para o exemplo conceitual de 43–45 px porque isso aumentaria o personagem em relação à locomoção já aprovada.

O limite inferior do frame idle está na borda do pixel 64. Com pivot central de 32 px, posição visual `y=-10` e escala `0.68`, a baseline visual fica a `11,76 px` do centro do `CharacterBody2D`. O pé físico fica a 12 px; a diferença subpixel de 0,24 px preserva o contorno sem afundá-lo no solo.

## Normalização por frame

`NiloVisualController` armazena a altura útil e a borda inferior útil de cada frame. A escala é calculada por:

```text
scale = target_visual_height / useful_frame_height
```

Depois, o pivot vertical é recalculado para manter a baseline canônica. Isso vale para a folha 4×4, revólver e espingarda. Squash, recoil e antecipação são aplicados depois da normalização e continuam sendo variações intencionais.

| Sequência | Altura útil do source | Escala normalizada aproximada |
|---|---:|---:|
| Idle de referência | 53 px | 0,680 |
| Corrida | 48–51 px | 0,707–0,751 |
| Revólver | 270–290 px | 0,124–0,133 |
| Espingarda | 271–286 px | 0,126–0,133 |

## Proporção do elenco

As diferenças abaixo são intencionais e foram calibradas a partir do primeiro frame útil de cada folha.

| Personagem | Altura-alvo | Proporção sobre Nilo | Papel visual |
|---|---:|---:|---|
| Nilo | 36,04 px | 1,00 | Referência canônica |
| Pistoleiro | 35,0 px | 0,97 | Humano ágil, silhueta estreita |
| Saqueador | 38,5 px | 1,07 | Mais largo e fisicamente ameaçador |
| Zé Tranca | 47,1 px | 1,31 | Boss dominante, sem ocupar a arena inteira |

## Baseline e sombras

- A borda inferior útil do sprite deve coincidir visualmente com o pé do collider.
- `ContactShadow2D` usa o offset físico de cada personagem e permanece no último chão conhecido durante salto ou queda.
- No ar, a sombra diminui e perde opacidade; não acompanha verticalmente o corpo.
- Ao substituir uma folha, medir altura útil e borda inferior. Não ajustar escala ou posição “a olho” com um multiplicador global.

## Validação

`game_feel_validation.tscn` compara altura e baseline normalizadas em idle, corrida, revólver e espingarda com tolerância de `0,05 px`. A captura `nilo_comparacao_escala.png` mostra as quatro poses na mesma linha de chão.
