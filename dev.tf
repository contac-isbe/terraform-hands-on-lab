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
  name = "terraform-lab-backend:1.0.0"

  build {
    context = abspath("${path.module}/backend")
  }

  triggers = {
    source     = filesha256("${path.module}/backend/index.js")
    package    = filesha256("${path.module}/backend/package.json")
    lock       = filesha256("${path.module}/backend/package-lock.json")
    dockerfile = filesha256("${path.module}/backend/Dockerfile")
  }
}

resource "docker_image" "bd_dev" {
  name = "postgres:18.6-alpine"
}

resource "docker_container" "web_dev" {
  name  = "web-dev"
  image = docker_image.web_dev.image_id

  volumes {
    host_path      = abspath("${path.module}/frontend")
    container_path = "/usr/share/nginx/html"
    read_only      = true
  }

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

  env = [
    "APP_ENV=DEV",
    "PGHOST=bd-dev",
    "PGPORT=5432",
    "PGUSER=dev",
    "PGDATABASE=dev",
    "PGPASSWORD=${var.postgres_password}",
  ]

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
