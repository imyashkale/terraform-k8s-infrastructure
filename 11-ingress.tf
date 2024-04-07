# Kubernetes Service Manifest (Type: Load Balancer)
resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = "argocd"
    namespace = "argocd"
    annotations = {
      "alb.ingress.kubernetes.io/load-balancer-name"           = "${local.name}"
      "alb.ingress.kubernetes.io/scheme"                       = "internet-facing"
      "alb.ingress.kubernetes.io/healthcheck-protocol"         = "HTTP"
      "alb.ingress.kubernetes.io/healthcheck-port"             = "traffic-port"
      "alb.ingress.kubernetes.io/healthcheck-path"             = "/"
      "alb.ingress.kubernetes.io/healthcheck-interval-seconds" = 15
      "alb.ingress.kubernetes.io/healthcheck-timeout-seconds"  = 5
      "alb.ingress.kubernetes.io/success-codes"                = 200
      "alb.ingress.kubernetes.io/healthy-threshold-count"      = 2
      "alb.ingress.kubernetes.io/unhealthy-threshold-count"    = 2

      // SSL
      "alb.ingress.kubernetes.io/listen-ports"    = jsonencode([{ "HTTPS" = 443 }, { "HTTP" = 80 }])
      "alb.ingress.kubernetes.io/certificate-arn" = "${aws_acm_certificate.acm_cert.arn}"
      "alb.ingress.kubernetes.io/ssl-redirect"    = 443

      // External DNS
      "external-dns.alpha.kubernetes.io/hostname" : "argocd.imyashkale.com"

      # Ingress Groups
      "alb.ingress.kubernetes.io/group.name"  = "ultra"
      "alb.ingress.kubernetes.io/group.order" = 20
    }
  }

  spec {
    ingress_class_name = "aws-ingress-class"
    rule {
      host = "argocd.imyashkale.com"
      http {
        path {
          backend {
            service {
              name = "argocd-server"
              port {
                number = 80
              }
            }
          }
          path      = "/"
          path_type = "Prefix"
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "web_service_ingress" {
  metadata {
    name      = "web-service-ingress"
    namespace = "apps"
    annotations = {
      "alb.ingress.kubernetes.io/load-balancer-name"           = "${local.name}"
      "alb.ingress.kubernetes.io/scheme"                       = "internet-facing"
      "alb.ingress.kubernetes.io/healthcheck-protocol"         = "HTTP"
      "alb.ingress.kubernetes.io/healthcheck-port"             = "traffic-port"
      "alb.ingress.kubernetes.io/healthcheck-path"             = "/"
      "alb.ingress.kubernetes.io/healthcheck-interval-seconds" = 15
      "alb.ingress.kubernetes.io/healthcheck-timeout-seconds"  = 5
      "alb.ingress.kubernetes.io/success-codes"                = 200
      "alb.ingress.kubernetes.io/healthy-threshold-count"      = 2
      "alb.ingress.kubernetes.io/unhealthy-threshold-count"    = 2

      // SSL
      "alb.ingress.kubernetes.io/listen-ports"    = jsonencode([{ "HTTPS" = 443 }, { "HTTP" = 80 }])
      "alb.ingress.kubernetes.io/certificate-arn" = "${aws_acm_certificate.acm_cert.arn}"
      "alb.ingress.kubernetes.io/ssl-redirect"    = 443

      // External DNS
      "external-dns.alpha.kubernetes.io/hostname" : "apps.imyashkale.com"

      # Ingress Groups
      "alb.ingress.kubernetes.io/group.name"  = "ultra"
      "alb.ingress.kubernetes.io/group.order" = 20
    }
  }

  spec {
    ingress_class_name = "aws-ingress-class"
    rule {
      host = "apps.imyashkale.com"
      http {
        path {
          backend {
            service {
              name = "web-service"
              port {
                number = 80
              }
            }
          }
          path      = "/"
          path_type = "Prefix"
        }
      }
    }
  }
}



