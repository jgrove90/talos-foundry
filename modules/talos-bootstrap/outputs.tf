output "bootstrap_node" {
  description = "Control plane node used for bootstrap and kubeconfig retrieval."
  value       = local.bootstrap_node
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint used in generated Talos machine configuration."
  value       = local.cluster_endpoint
}

output "talosconfig" {
  description = "Generated talosconfig content for cluster administration."
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
}

output "kubeconfig_raw" {
  description = "Generated kubeconfig content retrieved from the bootstrapped cluster."
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
}