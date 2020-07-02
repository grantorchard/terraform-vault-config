resource vault_policy "admin" {
  name = "admin"
  policy = file("./files/admin.hcl")
}