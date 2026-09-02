# Checklist de QC de sprites

## Arquivo

- Confirmar RGBA e transparência real nas áreas vazias.
- Confirmar que nenhum frame invade a célula vizinha.
- Conferir dimensões, grid, gutters e regiões usadas pelo Godot.
- Manter filtro nearest e evitar reamostragem fracionária.

## Personagem e inimigos

- Comparar altura visual e largura do corpo entre idle, walk, run, armas, dano e morte.
- Medir baseline dos pés; poses agachadas ou inclinadas podem ter altura natural menor.
- Manter pivô estável no ponto de contato com o chão.
- Verificar chapéu, arma, clarão e FX contra os limites do frame.
- Separar deslocamento intencional da pose de erro de anchor.

## Cenário

- Assentar props na linha visual do chão.
- Alinhar topo físico à superfície aparente.
- Evitar halos claros de remoção de fundo.
- Conferir ordem de desenho para não ocultar portas, NPCs, inimigos ou o jogador.

## Evidência

Renderizar capturas em 1920×1080 e testar ao menos os estados extremos do atlas. Para mudanças grandes, atualizar os prints oficiais.
