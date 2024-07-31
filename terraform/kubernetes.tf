resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.resource_prefix
  }
}

resource "kubernetes_persistent_volume" "library_app_pv" {
  metadata {
    name = "${var.resource_prefix}-library-app-pv"
  }

  spec {
    capacity = {
      storage = "5Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"

    persistent_volume_source {
      host_path {
        path = "/mnt/data"
        type = "DirectoryOrCreate"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "library_app_pvc" {
  depends_on = [
    kubernetes_namespace.namespace,
    kubernetes_persistent_volume.library_app_pv
  ]

  metadata {
    name      = "${var.resource_prefix}-library-app-pvc"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.library_app_pv.metadata[0].name
  }
}

resource "kubernetes_deployment" "library_app" {
  depends_on = [
    kubernetes_namespace.namespace
  ]

  metadata {
    name      = "${var.resource_prefix}-library-app-deployment"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "${var.resource_prefix}-library-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "${var.resource_prefix}-library-app"
        }
      }

      spec {
        container {
          name  = "${var.resource_prefix}-library-app"
          image = var.docker_image
          port {
            container_port = 5000
          }

          volume_mount {
            name       = "${var.resource_prefix}-library-db-storage"
            mount_path = "/app/data"
          }
        }

        volume {
          name = "${var.resource_prefix}-library-db-storage"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.library_app_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "library_app_service" {
  depends_on = [
    kubernetes_namespace.namespace
  ]

  metadata {
    name      = "${var.resource_prefix}-library-app-service"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  spec {
    type = "LoadBalancer"
    port {
      port        = 5000
      target_port = 5000
    }

    selector = {
      app = "${var.resource_prefix}-library-app"
    }
  }
}
