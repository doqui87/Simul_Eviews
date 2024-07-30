'=======================================
' Introducción a la econometría
' 	Un enfoque basado en simulación
'	Guido Ianni
'
' 	DISTRIBUCIONES BIVARIADAS
'=======================================

' Este programa 

' A)Simula un modelo de regresion simple y=c(1)+c(2)*x + u
'		Plotea el scatter de una simulación, la E(y|x) y las bandas de confianza del 95%

' B) Simula un modelo no lineal en X (pero lineal en parámetros) 
'	Plotea scatter de dos "fits" con parámetros arbitrarios
'	El correspondiente a estimar el modelo lineal en X por MCO
'	La estimación por MCO del verdadero modelo



'++ Seteo PARAMETROS
!n = 200
!beta1 = 3
!beta2 = -1

!sigma = 1/2


'++ Creo WorkFile
wfclose(noerr)
wfcreate(wf=Multivariate, page=MRLS) u 1 !n
delete *


'==================
'   SIMULAR
'==================

series x = rnd

series modelo = !beta1 + !beta2 * x
series y = modelo + nrnd*!sigma

series upper = modelo + @qnorm(0.975) * !sigma
series lower = modelo + @qnorm(0.025) * !sigma


'===========
'   FIGURAS
'===========
group xy x y modelo upper lower

freeze(fig1) xy.xyline
fig1.setelem(1) lpat(none) symbol(filledcircle)
fig1.setelem(2) lcolor(black) lwidth(2)
fig1.setelem(3) lcolor(gray) lwidth(0.5)
fig1.setelem(4) lcolor(gray) lwidth(0.5)
fig1.addtext(t,just(c), font(Garamond, 18,b))  "Modelo de Regresion Lineal Simple"
fig1.legend position(botcenter) columns(4)



'=======================================
'             CasoB | Otro Modelo
'=======================================


'++Simular SERIES
series x = rnd

series y = -@cos(@pi*x) + nrnd/15



'++Agregar Regresiones arbitrarias
series fit1 = -.5 + 1.1 *x
fit1.displayname -.5 + 1.1x

series fit2 = -2 + 4 *x
fit2.displayname -2 + 4x

'++Estimar modelo lineal
equation linreg.ls y c x 'modelo lin-lin
series fit3 = c(1)+c(2)*x
fit3.displayname MCO

equation non_linreg.ls y c cos(x) 'modelo cos-lin
series fit4 = c(1)+c(2)*cos(x)
fit4.displayname Non_lin_model

for !n_graph=1 to 4
	graph zfig2_{!n_graph}.xyline x y fit{!n_graph}
	zfig2_{!n_graph}.sort(x)
	zfig2_{!n_graph}.setelem(1) lpat(none) symbol(filledcircle) 
	zfig2_{!n_graph}.setelem(2) lcolor(gray) linewidth(1) legend()
	!scr = @round(@sumsq(y-fit{!n_graph}))
	%fitted= fit{!n_graph}.@displayname
	zfig2_{!n_graph}.addtext(itl, just(c), font(cambria, 18)) y ={%fitted}       (SCR=!scr)
next



graph fig2.merge zfig2_1 zfig2_2 zfig2_3 zfig2_4
fig2.addtext(t, just(c), font(garamond, 24, b))  "Modelos de regresion lineal para y = -@cos(@pi*x) + nrnd/15"
fig2.align(2,1,1)
