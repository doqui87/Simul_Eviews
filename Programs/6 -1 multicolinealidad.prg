'=======================================
' Introducción a la econometría
' 	Un enfoque basado en simulación
'	Guido Ianni
'
' 	MULTICOLINEALIDAD
'=======================================

'     y ~ x1 + x2 + x3

'==================
'	SETTING
'==================

' En este programa simulamos dos modelos (Alta y Baja), uno con alta y otro con baja multicolinealidad 

'	(x1, x2, x3) ~ N(μx, Σx)
'			y ~ N(μy, σy)
'			μy = b0 + b1 x1 + b2 x2 + b3 x3  
'	
' Ambos modelos difieren en la correlación ρ que existe entre X1 y X2 (baja tiene la ρ/2). 
'	X3 es independiente de X1 y X2
'	σy se calibra a partir de al correlacion deseada entre (μy, y)
'	Todas las series tienen media cero y varianza unitaria


'==================
'	PROCESOS
'==================
' Además de los modelos de reresión ALTA y BAJA se estiman dos modelos más:
'		PCA2 realiza la proyección de las X sobre los de 2 primeros componentes principales
'		Bias estima un modelo omitiendo uno de los regresores colineales (x2)


'==================
'	FIGURAS
'==================

' FIG1:
'		Scatter Matrix de regresores en ambos modelos (última rep)

' FIG2: 
'		Elipses de confianza para las estimaciones puntuales 
'			con valores verdaderos señalados (altima rep)

' FIG3:
'		Histograma de los estimadores MonteCarlo de los 4 modelos de regresion

' FIG4:
'		Montecarlo distribuciones de b1 b2 y b3 y RB_true de modelo Alta

		

'==================
'	ACTIVIDADES
'==================

'	>  Observar los efectos de la correlación de las X en
'		R2 
'		t-statistics (p-vals)
'		F-Statistics

'	> Obtener los VIFs de los coeficientes cada ecuación
'	> Realizar la descomposición de la varianza basada en SVD
'	
'	> Mínimos Cuadrados restringidos (MCR)
'			Restricciones verdaderas y aproximadamente verdaderas
'			Test de Wald


		
''==================
'	PARAMETROS
'==================

!R  = 4
!n = 50 		


!rho12 = 0.995
!b1 = 1
!b2 = 2
!b3 = 11

!rhoxy = 0.8

!aprox = 1.2


' ++++++++
' Crear Workfile y borrar contenido
'+++++++++
wfclose(noerr)
wfcreate(wf=multicol, page=simulations) u 0 !n
delete *

' Crear series NAs y ecuaciones
series x1 
series x2_a
series x2_b
series x3
series muy_a
series muy_b
series y_a
series y_b

group xs_a x1 x2_a x3 
group xs_b x1 x2_b x3 

equation eqALTA 
equation eqBAJA
equation eqPCA2
equation eqBIAS
 
'==================
'   MONTECARLO
'==================

matrix(!R, 10)  simres


' Simular DGP
for !rep=1 to !R

	x1 = nrnd
	x2_a = !rho12*x1 + (1-!rho12^2)*nrnd
	x2_b = !rho12*x1/2 + (1-!rho12^2/4)*nrnd
	x3 = nrnd
	muy_a = !b1 * x1 +!b2 * x2_a + !b3 * x3
	muy_b= !b1 * x1 +!b2 * x2_b+ !b3 * x3
	y_a = !rhoxy  * muy_a + (1-!rhoxy)*nrnd
	y_b = !rhoxy  * muy_b + (1-!rhoxy)*nrnd

	xs_a.makepcomp pca1 pca2 pca3

	eqALTA.ls y_a x1 x2_a x3 c
	eqBAJA.ls y_b x1 x2_b x3 c
	eqPCA2.ls y_a pca1 pca2 c 
	eqBIAS.ls y_a x1 c x3

	simres(!rep, 1) = eqALTA.@coefs(1)
	simres(!rep, 2) = eqALTA.@coefs(2)
	simres(!rep, 3) = eqALTA.@coefs(3)
	simres(!rep, 4) = eqBAJA.@coefs(1)
	simres(!rep, 5) = eqBAJA.@coefs(2)
	simres(!rep, 6) = eqBAJA.@coefs(3)
	simres(!rep, 7) = eqBIAS.@coefs(1)
	simres(!rep, 8) = eqBIAS.@coefs(3)
	simres(!rep, 9) = eqPCA2.@coefs(1)
	simres(!rep, 10) = eqPCA2.@coefs(2)




