---
title: Jenkinsfile模版仓库
categories: 笔记
tags:
  - Docker
ai:
  - 个人使用的一些Jenkinsfile模版。
abbrlink: e5be
date: 2023-06-07 21:58:39
---

### 1. `git` -> `dockerhub` -> `kubernetes`

- 适用jenkins运行在kubernetes中。
- 需要安装git和kubernetes插件。

```groovy
podTemplate(cloud: '<cloud-name>', yaml:
'''
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: docker-kubectl
      image: <docker-kubectl-image>
      securityContext:
        privileged: true
''') {
    node(POD_LABEL) {
        def myRepo = checkout scm
        def commitHash = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
        def imageTag = "<dockerhub-username>/<reponame>:${commitHash}"

        stage('构建镜像并部署') {
            container('构建镜像并部署') {
                withCredentials([[$class: 'UsernamePasswordMultiBinding',
                credentialsId: 'dockerhub',
                usernameVariable: 'DOCKER_HUB_USER',
                passwordVariable: 'DOCKER_HUB_PASSWORD']]) {
                    container('docker') {
                        sh """
                            docker login -u ${DOCKER_HUB_USER} -p ${DOCKER_HUB_PASSWORD}
                            docker build -t ${imageTag} .
                            docker tag ${imageTag} ${imageTag}
                            docker push ${imageTag}
                        """
                        withKubeConfig([namespace: "star"]) {
                            sh """
                                kubectl set image deployment/<deployment-name> <container-name>=${imageTag} --record
                            """
                        }
                    }
                }
            }
        }
    }
}
```
