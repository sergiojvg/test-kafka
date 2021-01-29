locals {
  k3s_config_file_path = "/etc/rancher/k3s/k3s.yaml"
}

provider "kubernetes" {
  config_path = local.k3s_config_file_path
}

provider "helm" {
  kubernetes {
    config_path = local.k3s_config_file_path
  }
}

resource "helm_release" "kafka" {
  name       = "kafka"
  chart      = "kafka"
  repository = "https://charts.bitnami.com/bitnami"
  namespace  = "default"
  timeout    = "1200"

  values =[<<EOF
#service:
#  type: LoadBalancer
metrics:
  kafka: 
    enabled: true
  jmx:
    enabled: true
provisioning:
  enabled: true
  topics:
  - name: input
    partitions: 1
    replicationFactor: 1
    config:
      max.message.bytes: 64000
      flush.messages: 1
  - name: output
    partitions: 1
    replicationFactor: 1
    config:
      max.message.bytes: 64000
      flush.messages: 1
EOF
 ]
}



resource "kubernetes_pod" "consumer" {
  metadata {
    name = "consumer"
  }
  spec {
    container {
      name = "consumer"
      image  = "docker.io/sergiojvg92/ruby-producer2:v0.5"
      command = [
        "ruby",
        "/usr/src/app/consumer.rb"
      ]
    }
  }
}


resource "kubernetes_pod" "producer" {
  metadata {
    name = "producer"
  }
  spec {
    container {
      name = "provider"
      image  = "docker.io/sergiojvg92/ruby-producer2:v0.5"
      command = [
        "ruby",
        "/usr/src/app/producer.rb"
      ]
    }
  }
}


