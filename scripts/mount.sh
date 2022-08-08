

SSH_PATH="/home/harsunda1/anthos-config-sync/ssh/acm-public-key"
echo $(gcloud secrets versions access latest --secret="acm-private-key") >> ${SSH_PATH}
kubectl get secrets -n config-management-system

kubectl create secret generic git-creds \
 --namespace=${ACM_NAMESPACE}\
 --from-file=ssh=${SSH_PATH}

CLUSTER="gke-acm-cluster"
PROJECT_ID="sandbox-db-enablers"
USER_NAME="harideveloper" 
HELM_GIT_CREDS=$(echo $(gcloud secrets versions access latest --secret="act-root-sync-private-key"))
helm upgrade config-sync . \
 --set clusterName="${CLUSTER}" \
 --set projectID="${PROJECT_ID}" \
 --set configsync.getUsername="${USER_NAME}" \
 --set configsync.getSSH="${HELM_GIT_CREDS}"

helm upgrade config-sync . \
 --set clusterName="${CLUSTER}" \
 --set projectID="${PROJECT_ID}" \
 --set configsync.gitProxy="${USER_NAME}" \
 --set configsync.getUsername="${USER_NAME}" \
 --set configsync.getSSH="hari" \ –dry-run --debug

