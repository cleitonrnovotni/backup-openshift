#!/bin/bash

## ALTERAR DIRETÓRIO DE BACKUP CONFORME DEMANDA ##

BACKUP_ROOT_DIR=/mnt/backup

for project in $(oc get project | grep -v openshift | grep -v management-infra | grep -v kube | awk '{print $1}' | grep -v NAME)
do
        if [ -d ${BACKUP_ROOT_DIR}/${project} ]
        then
                echo "Diretório de backup do projeto ${project} já existe, prosseguindo com backup"
        else
                echo "Diretório de backup do project ${project} será criado"
                mkdir ${BACKUP_ROOT_DIR}/${project}
        fi
        oc project ${project}
        for pvc in $(oc get pvc | awk '{print $3}' | grep -v VOLUME | grep -v NAME)
        do
            echo "Fazendo backup do volume persistente $(oc get pvc | grep -i $pvc | awk '{print $1}') do projeto ${project}"
            tar zcvf ${BACKUP_ROOT_DIR}/${project}/$(oc get pvc | grep -i $pvc | awk '{print $1}').tar.gz $(gluster volume info $(oc describe pv $pvc | grep -i path | awk '{print $2}') | grep -i $(hostname -i) | cut -d ':' -f 3)
        done
done
