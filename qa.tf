variable "qa_postgres_password" {
  description = "Contraseña local de PostgreSQL para QA."
  type        = string
  sensitive   = true
}

resource "docker_network" "qa" {
  name = "qa-network"
}

# Reutiliza las imágenes oficiales de DEV con las mismas versiones.
resource "docker_container" "web_qa" {
  name  = "web-qa"
  image = docker_image.web_dev.image_id

  ports {
    internal = 80
    external = 5001
    ip       = "127.0.0.1"
  }

  networks_advanced {
    name = docker_network.qa.name
  }
}

resource "docker_container" "api_qa" {
  name  = "api-qa"
  image = docker_image.api_dev.image_id

  # Mantiene Node.js activo hasta incorporar el backend.
  command = ["node", "-e", "setInterval(() => {}, 2147483647)"]

  ports {
    internal = 3000
    external = 5002
    ip       = "127.0.0.1"
  }

  networks_advanced {
    name = docker_network.qa.name
  }
}

resource "docker_container" "bd_qa" {
  name  = "bd-qa"
  image = docker_image.bd_dev.image_id

  env = [
    "POSTGRES_USER=qa",
    "POSTGRES_DB=qa",
    "POSTGRES_PASSWORD=${var.qa_postgres_password}",
  ]

  ports {
    internal = 5432
    external = 5003
    ip       = "127.0.0.1"
  }

  networks_advanced {
    name = docker_network.qa.name
  }
}
