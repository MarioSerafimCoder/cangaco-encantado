# Iteração 0.2.4 — Environmental Composition Pass

Esta iteração transforma cinco áreas adicionais da Vila do Umbuzeiro em cenas ambientais editáveis e corrige a inconsistência visual de Nilo entre movimento e disparo. O gameplay e o percurso permanecem os mesmos.

## Escala visual

A altura-alvo de Nilo é `36,04 px`, derivada dos `53 px` úteis do frame-base na escala `0,68`. Cada pose usa sua própria altura útil para calcular a escala, enquanto a borda inferior útil é ancorada na baseline canônica de `11,76 px` em relação à origem do personagem.

Isso elimina o aumento aparente durante revólver e espingarda sem deformar o spritesheet nem introduzir offsets por arma. A comparação automatizada registra idle, corrida e as duas armas na mesma linha de chão.

## Salas produzidas

- `telhados`: quatro fachadas completas, telhados transitáveis, torre, varal e colisões alinhadas.
- `praca_umbu`: Umbuzeiro central, base de pedra, caminho, mercado e leitura distinta para ocupado/libertado.
- `barracos`: ruínas completas, telhado colapsado, entulho, cinzas, fogo e fumaça.
- `posto`: torre de vigia, sede, paliçada, suprimentos e foreground controlado.
- `arena`: portão monumental, torres, plataforma, barricadas, braseiro e centro de combate livre.

As cinco reutilizam módulos de fundo contínuo e chão em camadas, têm nós próprios de geometria/gameplay/câmera e não recebem decoração duplicada do `VilaArtDecorator`.

## Personagens e profundidade

Nilo, Saqueador, Pistoleiro e Zé Tranca possuem escala canônica documentada. Todos receberam sombra de contato pixelada que acompanha o último ponto de chão e perde largura/opacidade durante o salto, sem blur.

## Estado do mundo

As cenas contêm grupos `room_occupied_only` e `room_liberated_only`. A troca altera bandeiras, VFX, iluminação e moradores, mas preserva as colisões e a travessia. Spawns ocupantes continuam sendo controlados pelo `WorldState` e pelo mesmo sistema de save existente.

## Validação

- validação de altura e baseline nas quatro famílias visuais de Nilo;
- registro, bounds, entradas, paralaxe, chão e colisões das seis salas produzidas;
- troca ocupado/libertado sem duplicação do decorador;
- smoke tests da cena principal e do laboratório de movimento;
- capturas oficiais das salas e comparação lado a lado de Nilo.

As decisões reutilizáveis estão em `ENVIRONMENT_COMPOSITION_GUIDE.md`, `CHARACTER_VISUAL_SCALE.md` e `ROOM_PRODUCTION_PIPELINE.md`.
