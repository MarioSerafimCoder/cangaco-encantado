---
name: cangaco-2d-assets
description: Inspeciona, corrige, prepara e integra sprites, spritesheets, atlas, tiles, props, FX e animações 2D do Cangaço Encantado. Use em transparência, recorte, escala, baseline, pivô, grid, importação ou consistência visual de pixel art.
---

# Cangaço 2D Assets

Preserve os assets aprovados e a identidade pixel art. Use geração somente quando a auditoria demonstrar uma lacuna real.

## Trabalho

1. Inspecione arquivo-fonte, import settings, regiões de atlas, frames, nós visuais e código de animação.
2. Meça conteúdo visível, transparência, baseline, pivô, anchor e bounding box.
3. Descubra se a falha vem do arquivo, região, offset, escala, importação ou transição de animação.
4. Corrija a causa; não compense cada animação com escalas arbitrárias.
5. Integre mantendo nearest filtering, pixel snap e alinhamento ao grid lógico do projeto.
6. Renderize em gameplay e compare ações, direções e estados.

Leia [references/sprite-qc.md](references/sprite-qc.md) para auditorias de personagem, atlas ou clipping.

Quando `generate2dsprite` estiver disponível, use-o primeiro como inspetor, validador e processador. Não regenere automaticamente o acervo existente.
