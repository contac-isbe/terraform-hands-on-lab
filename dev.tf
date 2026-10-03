variable "postgres_password" {
  description = "Contraseña local de PostgreSQL para DEV."
  type        = string
  sensitive   = true
}

resource "docker_network" "dev" {
  name = "dev-network"
}

resource "docker_image" "web_dev" {
  name = "nginx:1.30.5-alpine"
}

resource "docker_image" "api_dev" {
  name = "node:24.21.0-alpine"
}

resource "docker_image" "bd_dev" {
  name = "postgres:18.6-alpine"
}

resource "docker_container" "web_dev" {
  name  = "web-dev"
  image = docker_image.web_dev.image_id

  ports {
    internal = 80
    external = 4001
    ip       = "127.0.0.1"
  }

  networks_advanced {
    name = docker_network.dev.name
  }
}

resource "docker_container" "api_dev" {
  name  = "api-dev"
  image = docker_image.api_dev.image_id

  # Mantiene Node.js activo hasta incorporar el backend.
  command = ["node", "-e", "setInterval(() => {}, 2147483647)"]

  ports {
    internal = 3000
    external = 4002
    ip       = "127.0.0.1"
  }

  networks_advanced {
    name = docker_network.dev.name
  }
}

resource "docker_container" "bd_dev" {
  name  = "bd-dev"
  image = docker_image.bd_dev.image_id

  env = [
    "POSTGRES_USER=dev",
    "POSTGRES_DB=dev",
    "POSTGRES_PASSWORD=${var.postgres_password}",
  ]

  ports {
    internal = 5432
    external = 4003
    ip       = "127.0.0.1"
  }

  networks_advanced {
    name = docker_network.dev.name
  }
}
