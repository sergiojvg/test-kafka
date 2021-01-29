#########################################################################
########################## PROMETHEUS SERVER ############################
#########################################################################

resource "helm_release" "prometheus" {
  name       = "prometheus"
  chart      = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  namespace  = "default"
  timeout    = "1200"

  values =[<<EOF
alertmanager:
  enabled: false
  persistentVolume:
    enabled: false

kubeStateMetrics:
  enabled: false

nodeExporter:
  enabled: false

server:
  persistentVolume:
    enabled: false

pushgateway:
  enabled: false

serverFiles:
  prometheus.yml:
    scrape_configs:
      - job_name: 'kafka-metrics'
        kubernetes_sd_configs:
          - role: endpoints
        scheme: http
        metrics_path: '/metrics'
        relabel_configs:
          - source_labels: 
            - __meta_kubernetes_service_label_app_kubernetes_io_instance
            action: keep
            regex: kafka
          - source_labels: 
            - __meta_kubernetes_service_label_app_kubernetes_io_component
            action: keep
            regex: metrics
      - job_name: 'kafka-jmx'
        kubernetes_sd_configs:
          - role: endpoints
        scheme: http
        metrics_path: '/metrics'
        relabel_configs:
          - source_labels: 
            - __meta_kubernetes_service_label_app_kubernetes_io_instance
            action: keep
            regex: kafka
          - source_labels: 
            - __meta_kubernetes_service_label_app_kubernetes_io_component
            action: keep
            regex: kafka
          - source_labels: 
            - __meta_kubernetes_service_label_app_kubernetes_io_name
            action: keep
            regex: kafka
          - source_labels: 
            - __meta_kubernetes_pod_container_port_name
            action: keep
            regex: metrics
EOF
 ]
}

data "kubernetes_service" "prometheus-server" {
  metadata {
    name = "prometheus-server"
  }
  depends_on = [helm_release.prometheus]
}

resource "kubernetes_service" "prometheus-lb" {
  metadata {
    name = "prometheus-lb"
  }
  spec {
    selector = {
      "app" = "prometheus"
      "component" = "server"
    }
    session_affinity = "ClientIP"
    port {
      port        = 9090
      target_port = 9090
    }

    type = "LoadBalancer"
  }
}

#########################################################################
############################### GRAFANA #################################
#########################################################################

resource "helm_release" "grafana" {
  name       = "grafana"
  chart      = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  namespace  = "default"
  timeout    = "1200"
  version    = "6.1.17"

  values =[<<EOF

service:
  type: LoadBalancer
  port: 3000
  targetPort: 3000

adminUser: evolution
adminPassword: evolution

plugins: 
  - grafana-piechart-panel

datasources: 
  datasources.yaml:
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      url: http://${data.kubernetes_service.prometheus-server.metadata.0.name}
      access: proxy
      isDefault: true

dashboardProviders: 
  dashboardproviders.yaml:
    apiVersion: 1
    providers:
    - name: 'default'
      orgId: 1
      folder: ''
      type: file
      disableDeletion: false
      editable: true
      options:
        path: /var/lib/grafana/dashboards/default

dashboards: 
  default:
    kafka-main-server:
      gnetId: 12460
      revision: 1
      datasource: Prometheus
    kafka-topics:
      gnetId: 10122
      revision: 1
      datasource: Prometheus
EOF
 ]
}

