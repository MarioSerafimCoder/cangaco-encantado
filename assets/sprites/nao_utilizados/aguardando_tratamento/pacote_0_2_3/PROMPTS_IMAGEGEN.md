# Registro ImageGen — pacote visual 0.2.3

Modo utilizado: ImageGen integrado. As imagens atuais do jogo e a folha de Nilo foram usadas apenas como referências de estilo e identidade.

## 01 — HUD personalizado

```text
Use case: stylized-concept
Asset type: production source atlas for a 2D metroidvania HUD
Primary request: create a personalized pixel-art HUD kit for “Cangaço Encantado”, matching the warm Brazilian sertão chibi pixel-art style visible in the reference screenshot.
Subject: clearly separated UI pieces: one compact player status panel frame, small life diamond icons in full and empty states, a six-shot revolver cylinder ammo indicator, a two-shell shotgun indicator, two cabaça healing charge icons in full and empty states, a wide boss health bar frame with matching fill cap pieces, a narrow room-name banner, a small world-state plaque, button prompt frames, corner ornaments, separators, and small leather/iron UI rivets.
Style/medium: crisp hand-crafted 16-bit pixel art, dark leather, aged wood, oxidized iron, brass details, subtle cordel-inspired geometric ornament; game-ready strong silhouettes.
Composition/framing: atlas sheet, every element isolated with generous green gaps, no mockup screen, no characters.
Color palette: dark brown leather, umber wood, charcoal iron, muted brass, warm cream highlights, restrained red and turquoise accents.
Text: no text, no letters, no numbers.
Backdrop: perfectly flat uniform chroma-key green #00FF00 across the entire canvas.
Constraints: exact same green everywhere in the background; no gradient, texture, shadow, glow, dust, antialias halo, or transparency on the green; keep all asset edges crisp; no watermark; no extra scenery; no logos.
```

## 02 — Preenchimento da Rua

```text
Use case: stylized-concept
Asset type: production source atlas of modular 2D metroidvania environment props
Primary request: create small and medium filler props to eliminate empty spaces in the Rua das Cinzas while matching the exact sertão chibi pixel-art environment style of the reference.
Subject: isolated modular assets including six rock and rubble clusters, four dry grass and caatinga tufts, three low cactus clusters, two broken fence segments, two burnt beam piles, stacked clay roof tiles, two crate-and-sack groups, one barrel group, one broken handcart, loose planks, clay pots, scattered bones, shallow ground-edge clumps, and three narrow foreground silhouettes.
Style/medium: crisp detailed 16-bit pixel art, weathered Brazilian sertão materials, dark outlines, game-ready readable silhouettes.
Composition/framing: atlas sheet with every prop fully visible, separated by wide green gaps, no overlaps, no full scene.
Color palette: sun-baked umber, terracotta, dusty ochre, charred brown, muted cactus green, dark charcoal outlines.
Backdrop: perfectly flat uniform chroma-key green #00FF00 across the entire canvas.
Constraints: exact same green everywhere in background; no background shadows, glow, dust, gradients, texture, transparency, labels, characters, buildings, watermark, or extra scenery; crisp pixel edges and generous padding around each asset.
```

## 03 — Transições e limites

```text
Use case: stylized-concept
Asset type: production source atlas of 2D metroidvania room-transition and gap-filler architecture
Primary request: create modular architectural pieces that fill visible seams and empty transitions between Cangaço Encantado rooms, matching the sertão pixel-art style in the two reference screenshots.
Subject: isolated assets including two adobe wall end-caps, two ruined wall columns, three doorway shadow inserts, one arched passage, two wooden gate frames, two roof-edge caps, three ground-to-wall corner pieces, two short stair sets, one narrow raised walkway, two porch supports, hanging cloth strips, one dark interior opening, one broken church masonry transition, and low rubble strips that can cover floor seams.
Style/medium: crisp 16-bit pixel art, hand-built adobe, terracotta roof tile, aged wood and iron, Brazilian sertão architecture, dark readable outlines.
Composition/framing: clean atlas sheet; every piece separate and fully visible with generous padding; front or side orthographic game view; no assembled scene.
Backdrop: perfectly flat uniform chroma-key green #00FF00.
Constraints: background must be one exact green with no gradients, texture, shadow, glow, transparency, smoke or dust; no characters, no text, no logos, no watermark; assets must not overlap and must have crisp pixel edges.
```

## 04 — VFX

```text
Use case: stylized-concept
Asset type: production source atlas for animated 2D metroidvania VFX
Primary request: create clean pixel-art animation source frames for occupied Rua das Cinzas, matching the reference.
Subject: separated animation strips with equal-sized clearly spaced frames: six-frame small ground fire, six-frame brazier fire, six-frame dark smoke plume, four-frame ember sparks, four-frame foot dust, four-frame landing dust, three distinct revolver muzzle flashes, three larger shotgun muzzle flashes, four impact sparks, and two warm static light-glow sprites.
Style/medium: crisp hand-authored 16-bit pixel art effects, readable at small scale, strong silhouettes, minimal color ramps.
Composition/framing: organized atlas; each animation runs left-to-right in its own row; frames never touch or overlap; green gutter around every frame; no characters or scenery.
Backdrop: perfectly flat uniform chroma-key green #00FF00.
Constraints: no text or frame labels; exact same green background everywhere; no background texture, gradients, shadows, halos, transparency or watermark; effects themselves may contain internal glow colors but must have hard clean edges against green; no extra objects.
```

## 05 — Nilo atirando

```text
Use case: stylized-concept
Asset type: production source spritesheet for a 2D metroidvania player shooting animation
Input images: the current Nilo sheet is the identity and style reference; preserve his chibi proportions, face, brown leather cangaceiro hat, red scarf, cream shirt, brown clothing, outline weight and pixel-art palette.
Primary request: create two left-to-right animation strips for Nilo shooting while facing right.
Subject: top strip REVOLVER with six distinct full-body frames: steady idle, raise revolver, aim anticipation, muzzle-fire recoil, recoil peak, settle back to aim. Bottom strip SHOTGUN with six distinct full-body frames: steady idle, bring long shotgun forward, brace, muzzle-fire with stronger recoil, recoil peak with planted feet, recover. Keep feet on one identical baseline in all grounded frames.
Composition/framing: exactly two horizontal rows of six isolated equal-scale full-body poses; generous green gutter between frames; every frame fully visible; consistent character size and pivot; all characters face right.
Backdrop: perfectly flat uniform chroma-key green #00FF00.
Constraints: do not redesign Nilo; no extra characters; no detached limbs; no duplicated weapons; no text, labels, grid lines, shadows on the background, gradients, texture, transparency, logos or watermark; exact same green background everywhere; crisp clean edges.
```

O primeiro resultado desta folha veio com fundo preto. Foi feita uma edição adicional pedindo para trocar somente o fundo por `#00FF00`, preservando as doze poses.

