# Redis StatefulSet у Kubernetes (Minikube)

## Опис

Створено Redis-кластер у Kubernetes з використанням StatefulSet. Кожен под має власний том для зберігання даних та стабільне DNS-ім’я для внутрішньої взаємодії.

## Що створено

- `redis-service.yaml` — Headless Service для подів StatefulSet
- `redis-statefulset.yaml` — StatefulSet з двома Redis-подами та PVC для кожного

## Запуск

minikube start --driver=docker

kubectl apply -f redis-service.yaml
kubectl apply -f redis-statefulset.yaml

kubectl exec -it redis-0 -- redis-cli
set mykey "hello"
get mykey

kubectl delete pod redis-0
kubectl get pods

kubectl exec -it redis-0 -- redis-cli
get mykey