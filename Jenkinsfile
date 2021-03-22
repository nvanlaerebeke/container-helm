pipeline {
  agent {
    kubernetes {
      yaml '''
kind: Pod
metadata:
  name: kaniko
spec:
  volumes:
    - name: kaniko-cache
      nfs: 
        server: nas.crazyzone.be 
        path: /volume1/docker-storage/kaniko/cache
  containers:
  - name: kaniko
    image: registry.crazyzone.be/kaniko:20210317
    imagePullPolicy: Always
    tty: true
    command:
    - sleep
    - infinity
    volumeMounts:
    - name: kaniko-cache
      mountPath: /cache   
'''
    }

  }
  stages {
    stage('build') {
      steps {
        container(name: 'kaniko', shell: '/busybox/sh') {
          sh '''#!/busybox/sh 
NAME=helm
VERSION=`cat VERSION`
REGISTRY=registry.crazyzone.be
REGISTRY_MIRROR=registry-mirror.crazyzone.be

if [[ $GIT_LOCAL_BRANCH == "main" || $GIT_LOCAL_BRANCH == "master" ]];
then
  TAG=latest
else
  TAG=$GIT_LOCAL_BRANCH
fi
/kaniko/executor --dockerfile Dockerfile --context `pwd`/ --verbosity debug --destination $REGISTRY/$NAME:$TAG --destination $REGISTRY/$NAME:$VERSION --cache=true --cache-repo $REGISTRY/cache --registry-mirror $REGISTRY_MIRROR
            '''
        }
      }
    }
  }
}