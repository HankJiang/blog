def label = "jenkins-slave"
podTemplate(label: 'jenkins-slave' , cloud: 'k8s') {
    node('jenkins-slave') {
        //拉取仓库代码
        def myRepo = checkout scm
        def gitBranch = myRepo.GIT_BRANCH.replaceAll("origin/","").replaceAll("/","-").replaceAll("\\.","-")
        def timestamp = sh(script: "echo `date '+%Y%m%d%H%M%S'`", returnStdout: true).trim()
        def gitCommit = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
        gitCommit = "${gitCommit}_${timestamp}"

        //镜像标签，这里使用git分支名作为镜像的tag
        def imageTag = "${gitBranch}"
        //镜像仓库基础地址
        def dockerRegistryUrl = "https://hub.docker.com/r/gsxxm/blog"
        //应用服务名称，统一用于以下各个变量名称
        def appName = "blog"

        //模板需要更改的值 开始
        //helm工具发布时，使用的名称，这里使用【应用名-分支名】的格式
        def helmReleaseName = "${appName}-${gitBranch}"
        //部署应用服务的命名空间
        def namespace = "${appName}"
        //镜像的中间名称，用于平均基础镜像地址
        def imageEndpoint = "${appName}/webapi"
        //模板需要更改的值 结束

        //完整镜像地址（不包含镜像tag）
        def image = "${dockerRegistryUrl}/${imageEndpoint}"
        //helmChart模版的仓库名称
        def chartName = "${appName}"
        //helmChart的版本
        def chartVersion = "1.0"
        //helmChart完整名称
        def chartDirName = "${appName}/${appName}"
        //K8S的网络模式，一般有Cluster（不对外访问）、NodePort（释放端口对外访问）
        def serviceType = "ClusterIP"
        //如果serviceType值是NodePort，这里可以设置指定供对外访问的端口号，不指定则随机，范围详见K8S的NodePort范围，默认是30000-32767
        def serviceNodePort = ""

        stage('构建 Docker 镜像阶段') {
            container('构建 Docker 镜像') {
                withCredentials([[$class: 'UsernamePasswordMultiBinding',
                credentialsId: 'dockerhub',
                usernameVariable: 'DOCKER_HUB_USER',
                passwordVariable: 'DOCKER_HUB_PASSWORD']]) {
                    //此处是引入了docker环境，进行docker的打包，推送到远程仓库等操作
                    container('docker') {
                        sh """
                        docker login ${dockerRegistryUrl} -u ${DOCKER_HUB_USER} -p ${DOCKER_HUB_PASSWORD}
                        docker build -t ${imageEndpoint}:${imageTag} .
                        docker tag ${imageEndpoint}:${imageTag}   ${dockerRegistryUrl}/${imageEndpoint}:${imageTag}
                        docker push ${image}:${imageTag}
                        """
                    }
                }
            }
        }
    }
}
