#!/bin/bash
#
# Miss�o do script
# Fazer um backup global do GLPI antes de atualiza��es do SO.
#
# Detalhes do script
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
# Faz o registro do in�cio do backup global do GLPI.	   
logApp INFO "Fazendo backup global do GLPI."

# Faz o backup da base de dados e registra em LOG
logApp INFO "In�cio do backup da base de dados MySQL."
/usr/local/backup/bkp_mysql-glpi.sh

if [ "$?" -eq "0" ]
then

	# Faz o backup da aplica��o GLPI
	logApp INFO "INFO: In�cio do backup da aplica��o GLPI."
	/usr/local/backup/bkp-app-script.sh
	if [ "$?" -eq "0" ]
	then

		# Faz o backup dos artefatos de dados do GLPI
		logApp INFO "INFO: In�cio do backup dos artefatos de dados do GLPI."
		/usr/local/backup/bkp-artefatos-dados_script.sh
		if [ "$?" -eq "0" ]
		then

			# Faz o backup das configura��es de seguran�a e base de 
			# dados do GLPI
			logApp INFO "In�cio do backup das configura��es de seguran�a e base de dados do GLPI."
			/usr/local/backup/bkp-conf-seg_script.sh			

			if [ "$?" -eq "0" ]
			then

				# Faz o backup das configura��es do servidor Apache2
				logApp INFO "In�cio do backup das configura��es do servidor Apache2."
				/usr/local/backup/bkp-apache2.sh
				
				if [ "$?" -eq "0" ]
				then
					logApp INFO "Sucesso no backup global do GLPI!"
				else
					logApp ERROR "Falha no backup global do GLPI, backup das configura��es do Apache2. Verificar o log do backup do Apache2."
					exit 1
				fi
			else
				logApp ERROR "Falha no backup global do GLPI, backup das configura��es de seguran�a e base de dados. Verificar o log do backup das configura��es."
				exit 1
			fi
		else
			logApp ERROR "Falha no backup global do GLPI, backup dos artefatos de dados. Verificar o log do backup dos artefatos."
			exit 1
		fi

	else
		logApp ERROR "Falha no backup global do GLPI, backup da aplica��o. Verificar o log do backup da aplica��o."		
		exit 1
	fi

else

	logApp INFO "Falha no backup global do GLPI, backup do MySQL. Verificar o log do backup do MySQL."
fi