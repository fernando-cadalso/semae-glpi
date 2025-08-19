#!/bin/bash
# MISSAO DO SCRIPT
#
# Faz o backup da aplicação GLPI.
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
		#Se a gravação falhou, então o mapeamento não está conectado.
		#Registra em log e tenta fazer o mapeamento
		logApp INFO "Mapeamento não montado. Tentando mapear..."
		mount -a
		#Valida a montagem do compartilhamento corretamente
		if [ "$?" -ne "0" ]
		then
			#Sai da função em caso de falha
			logApp ERROR "ERR.: Falha ao montar o mapeamento. Verifique a conexão de rede e o acesso à pasta compartilhada."
			return 1
		else
			logApp INFO "Mapeamento reconectado."
			return 0
		fi
	else
		#A gravação foi bem sucedida, então sai da função com sucesso
		#e apaga o arquivo.
		rm -f $destino_backup/teste_bkp
		return 0
	fi
}
       logApp INFO "INFO: Início do backup da aplicação GLPI."

       #Origem dos arquivos
       arquivos_backup="/var/www/glpi"

       #Destino do backup
       destino_backup="/mnt/backup/app/app"

       #Estrutura do nome do arquivo de backup
       data=$(date +%F_%H-%M)
       nome_arquivo="App-GLPI_${data}.tgz"

       #Valida o compartilhamento do backuup
       validaCompartilhamento

       if [ "$?" -ne "0" ]	   
	then
		#Exibe falha de compartilhamento
		logApp INFO "Possível falha na conexão de rede. Verifique."
		exit 1
	else
	       #Realiza o backup da aplicação
	       tar czf $destino_backup/$nome_arquivo $arquivos_backup && logApp INFO "Backup da aplicação GLPI realizado com sucesso." || logApp ERROR "Falha ao realizar o backup da aplicação GLPI. Verifique: se possui permissao de escrita na pasta; se a pasta de destino esta mapeada; se o compartilhamento ainda existe; se o servidor esta conectado; se existe conexo de rede."
		   
		   #Lista os arquivos de backup
		   ls -lah /mnt/backup/app/app
	fi