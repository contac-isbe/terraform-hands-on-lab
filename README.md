# Terraform Hands-on Lab

Proyecto simple con Terraform y Docker para ejecutar frontend Nginx, backend Node.js y PostgreSQL en los ambientes DEV y QA, con redes separadas.

## Requisitos

- Terraform 1.16.5 disponible en el PATH.
- Docker Desktop para Windows, iniciado y con el motor de contenedores Linux funcionando. La conexión de Terraform está configurada para ese motor.
- Git para clonar el repositorio y conexión a Internet para descargar el provider, las imágenes y las dependencias.

## Clonar y configurar

```bash
git clone https://github.com/contac-isbe/terraform-hands-on-lab.git
cd terraform-hands-on-lab
```

Crea un archivo `terraform.tfvars` en la raíz del proyecto. Está ignorado por Git y no se incluye al clonar:

```ini
postgres_password    = "una_contraseña"
qa_postgres_password = "otra_contraseña"
```

Las contraseñas son ejemplos: reemplázalas por contraseñas propias y diferentes para DEV y QA. No subas este archivo al repositorio.

## Ejecutar

Desde la raíz del proyecto:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Confirma con `yes` cuando Terraform lo solicite. Terraform construye el backend; no necesitas instalar Node.js localmente.

## URLs y puertos

```text
DEV
Frontend:   http://localhost:4001
Backend:    http://localhost:4002
PostgreSQL: localhost:4003

QA
Frontend:   http://localhost:5001
Backend:    http://localhost:5002
PostgreSQL: localhost:5003
```

El frontend muestra una página de servicio activo. El backend responde en `/` con el resultado de una consulta a PostgreSQL. El usuario y la base de datos son `dev` para DEV y `qa` para QA; las contraseñas son las de `terraform.tfvars`.

Verifica los seis contenedores con:

```bash
docker ps
```

## Eliminar la infraestructura

```bash
terraform destroy
```

Confirma con `yes`. Esto elimina los recursos administrados por Terraform, incluidos los datos locales de PostgreSQL.
