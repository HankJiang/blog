podTemplate(cloud: 'k8s', yaml:
'''
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: docker
      image: gsxxm/docker-kubectl:latest
      securityContext:
        privileged: true
      env:
        - name: DOCKER_TLS_CERTDIR
          value: ""
''') {
    node(POD_LABEL) {
        def gitRepo = "https://github.com/HankJiang/blog.git"
        def imageTag = "gsxxm/blog:${commitHash}"

        git 'https://github.com/HankJiang/blog.git'
        def commitHash = sh(script: 'git rev-parse --short HEAD', returnStdout: true)

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
                                kubectl set image deployment/blog blog=${imageTag} --record
                            """
                        }
                    }
                }
            }
        }
    }
}

