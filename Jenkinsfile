podTemplate(cloud: 'k8s', yaml:
'''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: dind-kubectl
    image: gsxxm/docker-kubectl:latest
    securityContext:
      privileged: true
    env:
    - name: DOCKER_TLS_CERTDIR
      value: ""
    - name: DOCKER_HOST
      value: tcp://localhost:2375
    volumeMounts:
    - name: dind-storage
      mountPath: /var/lib/docker
  volumes:
  - name: dind-storage
    emptyDir: {}
''') {
    node(POD_LABEL) {
        def myRepo = checkout scm
        def commitHash = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
        def imageTag = "gsxxm/blog:${commitHash}"

        stage('构建镜像并部署') {
            container('构建镜像并部署') {
                withCredentials([[$class: 'UsernamePasswordMultiBinding',
                credentialsId: 'dockerhub',
                usernameVariable: 'DOCKER_HUB_USER',
                passwordVariable: 'DOCKER_HUB_PASSWORD']]) {
                    container('dind-kubectl') {
                        sh """
                            docker login -u ${DOCKER_HUB_USER} -p ${DOCKER_HUB_PASSWORD}
                            docker build -t ${imageTag} .
                            docker tag ${imageTag} ${imageTag}
                            docker push ${imageTag}
                        """
                        withKubeConfig([namespace: "star"]) {
                            sh """
                                kubectl set image deployment/blog blog=${imageTag} --record
                            """
                        }
                    }
                }
            }
        }
    }
}

