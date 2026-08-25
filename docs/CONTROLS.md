# Manual de controles - teclado

## Iniciar o jogo

Abra o projeto no Godot e pressione **F6** para executar a cena atual ou **F5** para executar o projeto completo.

## Movimento

| Comando | Tecla | Uso |
|---|---|---|
| Andar para a esquerda | `A` ou `←` | Move Nilo para a esquerda. |
| Andar para a direita | `D` ou `→` | Move Nilo para a direita. |
| Direção para cima | `W` ou `↑` | Combina com mira ou facão. |
| Direção para baixo | `S` ou `↓` | Fast fall no ar e ataque descendente. |
| Pular | `Espaço` | Segure para um salto mais alto; solte cedo para salto curto. |
| Agachar | `Ctrl` | Reduz a altura e a velocidade de Nilo enquanto está no chão. |

O salto aceita o comando por aproximadamente 0,12 s antes de tocar o chão e ainda funciona por 0,10 s depois de sair de uma borda.

## Combate

| Comando | Tecla | Uso |
|---|---|---|
| Facão | `J` | Pressione repetidamente para o combo de três golpes. |
| Corte para cima | `W` + `J` | Cria um golpe vertical acima de Nilo. |
| Corte descendente | No ar, `S` + `J` | Ataca para baixo; acertar um inimigo impulsiona Nilo para cima. |
| Revólver | `K` | Um disparo por pressão; solte e pressione novamente. O tambor recarrega automaticamente após 6 tiros. |
| Espingarda | `L` | Disparo curto e forte com recoil; recarrega após 2 tiros. |
| Ativar mira | Segure `Shift` | Use com `W`/`S` e o revólver para mirar verticalmente. |

A espingarda causa a maior quebra de postura. Quando a postura do inimigo chega a zero, ele fica atordoado temporariamente.

## Sobrevivência e mundo

| Comando | Tecla | Uso |
|---|---|---|
| Usar Cabaça de Água | `Q` | Inicia cura de 2 HP; receber dano durante 1,1 s interrompe o uso. |
| Interagir | `E` | Ativa portas, atalhos e outros objetos próximos. |
| Pausar/continuar | `Esc` | Alterna a pausa. |
| Mostrar/ocultar debug | `F3` | Exibe estado, posição, velocidade e formas técnicas de hitbox. Começa desligado. |
| Liberar a Vila (debug) | `F12` | Muda o estado para `LIBERATED` e salva. |

Checkpoints restauram vida, munição e as duas cargas da Cabaça. Ao morrer, Nilo retorna ao último checkpoint ativado.
