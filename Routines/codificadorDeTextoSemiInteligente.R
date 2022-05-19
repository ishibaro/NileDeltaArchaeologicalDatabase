#Convertidor automatico de datos sin estructura a códigos predefinidos (datos estructurados)
#Israel Hinojosa Baliño
#19 abril 2022
#data dictionary in R
#based on https://stackoverflow.com/questions/48992792/word-matching-with-dictionaries-using-r-analyzing-survey-comments-with-existing
#the following produces a TRUE and FALSE table depending on a dictionary
#each dictionary might correspond to a CODE (e.g temporality=LBA)
#based on the dictionary, we can then create the matrix and do all matching

# replace FALSE values into NA values
# https://cran.r-project.org/web/packages/naniar/vignettes/replace-with-na.html
install.packages("naniar")
library(naniar)

#ejemplo de lista
EESdesc <- c("Surveyed by Amsterdam University survey 1984-5. Tell split in about 1980 into two by new fields (intact on 1960s CORONA images). Excavations by Amsterdam University since 1988, directed by Willem Van Haarlem have revealed Late Predynastic, Archaic and MK remains.",
                "GR tombs found here and a Ptolemaic statue recovered. Satellite images show the mound is in the centre of the town, and used as a cemetery.",
                "Modern name Tell Sahil. Amsterdam University survey 1984. Fired Roman bricks and late Roman sherds on the surface. Red granite column base seen 1984 in SW part. Clear of overbuilding, in cultivation.",
                "Amsterdam University survey 1984-5: Low mound with northern Predynastic to Naqada III levels. Also OK and MK (?) sherds. The 1914 map shows two mounds separated by a field, a configuration which still persists. Clear of modern structures in 2017. Excavations by French Institute began in 2015",
                "Site overbuilt by a village and orchards. Late Period to Byzantine remains. Just north of Tellein (EES no. 521).")

#eventualmente sería posible importar un archivo determinado, explorar la variable donde está el texto
# y posteriormente añadir a esta tabla la columna con las claves

#esta era una lista de palabras claves para categoria, pero he transformado las categorias en nombres de lista (ver abajo)
#MiddleKingdom <- c("MK", "Medio Reino", "M Kingdom")
#Roman <- c("Roman", "Roman period")
#Greek <- c("Ptolemaic", "Greek", "Hellenic")
#LateRoman <- c("Late Roman", "Byzantine")

# estas son las palabras claves de cada categoria
# he transformado las categorias en nombres de lista. Los nombres de lista serán serán usados como identificadores únicos
# aqui se construye la lista que constituirá el diccionario, la primera parte es la clave y la segunda parte es la lista de palabras clave
# que pueden identificar la categoría en un texto sin estructura. Nótese que:
# 
# he separado estas dos listas para facilidad de uso pero pueden hacerse en una sola rutina

lista <- list(
              "AE.MK" = c("MK", "Medio Reino", "M Kingdom"),
              "GR.RO" = c("Roman", "Roman period"),
              "GR.HE" = c("Ptolemaic", "Greek", "Hellenic"),
              "BE.PP" = c("Late Roman", "Byzantine"),
              "AE.OK" = c("OK", "Old Kingdom", "Reino Antiguo") 
              )

#ahora se genera la función que busca en cada fila elementos de cada categoría
# la palabra diccionario en este caso es una variable "dummy" para lapply
# grepl es la función que busca los valores
# lapply es la funcion que permite a grepl buscar el primer valor, y luego los subsecuentes en cada categoria
# ver https://stackoverflow.com/a/48993098/3543454

buscar = function(diccionario,EESdesc){
  apply(do.call(rbind,lapply(diccionario,grepl,EESdesc,ignore.case=T)),2,any)
}

res = lapply(lista,buscar,EESdesc)

df <- cbind(as.data.frame(res), EESdesc)

# Finalmente cambiamos los valores TRUE al valor de su columna
# este codigo sirve pero las columnas no aceptan espacios, por ahora es lo que me ha funcionado
# quiza aqui sirva el tidyverse o mas bien necesite modificar
# la llamada a los codigos 
# https://stackoverflow.com/questions/34717909/how-would-i-change-true-values-in-a-cell-to-the-name-of-a-column-header-r-progr

df[df==TRUE] <- colnames(df)[which(df==TRUE, arr.ind=TRUE)[,'col']]

#se utiliza el paquete naniar para sustituir FALSE por NA
na_strings <- c("FALSE")
df.na <- df %>%
  replace_with_na_all(condition = ~.x %in% na_strings)

# Finalmente se concatenan los valores por caso
# Nótese que se usa first and last, con names, para que automáticamente se seleccionen únicamente las columnas con claves
df.na %>%
    unite('Categorias',first(names(lista)):last(names(lista)), sep = ", ", remove = TRUE, na.rm = TRUE)

#el resultado final es un lista con arrays pero tendria que ser cambiada a otro formato para que luego se pudiera modificar
# con pivot_longer o gather....pero despues de haber transformado el array a una lista dentro del campo,

#de hecho se puede usar pivot longer si añado directamente un ID a cada elemento de la lista

# o sea, asignar una fila a cada elemento
# a este codigo hay que agregar meter un archivo, de ese archivo tomar solo la descripcion
# luego procesarla y exportarla...los codigos eventualmente estarian ligados a las termporalidades para efectos analiticos
