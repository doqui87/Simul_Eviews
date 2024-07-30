'=======================================
' Introducción a la econometría
' 	Un enfoque basado en simulación
'	Guido Ianni
'
' 	DISTRIBUCIONES BIVARIADAS
'=======================================

' Esta simulación se centra en modelos no lineales. En particular, se simula
'			log(y) = XB +u
'				 z  = a + b SIN(x) + u

' Se presentan los SCATTER para XY y XZ con una muestra chica
'			fit lin-log y poly(2) para XY
'			fit poly(1) poly(2) y poly(3) para XZ

' La ACTIVIDAD de esta simulacion es
'	Fijar el rango del eje LEFT de cada vista
'	Observar la varianza de y|x a medida que se core la ventana del sample
'	Observar la varianza de cada estimación no-lineal 
'	Agregar poly-fit de grados mayores y ver si ajusta mejor o no a los datos
'	Confirmar estimando estos modelos



'++ Seteo PARAMETROS
!n = 200
!window = 20


'++ Creo WorkFile
wfclose(noerr)
wfcreate test u 1 !n
delete *

rndseed  42

'++ Creo WorkFile
series x=rnd 'simular x
series log(y)=2+3*x+nrnd/2 'simular y
series z=2+3*sin(x/@pi)+nrnd/2 'simular z


group xy x y 'crear griupo
group xz x z

'Vistas de XY
xy.scat linefit(yl) linefit(xd=2) 'Agregar fit lin-log y poly(2)


'Vistas de XZ
xz.scat linefit(xd=1) linefit(xd=2) linefit(xd=3)

'++ Fijo VENTANA
smpl @first @first+!window-1

