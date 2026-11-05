FROM nginx:1.27-alpine

COPY dist/student-app/browser/ /usr/share/nginx/html/

EXPOSE 80
