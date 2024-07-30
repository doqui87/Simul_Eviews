'=======================================
' Introducción a la econometría
' 	Un enfoque basado en simulación
'	Guido Ianni

'	DISTRIBUCIONES BASADAS EN LA NORMAL
'=======================================

' Distribuciones importantes derivadas de la distribución normal
'       - ChiSq (chi-cuadrado)
'       - T-Student
'       - F de Fisher

' +++ Fijar PARÁMETROS
!n = 100000 'n observaciones
!gl = 5 'Grados de libertad de chisq
!gl2 = 10 'Grados de libertad del denominador para la F

'++ Crear worfile
wfclose(noerr)
wfcreate (wf=WFile, page=Simulations) u 1 !n
delete *

'++ Crear series
series norm = nrnd
series lognorm = @exp(norm)
series chi_1 = norm^2


'=======================================
'Simular CHISQ
'=======================================
'Inicializar las chis
series chi_{!gl}=0
series chi_{!gl2}=0

' Simular una ChiSq(k)
for !i=1 to !gl
	series temp = nrnd^2
	series chi_{!gl} = chi_{!gl} + temp
next 

' Simular otra ChiSq
for !i=1 to !gl2
	series temp = nrnd^2
	series chi_{!gl2} = chi_{!gl2} + temp
next

' Crear T y F
series t_{!gl}  = norm / @sqrt( chi_{!gl}/!gl )
series F_{!gl}{!gl2}  = chi_{!gl}/!gl /chi_{!gl2}/!gl2




'=======================================
'	Crear FIGURAS
'=======================================
group distr norm chi_1 chi_{!gl} chi_{!gl2} t_{!gl} F_{!gl}{!gl2}

'
freeze(fig_z) norm.distplot hist(anchor=0, scale=dens) theory
freeze(fig_chi1) chi_1.distplot hist(anchor=0, scale=dens)  theory(dist=chisq, p1=1)
freeze(fig_chi{!gl}) chi_{!gl}.distplot hist(anchor=0, scale=dens)  theory(dist=chisq, p1=!gl)
freeze(fig_chi{!gl2}) chi_{!gl2}.distplot hist(anchor=0, scale=dens)  theory(dist=chisq, p1=!gl2)
freeze(fig_t{!gl}) t_{!gl}.distplot hist(anchor=0, scale=dens) theory(dist=tdist, p1=0, p2=1, p3=!gl)
freeze(fig_F{!gl}{!gl2}) F_{!gl}{!gl2}.distplot hist(anchor=0, scale=dens)

graph fig1.merge fig_z  fig_chi1 fig_chi{!gl} fig_chi{!gl2}
Fig1.addtext(t, font(24)) "Histogramas de variables aleatorias derivadas de la distribución normal\n(y ajuste a las distribuciones teoricas)"


