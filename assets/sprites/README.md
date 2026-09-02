# Organização de sprites

Esta pasta é a fonte central das imagens de produção do jogo.

## `usados/`

Contém somente sprites carregados por cenas, scripts, recursos ou ferramentas do projeto:

- `cenarios/`: Área 01, Rua das Cinzas e Vila do Umbuzeiro;
- `personagens/`: jogador, inimigos e chefes;
- `interface/`: HUD, menu, Diário, diálogo e loja;
- `efeitos/`: efeitos visuais de ocupação, fogo e tiros;
- `ferramentas/`: imagens usadas apenas por cenas de validação.

## `nao_utilizados/`

Contém material que não é carregado pelo projeto:

- `aguardando_tratamento/`: folhas com fundo, pacotes de produção e imagens ainda não integradas;
- `fontes/`: arquivos-fonte usados para gerar versões tratadas;
- `guias/`: folhas auxiliares ainda não referenciadas;
- `personagens/conceitos/`: conceitos sem uso direto em cenas ou scripts.

O arquivo `.gdignore` impede que o editor importe essa árvore enquanto os arquivos não estiverem em uso.

Quando um sprite for integrado ao jogo, mova-o para a subdivisão adequada de `usados/` e atualize suas referências `res://`. Não duplique a mesma versão entre as duas áreas.

Capturas de tela, imagens de documentação e os originais preservados em `assets/source/reference/` não fazem parte deste inventário.
