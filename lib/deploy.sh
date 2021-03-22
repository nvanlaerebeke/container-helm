function helm_wait_till_ready_registry {
    local CHART_NAME=$1
    local NAME=$2
    local NAMESPACE=$3

    # full list: unknown, deployed, uninstalled, superseded, failed, uninstalling, pending-install, pending-upgrade or pending-rollback
    local STATUS=`helm status "$CHART_NAME" -n $NAMESPACE -o json | jq -r .info.status`
    
    #unable to get status
    if [ $? -ne 0 ];
    then
        echo "Unable to get status"
        sleep 5
        helm_wait_till_ready_registry "$CHART_NAME" "$NAME" "$NAMESPACE"
        return
    fi

    if [[ "$STATUS" != "unknown" && "$STATUS" != "deployed" && "$STATUS" != "failed" ]]; then
        sleep 1
        helm_wait_till_ready_registry "$CHART_NAME" "$NAME" "$NAMESPACE"
        return
    fi

    if [ $STATUS == "failed" ];
    then
        echo "Status is failed, re-deploy"
        sleep 5
        helm uninstall -n $NAMESPACE "$CHART_NAME"
        helm_install_from_registry "$CHART_NAME" "$NAME" "$NAMESPACE"
        return
    fi

    local INFO=`kubectl get deployment -n $NAMESPACE ''$CHART_NAME'' -o json`
    if [ -z "$INFO" ];
    then
        echo "No deloyment found, waiting..."
        sleep 5
        helm_wait_till_ready_registry "$CHART_NAME" "$NAME" "$NAMESPACE"
        return
    else 
        local REPLICA_COUNT=`echo $INFO | jq -r '.status.availableReplicas'`
        if [[ $REPLICA_COUNT != null && $REPLICA_COUNT -gt 0 ]];
        then
            return
        else 
            local KUBE_STATUS=`echo $INFO | jq -r '.status.conditions[0].type'`
            #ToDo: error handling for when things to fubar
            sleep 1
            helm_wait_till_ready_registry "$CHART_NAME" "$NAME" "$NAMESPACE"
            return
        fi
    fi
}

function helm_install_from_registry {
    local NAME=$1
    local NAMESPACE=$2
    local TMP_DIR=$(mktemp -d -t helm-XXXXXXXXXX)
    
    mkdir -p $TMP_DIR && cd $TMP_DIR
    helm chart pull registry.crazyzone.be/$NAME:latest
    helm chart export registry.crazyzone.be/$NAME:latest > /dev/null 2>&1
    
    local CHART_NAME=`yq read */Chart.yaml -j | jq -r .name`
    if [ -z $NAMESPACE ]; 
    then
        local NAMESPACE=`yq read */Chart.yaml -j | jq -r .namespace`
    fi
    local EXISTS=`helm list -n $NAMESPACE -o json | jq '.[] | select(.name == "'$CHART_NAME'")'`
    if [ ! -z "$EXISTS" ];
    then
        echo "$NAME already exists, uninstall"
        helm uninstall -n $NAMESPACE "$CHART_NAME" > /dev/null 2>&1
    fi
    
    helm install -n "$NAMESPACE" "$CHART_NAME" "$CHART_NAME"
    if [ ! -z "$TMP_DIR" ];
    then
        rm -rf "$TMP_DIR"
    fi
    helm_wait_till_ready_registry "$CHART_NAME" "$NAME" "$NAMESPACE"
}