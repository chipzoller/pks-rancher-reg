#!/bin/sh
#requires curl and jq
# Get PKS cluster name from node label using JSONPath.
PKS_CLUSTER=$(/kubectl get nodes -o jsonpath='{.items[0].metadata.labels.pks-system/cluster\.name}')
echo "PKS cluster name is: $PKS_CLUSTER"
echo "Rancher server is: $RANCHER_SERVER"
#echo "Token is: $RANCHER_BEARER"
#echo "Rancher cert is: $(cat $CURL_CA_BUNDLE)"
# Register the cluster with Rancher returning the cluster ID value. Fail if value is empty.
RANCHER_CID=$(curl -s -H "Authorization: Bearer $RANCHER_BEARER" -H "Accept: application/json" -H "Content-Type: application/json" -X POST "https://$RANCHER_SERVER/v3/cluster" -d '{ "dockerRootDir": "/var/vcap/store/docker/docker", "enableClusterAlerting": false, "enableClusterMonitoring": false, "enableNetworkPolicy": false, "type": "cluster", "name": "'"$PKS_CLUSTER"'" }' | jq -r '.id')
if [[ ! $RANCHER_CID =~ ^c- ]];
then
  echo "Returned cluster ID is not in the expected format. Check to ensure the CA certificate contains line breaks before and after the contents."
  exit 1
else
  echo "Cluster ID is: $RANCHER_CID"
fi
# Call to Rancher to generate the registration manifest. Fail if value is empty.
RANCHER_REG=$(curl -s -H "Authorization: Bearer $RANCHER_BEARER" -H "Accept: application/json" -H "Content-Type: application/json" -X POST "https://$RANCHER_SERVER/v3/clusterregistrationtoken" -d '{"type":"clusterRegistrationToken","clusterId":"'"$RANCHER_CID"'"}' | jq -r '.manifestUrl')
if [[ ! $RANCHER_REG =~ ^https.*yaml$ ]];
then
  echo "RANCHER_REG did not return a valid path to YAML. Script will fail."
  exit 1
else
  echo "Registration URL is: $RANCHER_REG"
fi
echo "Registering $PKS_CLUSTER with $RANCHER_SERVER"
curl -sfL $RANCHER_REG | /kubectl apply -f -
# Verify if cluster successfully registered?
