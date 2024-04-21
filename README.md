# explicacion
### app.py
usa socket para conseguir la ip del host y con boto3 lista todo los archivos luego con una expresion checa
la terminacion de cada archivo y hace un sum de los que hagan match ( .mp3, .mp4, jpg), para que funcione
con los 3 casos se pasa el typefile como variable de ambiente y tambien el bucket. 
### Dockerfile
solo se utiliza una imagen de python y con pip se instalan las dependencias
### Terraform 
para hacer los templates mas dinamicos y versatiles utilice variables map, modulos, ciclos y condiciones. 
#### flujo terraform
se crean 2 buckets ivan-task donde se guardaran las imagenes/videos/audios y ci-ivan-task el cual utilizara
codepipeline para buildear la imagen y deployarla

tambien se crea app.zip y se sube al bucket para que posteriormente codebuild lo utilize. 
y se crean los modulos en el caso de roles y ecs se usa count ya que para esto utilizaremos 3 roles: role para ci, role para la task (bajar imagen de ecr) y role para el container, sobre ecs se usa el count para crear
el task definition y el service de los 3 contenedores que se necesitan.
##### modules
###### vpc
se crean 2 subnets privadas y 2 publicas para tener alta disponibilidad, se crea un internet gateway para las publicas y las privadas utilizan nat gatewaay con eip atados a la publica de la misma az y se configuran las tablas de cada grupo (publico y privado)
###### roles
para los roles el template es igual y la difernecia viene desde la variable roles la cual tiene una lista de los roles, service y permisos .


###### alb
el application load balancer tiene configurada 3 reglas para enviar el trafico a cada container, ya que no prepare una pagina home si el path no es especificado enviara a audio, 

###### ecs
se crea una task definition y se pone con una imagen sample de aws lo cual sera remplazado despues por codepipeline, utilice fargate para facilitar el trabajo y se configuro en la subnet privada, se pasa como variable de ambiente el tipo de archivo y el bucket que se usaran
###### ci
aqui se crea el ecr y desde el bucket de ci se baja el zip donde viene el codigo y el dockerfile, se buildea la imagen y se sube a ecr, despues es deployado a los 3 services. 
