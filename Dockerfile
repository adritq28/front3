# Usa una imagen base de nginx para servir archivos estáticos
FROM nginx:alpine

# Copia los archivos construidos de la aplicación Flutter al directorio de trabajo de nginx
COPY build/web /usr/share/nginx/html

# Exponer el puerto 80 para el tráfico HTTP
EXPOSE 80

# Comando para iniciar Nginx
CMD ["nginx", "-g", "daemon off;"]
