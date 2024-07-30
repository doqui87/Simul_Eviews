'=======================================
' Introducción a la econometría
' 	Un enfoque basado en simulación
'	Guido Ianni
'
' MODELOS BIVARIADOS - Transf. BOX-COX

'=======================================



'Las distribuciones de probabilidad están determinadas si uno determina σ^2 (μ) 
'	en la normal σ^2(μ)=σ^2, pero eso no pasa en todas las distribuciones; 
'										al margen de las transformaciones loc, scale

'El objetivo de Box-Cox, de alguna forma, es transformar una VA 
'	(generalmente, de la variable de respuesta de un modelo de regresión) 
'	para lograr que σ^2 (μ) sea “más o menos constante”


'Las transformaciones Box-Cox tienen la pinta 

'          ===========================
'			B(y, !theta) = (y ^ theta -1)/!theta
'          ===========================

'	Tiene como casos particulares 
'     		B(y, 1) = y
'     		B(y, 0) = log(y)

' Vamos a analizar tres tipos de modelos
'				y = !beta1 +!beta2 * B(x, !theta) + u
'	B(z,!theta) = !beta1 +!beta2 * x                 + u
'	B(w,!theta) = !beta1 +!beta2 * B(x, !theta)+ u

' Para eso hay que tener primero en cuenta
'		los efectos de !theta sobre la distribución de Y

' Analíticamente, si y*  = B(y)
'	Una expansión de Taylor alrededor de y=muy da
' 			y* = B(mu) + B'(mu) (y-mu), lo que implica
' 		V[y*] ~ B'(mu)^2 V(y)

' Es decir, la transformación Box-Cox logra estabilizar la varianza de y* si B'(mu) es proporcional al desvío de Y

' Además estimamos z4 ~ x  y observamos el scatter de los residuos contra el valor del target

'  =====================
'			ACTIVIDAD
'  =====================

'	Observar los histogramas de
'			X, Y, Z, y W
'	Observar los scaters de X con Y, Z y Z

'	El objetivo es 
'			desarrollar algunas intuiciones acerca de 
'			cuándo es conveniente transformar variables en un modelo de regresión

' Esto va a quedar más claro con las simulaciones

' (Ejercicio): Estimar el modelo no-lineal que mejor aproxime



'  =====================
'		SIMULACIONES
'  =====================

' ++Seteo PARÁMETROS
!n =1000


%thetas = "-1 -0.5 0 1/2 1 1.1 1.5 2 3"


%distr_X = "1 + 10*rnd"

' b(y) = !beta1 + !beta2 * b(x) + u
!beta1 = 1
!beta2 = 1
!sigmau = 1/4


'++ Creo WorkFile
wfclose(noerr)
wfcreate(wf=BoxCoxTrans) u 1 !n


'==================
'   SIMULAR
'==================
series x = {%distr_X}

!counter = 0

'++ LOOPEAR
for %theta {%thetas}
	!counter = !counter+1
	
	if %theta="0" then

		series 			bx{!counter} = log(x)
		series 			  y{!counter} = !beta1 + !beta2 * bx{!counter} + nrnd*!sigmau
		series  		 log(z{!counter}) = !beta1 + !beta2 *x + nrnd*!sigmau
		series 		log(w{!counter}) = !beta1 + !beta2 *bx{!counter} + nrnd*!sigmau

	else

		series 			bx{!counter} = (x^{%theta}-1)/{%theta}
		series   			 y{!counter} = !beta1 + !beta2 * bx{!counter} + nrnd*!sigmau
		series 					     bz = !beta1 + !beta2 *x + nrnd*!sigmau
		series			 	z{!counter} = ({%theta}*bz+1)^(1/{%theta})
		series (w{!counter}^{%theta}-1)/{%theta} =  !beta1 + !beta2 * bx{!counter} + nrnd*!sigmau


	endif

	y{!counter}.displayname theta={%theta}
	z{!counter}.displayname theta={%theta}
	w{!counter}.displayname theta={%theta}

	'===========
	'   FIGURAS - crear
	'===========

	graph xy{!counter}.scat x y{!counter}
	graph xz{!counter}.scat x z{!counter}
	graph xw{!counter}.scat x w{!counter}
	freeze(bx{!counter}_h) bx{!counter}.distplot hist
	freeze(y{!counter}_h) y{!counter}.distplot hist
	freeze(z{!counter}_h) z{!counter}.distplot hist
next

'Hacer strings de todos los graficos
%xy   = @wlookup("xy?", "graph")
%xz   = @wlookup("xz?", "graph")
%xw  = @wlookup("xw?", "graph")
%bx_h=@wlookup("bx?_h", "graph")
%y_h = @wlookup("y?_h", "graph")
%z_h = @wlookup("z?_h", "graph")

'===========
'   FIGURAS - merge
'===========
graph ScattersXY.merge {%xy}
graph ScattersXZ.merge {%xz}
graph ScattersXW.merge {%xw}
graph Hists_bx.merge {%bx_h}
graph Hists_y.merge {%y_h}
graph Hists_z.merge {%z_h}


ls z4 c x 
graph u_y.scat resid z4
u_y.addtext(t) Scatterplot de u\hat contra target de modelo mal transf. por box-cox


