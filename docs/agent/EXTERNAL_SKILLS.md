# Skills externas de referência

As Skills próprias ficam em `.agents/skills/`. Dependências externas não são copiadas para evitar forks desatualizados e bibliotecas desnecessárias.

| Skill | Origem | Política no projeto |
| --- | --- | --- |
| Skill Creator | https://github.com/openai/skills/tree/main/skills/.system/skill-creator | Referência estrutural para Skills próprias. |
| generate2dsprite | https://github.com/0x0funky/agent-sprite-forge/tree/main/skills/generate2dsprite | Usar como inspector/validator/processor antes de gerar arte. |
| planning-with-files | https://github.com/OthmanAdi/planning-with-files/tree/master/.agents/skills/planning-with-files | Usar em tarefas extensas; arquivos temporários em `.agent/`. |
| systematic-debugging | https://github.com/obra/superpowers/tree/main/skills/systematic-debugging | Usar em bugs e regressões, com investigação de causa. |
| verification-before-completion | https://github.com/obra/superpowers/tree/main/skills/verification-before-completion | Produzir evidência atual antes de afirmar conclusão. |

Quando uma Skill externa estiver disponível no ambiente do Codex, use a versão instalada. Caso não esteja, siga os princípios permanentes equivalentes descritos no `AGENTS.md`, sem inventar uma cópia parcial com o mesmo nome.
