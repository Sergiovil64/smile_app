# SMILE APP

## Descripción 
SMILE APP es una aplicación móvil enfocada en el autocuidado y el bienestar emocional de adolescentes en Bolivia. Permite registrarse e iniciar sesión de forma segura, registrar estados emocionales (texto/audio + indicador de ánimo), consultar el historial y visualizar tendencias de progreso. Además, ofrece actividades de autocuidado guiadas y contenido educativo (audio, texto y video), incluyendo búsqueda y visualización de detalle. Un perfil de usuario editable centraliza la información personal de forma opcional (incluida foto de perfil). Para administración, se contempla la gestión de usuarios y la publicación de contenido educativo.

## Objetivo general
Desarrollar una Aplicación móvil Full Stack para promover el autocuidado y el bienestar emocional en adolescentes en Bolivia, mediante registro y seguimiento del estado emocional, historial de progreso y actividades guiadas de autocuidado.

## Objetivos específicos
  - Diseñar la arquitectura de la app móvil con Clean Architecture (presentación, dominio y datos) y documentarla (incluyendo diagrama C4) antes de la conclusión del proyecto.
  - Implementar en Flutter los módulos base: autenticación, registro emocional y ejecución de al menos 2 actividades de autocuidado, disponibles antes de la conclusión del proyecto.
  - Configurar Supabase + PostgreSQL con mínimo 5 tablas principales, RLS (Row Level Security) y políticas de acceso listas antes de la implementación final del frontend.
  - Aplicar principios OWASP relevantes: autenticación segura, control de acceso por roles, y validaciones de entrada/salida en los flujos críticos antes del cierre del proyecto. 

## Alcance (qué incluye / qué NO incluye) 
Incluye:
- Registro, inicio de sesión, recuperación de contraseña, sesión activa y cierre de sesión
- Identificación de rol Usuario / Administrador al iniciar sesión
- Perfil: ver y editar nombres, apellidos, fecha de nacimiento y foto
- Pantalla principal por rol
- Persistencia segura en PostgreSQL (Supabase) con RLS
- Base de código frontend organizada con Clean Architecture
- Gestión de usuarios (CRUD) por administrador
- Carga y gestión de contenido educativo por administrador (audio/texto/video)
- Registro emocional con texto/audio e indicador de estado de ánimo
- Visualización de progreso: resúmenes y tendencias
- Lista de actividades de autocuidado
- Lista de contenido educativo con buscador, detalle y visualización por tipo

No incluye (por ahora):
- Chat en tiempo real o soporte con profesionales
- Integración con Inteligencia Artificial.
- Roles avanzados.

## Stack tecnológico
- Frontend (Mobile): Flutter (Dart)
- Backend (BaaS): Supabase (Auth + PostgREST + Storage)
- Base de datos: PostgreSQL (Supabase) con RLS
- Almacenamiento de archivos: Supabase Storage (audios, videos, imágenes de perfil)
- Control de versiones: Git + GitHub

## Arquitectura (resumen simple) 
***Flutter (Cliente móvil)*** → ***Supabase (Auth / REST / Storage)*** → ***PostgreSQL (con RLS y políticas)***

- La app Flutter consume:
  - Auth para registro/login/recuperación de contraseña y sesión.
  - PostgREST (REST automático sobre PostgreSQL) para CRUD de entidades (emociones, actividades, contenidos, perfiles).
  - Storage para archivos (audio/video/fotos).

- RLS restringe el acceso por usuario/rol directamente desde la base de datos (seguridad “desde el dato”).

## Operaciones core
> Nota: Supabase SDK provee acceso directo a operaciones en Base de Datos desde Flutter.

***Auth***

`signUp`, `signInWithPassword`, `resetPasswordForEmail`, `signOut`

***Registros emocionales***

`from('emotion_logs').insert(...)`

`from('emotion_logs').select(...).order(...)`

***Contenido educativo***

`from('educational_contents').select(...).ilike(...)`

***Actividades***

`from('selfcare_activities').select(...)`

`from('activity_sessions').insert(...)`

***Perfil***

`from('profiles').select(...)`

`from('profiles').update(...)`

***Storage***

`storage.from('bucket').upload(...)`

`storage.from('bucket').createSignedUrl(...)`

## Cómo ejecutar el proyecto (local)`
 
1. Clonar repositorio 


       git clone https://github.com/Sergiovil64/smile_app.git 
 
2. Instalar dependencias 

        flutter pub get 
 
3. Configurar variables de entorno 

        Crear archivo .env 
 
4. Ejecutar servidor 

        flutter run

***Requisitos previos***
- Flutter SDK instalado y configurado (flutter doctor).
- Un proyecto en Supabase con:
  - Auth habilitado (Email/Password)
  - Tablas principales creadas (mín. 5)
  - Políticas RLS definidas para cada tabla
  - Buckets en Storage para audios/videos/fotos
 
## Variables de entorno (ejemplo) 

    SUPABASE_URL=https://mysupabasereference.supabase.co
    SUPABASE_ANON_KEY=my.supabase.anon.key
 
## Equipo y roles
  - Sergio Villafan: Backend (Supabase)
  - Sergio Villafan: Frontend
  - Sergio Villafan: DevOps / QA 