podTemplate(cloud: 'k8s', yaml:
'''
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: docker
      image: docker:19.03.1-dind
      securityContext:
        privileged: true
      env:
        - name: DOCKER_TLS_CERTDIR
          value: ""
''') {
    node(POD_LABEL) {
        git 'https://github.com/HankJiang/blog.git'
        def imageTag = "gsxxm/blog:latest"

        stage('构建Docker镜像') {
            container('构建 Docker 镜像') {
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
                    }
                }
            }
        }

        stage('部署到集群') {
            withKubeConfig([namespace: "star"]) {
                sh 'kubectl apply -f deployment.yaml'
            }
        }
    }
}

