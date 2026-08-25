# Prints do jogo

Esta pasta mantém as capturas visuais oficiais da build atual. Os arquivos devem ser sobrescritos sempre que houver uma mudança visual grande em personagens, HUD, cenário, iluminação ou VFX.

## Atualização automática

Execute a cena Godot:

```text
res://tools/mvp_visual_test.tscn
```

Ela atualiza as capturas com nomes descritivos da ação apresentada:

- `andando_no_mapa_01.png`
- `dano_de_personagem.png`
- `combate_com_ze_tranca.png`
- `vila_libertada_praca_do_umbu.png`

As grandes mudanças ambientais também atualizam `ambiente_01_...png` até `ambiente_13_...png`, com uma captura para cada sala que recebeu o novo kit visual. A Rua das Cinzas permanece representada por `andando_no_mapa_01.png`.

Não use nomes genéricos como `screenshot1.png`. Se uma nova captura for adicionada, o nome deve descrever claramente a ação, personagem ou local mostrado.
