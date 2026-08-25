# Polimento visual e game feel

Esta iteração transforma o graybox funcional da Vila do Umbuzeiro em um vertical slice estilizado, sem criar mapas ou substituir a arquitetura de gameplay.

## Spritesheet e animação

- Nilo usa a folha chibi RGBA `generic_sertanejo_chibi_4x4_64px.png`.
- A folha mede 256x256 px: quatro colunas, quatro linhas e células exatas de 64x64 px.
- A corrida percorre os quatro frames da segunda linha. O intervalo varia de 0,16 s a 0,085 s conforme a velocidade horizontal.
- Idle, corrida, agachamento, salto, queda, tiros, facão, cura, dano e morte têm seleção de frame explícita.
- A troca de estado reinicia apenas o relógio da animação atual, evitando herdar frames e causar flicker.
- Idle recebe respiração sutil; corrida recebe bob; salto/queda usam squash e stretch leves.

## HUD

O HUD principal foi separado do diagnóstico técnico. Vida, revólver, espingarda, Cabaça, estado da Vila e barra de chefe usam painéis com hierarquia, sombra e paleta de couro/metal. O painel técnico começa oculto e é alternado por `F3`; a mesma opção controla o desenho de hitboxes.

## Vila e estados do mundo

O cenário permanece modular por limites de sala. A Rua das Cinzas usa uma cena própria com layers, colisão e spawns editáveis; as demais áreas continuam no sistema híbrido de atlas rasterizados e geometria do graybox.

- `OCCUPIED`: paleta pesada, janelas apagadas, incêndios, fumaça e filtro avermelhado discreto.
- `LIBERATED`: céu mais quente, serras verdes, janelas acesas, árvore viva, moradores e pássaros na Praça.

## Feedback visual

`GameFeelFX` fornece efeitos procedurais leves para poeira de corrida, poeira de pouso, disparos, facão, impactos e cura. Nilo aplica recoil visual na espingarda, feedback de dano menos agressivo e micro shake na câmera. Nenhum efeito altera colisões ou regras de combate.

## Correções técnicas

- Revólver alterado conscientemente para modo semiautomático (`just_pressed`).
- Hurtbox e collider corporal agora reduzem e deslocam juntos durante o agachamento.
- Hitboxes de depuração ficam ocultas por padrão.
- Suavização da câmera aumentada de 8 para 10.
- A cena `tools/game_feel_validation.tscn` verifica quatro frames de corrida, agachamento e semiautomático.

## Limitações restantes

- O spritesheet chibi atual é um placeholder genérico; ainda falta produzir a identidade final de Nilo com pivôs e silhuetas revisados por artista.
- Inimigos e chefe continuam usando folhas conceituais irregulares e shader de remoção de branco.
- Os VFX são procedurais e não substituem sprites de efeitos finais.
- Ainda faltam áudio, hitstop calibrado por playtest humano e separação física das treze salas em cenas próprias.
