function GetChartInfo {
    NAME=`yq read Chart.yaml -j | jq -r .name`
    REGISTRYNAME=helm-$NAME
    VERSION=`yq read Chart.yaml -j | jq -r .version`
    REGISTRY=`yq read Chart.yaml -j | jq -r -e .registry`
    if [ $? -ne 0 ];
    then
        REGISTRY=registry.crazyzone.be
    fi
}

function push {
    GetChartInfo
    
    if [[ $GIT_LOCAL_BRANCH == "main" || $GIT_LOCAL_BRANCH == "master" ]];
    then
        local TAG=latest
    else
        local TAG=$GIT_LOCAL_BRANCH
    fi

    local FULLVERSIONNAME=$REGISTRY/$REGISTRYNAME:$VERSION
    local FULLLATESTNAME=$REGISTRY/$REGISTRYNAME:$TAG

    helm chart save . "$FULLVERSIONNAME"
    helm chart save . "$FULLLATESTNAME"

    helm chart push "$FULLVERSIONNAME"
    helm chart push "$FULLLATESTNAME"
}


function upgrade {
    local NAMESPACE=$1
    if [[ $GIT_LOCAL_BRANCH == "main" || $GIT_LOCAL_BRANCH == "autoupdate" ]];
    then
        GetChartInfo
        local DEPLOYMENT=`helm list -n "$NAMESPACE" -o json -f "$NAME" | jq '.[]'`
        if [ $? -ne 0 ];
        then
            echo "Failed getting deployments"
            exit 1
        else
            echo "Found deployment"
            echo $DEPLOYMENT | jq
        fi

        local DEPLOYED_VERSION=`echo $DEPLOYMENT | jq -r '.app_version'`
        local TARGETNAME=`echo $DEPLOYMENT | jq -r '.name'`
        
        if [ $DEPLOYED_VERSION == $VERSION ];
        then
            echo "Running auto update"
            echo helm upgrade --install -n "$NAMESPACE" "$TARGETNAME" .
            helm upgrade --install -n "$NAMESPACE" "$TARGETNAME" .
            if [ $? -ne 0 ];
            then
                echo "Failed to upgrade helm chart"
                exit 1
            else 
                echo "Update completed"
                helm list -n "$NAMESPACE" -o json -f "$NAME"
            fi
        else
            echo "Deployed version $DEPLOYMENT_VERSION does not match $VERSION, skipping auto update"
            return;
        fi
    else
        echo "Not building the master branch, not auto updating"
        return;
    fi
}