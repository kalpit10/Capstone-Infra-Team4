resource "null_resource" "test" {
  triggers = {
    created_by = "capstone-team"
    test_run   = "gha"
  }
}
