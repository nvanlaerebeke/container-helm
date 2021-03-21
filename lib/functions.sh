function GetChartInfo {
    NAME=helm-`yq read Chart.yaml -j | jq -r .name`
    VERSION=`yq read Chart.yaml -j | jq -r .version`
    NAMESPACE=`yq read Chart.yaml -j | jq -r .namespace`
    REGISTRY=`yq read Chart.yaml -j | jq -r -e .registry`
    if [[ $? -ne 0 ];
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

    local FULLVERSIONNAME=$REGISTRY/$NAME:$VERSION
    local FULLLATESTNAME=$REGISTRY/$NAME:$TAG

    helm chart save . "$FULLVERSIONNAME"
    helm chart save . "$FULLLATESTNAME"

    helm chart push "$FULLVERSIONNAME"
    helm chart push "$FULLLATESTNAME"
}

function upgrade {
    if [[ $GIT_LOCAL_BRANCH == "main" || $GIT_LOCAL_BRANCH == "autoupdate" ]];
    then
        GetChartInfo       
        helm upgrade -n "$NAMESPACE" "$NAME" .
    fi
}