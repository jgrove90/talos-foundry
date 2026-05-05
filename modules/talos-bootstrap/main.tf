terraform {
  required_providers {
    talos = {
      source = "siderolabs/talos"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}

locals {
  control_plane_nodes = sort(var.control_plane_nodes)
  bootstrap_node      = local.control_plane_nodes[0]
  cluster_endpoint    = var.cluster_endpoint != "" ? var.cluster_endpoint : "https://${local.bootstrap_node}:6443"
}

resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  machine_type     = "controlplane"
  cluster_endpoint = local.cluster_endpoint
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  talos_version    = var.talos_version
  config_patches   = var.controlplane_config_patches
}

resource "talos_machine_configuration_apply" "controlplane" {
  count = length(local.control_plane_nodes)

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = local.control_plane_nodes[count.index]
  endpoint                    = local.control_plane_nodes[count.index]
  apply_mode                  = var.apply_mode
}

resource "talos_machine_bootstrap" "this" {
  node                 = local.bootstrap_node
  endpoint             = local.bootstrap_node
  client_configuration = talos_machine_secrets.this.client_configuration

  depends_on = [talos_machine_configuration_apply.controlplane]
}

resource "talos_cluster_kubeconfig" "this" {
  node                 = local.bootstrap_node
  endpoint             = local.bootstrap_node
  client_configuration = talos_machine_secrets.this.client_configuration

  depends_on = [talos_machine_bootstrap.this]
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = local.control_plane_nodes
  endpoints            = [local.bootstrap_node]
}

resource "local_sensitive_file" "talosconfig" {
  content         = data.talos_client_configuration.this.talos_config
  filename        = "${var.config_output_dir}/talosconfig"
  file_permission = "0600"
}

resource "local_sensitive_file" "kubeconfig" {
  content         = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename        = "${var.config_output_dir}/kubeconfig"
  file_permission = "0600"
}