'=======================================
' Introducción a la econometría
' 	Un enfoque basado en simulación
'	Guido Ianni
'
' 	DISTRIBUCIONES BIVARIADAS
'=======================================

' Este programa simula una variable aleatoria y~N(mu, sigma^2)
'	la particularidad es que mu=f(D) donde D es una variable categótica



'++ Seteo PARAMETROS
!n=300

!mu1 = 1
!mu2 = 2
 !sigma = 1/4

'++ Creo WorkFile
wfclose(noerr)
wfcreate(wf=Multivariate, page=Multi) u 1 !n
delete *


'==================
'   SIMULAR
'==================
series cat = (nrnd>0.3)
series y = !mu1 + (!mu2-!mu1)*cat + nrnd*!sigma


'===========
'   FIGURAS
'===========
freeze(zfig1a) y.distplot hist() kernel() 
freeze(zfig1b) y.boxplot within(CAT)

graph fig1.merge zfig1a zfig1b
fig1.addtext(t,just(c), font(Garamond, 18,b))  "Histograma de una VA con mu=f(cat) y Boxplot por categoria"
fig1.align(2,1,1)
show fig1


'=============
'   ACTIVIDADES
'=============

' 1. Crear series y1 e y2 separando a y por categoria
' 2. Hacer un test de igualdad de medias

' 3. Extender el codigo para que hayan 3 o mas categorias y hacer el test de igualdad de todos los grupos

