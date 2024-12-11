
# lnx_clean_system

**lnx_clean_system** é um script Bash que automatiza a limpeza de diretórios no Linux, como `~/Downloads` e `/tmp`, com suporte para configurações de tempo e integração com `systemd`.

## Recursos

- Limpeza automática de arquivos em diretórios específicos.
- Configuração de exclusão com base na idade dos arquivos (`--days`).
- Integração com `systemd` para agendamento via timer.
- Logs opcionais para monitorar a execução.
- Personalizável e fácil de usar.

## Instalação

1. Clone o repositório:
   ```bash
   git clone https://github.com/julio-qa/lnx_clean_system.git
   cd lnx_clean_system
   ```

2. Torne o script executável:
   ```bash
   chmod +x lnx_clean_system.sh
   ```

3. Copie o script para um diretório no seu PATH, como `~/bin`:
   ```bash
   ln -s ~/git/lnx_clean_system/lnx_clean_system.sh ~/bin/lnx_clean_system
   ```

## Configuração com systemd

Para uma limpeza automatizada, configure o script com `systemd`:

1. Crie o arquivo de serviço:
   ```bash
   sudo nano /etc/systemd/system/lnx_clean_system.service
   ```

   Copie o seguinte conteúdo:

   ```ini
   [Unit]
   Description=Executa a limpeza do sistema
   After=network.target

   [Service]
   StandardOutput=journal
   StandardError=journal
   Type=oneshot
   User=SEU_USUARIO
   WorkingDirectory=/home/SEU_USUARIO
   Environment="HOME=/home/SEU_USUARIO"
   ExecStart=/bin/bash /home/SEU_USUARIO/git/lnx_clean_system/lnx_clean_system.sh -d -y --days=30

   [Install]
   WantedBy=multi-user.target
   ```

2. Crie o arquivo de timer:
   ```bash
   sudo nano /etc/systemd/system/lnx_clean_system.timer
   ```

   Copie o seguinte conteúdo:

   ```ini
   [Unit]
   Description=Timer para limpeza do sistema

   [Timer]
   OnCalendar=*-*-* 00:00:00
   Persistent=true
   WakeSystem=true

   [Install]
   WantedBy=timers.target
   ```

3. Ative e inicie o timer:
   ```bash
   sudo systemctl enable lnx_clean_system.timer
   sudo systemctl start lnx_clean_system.timer
   ```

## Uso Manual

Execute o script manualmente com os parâmetros desejados:

```bash
lnx_clean_system -d -y --days=30
```

Opções disponíveis:

- `-d, --downloads`: Limpa o diretório `~/Downloads`.
- `-t, --tmp`: Limpa o diretório `/tmp`.
- `-r, --recycle-trash`: Esvazia a lixeira do usuário.
- `-y, --force`: Não solicita confirmação.
- `--days=N`: Exclui apenas arquivos com mais de N dias.
- `-v, --verbose`: Exibe detalhes das operações.

## Contribuição

Contribuições são bem-vindas! Para contribuir:

1. Faça um fork do repositório.
2. Crie uma branch para sua feature/bugfix:
   ```bash
   git checkout -b minha-feature
   ```
3. Envie suas alterações:
   ```bash
   git push origin minha-feature
   ```

4. Abra um Pull Request.

## Licença

Este projeto está licenciado sob a [MIT License](LICENSE).
