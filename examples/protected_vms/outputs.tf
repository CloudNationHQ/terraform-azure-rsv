output "instance" {
  sensitive = true
  value = {
    for k, module_instance in module.vm : k => module_instance.instance
  }
}
