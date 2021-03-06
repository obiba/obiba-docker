#!/bin/bash

RED=\033[0;31m
NC=\033[0m

help:
	@echo "###########################################################################################################"
	@echo "# make init : Init folders add backup, import_folder, export_folder                                       #"
	@echo "# make up : Up Containers                                                                                 #"
	@echo "# make down :Down Containers                                                                              #"
	@echo "# make stop :Stop Containers                                                                              #"
	@echo "# make start :Start Containers                                                                            #"
	@echo "# make shell : Shell into Drupal container                                                                #"
	@echo "# make backup-drupal : Backup the  Drupal container                                                       #"
	@echo "# make restore-drupal : Restore the Drupal container                                                       #"
	@echo "# make logs-drupal : display Drupal logs                                                                  #"
	@echo "# ./removeAll.sh : $(RED)Warning$(NC) To use with caution remove Drupal container and his volumes                    #"
	@echo "###########################################################################################################"

BACKUP_FOLDER=$(CURDIR)/backup

# Backup Drupal installation
backup-drupal: backup-drupal-container backup-mysql-container

backup-drupal-container: backup-drupal-docker backup-drupal-default backup-drupal-libraries backup-drupal-modules backup-drupal-themes backup-drupal-vendor

# Restore Drupal installation
restore-drupal: stop restore-drupal-container restore-mysql-container start

restore-drupal-container: restore-drupal-docker restore-drupal-default restore-drupal-libraries restore-drupal-modules restore-drupal-themes restore-drupal-vendor

# Export Drupal Obiba Mica code Base
export-drupal: export-drupal-build

# import Drupal Obiba Mica code Base
import-drupal: import-drupal-build

init:
	mkdir $(BACKUP_FOLDER) && \
	mkdir $(EXPORT_FOLDER) && \
	mkdir $(IMPORT_FOLDER)

up:
	docker-compose up -d

stop:
	docker-compose stop

start:
	docker-compose start

down:
	docker-compose down

shell:
	docker-compose exec drupal bash

backup-mysql-container:
	docker export yorkdocker_mysql_1 | gzip > $(BACKUP_FOLDER)/mysql.gz && \
	cd /data/containers/mysql_db/ && \
	tar -cvf $(BACKUP_FOLDER)/mysql_volume.gz *

restore-mysql-container:
	zcat $(BACKUP_FOLDER)/mysql.gz | docker import - yorkdocker_mysql_1 && \
	cp $(BACKUP_FOLDER)/mysql_volume.gz /data/containers/mysql_db/ && \
	cd /data/containers/mysql_db/ && \
	tar -xvf mysql_volume.gz


include drupal-manager.mk
include drupal-transfert-image.mk