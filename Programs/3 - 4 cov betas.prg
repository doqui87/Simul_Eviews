'=======================================
' Introducción a la econometría
' 	Un enfoque basado en simulación
'	Guido Ianni
'
' 	DISTRIBUCIONES BIVARIADAS
'=======================================

' En esta simulación vamos a ver las distribuciones empíricas de los estimadores de beta de un MRLS a través de una simulación de MonteCarlo

'	- Simulamos el modelo y ~ x
' 	- Estimamos por MCO y Guardamos los beta_hats los sigma_hats
' 	- Construimos los T-statistics de cada regresión 
'	- y determinamos si se rechazó H0: betahat=beta

' 	Se presentan los histogramas de beta_hats y sigma_hats
'	Se presentan los scatters para ver la distribución bivariada




'++ Seteo PARAMETROS
!n = 5
!R = 100

!beta1 = 3
!beta2 = 1
!sigma = 1


'++ Creo WorkFile
wfclose(noerr)
wfcreate(wf=Multi, page=sims) u 1 !n
delete *


'==================
'   SIMULAR
'==================
series x = rnd


'++ LOOPEAR

matrix (!R, 4) estimates

for !i=1 to !R
'	Simular series
	series u =nrnd 'distribucion de errores
	series y = !beta1+!beta2*x+u

	equation eq01.ls y c x ' Estimar una regresión y~x

'	Guardar resultados
	estimates(!i, 1) = eq01.@coefs(1)
	estimates(!i, 2) = eq01.@coefs(2)
	estimates(!i, 3) = eq01.@stderrs(1)
	estimates(!i, 4) = eq01.@stderrs(2)
next



'==================
'   NEW PAGE
'==================
'Crear pagina con resultados de simulaciones
pagecreate(page=simres) u 1 !R

'Inicializar las series para guardar los resultados
series b1
series b2
series sigma1
series sigma2

group statistics b1 b2 sigma1 sigma2


' Nos traemos los resultados y escribimos las series
copy sims\estimates estimates

mtos(estimates, statistics) 'Matrix-to-Series conversion

' Construimos los T-statistics de cada regresión y determinamos si se rechazó H0: betahat=beta

series tB1 = (b1 - !beta1)/sigma1
series tB2 =  (b2 - !beta2)/sigma2

series reject_H_b1 = abs(tb1) > @qtdist(0.975, !n-2)
series reject_H_b2 = abs(tb2) > @qtdist(0.975, !n-2)

group betas b1 b2


'===========
'   FIGURAS
'===========

'+ HISTOGRAMAS beta_hat

freeze(fig1) betas.distplot(m) hist(anchor=0, scale=dens) theory()
fig1.addtext(t, just(c), font(garamond, 24, b))  Histogramas de estimadores MCO n={!n}


'++ Distribucion conjunta beta_hat
freeze(fig2) betas.scat(ab=histogram) linefit()
fig2.addtext(t, just(c), font(garamond, 24, b))  Distribución conjunta de estimadores MCO

group sigmas sigma1 sigma2

' ++ HISTOGRAMAS var(beta_hats)
freeze(fig3) sigmas.distplot(m) hist(anchor=0, scale=dens) theory()
fig3.addtext(t, just(c), font(garamond, 24, b))  Histograma var_hat(beta_hat)


'++ Distribucion conjunta beta_hat
freeze(fig4) sigmas.scat(ab=histogram) linefit()
fig3.addtext(t, just(c), font(garamond, 24, b)) Distribucion conjunta de estimadores var_hat(beta_hat)



'===========
'   TABLAS
'===========

group reject reject_h_b1 reject_h_b2

freeze(TSI_alpha) reject.stats


'===========
'   ACTIVIDADES
'===========

' Construir curvas de potencia para reject_H_b1 y reject_H_b2 ?

' Cambiar distribución de U (x ej, una chi-sq, que es altamente no-simetrica) y ver cómo cambian los resultados.


