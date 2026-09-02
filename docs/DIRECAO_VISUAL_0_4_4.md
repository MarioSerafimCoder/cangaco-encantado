# Direção visual da experiência inicial — 0.4.4

## Relatório final

1. A reorganização de sprites foi verificada por referências estáticas, importação do Godot, execução da cena principal e bateria automatizada. Nenhuma referência `res://` permaneceu apontando para os caminhos antigos.
2. Os 38 screenshots anteriores foram preservados em `prints_do_jogo/area_01_vertical_slice/archive/antes_direcao_visual_2026-09-01/`.
3. A revisão atual passou a ser gravada em `prints_do_jogo/area_01_vertical_slice/current/`, evitando sobrescrita do histórico.
4. Os dez grupos ambientais pedidos já existiam entre os sprites não utilizados. Nove atlas foram tratados com transparência e copiados para `assets/sprites/usados/cenarios/polimento_experiencia_0_4_4/`.
5. A lacuna de poses de Nilo foi preenchida com `10_nilo_aquisicao_reacao_fundo_branco.png`, mantendo o arquivo como fonte ainda não utilizada e pronta para recorte.
6. Vila Baixa, Praça do Umbu, Igreja/Cemitério e Telhados da Vila agora possuem composição visual materializada nos respectivos `.tscn`; o compositor runtime ficou restrito aos trechos subterrâneos ainda dinâmicos.
7. Os moradores Bento, Lia, Seu Anselmo, Mariano, Irmão Tomé e Zé Lino foram materializados nas cenas em que aparecem.
8. A Praça recebeu um umbuzeiro monumental com banco circular, banco secundário e barraca de mercado.
9. A Igreja perdeu a faixa atmosférica deslocada e recebeu muro, portão, trecho quebrado e túmulos de cemitério. O checkpoint e o Passo da Pedra também estão materializados na cena.
10. Telhados ganhou fachadas com alturas diferentes, casa de dois pisos, varanda, telhado quebrado, vigas e oito superfícies caminháveis editáveis. As laterais físicas continuam servindo ao Passo da Pedra.
11. Casa de Nilo ganhou enquadramento local mais alto e teve as extensões inferiores redundantes ocultadas, mantendo o chão próximo da faixa de 58–65% da tela.
12. `CameraCompositionZone` permite ajustes locais de enquadramento sem alterar o perfil global. Casa e rota alta de Telhados já usam zonas autorais.
13. Os checks de coordenada do HUD foram removidos. Pistola e rifle agora são ensinados por `TutorialTrigger` visível nas cenas, preservando os mesmos IDs de tutorial e save.
14. O objetivo aparece completo por 2,6 segundos e depois permanece compacto no canto superior direito. A aquisição de habilidade recebeu apresentação especial de aproximadamente 1,7 segundo e o aviso duplicado foi removido.
15. A manifestação recebeu pulsação e anéis mais intensos durante a fala, e Raimundo, Dona Tereza, Seu Anselmo e Irmão Tomé possuem reação visual ao sinal do Encantado. Nenhum sistema, nó ou arquivo de áudio foi adicionado.

## Validação

- validação estática de arquivos, ações e referências;
- importação completa no Godot 4.7.1;
- execução da cena principal por 180 quadros;
- todas as suítes de produção existentes;
- nova suíte `visual_direction_validation.tscn` para materialização, câmera, tutoriais, HUD, Telhados e cobertura de assets;
- revisão visual 1920×1080 regenerada e inspecionada.
