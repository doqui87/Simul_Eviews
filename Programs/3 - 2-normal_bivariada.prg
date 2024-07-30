'=======================================
' Introducción a la econometría
' 	Un enfoque basado en simulación
'	Guido Ianni
'
' 	DISTRIBUCIONES BIVARIADAS
'=======================================

' Este programa simula distribución NORMAL BIVARIADA
'     - Presenta scatter plot con 



' ++Seteo PARÁMETROS
!n = 50

!rho = 0.8
!beta = 1

!mux = 10
!sigmax = 1
!muy = 4
!sigmay =!beta * !sigmax / !rho


'++ Crear worfile
wfclose(noerr) 'Crear WorkFile
wfcreate(wf=Multivariate, page=Multi) u 1 !n
delete *


'++Simular SERIES
series etax = nrnd
series etay = !rho * etax + @sqrt(1-!rho^2) * nrnd
series x = !mux +etax * !sigmax
series y = !muy +etay * !sigmay
series truth = (!muy-!beta*!mux) + !beta * x


!icept = !muy-!beta*!mux

' Crear Gráfico de Dispersión de X e Y
' (leyendas tienen Offset en setelem() )


'===========
'   FIGURAS
'===========
group xy x y
freeze(Fig1) xy.scat(ab=histogram) user(icept=!icept, slope=!beta) linefit() CELLIPSE(size=0.95 0.99) 
fig1.options linepat
fig1.legend position(bc) columns(3)
fig1.setelem(2) lcolor(black) lpat(solid) 
fig1.setelem(3) lcolor(green) legend(E(y|x))
fig1.setelem(4) lcolor(gray) lwidth(0.5) legend(MCO)
fig1.setelem(5) lcolor(gray) lwidth(0.5) legend(IC .95 y .99)
fig1.setelem(7) legend()
fig1.addtext(ac, just(c))  "Scatter de una normal bivariada\n(+ E(y|x), LineFit y Elipses de Confianza)"



'===========
'   ACTIVIDADES
'===========

' 1. Estimar regresión y~x por MCO
' 2. Invertir el modelo anterior (poner a y en función de x) - guardar en un vector de coeficientes
' 3. Estimar x~y y comprobar si las estimaciones coinciden, explicar resultados





