'=======================================
' Introducción a la econometría
' 	Un enfoque basado en simulación
'	Guido Ianni
'
' 	ESTADÍSTICA DESCRIPTIVA
'=======================================

' Este programa simula unas cuantas distribuciones de probabilidad univariadas
' 	e ilustra sus propiedades a través de estadísticas descriptivas y gráficos.


' +++ Fijar PARÁMETROS
!n = 10000

'Después, creo el archivo de trabajo (workfile), 
wfclose(noerr)
wfcreate (wf=WFile, page=pagina) u 1 !n
'y me aseguro que siempre que corro el archivo esté vacío
'	(Ojo que esto implica que todo lo que hago a mano se pierde cuando ejecuto)
delete * 



'=======================================
'Simular unas cuantas distribuciones de probabilidad
'=======================================
' 	Ver referecias en Command Reference  (p.604)
'		Ch. 17 - Statistical Distribution Functions

series norm = nrnd
series bernoulli = @rbinom(1,1/3) 'n, p parámetros
series binomial = @rbinom(9,1/3) 
series chisq = @rchisq(5)
series F = @rfdist(100,200)
series gamma = @rgamma(1,3)
series poisson = @rpoisson(3)
series normal = 3+@rnorm
series lognormal =  @rlognorm(1,1)

series weibull = @rweib(1,10) 'Asimetrica negativa
series exponencial = @rexp(1) 'Asimetrica positiva
series unif = @runif(0,1) 'Colas livianas
series bimodal = @rbeta(.8,.8) 'BIMODAL
series beta = @rbeta(2,2)
series laplace = @rlaplace



'=======================================
'	Crear FIGURAS
'=======================================

'  ++ Histogramas ++
group gr_hists norm unif beta weibull f 'Agrupar algunas distrubiciones 
freeze(Fig1) gr_hists.distplot(hist) 'Crear las figuras
Fig1.addtext(t, font(24)) "Histogramas de variables aleatorias seleccionadas"

' ++ Means Boxplots
group gr_sel_distrs binomial gamma poisson normal
freeze(zfig2a) gr_sel_distrs.bar(contract=mean) 'Barplot demedias
freeze(zfig2b) gr_sel_distrs.boxplot 'Boxplots
graph Fig2.merge zfig2a zfig2b* 'Unir las dos partes
Fig2.addtext(t, font(24)) "Medias y Boxplots  de Variables Aleatorias Seleccionadas"
fig2.align(2,1,1)

' ++ QQ plots!
group Gr_qq chisq weibull unif laplace  bimodal normal
freeze(Fig3) Gr_qq.qqplot theory() 'Mostrar QQ-Plots
Fig3.addtext(t, font(24)) "Q-Q Plots de VA Seleccionadas"
freeze(Fig3_hists)Gr_qq.distplot(m) hist(anchor=0)
Fig3_hists.addtext(t, font(24)) "Histogramas de las VA de la Fig3"



