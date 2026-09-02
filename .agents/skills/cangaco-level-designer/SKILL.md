---
name: cangaco-level-designer
description: Analisa e melhora salas, arquitetura, plataformas, telhados, interiores, caminhos, verticalidade, exploração, encontros e câmera espacial do Cangaço Encantado. Use quando a tarefa altera o lugar jogável ou sua leitura.
---

# Cangaço Level Designer

Construa lugares, não plataformas abstratas. Toda superfície jogável deve pertencer a uma arquitetura compreensível: telhado, casa, fundação e solo.

## Trabalho

1. Inspecione a cena no editor e em execução, incluindo colisões, limites de câmera e conexões com salas vizinhas.
2. Determine a função de cada trecho: ensino, combate, descanso, exploração, antecipação, landmark ou transição.
3. Preserve rotas e progressão existentes; corrija a causa de bloqueios ou incoerências.
4. Faça a geometria visual coincidir com a física. Alinhe plataformas à superfície visível e elimine colisões invisíveis.
5. Garanta acesso legível a rotas altas com elementos arquitetônicos coerentes.
6. Teste entrada, saída, salto, pouso, retorno, câmera e habilidades de travessia.

## Critérios

- A composição deve comunicar onde ir sem depender de setas constantes.
- Espaço vazio precisa de função; não o preencha aleatoriamente com caixas e pedras.
- Use variações e clusters para reduzir repetição, preservando áreas de descanso visual.
- Telhados visíveis são caminháveis quando fazem parte da rota; paredes de habilidade precisam de leitura consistente.
- Portas, NPCs, inimigos e o herói não podem ser ocultos por foreground decorativo.
- Igreja, cemitério e casas devem parecer assentados no terreno, nunca enterrados ou flutuando.
- Observe quanto da tela é consumido por massa de solo sem gameplay.

Valide com `room_production_validation`, `first_rooms_traversal_validation`, `metroidvania_validation` e capturas 1920×1080 quando aplicável.
