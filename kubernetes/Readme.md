## Readme.md

![single line command refernce](https://jamesdefabia.github.io/docs/user-guide/kubectl/kubectl_run/)

_understanding of deployments_

![image](https://user-images.githubusercontent.com/57703276/198818503-ac49b212-b8e3-4788-9763-ae294662246f.png)


**pod with single container**

```yml
---
apiVersion: v1
kind: Pod
metadata:
  name: frontend
  namespace: op
spec:
  containers:
    - name: frontend
      image: nginx
      ports:
        - containerPort: 80
```

**pod with dual same container** - conflict error

```yml
---
apiVersion: v1
kind: Pod
metadata:
  name: frontend
  namespace: op
spec:
  containers:
    - name: frontend1
      image: nginx
      ports:
        - containerPort: 80
    - name: frontend2
      image: nginx
      ports:
        - containerPort: 80
```

**commands**

```bash
kubectl logs frontend -c frontend1 -n op
kubectl logs frontend -c frontend2 -n op
```

**pod with dual diffrenct container**

```yml
---
apiVersion: v1
kind: Pod
metadata:
  name: frontend-frontend
  namespace: op
spec:
  containers:
    - name: frontend
      image: nginx
      ports:
        - containerPort: 80
    - name: db
      image: mysql:5.7
      env:
        - name: MYSQL_ROOT_PASSWORD
          value: PasswordChange
      ports:
        - containerPort: 3306
```

**commands**

```bash
kubectl logs frontend-frontend -c frontend -n op
kubectl logs frontend-frontend -c db -n op
```

**multiple container with single pod**

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: frontend-db
  namespace: op
  labels:
    group: wd
spec:
  containers:
    - name: frontend
      image: nginx
      ports:
        - containerPort: 80
    - name: db
      image: mysql:5.7
      env:
        - name: MYSQL_ROOT_PASSWORD
          value: PasswordChange
      ports:
        - containerPort: 3306
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-db
  namespace: op
spec:
  type: ClusterIP
  selector:
    group: wd
  ports:
    - name: frontend
      port: 80
    - name: mysql
      port: 3306
```

**Environment variable setup**

```yml
---
apiVersion: v1
kind: Pod
metadata:
  name: frontend
  namespace: op
  labels:
    group: frontend
spec:
  containers:
    - name: frontend
      image: nginx
      env:
        - name: group
          value: frontend
      ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: frontend
  namespace: op
spec:
  type: LoadBalancer # For op-prem use this nodePort. this is validation purpose only
  selector:
    group: frontend
  ports:
    - name: frontend
      port: 80
---
apiVersion: v1
kind: Pod
metadata:
  name: db
  namespace: op
  labels:
    group: db
spec:
  containers:
    - name: db
      image: mysql:5.7
      env:
        - name: MYSQL_ROOT_PASSWORD
          value: PasswordChange
      ports:
        - containerPort: 3306
---
apiVersion: v1
kind: Service
metadata:
  name: db
  namespace: op
spec:
  type: ClusterIP
  selector:
    group: db
  ports:
    - name: mysql
      port: 3306
```

_switch the namespace_

```bash
kubectl config set-context --current --namespace=argocd
```
_change the exist service type_

```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

_configmap map as a environment variable_

```yml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: db
data:
  MYSQL_ROOT_PASSWORD: PasswordChange
---
apiVersion: v1
kind: Pod
metadata:
  name: db
  namespace: op
  labels:
    group: db
spec:
  containers:
    - name: db
      image: mysql:5.7
      envFrom:
        - configMapRef:
            name: db
      ports:
        - containerPort: 3306
---
apiVersion: v1
kind: Service
metadata:
  name: db
  namespace: op
spec:
  type: ClusterIP
  selector:
    group: db
  ports:
    - name: mysql
      port: 3306
```

_secret map as a env_

```yml
---
apiVersion: v1
kind: Secret
metadata:
  name: db
data:
  MYSQL_ROOT_PASSWORD: UGFzc3dvcmRDaGFuZ2UK
---
apiVersion: v1
kind: Pod
metadata:
  name: db
  namespace: op
  labels:
    group: db
spec:
  containers:
    - name: db
      image: mysql:5.7
      envFrom:
        - secretRef:
            name: db
      ports:
        - containerPort: 3306
---
apiVersion: v1
kind: Service
metadata:
  name: db
  namespace: op
spec:
  type: ClusterIP
  selector:
    group: db
  ports:
    - name: mysql
      port: 3306
```


```yml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: nginx:latest
        ports:
        - containerPort: 80
```

_statefulset_

```yml
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: db
spec:
  serviceName: "db" # Mandatory**
  replicas: 2
  selector:
    matchLabels:
      app: db
  template:
    metadata:
      labels:
        app: db
    spec:
      containers:
        - name: db
          image: mysql:5.7
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: PasswordChange
          ports:
            - containerPort: 3306
              name: db
---
apiVersion: v1
kind: Service
metadata:
  name: db
spec:
  type: ClusterIP
  selector:
    app: db
  ports:
    - name: mysql
      port: 3306

```

_Deamonset_

```yml
---
apiVersion: apps/v1
kind: DaemonSet # replica equal to number of nodes 20
metadata:
  name: frontend
spec:
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: nginx:latest
        ports:
        - containerPort: 80
```

probes

```yml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
        - name: frontend
          image: nginx:latest
          ports:
            - containerPort: 80 # /
          startupProbe:    # Application start up min time
            httpGet:
              path: /
              port: 80
            periodSeconds: 10
            failureThreshold: 30
          readinessProbe:  # application wait for 10s to running state  updation        
            httpGet:
              path: /
              port: 80
            periodSeconds: 10
            failureThreshold: 30
          livenessProbe:  # Polling interval for apps 
            httpGet:
              path: /
              port: 80
            periodSeconds: 10
            failureThreshold: 30
```

_init containers_

```yml
# Main service
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: node
spec:
  replicas: 3
  minReadySeconds: 10
  selector:
    matchLabels:
      app: node
  template:
    metadata:
      name: web
      labels:
        app: node
    spec:
      containers:
      - name: node-server
        image: jjino/node-redis:v1.0
        ports:
        - containerPort: 8080
      initContainers:
      - name: init
        image: jjino/test:latest
        args:
        - sh
        - -c
        - while true; do STATUS=$(redis-cli -h redis -p 6379 ping); if [ $STATUS = "PONG" ]; then echo "Connected"; break; else echo "Not connected"; fi; sleep 10; done
---
apiVersion: v1
kind: Service
metadata:
  name: node
spec:
  selector:
    app: node
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: LoadBalancer

# dependency service
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
spec:
  replicas: 1
  selector:
    matchLabels:
      role: redis
  template:
    metadata:
      name: redis
      labels:
        role: redis
    spec:
      containers:
      - name: redis-server
        image: redis
        ports:
        - containerPort: 6379 
          protocol: TCP
---
apiVersion: v1
kind: Service
metadata:
  name: redis
spec:
  selector:
    role: redis
  type: ClusterIP
  ports:
  - port: 6379
```

_loadbalancer with targetPort_

```yml
---
apiVersion: v1
kind: Pod
metadata:
  name: db
  namespace: op
  labels:
    group: db
spec:
  containers:
    - name: db
      image: jjino/node-api:v1001
      ports:
        - containerPort: 9000 
---
apiVersion: v1
kind: Service
metadata:
  name: db
  namespace: op
spec:
  type: LoadBalancer 
  selector:
    group: db
  ports:
    - name: mysql
      port: 80
      targetPort: 9000
```

_nodePort service_

```yml
---
apiVersion: v1
kind: Pod
metadata:
  name: db
  labels:
    group: db
spec:
  containers:
    - name: db
      image: jjino/node-api:v1001
      ports:
        - containerPort: 9000 
---
apiVersion: v1
kind: Service
metadata:
  name: db
spec:
  type: NodePort
  selector:
    group: db
  ports:
    - name: mysql
      port: 80
      targetPort: 9000
```

_podAntiAffinity__ - Each node run as a single pod with same applicaition

```yml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 10
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - frontend
              topologyKey: kubernetes.io/hostname
      containers:
        - name: frontend
          image: nginx:latest
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: db
spec:
  type: ClusterIP
  selector:
    app: frontend
  ports:
    - name: mysql
      port: 80
      targetPort: 9000
```

_podAffinity__ - All pods run with same node with same application

```yml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 10
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      affinity:
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - frontend
            topologyKey: kubernetes.io/hostname
      containers:
        - name: frontend
          image: nginx:latest
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: db
spec:
  type: ClusterIP
  selector:
    app: frontend
  ports:
    - name: mysql
      port: 80
      targetPort: 9000
```

_node selector_

```bash
kubectl label node aks-agentpool-42344554-vmss000000 operation=unknown
kubectl get nodes -l operation=unknown
```

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 10
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      nodeSelector:
        operation: unknown
      containers:
        - name: frontend
          image: nginx:latest
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: db
spec:
  type: ClusterIP
  selector:
    app: frontend
  ports:
    - name: mysql
      port: 80
      targetPort: 9000
```

_tolerations_

```yml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 10
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      tolerations:
      - key: "operation"
        operator: "Exists"
        effect: "NoSchedule" # supported values: "NoSchedule", "PreferNoSchedule", "NoExecute"
      containers:
        - name: frontend
          image: nginx:latest
          ports:
            - containerPort: 80
```
