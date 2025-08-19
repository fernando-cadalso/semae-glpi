#!/bin/bash
# MISSAO DO SCRIPT
#
# Faz o backup dos artefatos de dados do GLPI: /var/lib/glpi
#
# DETALHAMENTO DA MISSAO
# Cria o log da execucao do script
function logApp() {
	 local LOG_LEVEL=$1
	  shift
	   MSG=$@
	    TIMESTAMP=$(date +"%Y-%m-%d %T")
	     HOST=$(hostname -s)
	      PROGRAM_NAME=$0

	       logger "${PROGRAM_NAME}[${PID}]: ${LOG_LEVEL} ${MSG}"

       }
	   
#Valida o compartilhamento do backuup
function validaCompartilhamento(){

	#Tenta gravar um arquivo na pasta do backup
	touch $destino_backup/teste_bkp
	if [ "$?" -ne "0" ]
	then
		#Se a grava��o falhou, ent�o o mapeamento n�o est� conectado.
		#Registra em log e tenta fazer o mapeamento
		logApp INFO "Mapeamento n�o montado. Tentando mapear..."
		mount -a
		#Valida a montagem do compartilhamento corretamente
		if [ "$?" -ne "0" ]
		then
			#Sai da fun��o em caso de falha
			logApp ERROR "Falha ao montar o mapeamento. Verifique a conex�o de rede e o acesso � pasta compartilhada."
			return 1
		else
			logApp INFO "Mapeamento reconectado."
			return 0
		fi
	else
		#A grava��o foi bem sucedida, ent�o sai da fun��o com sucesso
		#e apaga o arquivo.
		rm -f $destino_backup/teste_bkp
		return 0
	fi
}

	logApp INFO "In�cio do backup dos artefatos de dados do GLPI..."

	#Origem dos arquivos
	arquivos_backup="/var/lib/glpi"

	#Destino do backup
	destino_backup="/mnt/backup/db"

	#Estrutura do nome do arquivo de backup
	data=$(date +%F_%H-%M)
	nome_arquivo="Artefato-dados_${data}.tgz"

	#Valida o compartilhamento do backuup
	validaCompartilhamento

	if [ "$?" -ne "0" ]	   
	then
		#Exibe falha de compartilhamento
		logApp INFO "Poss�vel falha na conex�o de rede, para fazer o backup dos artefatos de dados do GLPI . Verifique."
		exit 1
	else
	       #Realiza o backup
	       tar czf $destino_backup/$nome_arquivo $arquivos_backup && logApp INFO "Backup dos artefatos de dados do GLPI realizado com sucesso." || logApp ERROR "Falha ao realizar o backup dos artefatos de dados do GLPI. Verifique: se possui permissao de escrita na pasta; se a pasta de destino esta mapeada; se o compartilhamento ainda existe; se o servidor esta conectado; se existe conexo de rede."
		   
		   #Lista os arquivos de backup
		   ls -lah /mnt/backup/db
	fi