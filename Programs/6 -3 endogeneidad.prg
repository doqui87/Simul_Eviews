'=======================================
' Introducción a la econometría
' 	Un enfoque basado en simulación
'	Guido Ianni
'
' 	ENDOGENEIDAD
'=======================================

' En este programa ilustramos los efectos de:
'		> Incorporar regresores irrelevantes [ineficiencia]
'		> Omitir regresores relevantes 
'				- Que correlacionan con las X [sesgado e inconsistencia]
'				- Que NO correlacionan con las X [consitencia]


'Montecarlo de 
'	y = μ + e  ~ N(μ, σ^2)
'	μ = b1 x1 + b2 x2 + b3 x3
'	corr(x1, x2) = rho2
'	corr(x1, x3) = 0
'	corr(x1, x4) = rho4 [que no está en el modelo]


' El resto de las explicativas son ortogonales

'Se estiman 4 modelos: 
'	TRUE
'	OMITX2
'	OMITX3
'	ADDX4


' FIGURAS 
'		Se muestran las distribuciones empíricas para cada modelo de β1_hat
'		Se muestran las distribuciones empíricas para cada modelo de TODOS los β_hat

'==================
'	ACTIVIDADES
'==================


'==================
'	PARAMETROS
'==================

!n = 50
!R  = 1000


!b1 = 1
!b2 = 2
!b3 = 3


!rho2 = 0.7
!rho4 = 0.8


!sigma_u = 1


' ++++++++
' Crear Workfile y borrar contenido
'+++++++++
wfclose(noerr)
wfcreate(wf=endog, page=simulations) u 0 !n
delete *

' Crear NA series y empty equations

series x1 = nrnd
series x2 = !rho2*x1+(1-!rho2^2)*nrnd
series x3 = nrnd
series x4 = !rho4*x1+(1-!rho4^2)*nrnd
series mu = !b1 * x1 + !b2 * x2 + !b3 * x3


series y
series u

group Xs x1 x2 x3 x4
xs.cov() corr

equation eq_TRUE
equation eq_OMITx2
equation eq_OMITx3
equation eq_ADDx4


 
'==================
'   MONTECARLO
'==================

matrix(!R, 11)  simres

' Simular DGP
for !rep=1 to !R

	u  = !sigma_u * nrnd
	y = mu + u

	eq_TRUE.ls y x1 x2 x3 c	
	eq_OMITx2.ls y x1 x3 c
	eq_OMITx3.ls y x1 x2 c
	eq_ADDx4.ls y x1 x2 x3 x4 c


	simres(!rep, 1) = eq_TRUE.@coefs(1)
	simres(!rep, 2) = eq_TRUE.@coefs(2)
	simres(!rep, 3) = eq_TRUE.@coefs(3)
	simres(!rep, 4) = eq_OMITx2.@coefs(1)
	simres(!rep, 5) = eq_OMITx2.@coefs(2)
	simres(!rep, 6) = eq_OMITx3.@coefs(1)
	simres(!rep, 7) = eq_OMITx3.@coefs(2)
	simres(!rep, 8) = eq_ADDx4.@coefs(1)
	simres(!rep, 9) = eq_ADDx4.@coefs(2)
	simres(!rep, 10) = eq_ADDx4.@coefs(3)
	simres(!rep, 11) = eq_ADDx4.@coefs(4)

next



'================== 
'   SIMRESULTS 
'================== 
'Crear pagina con resultados de simulaciones 
pagecreate(page=simresults) u 1 !R

'Inicializar las series para guardar los resultados 
series true_b1
series true_b2
series true_b3

series omitx2_b1
series omitx2_b3

series omitx3_b1
series omitx3_b2

series addx4_b1
series addx4_b2
series addx4_b3
series addx4_b4


group estimates true_b1 true_b2 true_b3 omitx2_b1 omitx2_b3 omitx3_b1 omitx3_b2 addx4_b1 addx4_b2 addx4_b3 addx4_b4

group b1_estimates true_b1 omitx2_b1 omitx3_b1 addx4_b1

' Copiar y convertir a series
copy simulations\simres simres

mtos(simres, estimates) 'Matrix-to-Series conversion 
'================== 
'		   PLOT 
'================== 

'FIG_b1
freeze(fig_b1) b1_estimates.distplot(s)  theory()
fig_b1.draw(line, bottom, pattern(1), linewidth(2), top) !b1
fig_b1.addtext(t, just(c), font(garamond, 14)) Distribución de estimaciones de BETA1



%betas = @wlookup("*TRUE*", "series")
group betas  {%betas}
freeze(fig_TRUE) betas.distplot(s)  theory()
fig_true.draw(line, bottom, pattern(1), linewidth(2), top) !b1
fig_true.draw(line, bottom, pattern(1), linewidth(2), top) !b2 
fig_true.draw(line, bottom, pattern(1), linewidth(2), top) !b3
fig_true.addtext(t, just(c), font(garamond, 18)) Modelo bien especificado


%betas = @wlookup("*OMITX2*", "series")
group betas  {%betas}
freeze(fig_OMITX2) betas.distplot(s)  theory()
fig_OMITX2.draw(line, bottom, pattern(1), linewidth(2), top) !b1 
fig_OMITX2.draw(line, bottom, pattern(1), linewidth(2), top) !b3
fig_OMITX2.addtext(t, just(c), font(garamond, 18)) OMITX2


%betas = @wlookup("*OMITX3*", "series")
group betas  {%betas}
freeze(fig_OMITX3) betas.distplot(s)  theory()
fig_OMITX3.draw(line, bottom, pattern(1), linewidth(2), top) !b1 
fig_OMITX3.draw(line, bottom, pattern(1), linewidth(2), top) !b2
fig_OMITX3.addtext(t, just(c), font(garamond, 18)) OMITX3


%betas = @wlookup("*ADDX4*", "series")
group betas  {%betas}
freeze(fig_ADDX4) betas.distplot(s)  theory()
fig_ADDX4.draw(line, bottom, pattern(1), linewidth(2), top) !b1 
fig_ADDX4.draw(line, bottom, pattern(1), linewidth(2), top) !b2
fig_ADDX4.draw(line, bottom, pattern(1), linewidth(2), top) !b3
fig_ADDX4.draw(line, bottom, pattern(1), linewidth(2), top) 0
fig_ADDX4.addtext(t, just(c), font(garamond, 18)) ADDX4

graph all_models.merge fig_true fig_omitx2 fig_omitx3 fig_addx4
all_models.addtext(t, just(c), font(garamond, 30)) Distribución de estimaciones



show fig_b1
show all_models
show estimates.stats


