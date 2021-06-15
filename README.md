# OrgComp
Este es un proyecto realizado para la materia Organización del Computador 2021 de la Facultad de Matemática, Astronomía, Física y Computación.
El proyecto consiste en utilizar assembler ARMv8 para generar una imagen estática usando QEMU para emular el framebuffer de una Raspberry Pi 3, 
y luego agregar una animación de al menos 10 segundos.

# Cómo correrlo
Para poder ejecutar el proyecto es necesario tener instalado QEMU y una versión específica de GDB.
## Instalación
Correr los siguientes comandos en orden:

Tener actualizados los repositorios
```
$ sudo apt update
```
Setting up aarch64 toolchain
```
$ sudo apt install gcc-aarch64-linux-gnu
```
Setting up QEMU ARM (incluye aarch64)
```
$ sudo apt install qemu-system-arm
```
Fetch and build aarch64 GDB
```
$ sudo apt install gdb-multiarch
```
Configurar GDB para que haga las cosas más amigables
```
$ wget -P ~ git.io/.gdbinit
```
Este último comando crea un archivo llamado .gdbinit en el directorio personal que configura GDB para funcionar como un Dashboard
Si se quiere volver a la versión normal, es necesario eliminarlo del directorio, teniendo en cuenta que es un archivo oculto.

## Ejecución
Abrir una terminal en la carpeta del ejercicio que se quiera ver y ejecutar el comando:
```
$ make run
```
