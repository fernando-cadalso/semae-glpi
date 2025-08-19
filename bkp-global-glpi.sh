#!/bin/bash
#
# Missão do script
# Fazer um backup global do GLPI antes de atualizações do SO.
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
# Faz o registro do início do backup global do GLPI.	   
logApp INFO "Fazendo backup global do GLPI."

# Faz o backup da base de dados e registra em LOG
logApp INFO "Início do backup da base de dados MySQL."
/usr/local/backup/bkp_mysql-glpi.sh

if [ "$?" -eq "0" ]
then

	# Faz o backup da aplicação GLPI
	logApp INFO "INFO: Início do backup da aplicação GLPI."
	/usr/local/backup/bkp-app-script.sh
	if [ "$?" -eq "0" ]
	then

		# Faz o backup dos artefatos de dados do GLPI
		logApp INFO "INFO: Início do backup dos artefatos de dados do GLPI."
		/usr/local/backup/bkp-artefatos-dados_script.sh
		if [ "$?" -eq "0" ]
		then

			# Faz o backup das configurações de segurança e base de 
			# dados do GLPI
			logApp INFO "Início do backup das configurações de segurança e base de dados do GLPI."
			/usr/local/backup/bkp-conf-seg_script.sh			

			if [ "$?" -eq "0" ]
			then

				# Faz o backup das configurações do servidor Apache2
				logApp INFO "Início do backup das configurações do servidor Apache2."
				/usr/local/backup/bkp-apache2.sh
				
				if [ "$?" -eq "0" ]
				then
					logApp INFO "Sucesso no backup global do GLPI!"
				else
					logApp ERROR "Falha no backup global do GLPI, backup das configurações do Apache2. Verificar o log do backup do Apache2."
					exit 1
				fi
			else
				logApp ERROR "Falha no backup global do GLPI, backup das configurações de segurança e base de dados. Verificar o log do backup das configurações."
				exit 1
			fi
		else
			logApp ERROR "Falha no backup global do GLPI, backup dos artefatos de dados. Verificar o log do backup dos artefatos."
			exit 1
		fi

	else
		logApp ERROR "Falha no backup global do GLPI, backup da aplicação. Verificar o log do backup da aplicação."		
		exit 1
	fi

else

	logApp INFO "Falha no backup global do GLPI, backup do MySQL. Verificar o log do backup do MySQL."
fi