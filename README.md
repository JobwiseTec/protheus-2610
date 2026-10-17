# docker-protheus-2610
Protheus 12.1.2610 em containers Docker (Postgres, DBAccess, License Server 3.7.2, AppServer 26.3, SmartView 3.11), **gerenciado pelo DeskFlow Control** — o painel web que sobe junto e controla todos os serviços.

> Em preparação: as imagens `emebatista/*-2610` ainda não foram publicadas no Docker Hub. Enquanto isso, use o repositório da versão anterior: https://github.com/emebatista/docker-protheus-2510

📘 **Guia completo em PDF** (download, primeira subida, DeskFlow, Protheus, SmartView, operação e problemas comuns): [docs/Guia-Protheus-2610-Docker-DeskFlow.pdf](docs/Guia-Protheus-2610-Docker-DeskFlow.pdf)

Procedimentos:
1. Instalar o <b>Docker</b> ( https://www.docker.com/products/docker-desktop/ ). <b>IMPORTANTE:</b> Se você possui um Mac com chip M1/M2, desabilite no Docker a opção "Use Rosetta for x86_64/amd64 emulation on Apple Silicon", caso contrário os conteiners podem não subir. 
2. Criar uma pasta e copiar para ela este repositório (botão <b>Code → Download ZIP</b>, ou ```git clone https://github.com/emebatista/docker-protheus-2610.git```). São necessários o <b>docker-compose.yml</b>, o <b>conf.inf</b> e a pasta <b>deskflow/</b> (configuração do DeskFlow Control).
3. Abrir o terminal dentro dessa pasta e dar os comandos: <br>
```docker login``` <br>
e depois <br>
```docker compose up -d``` <br> Se as imagens já estiverem em cache e quiser forçar baixá-las de novo, o comando é <br> ```docker compose up -d --pull always```<br>
No Docker Desktop, o grupo de containers chama-se <b>protheus2610</b> (nome fixo no compose; o DeskFlow depende dele). Na primeira subida o Docker cria os volumes `protheus12`, `protheus12-exclusivo`, `protheus12-license` e `dbaccess-multi` a partir das imagens: é neles que ficam INIs, RPO, dicionários e logs, e é por eles que o DeskFlow enxerga tudo.
4. Abrir o <b>DeskFlow Control</b> em <b>http://localhost:8073</b> (usuário ```admin```, senha ```msadm``` — troque no primeiro acesso). A topologia "Protheus 2610 (Docker)" já vem configurada com os seis serviços; acompanhe por ali a subida do banco (a vm `postgres-2610.sh` fica Running quando o restore do seed terminar) e use-o para parar, iniciar e reiniciar os serviços daqui em diante — não precisa de `docker compose` no dia a dia.
5. Acessar o <b>Protheus</b> através do smartclient através na porta <b>1234</b>. O nome do ambiente é <b>P2610</b>. Após subida dos containeres, aguarde 5 minutos até entrar pela primeira vez no sistema, pois logo na primeira construção do container o banco de dados será criado e restaurado o backup inicial. 
6. Acessar o <b>Protheus WebApp</b> através do navegador do endereço <b>http://localhost:4321</b>.
7. Usuário: Admin , senha: ```T0tvs@2026``` (senha da release 2610; na 2510 era ```$$T0tvs$$```)
8. Primeiro entre em SIGACFG / Cadastros / Configuração do Tipo de Ambiente -> Definir como "Desenvolvimento"
9. O SmartView já vem instalado e pré-configurado em uma máquina virtual chamada smartview-2610 com as portas 7017 e 7019 expostas:
    - Para verificar o status do serviço do SmartView: http://localhost:7019/diagnostic
    - Para alterar configuração do SmartView, criação de conectores, consultas específicas e relatórios, o endereço é http://localhost:7017/
    - Para reconfigurar o SmartView: http://localhost:7019/startup
    - Dentro do Protheus, para poder acessar os relatórios no novo formato, é preciso acessar SIGACFG / Ambiente / Cadastros / Configuração SmartView. Depois escolher a opção "token protheus". É IMPORTANTE informar na url o IP real da máquina (não localhost nem 127.0.0.1), informe no formato http://ip:7017 e clicar 'Testar Conexão'. Exemplo: http://192.168.0.10:7017.
    
    Para todas as configurações de IP no smartview, informe o IP do computador onde ele estará instalado:

![alt text](image-8.png)    

![alt text](image-9.png)

![alt text](image-4.png)
    
![alt text](image-6.png)

![alt text](image-7.png)

    - Para acessar o WebMonitor: http://localhost:1234/webmonitor
    - DeskFlow Control: http://localhost:8073 , usuário ```admin``` , senha ```msadm```
    
Notas:
1) Para utilizar o Protheus na interface sem a porta multiprotocolo, utilize o ambiente P2610D. Esta opção é útil quando se precisa compilar customizações desenvolvidas em ADVPL/TLPP.
2) Para apagar todas as imagens, volumes e containers que não estão rodando, o comando para apagar tudo e manter apenas os volumes do banco de dados e a pasta system_temp, o comando é :<br> ```docker system prune --all --volumes --force``` 
3) Parar, iniciar e reiniciar serviços: pelo DeskFlow (aba Serviços da topologia, ou Modo Exclusivo). Para baixar de novo a imagem de um container e recriá-lo:<br>
```docker compose up -d --no-deps --force-recreate --pull always protheus```<br>
(idem para `license`, `db`, `smartview`, `dbaccess`, `deskflow`). Os volumes nomeados preservam INIs, RPO e dados entre recriações; para voltar ao conteúdo original da imagem, remova o volume (`docker volume rm protheus2610_protheus12`) antes de recriar.
4) Se já possuir conteiners com a versão 2410 ou 2510, é preciso que estas vm estejam paradas para que as da versão 2610 possam subir, uma vez que usam as mesmas portas.
5) Existe um container para acesso exclusivo (protheus-2610-exclusivo), que não sobe serviços de Rest e permite alterar a base em modo exclusivo (porta 1235 / WebApp 4322). Use o botão <b>Ativar Exclusivo</b> do DeskFlow: ele para os serviços normais, sobe o exclusivo e, ao desativar, volta tudo ao normal.

