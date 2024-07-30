'=======================================
' Introducción a la econometría
' 	Un enfoque basado en simulación
'	Guido Ianni
'
'	LLN y MONTECARLO EN UN MRLS
'=================================
'Montecarlo es un método estadístico de muestreo repetido.

'Esencialmente, 
'	1)		se definen las características de la población (modelo probabilístico)
'	2)		se obtiene una muestra de esa población
'	3) 		se calcula alguna cosa (generalmente, algún estadístico)
'	3)		se repite el proceso muchas veces
'	4)		se observan (o analizan) las propiedades sobre el muestreo repetido

'=======================================
'  En esta simulación 
'=======================================
' 1) Vamos a simular un modelo de regresión simple

'								y = !beta * x + e

' 2) Realizar simulaciones para tamaños de muestra desde 1 hasta !nmax 

' 3) Vamos a usar Simulación de Montecarlo para mostrar
'		Resultados La Ley de los Grandes Números (LLN) cuando 
'		       A) x,e~IID(0, sigma^2)
'		       B)  x,e~non-IID(0, sigma^2_i) {nosotros vamos a agregar persistencia}
 
'============
' La LLN predice
'============

'    que el promedio de la suma de cuadrados de X converge a !mux^2+!sigmax^2
'    que el promedio de la suma de XY converge a !beta*(!mux^2+!sigmax^x2)
'	que el promedio de los beta_hat converge a beta



'=======================================
'             Caso A | LLN para observaciones IID
'=======================================

' ++Seteo PARÁMETROS
!nmax = 1000

!beta=0.5
!mux=1
!sigx=2
!sigu=0.2

'		Coeficientes de persistencia
!rhox = 0.8
!rhou = 0.4


wfclose(noerr)
wfcreate(wf=WFile, page=simulations) u 1 !nmax
delete *


series x=!mux + !sigx*nrnd
series u=!sigu*nrnd 
series y=!beta*x + u



'Creamos una matriz para guardar los resultados
matrix (!nmax,3) results

' Recorremos un loop
for !n=1 to !nmax

	smpl 1 !n

	results(!n,1)=@sumsq(x) / !n
	results(!n,2)=@inner(x,y) / !n
	results(!n,3)=@inner(x,y) / @sumsq(x)

next


'Creamos una nueva página para guardar las simulaciones 
pagecreate(page=simresults) u 1 !nmax

'Inicializamos las series para guardar los resultados
series sxx 
series sxy 
series beta
group gr1 sxx sxy beta

' Nos traemos los resultados y escribimos las series
copy simulations\results results
mtos(results, Gr1)


smpl @first+10 @last
freeze(fig1) gr1.line
fig1.draw(line, left, linewidth(1.5)) !mux^2+!sigx^2
fig1.draw(line, left, linewidth(1.5)) !beta*(!mux^2+!sigx^2)
fig1.draw(line, left, linewidth(1.5)) !beta
fig1.addtext(t,just(c), font(Garamond, 12,b)) Figura 1: LLN y obs iid




'=======================================
'             Caso B | LLN para observaciones Non-IID
'=======================================
' En esencia, repetimos todo de nuevo

pageselect simulations

!deltax = !mux * (1-!rhox)
!sx = @sqrt(!sigx^2 * (1-!rhox^2))
!su = @sqrt(!sigu^2 * (1-!rhou^2))

smpl 2 @last

series x = !deltax + !rhox * x(-1) + !sx*nrnd
series u =              !rhou * u(-1) + !su*nrnd


smpl @all
series y=!beta*x + u



' Recorremos el mismo loop de nuevo
for !n=1 to !nmax

	smpl 1 !n

	results(!n,1)=@sumsq(x) / !n
	results(!n,2)=@inner(x,y) / !n
	results(!n,3)=@inner(x,y) / @sumsq(x)

next




'=======================================
'		Volcar las simulaciones en una nueva página
'=======================================
pageselect simresults
smpl @all
copy simulations\results results_non_iid

mtos(results_non_iid, Gr1)

' ++++ Plotear
smpl @first+10 @last
delete(noerr) fig2
freeze(fig2) gr1.line
fig2.draw(line, left, linewidth(1.5)) !mux^2+!sigx^2
fig2.draw(line, left, linewidth(1.5)) !beta*(!mux^2+!sigx^2)
fig2.draw(line, left, linewidth(1.5)) !beta
fig2.addtext(t,just(c), font(Garamond, 12,b)) Figura 2: LLN y obs non-iid


