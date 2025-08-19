#!/bin/bash

# Miss�o do script: Backup global do GLPI antes de atualiza��es do SO.

# Fun��o de logging
logApp() {
    local LOG_LEVEL=$1
    shift
    MSG=$@
    TIMESTAMP=$(date +"%Y-%m-%d %T")
    HOST=$(hostname -s)
    PROGRAM_NAME=$(basename "$0")

    logger -p user.${LOG_LEVEL} "${PROGRAM_NAME}[$$]: ${LOG_LEVEL} ${MSG}"
}

# In�cio do backup
logApp INFO "Fazendo backup global do GLPI."

# Backup MySQL
if /usr/local/backup/bkp_mysql-glpi.sh; then

    # Backup Aplica��o GLPI
    if /usr/local/backup/bkp-app-script.sh; then

        # Backup Artefatos de Dados
        if /usr/local/backup/bkp-artefatos-dados_script.sh; then

            # Backup Configura��es de Seguran�a
            if /usr/local/backup/bkp-conf-seg_script.sh; then

                # Backup Apache2
                if /usr/local/backup/bkp-apache2.sh; then
                    logApp INFO "Sucesso no backup global do GLPI!"
                else
                    logApp ERROR "Falha no backup global do Apache2."
                    exit 1
                fi

            else
                logApp ERROR "Falha no backup global das configura��es de seguran�a."
                exit 1
            fi

        else
            logApp ERROR "Falha no backup global dos artefatos de dados."
            exit 1
        fi

    else
        logApp ERROR "Falha no backup global da aplica��o GLPI."
        exit 1
    fi

else
    logApp ERROR "Falha no backup global do MySQL."
    exit 1
fi