# Registro de geração visual — 0.2.1

Referências usadas em todas as criações:

- `prints_do_jogo/andando_no_mapa_01.png`
- `assets/characters/nilo_concept_sheet.png`

## Céu e distância

Modo: criação de asset.

Saída integrada: `assets/environments/rua_das_cinzas/rua_sky_far.png`.

Prompt:

> Create a production-ready ultra-wide 32:9 panoramic raster layer for a 2D metroidvania called "Cangaço Encantado". This is the SKY AND FAR DISTANCE layer of Rua das Cinzas, a dusty occupied sertão village in northeastern Brazil. Match the attached references only for the project's warm earthy pixel-art language and gameplay readability. Authentic crisp 16-bit pixel art with deliberate pixel clusters, limited palette, no antialiasing, no gradients that look digital-smooth. Full-bleed opaque image: pale dusty cyan-to-cream sky, thin atmospheric haze, distant layered caatinga hills and mesas, a few tiny far birds, subtle smoke plumes rising from outside the lower frame. Low contrast and low detail so a chibi hero remains readable. One continuous horizon; no repeated suns. No sun disc, no foreground, no houses, no ground, no characters, no enemies, no UI, no lettering, no logos, no border. Composition must tile visually at left and right edges if extended, while remaining a single continuous landscape.

## Vila intermediária

Modo: criação de asset.

Saída integrada: `assets/environments/rua_das_cinzas/rua_village_mid.png`.

Prompt:

> Create a production-ready ultra-wide 32:9 transparent raster layer for a 2D metroidvania called "Cangaço Encantado". This is the MIDGROUND VILLAGE layer for Rua das Cinzas, a dusty occupied sertão settlement in northeastern Brazil. Match the attached references for warm earthy pixel-art language and gameplay readability. Authentic crisp 16-bit pixel art, deliberate pixel clusters, limited palette, hard pixel edges, no antialiasing. Arrange a sparse continuous village silhouette along the lower half: small plaster-and-adobe houses with clay roof tiles, one ruined wall, wooden fences and gates, telegraph poles, dry caatinga brush, subtle charcoal smoke, torn cloth on one line, and occupation-era barricade details. Use muted ochre, terracotta, dusty brown and desaturated teal accents. Keep the central gameplay corridor readable and avoid a solid dark band. TRUE TRANSPARENT ALPHA everywhere outside the objects; preserve empty transparent sky above and transparent gaps between buildings. No checkerboard pattern, no painted background, no sky, no ground plane, no characters, no enemies, no UI, no lettering, no logos, no border. Objects must be fully visible and not cut off on the bottom edge; consistent baseline.

## Primeiro plano

Modo: criação de asset.

Saída integrada: `assets/environments/rua_das_cinzas/rua_foreground.png`.

Prompt:

> Create a production-ready ultra-wide 32:9 transparent raster layer for a 2D metroidvania called "Cangaço Encantado". This is the sparse CLOSE FOREGROUND layer for Rua das Cinzas, a dusty occupied sertão settlement in northeastern Brazil. Match the attached references for warm earthy pixel-art language. Authentic crisp 16-bit pixel art with deliberate pixel clusters, limited palette and hard edges, no antialiasing. Place only sparse framing elements along the extreme bottom and far sides: two dark caatinga branch clusters, small mandacaru cactus silhouettes, broken fence fragments, loose stones, a few dry grass tufts, one near hanging cloth corner and subtle warm ember flecks. Leave at least 70 percent of the center empty so gameplay and the chibi hero remain unobstructed. Avoid a continuous black band. TRUE TRANSPARENT ALPHA everywhere outside the objects. No checkerboard pattern, no painted background, no sky, no horizon, no solid ground plane, no characters, no enemies, no UI, no lettering, no logos, no border. All objects fully contained in frame.

## Tentativa de extração do matte

Modo: edição com referência única.

O resultado continuou opaco e precisou de correção manual posterior. As versões integradas atualmente têm transparência RGBA real; o shader provisório foi removido.

Prompt:

> Edit this image with a surgical background extraction. Preserve every village object, pixel-art edge, color, smoke plume, roof, fence, pole, plant and baseline exactly as shown. Remove the entire pale gray-and-white checkerboard background and every empty background pixel, replacing it with genuine transparent alpha (RGBA). Do not redesign, regenerate, crop, resize, recolor, blur, smooth, add or remove any village content. The result must contain only the village objects floating on true transparency. No checkerboard pattern and no white matte.
