---
title: Deployment模版仓库
categories: 笔记
tags:
  - Kubernetes
ai:
  - 个人使用的一些Deployment模版。
date: 2023-06-20 21:22:16
---

### 1. Jenkins

```yaml
############### pvc ###################
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: jenkins-data-home
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: "/mnt/k8s/jenkins"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-data-home-claim
  namespace: star
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
############### deployment ###################
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins
  namespace: star
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins
  template:
    metadata:
      labels:
        app: jenkins
    spec:
      terminationGracePeriodSeconds: 10
      containers:
        - name: jenkins
          image: jenkins/jenkins:latest
          imagePullPolicy: IfNotPresent
          env:
            - name: JAVA_OPTS
              value: -Duser.timezone=Asia/Shanghai
          ports:
            - containerPort: 8080
              name: web
              protocol: TCP
            - containerPort: 50000
              name: agent
              protocol: TCP
          resources:
            limits:
              cpu: 500m
              memory: 500Mi
            requests:
              cpu: 200m
              memory: 200Mi
          livenessProbe:
            httpGet:
              path: /login
              port: 8080
            initialDelaySeconds: 60
            timeoutSeconds: 5
            failureThreshold: 12
          readinessProbe:
            httpGet:
              path: /login
              port: 8080
            initialDelaySeconds: 60
            timeoutSeconds: 5
            failureThreshold: 12
          volumeMounts:
            - name: jenkinshome
              mountPath: /var/jenkins_home
      securityContext:
        runAsUser: 0
      volumes:
        - name: jenkinshome
          persistentVolumeClaim:
            claimName: jenkins-data-home-claim
############### service ###################
---
apiVersion: v1
kind: Service
metadata:
  name: jenkins
  namespace: star
  labels:
    app: jenkins
spec:
  selector:
    app: jenkins
  type: ClusterIP
  ports:
    - name: web
      port: 8080
      targetPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: jenkins-agent
  namespace: star
  labels:
    app: jenkins
spec:
  selector:
    app: jenkins
  type: ClusterIP
  ports:
    - name: agent
      port: 50000
      targetPort: 50000
```

### 2. Chat-GPT

```yaml
############### deployment ###################
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gpt
  namespace: <namespace>
spec:
  replicas: 1
  selector:
    matchLabels:
      app: gpt
  template:
    metadata:
      labels:
        app: gpt
    spec:
      nodeSelector:
        flag: <node-tag>
      terminationGracePeriodSeconds: 10
      containers:
        - name: gpt
          image: yidadaa/chatgpt-next-web
          imagePullPolicy: Always
          env:
            - name: OPENAI_API_KEY
              value: <api-key>
            - name: CODE
              value: <password1,password2,password3>
          ports:
            - containerPort: 3000
              name: web
              protocol: TCP
          resources:
            limits:
              cpu: 1000m
              memory: 1Gi
            requests:
              cpu: 500m
              memory: 512Mi
          securityContext:
            runAsUser: 0
############### service ###################
---
apiVersion: v1
kind: Service
metadata:
  name: gpt
  namespace: star
  labels:
    app: gpt
spec:
  selector:
    app: gpt
  type: ClusterIP
  ports:
    - name: web
      port: 3000
      targetPort: 3000
```
