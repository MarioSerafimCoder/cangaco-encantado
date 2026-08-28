# Manual de controles - teclado

## Iniciar o jogo

Abra o projeto no Godot e pressione **F6** para executar a cena atual ou **F5** para executar o projeto completo.

## Movimento

| Comando | Tecla | Uso |
|---|---|---|
| Andar/correr para a esquerda | `A` ou `←` | Anda para a esquerda e corre depois de manter por 2 segundos; a corrida aumenta o alcance do salto. |
| Andar/correr para a direita | `D` ou `→` | Anda para a direita e corre depois de manter por 2 segundos; a corrida aumenta o alcance do salto. |
| Direção para cima | `W` ou `↑` | Combina com mira ou facão. |
| Direção para baixo | `S` ou `↓` | Fast fall no ar e ataque descendente. |
| Pular | `Espaço` | Segure para um salto mais alto; solte cedo para salto curto. |
| Agachar | `Ctrl` | Reduz a altura e a velocidade de Nilo enquanto está no chão. |
| Salto de parede | `Espaço` junto à parede | Disponível depois de obter o Passo da Pedra na Igreja Velha. |
| Investida | `C` | Disponível depois de obter o Passo da Poeira nos Telhados; atravessa vãos e selos próprios. |

O salto aceita o comando por aproximadamente 0,12 s antes de tocar o chão e ainda funciona por 0,10 s depois de sair de uma borda.

## Combate

| Comando | Tecla | Uso |
|---|---|---|
| Facão | `J` | Pressione repetidamente para o combo de três golpes. |
| Corte para cima | `W` + `J` | Cria um golpe vertical acima de Nilo. |
| Corte descendente | No ar, `S` + `J` | Ataca para baixo; acertar um inimigo impulsiona Nilo para cima. |
| Pistola | `K` | Um disparo por pressão; solte e pressione novamente. O carregador recarrega automaticamente após 8 tiros. |
| Rifle | `L` | Disparo preciso, forte e de longo alcance; recarrega após 4 tiros. |
| Ataque especial | `I` | Golpe amplo de alto dano e forte quebra de postura; possui recarga de 5 segundos. |
| Ativar mira | Segure `Shift` | Use com `W`/`S` e a pistola ou o rifle para mirar verticalmente. |

O rifle causa mais dano de postura que a pistola, enquanto o ataque especial é a opção mais forte. Quando a postura do inimigo chega a zero, ele fica atordoado temporariamente.

## Sobrevivência e mundo

| Comando | Tecla | Uso |
|---|---|---|
| Usar Cabaça de Água | `Q` | Inicia cura de 2 HP; receber dano durante 1,1 s interrompe o uso. |
| Interagir | `E` | Conversa, examina, compra, ativa portas, atalhos e outros objetos próximos. |
| Abrir/fechar Diário de Nilo | `M` | Reúne mapa, itens, habilidades e amuletos. Use `Q`/`E` para trocar de aba e setas para selecionar salas. |
| Pausar/continuar | `Esc` | Abre o menu de pausa; pressione novamente para continuar ou voltar da tela atual. |
| Mostrar/ocultar debug | `F3` | Exibe estado, posição, velocidade e formas técnicas de hitbox. Começa desligado. |
| Liberar a Vila (debug) | `F12` | Muda o estado para `LIBERATED` e salva. |

Checkpoints restauram vida, munição e as duas cargas da Cabaça. Ao morrer, Nilo retorna ao último checkpoint ativado.

No gamepad, use o analógico ou D-pad para navegar, `A` para confirmar, `B` para voltar, `LB`/`RB` para trocar abas, `View/Back` para o Diário e `Start` para pausar. Os prompts mudam automaticamente conforme o último dispositivo utilizado.
