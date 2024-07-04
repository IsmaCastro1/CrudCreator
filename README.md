## Pasos para añadir herramienta a las variables de entorno

### 1. Ubicar el Script de PowerShell

Asegúrate de guardar el script en un directorio que no vayas a borrar por casualidad.

### 2. Abrir Configuración de Variables de Entorno

1. Presiona la tecla `Win` y busca `Editar las variables de entorno del sistema`.
2. Abajo a la derecha pulsa el boton **Variables de entorno** 

### 3. Editar la Variable de Entorno PATH

1. En la sección **Variables del sistema**, busca la variable llamada `Path` y selecciónala.
2. Haz clic en **Editar...**.

### 4. Añadir la Ruta del Script

1. En la ventana de edición de variables de entorno, haz clic en **Nuevo**.
2. Introduce la ruta de la carpeta donde se encuentra tu script de PowerShell.
3. Haz clic en **Aceptar** para cerrar todas las ventanas abiertas y aplicar los cambios.

### 5. Uso

1. Abre una nueva ventana de PowerShell dentro del directorio del proyecto.
2. Escribe `Creator.ps1` en la y presiona `Enter`.


## Notas Adicionales

- Asegúrate de que el script tiene los permisos adecuados para ejecutarse.
- Si encuentras problemas de ejecución, verifica la política de ejecución de PowerShell con el comando `Get-ExecutionPolicy` y ajusta según sea necesario usando `Set-ExecutionPolicy Unrestricted`.