---

<h2>Gerencie o Protheus com o DeskFlow Control</h2>

Este projeto vem preparado para ser operado pelo **DeskFlow Control**, uma ferramenta de gestão de ambientes Protheus/AppServer que roda no próprio servidor (Linux ou Windows) e controla serviços, ambientes, INIs, RPOs, patches e dicionários por uma interface web. Aqui ele roda como mais um container e enxerga o Protheus, o DBAccess, o License Server e o SmartView como serviços.

![DeskFlow - Monitor](deskflow-1-monitor.jpg)

<h3>Por que usar o DeskFlow no dia a dia</h3>

- **Um painel para tudo**: iniciar, parar e reiniciar cada serviço (ou todos de uma vez) com status em tempo real, portas em uso e consumo de memória. Chega de `docker compose stop/start` na mão.
- **Modo exclusivo com um clique**: para os serviços normais e sobe o `protheus-2610-exclusivo` (sem REST) para manutenções que exigem acesso exclusivo à base; desativa e tudo volta ao normal.
- **Ambientes e RPO sob controle**: promover RPO entre ambientes com histórico e rollback, comparar ambientes, gerar hash do RPO, aplicar patches (PTM/PAK/UPD) com defrag opcional e compilar fontes ADVPL/TLPP.
- **Atualização de dicionário**: upload dos arquivos de dicionário, backup automático do `systemload`, execução do UPDDISTR e restauração.
- **INIs sem medo**: edição dos `appserver.ini` com validação, comparação de seções, detecção de chaves duplicadas e conversão de encoding.
- **Auditoria da topologia**: checagens automáticas (INIs legíveis, ambiente principal único, sourcepaths válidos, ordem de start/stop, compilador configurado…) com semáforo verde/amarelo/vermelho.
- **Visão executiva**: saúde geral de todas as topologias, serviços operacionais, riscos de auditoria e atividade operacional do período.
- **Logs ao vivo**: `console.log` do AppServer e `dbaccess.log` direto na tela, com filtro por palavra-chave e download.
- **Agendador**: tarefas recorrentes (restart de serviços, promoções, patches) por cron ou intervalo.
- **Rastreabilidade**: log de todas as ações com usuário, hora, topologia, serviço e resultado; notificações em tempo real.
- **Usuários e permissões**: grupos, permissões por topologia/serviço/ambiente, integração opcional com Active Directory.
- **Multi-servidor**: controla também serviços remotos (SSH no Linux, SCM/WMI no Windows) a partir de uma única console.

![DeskFlow - Serviços](deskflow-2-servicos.jpg)

![DeskFlow - Ambientes](deskflow-3-ambientes.jpg)

![DeskFlow - Visão executiva](deskflow-4-visao-executiva.jpg)

![DeskFlow - Auditoria](deskflow-5-auditoria.jpg)

![DeskFlow - Log de ações](deskflow-6-log-acoes.jpg)

<h3>Já vem no compose</h3>

O DeskFlow faz parte do `docker-compose.yml`: os serviços `deskflow` e `deskflow-web` sobem com os demais no `docker compose up -d`. Ele monta os mesmos volumes que os containers do Protheus (`/protheus12`, `/dbaccess/multi`), por isso INIs, RPO, `console.log` e `dbaccess.ini` são os mesmos arquivos que o AppServer usa — editar INI, promover RPO, aplicar patch e ver log funcionam sobre o ambiente real. A pasta `deskflow/` do repositório guarda a configuração (`config.json` com a topologia pronta, `deskflow.ini`, `nginx/`) e, depois da primeira subida, os dados e a licença; ela fica na sua máquina e sobrevive a recriações dos containers.

Primeiro acesso: **http://localhost:8073**, usuário ```admin```, senha ```msadm``` (troque em Configuração → Usuários).

<h3>Licença</h3>

O DeskFlow Control é um produto licenciado por servidor. Esta demonstração em containers mostra o produto completo; para usar no seu ambiente (VM ou servidor físico, Linux ou Windows), solicite uma licença de avaliação ou comercial em **https://deskflow.com.br** (menu Contato) ou pelo e-mail `emebatista@hotmail.com`, informando nome da empresa e quantidade de servidores. A licença é aplicada nos campos `tenant_code`, `tenant_name` e `tenant_authorization` do `deskflow/deskflow.ini`.


ATENÇÃO!
Para que a base contenha dados de exemplo, aguarde até a vm do postgres chegar a este ponto:
![alt text](image-2.png)

Enquanto estiver em execução, aparecerá algo como:
![alt text](image-3.png)

