resource "kubernetes_namespace" "self_heal_system" {
  metadata {
    name = "self-heal-system"
    labels = {
      "name"                                       = "self-heal-system"
      "pod-security.kubernetes.io/enforce"         = "restricted"
      "pod-security.kubernetes.io/enforce-version" = "latest"
    }
  }
}

resource "kubernetes_namespace" "tenant_payment" {
  metadata {
    name = "tenant-payment"
    labels = {
      "name"      = "tenant-payment"
      "tenant_id" = "d3b07384-d113-495f-9f58-20d18d357d75"
    }
  }
}

resource "kubernetes_namespace" "tenant_checkout" {
  metadata {
    name = "tenant-checkout"
    labels = {
      "name"      = "tenant-checkout"
      "tenant_id" = "6c8b4b2b-4d45-4209-a1b4-4b532d56a31c"
    }
  }
}

resource "kubernetes_namespace" "observability" {
  metadata {
    name = "observability"
    labels = {
      "name"                               = "observability"
      "pod-security.kubernetes.io/enforce" = "privileged" # Prometheus node-exporter needs host access
    }
  }
}
