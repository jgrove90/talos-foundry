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

resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}

resource "talos_machine_configuration_apply" "controlplane_bootstrap" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = local.bootstrap_node
  endpoint                    = local.bootstrap_node
  apply_mode                  = var.apply_mode
}

resource "talos_machine_bootstrap" "this" {
  node                 = local.bootstrap_node
  endpoint             = local.bootstrap_node
  client_configuration = talos_machine_secrets.this.client_configuration

  depends_on = [talos_machine_configuration_apply.controlplane_bootstrap]
}

resource "talos_machine_configuration_apply" "controlplane_followers" {
  count = max(length(local.control_plane_nodes) - 1, 0)

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = local.control_plane_nodes[count.index + 1]
  endpoint                    = local.control_plane_nodes[count.index + 1]
  apply_mode                  = var.apply_mode

  depends_on = [talos_machine_bootstrap.this]
}

resource "talos_cluster_kubeconfig" "this" {
  node                 = local.bootstrap_node
  endpoint             = local.bootstrap_node
  client_configuration = talos_machine_secrets.this.client_configuration

  depends_on = [talos_machine_configuration_apply.controlplane_followers]
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