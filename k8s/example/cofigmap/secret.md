# secret

## 三种可选参数

+ generic
+ tls
+ docker-registry

## 三种类型

+ serviceaccount
+ Opaque
+ dockerconfigjson

## 使用secret

### 通过环境变量引入

```bash
kubectl create secret generic mysql-password --from-literal=password="123456"
```

```bash
kubectl get secrets mysql-password -o yaml
apiVersion: v1
data:
  password: MTIzNDU2
kind: Secret
metadata:
  creationTimestamp: "2022-11-09T08:25:07Z"
  name: mysql-password
  namespace: default
  resourceVersion: "346304"
  uid: ea39a658-7e0a-4c70-bcc1-f771a11e0719
type: Opaque
```

```bash
cat pod-secret.yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-secret
spec:
  containers:
  - name: mysql
    image: sealos.hub:5000/mariadb:10.3
    imagePullPolicy: IfNotPresent
    env:
      - name: MYSQL_ROOT_PASSWORD
        valueFrom:
          secretKeyRef:
            name: mysql-password
            key: password
  restartPolicy: Never
```

```bash
cat secret.yaml
apiVersion: v1
data:
  password: MTIzNDU2
kind: Secret
metadata:
  name: mysql-password
type: Opaque
```

### 通过Volume挂载secret
```bash
echo -n 'admin'|base64
YWRtaW4=
echo -n '12345'|base64
MTIzNDU=

cat secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
data:
  username: YWRtaW4=
  password: MTIzNDU=
type: Opaque

kubectl apply -f secret.yaml

cat pod-secret-volume.yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-secret-volume
spec:
  containers:
  - name: mysql
    image: sealos.hub:5000/busybox:latest
    imagePullPolicy: IfNotPresent
    command: [ "/bin/sh", "-c", "sleep 3600"]
    volumeMounts:
    - name: secret-volume
      mountPath: /etc/secret
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: mysecret

kubectl apply -f pod-secret-volume.yaml
kubectl exec -it pod-secret-volume -- ls /etc/secret
password  username
```
