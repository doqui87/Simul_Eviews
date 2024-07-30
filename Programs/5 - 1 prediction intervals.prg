'=======================================
' Introducción a la econometría
' 	Un enfoque basado en simulación
'	Guido Ianni
'
' 	REGRESSION CONFIDENCE INTERVALS
'=======================================

' Este programa retoma el trabajo con el dataset CPS09mar. 
' Se centra en las siguientes dos relaciones

'(Rel1):	EDUC vs LOG(WAGE)
'				sample: married (spouse present) black female and (experience=12)
'
'(Rel1):	EXPERIENCE(XD=2) VS LOG(WAGE)
'			sample: single (never married) asian male 
'			controles adicionales: educ 


' FIGURAS
'		FIG1: Presenta una motivación calculando la media condicional de log(wage) por cada control

'		FIG2: 
'			Estima el modelo apropiado (lineal para educ, cuadrático para exper)
'			Produce los Intervalos de confianza
'			Muestra los scatterplots

'La idea central es mostrar que, pese a que V(u|x) es constante [caso homoscedastico], V(u\hat|x) no lo es debido a la incertidumbre acerca de los parámetros. 
'Esto lo vamos a usar enseguida para corregir estimaciones robustas por heteroscedasticidad



'++ CARGAR DATAFRAME
wfclose(noerr)
wfopen cps09mar.wf1
delete fig* temp*

%sampleEDUC = " if married and black and female and experience=12"
%sampleEXPER= "if single and asian and male"

'++Construir series auxiliares

smpl @all

delete fig* temp*

series wage = earnings/(hours*week)
series lwage = log(wage)
series experience = age-education-6
series white = (race=1)
series black = (race=2)
series asian = (race=4)
series male = (female=0)
series married = (marital=1)
series single = (marital=7)


group lw_educ  education lwage
group lw_exp experience lwage 



'==========
'   	EDUC
'==========

SMPL {%sampleEDUC} 'Setear sample

'Crear Fis con Medias
freeze(FIG1A) lw_educ.scat(contract=mean) within(education) linefit()

' Estimar MCO
EQUATION eq_educ.ls lwage education c 'estimar


'+++++FIG2 +++++++
' Crear forecast y corecast standard error
eq_educ.fit(e, g) educ_f educ_se

'Corregir StdError de Forecast a Prediction
educ_se = @sqrt(educ_se^2 - eq_educ.@ssr/eq_educ.@df)

' Upper y Lower bounds del IC
series educ_low = educ_f - 2*educ_se
series educ_up = educ_f + 2*educ_se

'Plotear y customizar
graph fig2a.xyline education educ_f educ_up educ_low
fig2a.options linepat -legend
fig2a.sort(1)
fig2a.setelem(1) lcolor(black) lpat(solid)
fig2a.setelem(2) lcolor(grey) lpat(2)
fig2a.setelem(3) lcolor(grey) lpat(2)
fig2a.addtext(b, just(c), font(garamond,18)) education vs log(wage)



'==========
'	   EXP
'==========

SMPL {%sampleEXPER}
freeze(FIG1B) lw_exp.scat(contract=mean) within(experience) linefit(xd=2) 
equation eq_exp.ls lwage experience experience^2/100 c

series bkp_educ = education
education=12
series bkp_exp = experience
experience=70*@trend/50742


'++FIGs
'Forecast y Forecast_se
eq_exp.fit(e, g)  exp_f exp_se

'corregir StdError de Forecast a Prediction
exp_se = @sqrt(exp_se^2 - eq_exp.@ssr/eq_exp.@df) 

'Plotear
series exp_low = exp_f - 2*exp_se
series exp_up = exp_f + 2*exp_se
graph fig2b.xyline experience exp_f exp_up exp_low
fig2b.options linepat -legend
fig2b.sort(1)
fig2b.setelem(1) lcolor(black) lpat(solid)
fig2b.setelem(2) lcolor(grey) lpat(2)
fig2b.setelem(3) lcolor(grey) lpat(2)
fig2b.addtext(b, just(c), font(garamond,18)) experience vs log(wage)

smpl @all

graph fig1.merge fig1a fig1b
fig1.addtext(t, just(c), font(garamond,24,b)) Media de log(wage) por Categorias
fig1.align(2,1,1)

graph fig2.merge fig2a fig2b
fig2.addtext(t, just(c), font(garamond,24,b)) Prediccion e Intervalos de confianza para la regresion
fig2.align(2,1,1)

show fig2


