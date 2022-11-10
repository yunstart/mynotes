<!-- vscode-markdown-toc -->
* 1. [创建configmap](#configmap)
	* 1.1. [命令行直接创建](#)
	* 1.2. [通过文件创建](#-1)
	* 1.3. [通过目录创建](#-1)
	* 1.4. [通过yaml配置文件](#yaml)
* 2. [使用configmap](#configmap-1)
	* 2.1. [通过环境变量引入，使用configMapkeyRef](#configMapkeyRef)
	* 2.2. [通过环境变量引入，使用envfrom](#envfrom)
	* 2.3. [configmap做成volume，挂载到pod](#configmapvolumepod)
	* 2.4. [configmap热更新](#configmap-1)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->
# configmap
##  1. <a name='configmap'></a>创建configmap
###  1.1. <a name=''></a>命令行直接创建

通过`--from-literal`指定参数

```bash
kubectl create configmap tomcat-config --from-literal=tomcat_port=8080 --from-literal=server_name=myapp.tomcat.com
kubectl describe cm tomcat-config
Data
====
server_name:
----
myapp.tomcat.com
tomcat_port:
----
8080
```

###  1.2. <a name='-1'></a>通过文件创建

```bash
kubectl create configmap nginx --from-file=nginx=./nginx.conf
```

###  1.3. <a name='-1'></a>通过目录创建

```bash
kubectl create configmap nginx-conf --from-file=./nginx/
```

###  1.4. <a name='yaml'></a>通过yaml配置文件

```bash
apiVersion: v1
kind: ConfigMap
metadata:
  creationTimestamp: 2016-02-18T18:52:05Z
  name: game-config
  namespace: default
  resourceVersion: "516"
  uid: b4952dc3-d670-11e5-8cd0-68f728db1985
data:
  game.properties: |
    enemies=aliens
    lives=3
    enemies.cheat=true
    enemies.cheat.level=noGoodRotten
    secret.code.passphrase=UUDDLRLRBABAS
    secret.code.allowed=true
    secret.code.lives=30    
  ui.properties: |
    color.good=purple
    color.bad=yellow
    allow.textmode=true
    how.nice.to.look=fairlyNice  
```

##  2. <a name='configmap-1'></a>使用configmap

###  2.1. <a name='configMapkeyRef'></a>通过环境变量引入，使用configMapkeyRef

```bash
cat mysql-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql
  labels:
    app: mysql
data:
  log: "1"
  lower: "1"
```

```bash
cat pod-configmap.yaml
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: registry.k8s.io/busybox
      imagePullPolicy: IfNotPresent
      command: [ "/bin/sh", "-c", "env" ]
      env:
        - name: SPECIAL_LEVEL_KEY
          valueFrom:
            configMapKeyRef:
              name: special-config
              key: special.how
  restartPolicy: Never
```

###  2.2. <a name='envfrom'></a>通过环境变量引入，使用envfrom
```bash
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: registry.k8s.io/busybox
      command: [ "/bin/sh", "-c", "env" ]
      envFrom:
      - configMapRef:
          name: special-config
  restartPolicy: Never
```
###  2.3. <a name='configmapvolumepod'></a>configmap做成volume，挂载到pod
```bash
cat mysql-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql
  labels:
    app: mysql
data:
  MYSQL_ROOT_PASSWORD: "123456"
  my.cnf: |
    [mysqld]
    [mysql]
```

```bash
apiVersion: v1
kind: Pod
metadata:
  name: mysql-pod
spec:
  containers:
  - name: mysql
    image: sealos.hub:5000/mariadb:10.3
    imagePullPolicy: IfNotPresent
    envFrom:
      - configMapRef:
          name: mysql
    volumeMounts:
    - name: mysql-config
      mountPath: /tmp/config
  volumes:
  - name: mysql-config
    configMap:
      name: mysql
  restartPolicy: Never
```

###  2.4. <a name='configmap-1'></a>configmap热更新
+ 以卷的形式挂载，会自动热加载
+ 以env的形式挂载，不会自动热加载
