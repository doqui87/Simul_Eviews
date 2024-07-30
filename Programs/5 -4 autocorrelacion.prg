'=======================================
' Introducción a la econometría
' 	Un enfoque basado en simulación
'	Guido Ianni
'
' 	AUTOCORRELACION
'=======================================

'Montecarlo de 
'	y = μ + e  ~ N(μ, σe^2)
'	e = ρ u(-1) + u
'	u ~ N(0,σu^2)


'Ilustramos los momentos de un proceso AR(1) estable 
'		en el cual la distribución de ρ ̂ es sesgada pero consistente, 
'		y su distribución no es normal 
'		De hecho, no existe una solución analítica sencilla para esta distribución.


'Se estiman 3 modelos: 
'	IGNORE  		estima y ~ c Ignorando autocorrelación
'	AR 				Estimar un modelo AR(1) usando las funcionalidades de Eviews
'	AUTOCOR		Estima el modelo por MCG


' FIGURAS 
'		Se muestran las distribuciones empíricas para cada modelo de β ̂ y ρ ̂


'==================
'	ACTIVIDADES
'==================
' 1) Diagnosticar la autocorrelación
'
' 2) Recalibrar los parámetros a 
'	N=25 y R=100 (repeticiones insuficientes)
'	N=25 y R=10.000 (normalidad y alto sesgo)
'	N=250 y R=10.000 (consistencia)
'
' 3) En las simulaciones, los modelos 1 y 3 coinciden en su estimación, debido a que no existen otros regresores. 
'		Mostrarlo agregando otro regresor al modelo.
'
' 4) Ajustar el código para obtener:
'		Estimaciones de ρ según AR(1) donde cada repetición tiene una observación más que la anterior. 
'		Hacer el lineplot de ρ ̂ a medida que aumenta n
'		Ilustrar la convergencia de una forma alternativa.


'==================
'	PARAMETROS
'==================

!R  = 1000
!n = 50 		


!mu = 1
!rho = 0.7

!sigma_u = 1



' ++++++++
' Crear Workfile y borrar contenido
'+++++++++
wfclose(noerr)
wfcreate(wf=autocorrlacion, page=simulations) u 0 !n
delete *

' Crear NA series y empty equations
series y
series u
series e
series y_trans

equation eq1_ignore 
equation eq2_ar
equation eq3_autocor
equation eq3_aux
 
'==================
'   MONTECARLO
'==================

matrix(!R, 5)  simres

' Inicialiar u
smpl @first @first						
series e = nrnd * !sigma_u	'Asumir e(-1) = 0

' Simular DGP
for !rep=1 to !R

	smpl @first+1 @last
	u  = !sigma_u * nrnd
	e = !rho*e(-1) + u
	y = !mu + e

	eq1_ignore.ls y c


	eq2_ar.ls y c ar(1)


	eq1_ignore.makeresids ehat
	eq3_aux.ls ehat ehat(-1)
	!rhohat = eq3_aux.@coefs(1)
	y_trans = y * (1-!rhohat)
	eq3_autocor.ls y_trans c



	simres(!rep, 1) = eq1_ignore.@coefs(1)
	simres(!rep, 2) = eq2_ar.@coefs(1)
	simres(!rep, 3) = eq3_autocor.@coefs(1)/(1-!rhohat)
	simres(!rep, 4) = !rhohat
	simres(!rep, 5) = eq2_ar.@coefs(2)

next



'==================
'   SIMRESULTS
'==================
'Crear pagina con resultados de simulaciones
pagecreate(page=simresults) u 1 !R

'Inicializar las series para guardar los resultados
series b_ignore
series b_ar
series b_autocor

series rho_ar
series rho_autocor

group estimates b_ignore b_ar b_autocor  rho_ar rho_autocor
group b_estimates b_ignore b_ar b_autocor
group r_estimates rho_ar rho_autocor



' Copiar y convertir a series
copy simulations\simres simres

mtos(simres, estimates) 'Matrix-to-Series conversion
'==================
'		   PLOT
'==================

'FIG_MU
freeze(fig_mu) b_estimates.distplot(m) hist(anchor=0, binw=user, binval=0.1, scale=dens) 
fig_mu.draw(line, bottom, @rgb(255,0,0), linewidth(4)) !mu
fig_mu.setelem(1) fillcolor(grey)
fig_mu.addtext(t, just(c), font(garamond, 14)) media

'FIG_RHO
freeze(fig_rho) r_estimates.distplot(m) hist(anchor=0, binw=user, binval=0.03, scale=dens)
fig_rho.draw(line, bottom, @rgb(255,0,0), linewidth(4)) !rho
fig_rho.addtext(t, just(c), font(garamond, 18)) AUTOCORRELACION
fig_mu.setelem(2) lcolor(blue) linewidth(6)

' MERGE fig1
graph FIG1.merge fig_mu fig_rho
fig1.addtext(t, just(c), font(garamond, 24)) Distribucion muestral de los estimadores en un modelo AR(1)
fig1.align(3,1,1)

show fig1


