#!/usr/bin/env bash
echo "Installing PostgreSQL..."
oc new-app postgresql-persistent --param POSTGRESQL_DATABASE=gogs --param POSTGRESQL_USER=gogs --param POSTGRESQL_PASSWORD=gogs --param VOLUME_CAPACITY=4Gi -lapp=postgresql_gogs
echo "Installing Gogs..."
oc new-app wkulhanek/gogs:11.86 -lapp=gogs
oc patch dc gogs --patch='{ "spec": { "strategy": { "type": "Recreate" }}}'
oc set volume dc/gogs --add --overwrite --name=gogs-volume-1 --mount-path=/data/ --type persistentVolumeClaim --claim-name=gogs-data --claim-size=4Gi
echo "Exposing the service"
oc expose svc  gogs
echo "The Gogs route is:"
oc get route gogs
echo "Now open the Gogs URL in the browser and configure Gogs"
echo "After you have configured Gogs press Enter to continue"
read nothing
oc cp $(oc get pod | grep "^gogs" | grep Running | awk '{print $1}'):opt/gogs/custom/conf/app.ini $HOME/app.ini
oc create configmap gogs --from-file=$HOME/app.ini
oc set volume dc/gogs --add --overwrite --name=config-volume -m /opt/gogs/custom/conf/ -t configmap --configmap-name=gogs

