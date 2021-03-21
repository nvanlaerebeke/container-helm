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
        fi
        local DEPLOYED_VERSION=`echo $DEPLOYMENT | jq -r '.app_version'`
        local TARGETNAME=`echo $DEPLOYMENT | jq -r '.name'`
        
        if [ $DEPLOYED_VERSION == $VERSION ];
        then
            helm upgrade --install -n "$NAMESPACE" "$TARGETNAME" .
            if [ $? -ne 0 ];
            then
                echo "Failed to upgrade helm chart"
                exit 1
            fi
        fi
    fi
}