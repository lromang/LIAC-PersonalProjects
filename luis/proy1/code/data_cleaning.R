# Script que contiene las funciones utilizadas en el análisis de datos.
# Luis Manuel Román García


# Librerías utilizadas
library(ggplot2)
library(dplyr)
library(igraph)
library(ggmap)
library(data.table)
library(tm)
library(rmarkdown)
library(stringr)

# Escritorio de trabajo
setwd("/home/lgarcia/LIAC/projects/luis/proy1")

# Variables globales de formato.
color1 <- "#00BFA5"
color2 <- "#004D40"
color3 <- "#006064"
color4 <- "#01579B"
color5 <- "#9E9E9E"
theme <-       theme(panel.background = element_blank(),
                 axis.text.x = element_text(size = 10,
                                                         angle = 90,
                                                         face = "bold",
                                                         color = color2),
                 axis.text.y = element_text(size = 10,
                                                         face = "bold",
                                                         color = color2),
                 axis.title = element_blank(),
                 legend.title = element_text(size = 10,
                                                         face = "bold",
                                                         color = color2),
                legend.text = element_text(size = 7,
                                                         face = "bold",
                                                         color = color2),
                strip.text = element_text(size = 10,
                                                         face = "bold",
                                                         color = color2))

# Lectura de datos, para historia  utilizamos fread
# del paquete data.table para mayor velocidad.
estaciones   <- read.csv("./data/ecobici_estaciones.csv", stringsAsFactors = FALSE)
usuarios      <- read.csv("./data/ecobici_usuarios.csv", stringsAsFactors = FALSE)
distancias         <- read.csv("./data/ecobici_distancias.csv", stringsAsFactors = FALSE)
#historia       <- fread("./data/ecobici_historia.csv", stringsAsFactors = FALSE)

# Procesamiento de datos
#elección de columnas de interés.
estaciones <- subset(estaciones, select =
                                                 c("id",
                                                    "colonia",
                                                    "delegacion",
                                                    "longitud",
                                                    "latitud",
                                                    "nombre") )
estaciones$delegacion <- str_trim(estaciones$delegacion)
estaciones$delegacion <- tolower(estaciones$delegacion)
estaciones$delegacion <- str_replace_all(estaciones$delegacion, " ", "_")

#Si corremos el siguiente comando nos
# damos cuenta que hay 107 delegaciones.
# esto se debe a q hay registradas delegaciones que
# no existen y hay diferencias en el número de espacios
# por ejemplo "Benito Juárez" "Benito Juárez "
length(unique(usuarios$delegacion))
# por esto es necesario hacer un poco de preprocesamiento
# en los nombres.
delegaciones <- c("Álvaro Obregón",
"Azcapotzalco",
"Benito Juárez",
"Coyoacán",
"Cuajimalpa de Morelos",
"Cuauhtémoc",
"Gustavo A. Madero",
"Iztacalco",
"Iztapalapa",
"La Magdalena Contreras",
"Miguel Hidalgo",
"Milpa Alta",
"Tláhuac",
"Tlalpan",
"Venustiano Carranza",
"Xochimilco")
delegaciones <- tolower(delegaciones)
delegaciones <- str_replace_all(delegaciones, " ", "_")

names(usuarios) <- tolower(names(usuarios))
usuarios$delegacion <- str_trim(usuarios$delegacion)
usuarios$delegacion <- tolower(usuarios$delegacion)
usuarios$delegacion <- str_replace_all(usuarios$delegacion, " ", "_")
usuarios <- subset(usuarios, select =
                                          c("usuario",
                                             "sexo",
                                             "colonia",
                                             "delegacion",
                                             "estado",
                                             "medio.de.inscripcion",
                                             "fecha.de.inscripcion",
                                             "usos",
                                             "status"),
                                          estado == "D.F." &
                                          delegacion %in% delegaciones)
# transformamos caracteres en fechas.
usuarios$fecha.de.inscripcion <- as.Date(usuarios$fecha.de.inscripcion)
# Reduciremos el análisis dentro del DF. y a delegaciones válidas
# De esta forma tenemos todos los usuarios dentro de las delegaciones de interés.
# Declaramos las claves de cada base de datos para agilizar los cálculos
#setkey(historia, cust_id, station_removed, station_arrived)

# Hagamos algo de estadística descriptiva
# Usuarios.
# Dado el sesgo de la distribución, aplicamos una
# transformación
usu_usu <- ggplot(data = usuarios,
                                aes(x = usuario,
                                       y = usos,
                                       color =sqrt(usos) )) +
                    geom_point(size = .7, alpha = .8) +
                    facet_wrap(~sexo) +
                    theme +
                    scale_colour_gradient(low = color2, high= color1)
png("./graphs/usu_usu.png", width = 600, height = 400)
usu_usu
dev.off()

# Histograma usuario delegación
usu_del <- ggplot(data=usuarios,
                             aes(x = delegacion,y = usos, fill = sexo)) +
                 geom_bar(stat = "identity",position = "dodge") +
                 facet_wrap(~status, scales = "free")+
                 theme +
                 scale_fill_manual(values = c(color3, color1))
png("./graphs/usu_del.png", width = 600, height = 400)
 usu_del
dev.off()

# Evolución a lo largo del tiempo
usu_time <- ggplot(data = usuarios,
                                 aes(x = fecha.de.inscripcion,
                                        y = usos,
                                        color = sexo)) +
                    geom_point(size = .5, alpha = .5) +
                    geom_smooth(aes(group=sexo),
                                             method="loess",
                                             size=.7,
                                             se = FALSE) +
                    facet_wrap(~delegacion, scales = "free") +
                    theme +
                    scale_colour_manual(values = c(color3, color1))
png("./graphs/usu_time.png", width = 600, height = 400)
usu_time
dev.off()


# pasar los datos de las estaciones
# a un formato que pueda ser aprovechado
# por google maps.
#citymap['chicago'] = {
#  center: new google.maps.LatLng(41.878113, -87.629798),
#  population: 2714856
#};
estacionesTxt <- c()
for(i in 1:nrow(estaciones)){
    estacionesTxt[i] <-
    paste("citymap['",
     i ,
     "']={center:new google.maps.LatLng(",
    estaciones[i,5],",",estaciones[i,4],")};",
    sep = "")
}

fileConn <- file("./data/estacionesMaps.txt")
writeLines(estacionesTxt,fileConn)
close(fileConn)




