# link-shortener-module

- Módulo encargado de generar links acortados a partir de URLs largas.
  Valida códigos existentes, genera códigos únicos y almacena la información en DynamoDB.
  Diseñado para funcionar como Lambda de AWS usando API Gateway y middy como middleware.

# Características principales

- Generación de códigos únicos para URLs.

- Validación contra DynamoDB para evitar colisiones.

- Creación de URLs cortas con un dominio base configurable.

- Middleware de validación de esquema.

- Manejo de errores mediante middy y httpErrorHandler.

- Arquitectura organizada (handlers, utils, schema, databases, middleware).

# Estructura del proyecto

app/
├── node_modules/
└── src/
├── databases/
├── handlers/
│ └── shorten-link.ts
├── middleware/
├── schema/
└── utils/
terraform/
.gitignore
package.json
tsconfig.json
