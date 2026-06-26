provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.aws_foundation.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.aws_foundation.outputs.cluster_ca_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.aws_foundation.outputs.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.aws_foundation.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.aws_foundation.outputs.cluster_ca_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.aws_foundation.outputs.cluster_name]
    }
  }
}

provider "kubectl" {
  host                   = data.terraform_remote_state.aws_foundation.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.aws_foundation.outputs.cluster_ca_data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.aws_foundation.outputs.cluster_name]
  }
}