next


'==================
'   SIMRESULTS
'==================
'Crear pagina con resultados de simulaciones
pagecreate(page=simresults) u 1 !R

'Inicializar las series para guardar los resultados de las simuaciones
series a_b1
series a_b2
series a_b3

series b_b1
series b_b2
series b_b3
series bias_b1
series bias_b3

series pca2_1
series pca2_2

%param_names = @wlookup("*", "series")

group estimates {%param_names}

' Copiar y convertir a series 
copy simulations\simres simres

mtos(simres, estimates) 'Matrix-to-Series conversion 



series a_cl =  a_b1 - a_b2 
series b_cl = b_b1 - b_b2


group alta a_*
group baja b_*

group pca pca*
group bias bias*
group cl ?_cl*



'==================
'		   PLOT
'==================


' FIG1: Scatter Matrix de regresores en ambos modelos ultima rep)
pageselect simulations


freeze(fig1_a) xs_a.scatmat() CELLIPSE()
%correl = @str(@round(1000*@cor(x1, x2_a))/1000)
fig1_a.addtext(t, just(c), font(garamond, 24)) Correlacion x1-x2 = {%correl}

freeze(fig1_b) xs_b.scatmat() CELLIPSE()
%correl = @str(@round(1000*@cor(x1, x2_b))/1000)
fig1_b.addtext(t, just(c), font(garamond, 24)) Correlacion x1-x2 = {%correl}


graph fig1.merge fig1_a fig1_b
fig1.align(2,3,1)
fig1.addtext(t, just(c), font(garamond, 36, b)) Scatterplot regresores (Ultima simulacion)



' FIG2: Elipses de confianza para las estimaciones puntuales 
'			con valores verdaderos señalados (altima rep)
freeze(fig2_a) eqalta.cellipse
%correl = @str(@round(1000*@cor(x1, x2_a))/1000)
fig2_a.addtext(t, just(c), font(garamond, 24)) Correlacion x1-x2 = {%correl}

freeze(fig2_b) eqbaja.cellipse
%correl = @str(@round(1000*@cor(x1, x2_b))/1000)
fig2_b.addtext(t, just(c), font(garamond, 24)) Correlacion x1-x2 = {%correl}


graph fig2.merge fig2_a fig2_b
fig2.align(2,4,1)
fig2.addtext(t, just(c), font(garamond, 46, b)) Elipses de confianza coefs estimados (Ultima simulacion)


' FIG3: Montecarlo Scatterplots de beta_hats

pageselect simresults


freeze(fig3_a) alta.scatmat() CELLIPSE()
fig3_a.addtext(t, just(c), font(garamond, 24,b)) Modelo alta


freeze(fig3_b) baja.scatmat() CELLIPSE()
fig3_b.addtext(t, just(c), font(garamond, 24,b)) Modelo baja


graph fig3.merge fig3_a fig3_b
fig3.addtext(t, just(c), font(garamond, 46, b)) MonteCarlo Scatterplots beta_hats 
fig3.align(2,6,1)



' FIG4:  Montecarlo distribuciones de b1 b2 y b3 y RB_true de modelo Alta


freeze(fig4_a) alta.distplot(m) hist(scale=relferq)
freeze(fig4_b) baja.distplot(m) hist(scale=relferq)
freeze(fig4_bias) bias.distplot(m) hist(scale=relferq)
freeze(fig4_cl) cl.distplot(m) hist(scale=relferq)

graph fig4.merge fig4_a fig4_b
fig4.addtext(t, just(c), font(garamond, 46, b)) Distribucion MC de coeficientes estimados


' ++ FINISH
for %fig fig3 fig4 fig3_a fig3_b fig4_a fig4_b fig4_bias fig4_cl
	copy {%fig} simulations\{%fig}
next
pageselect simulations


