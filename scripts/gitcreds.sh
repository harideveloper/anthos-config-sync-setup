
echo -e "ACM_NAMESPACE is ${ACM_NAMESPACE}"
echo -e "GIT_USER is ${GIT_USER}"
echo -e "TOKEN is ${TOKEN}"
echo -e "TOKEN is ${SSH_PATH}"


gcloud container clusters get-credentials gke-acm-cluster --zone europe-west2-a --project sandbox-db-enablers
# echo $(gcloud secrets versions access latest --secret="acm-private-key") >> ${SSH_PATH}
GIT_CREDS=$(echo $(gcloud secrets versions access latest --secret="act-root-sync-private-key"))
echo $GIT_CREDS

kubectl get namespace

## USING TOKEN 
# kubectl create ns config-management-system && \
# kubectl create secret generic git-creds \
#   --namespace=${ACM_NAMESPACE}\
#   --from-literal=username=${GIT_USER} \
#   --from-literal=token=${TOKEN}


# kubectl create ns config-management-system && \
# kubectl create secret generic git-creds \
#  --namespace=${ACM_NAMESPACE}\
#  --from-file=ssh=${SSH_PATH}

## USING SSH
kubectl create secret generic git-creds \
 --namespace=${ACM_NAMESPACE}\
 --from-literal=username=${GIT_USER}\
 --from-literal=ssh="$GIT_CREDS"

kubectl get secrets -n config-management-system 