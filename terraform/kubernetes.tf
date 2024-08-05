# Create a Kubernetes namespace with a name based on the resource prefix
resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.resource_prefix
  }
}

# Define a Persistent Volume (PV) for the library application
resource "kubernetes_persistent_volume" "library_app_pv" {
  metadata {
    name = "${var.resource_prefix}-library-app-pv"
  }

  spec {
    capacity = {
      storage = "5Gi"  # Define the storage capacity of the PV
    }
    access_modes = ["ReadWriteOnce"]  # Specify that the volume can be mounted as read-write by a single node
    persistent_volume_reclaim_policy = "Retain"  # Retain the volume after it is released by the claim

    # Specify the source of the PV as a host path
    persistent_volume_source {
      host_path {
        path = "/mnt/data"  # Path on the host where the volume is stored
        type = "DirectoryOrCreate"  # Create the directory if it doesn't exist
      }
    }
  }
}

# Define a Persistent Volume Claim (PVC) for the library application
resource "kubernetes_persistent_volume_claim" "library_app_pvc" {
  depends_on = [
    kubernetes_namespace.namespace,  # Ensure the namespace is created before the PVC
    kubernetes_persistent_volume.library_app_pv  # Ensure the PV is created before the PVC
  ]

  metadata {
    name      = "${var.resource_prefix}-library-app-pvc"
    namespace = kubernetes_namespace.namespace.metadata[0].name  # Use the namespace created earlier
  }

  spec {
    access_modes = ["ReadWriteOnce"]  # The PVC can be mounted as read-write by a single node
    resources {
      requests = {
        storage = "5Gi"  # Request storage capacity of 5Gi for the PVC
      }
    }
    volume_name = kubernetes_persistent_volume.library_app_pv.metadata[0].name  # Bind the PVC to the specific PV
  }
}

# Create a Deployment for the library application
resource "kubernetes_deployment" "library_app" {
  depends_on = [
    kubernetes_namespace.namespace  # Ensure the namespace is created before the Deployment
  ]

  metadata {
    name      = "${var.resource_prefix}-library-app-deployment"
    namespace = kubernetes_namespace.namespace.metadata[0].name  # Use the namespace created earlier
  }

  spec {
    replicas = 3  # Define the number of replicas (pods) for the application

    selector {
      match_labels = {
        app = "${var.resource_prefix}-library-app"  # Label to identify the pods managed by this deployment
      }
    }

    template {
      metadata {
        labels = {
          app = "${var.resource_prefix}-library-app"  # Label for the pod template
        }
      }

      spec {
        container {
          name  = "${var.resource_prefix}-library-app"  # Name of the container
          image = var.docker_image  # Docker image to use for the container
          port {
            container_port = 5000  # Port that the container listens on
          }

          volume_mount {
            name       = "${var.resource_prefix}-library-db-storage"  # Name of the volume to mount
            mount_path = "/app/data"  # Path inside the container where the volume is mounted
          }
        }

        volume {
          name = "${var.resource_prefix}-library-db-storage"  # Name of the volume

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.library_app_pvc.metadata[0].name  # Bind the volume to the PVC
          }
        }
      }
    }
  }
}

# Create a Kubernetes Service to expose the library application
resource "kubernetes_service" "library_app_service" {
  depends_on = [
    kubernetes_namespace.namespace  # Ensure the namespace is created before the Service
  ]

  metadata {
    name      = "${var.resource_prefix}-library-app-service"
    namespace = kubernetes_namespace.namespace.metadata[0].name  # Use the namespace created earlier
  }

  spec {
    type = "LoadBalancer"  # Type of service, creates an external load balancer
    port {
      port        = 5000  # Port that the service will expose
      target_port = 5000  # Port on the container to which the traffic will be directed
    }

    selector = {
      app = "${var.resource_prefix}-library-app"  # Select the pods matching this label to forward traffic to
    }
  }
}
