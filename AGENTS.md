# Cangaço Encantado — regras de desenvolvimento

## Constituição

Cangaço Encantado é um projeto existente em Godot 4.7. Nunca o trate como greenfield. Antes de substituir sistemas, assets, cenas ou arquitetura, estude a implementação atual e prefira correções, complementos e refatorações localizadas. Reescrita substancial exige evidência de que uma solução incremental é insuficiente.

Preserve a identidade de pixel art, sertão, cangaço, fantasia e arquitetura nordestina. Não introduza sistemas genéricos, conteúdo da Área 02 ou novos escopos sem pedido explícito.

## Fonte de verdade

Antes de uma mudança relevante, examine o código, as cenas, `project.godot`, a documentação relacionada, `git status`, `git diff` e o histórico recente. Documentos antigos e nomes de arquivos não substituem a implementação atual. Preserve alterações locais do usuário.

O projeto usa viewport lógico 640×360, saída 1920×1080, filtro de textura nearest, pixel snap e renderizador GL Compatibility. A cena inicial é `scenes/main.tscn`.

## Roteamento de Skills

- Gameplay, movimento, combate e game feel: `cangaco-game-designer`.
- Fases, arquitetura, plataformas, telhados e câmera espacial: `cangaco-level-designer`.
- Sprites, animações, atlas, escala, pivô e importação: `cangaco-2d-assets`.
- Inimigos e comportamento: `cangaco-game-ai` junto da Skill de gameplay quando necessário.
- Loja, moedas, preços e recompensas: `cangaco-economy-designer`.
- Mudanças realmente multidisciplinares: `cangaco-game-studio`; não coordene múltiplos domínios quando uma Skill basta.
- Bugs: use `systematic-debugging` quando disponível e sempre investigue a causa antes de corrigir.
- Tarefas extensas: use `planning-with-files` quando disponível e mantenha os arquivos temporários em `.agent/`.
- Sprites: use `generate2dsprite` como inspetor/validador/processador primeiro e como gerador somente quando faltar arte.
- Antes de concluir: use `verification-before-completion` quando disponível e sempre produza evidência nova.

## Processo de qualidade

Classifique problemas como P0 (crash, softlock, save/progressão), P1 (colisão, escala, arquitetura ou UI quebrada), P2 (composição, câmera, feedback e repetição) ou P3 (micro-polimento). Trabalhe nessa ordem.

Para bugs: reproduza, observe, rastreie, formule uma hipótese, teste-a, encontre a causa, aplique a correção mínima e verifique regressões.

Para mudanças visuais: execute a cena e inspecione capturas em 1920×1080. Atualize `prints_do_jogo/area_01_vertical_slice/` em mudanças visuais grandes. Não aceite apenas “o Godot abriu” como prova visual.

Para concluir, rode os testes do domínio e os gates relevantes em `tools/`. O gate amplo mínimo inclui:

```powershell
./tools/validate_project.ps1
godot --headless --path . res://tools/boot_menu_validation.tscn
godot --headless --path . res://tools/area01_vertical_slice_validation.tscn
godot --headless --path . res://tools/room_production_validation.tscn
```

Não declare que algo funciona sem registrar o comando e o resultado atual.
