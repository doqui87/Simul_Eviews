subroutine EDA(string %varname)
' Realiza un análisis exploratorio de datos de la variable {%varname}


'	Crea un Spool para guardar el EDA
	spool _EDA_{%varname}

	' Realizar análisis exploratorio
	freeze(_temp{%varname}_stats) {%varname}.stats
	freeze(_temp{%varname}_hist) {%varname}.distplot hist(scale=dens) theory()
	freeze(_temp{%varname}_qq) {%varname}.qqplot theory()
	freeze(_temp{%varname}_correl) {%varname}.correl
	freeze(_temp{%varname}_correl_d1) {%varname}.correl(d=1)

	'Agregar análisis exploratorio al _EDA_{%varname}
	_EDA_{%varname}.append(name={%varname}_stats) {%varname}.stats
	_EDA_{%varname}.append(name= {%varname}_hist) temp{%varname}_hist
	_EDA_{%varname}.append(name= {%varname}_qq) temp{%varname}_qq
	_EDA_{%varname}.append(name= {%varname}_correl) temp{%varname}_correl
	_EDA_{%varname}.append(name= {%varname}_correl_d1) temp{%varname}_correld1
	
	'Clean
	delete _temp*

endsub 



subroutine fanchart (series true, series mean, series std_err, string %graph)

	' Crea un Fanchart a partir del verdadero valor de una serie (true), 
	'	el mean del forecast
	'	el standard_error del forecast
	' 	nombra al Fanchart %graph


	' Desvíos para agregar al FanChart
	%ses = "3 2 1 0.5"

	!counter =1

	'Crear grupo con series
	group _temp_group mean true
	for %se {%ses}
		series _temp{!counter}_low = mean - {%se} * std_err
		series _temp{!counter}_high = mean + {%se} * std_err
	
		_temp_group.add _temp{!counter}_low _temp{!counter}_high

		!counter=!counter+1
	next

	'Crear Fanchart
	freeze({%graph}) _temp_group.mixed line(1) line(2) band(3,4) band(5,6) band(7,8) band(9,10)

	' Personalizar
	{%graph}.setelem(2) linecolor(@rgb(0,0,0)) symbol(CIRCLE)
	{%graph}.setelem(1) linecolor(@rgb(255,0,0)) 
	{%graph}.setelem(1) fillcolor(@rgb(221,152,96))
	{%graph}.setelem(2) fillcolor(@rgb(236,125,66))
	{%graph}.setelem(3) fillcolor(@rgb(245,102,61))
	{%graph}.setelem(4) fillcolor(@rgb(227,75,49))
	{%graph}.legend -display

	'Clean
	delete(noerr)  _temp*

endsub


subroutine model_comparison(string %models_list, string %oo_smpl, string %table)
	'Crea una tabla para comparar performance de los modelos en %models_list
	'Calcula tanto métricas in-sample (R2, AIC, BIC, HQ, etc,
	'como también métricas de la performance out-of-sample MSE, MAE, etc.)


	%current_sample = @pagesmpl

	!n_models = @wcount(%models_list)
	!maxcol = !n_models+1

	' Crear tabla
	table (16, !n_models+1) {%table}


	{%table}.title Model Comparison

	'Fijar encabezados de fila
	{%table}(1,2) = "Model Comparison"
	{%table}(5,2) = "In-sample goodnes-of-fit"
	{%table}(6,1) = "R2"
	{%table}(7,1) = "Adjusted R2"
	{%table}(9,1) = "AIC"
	{%table}(10,1) = "BIC"
	{%table}(11,1) = "HQ"
	{%table}(13, 2) = "Out-of-sample Forecast Evaluation"
	{%table}(14,1) = "RMSFE"
	{%table}(15,1) = "MAFE"
	{%table}(16,1) = "MAPFE"
	
	smpl %oo_smpl
	
	' Iterar por columna, agregar métricas
	for !i=1 to !n_models
			%model = @word(%models_list, !i)
	
			{%table}(2,!i+1) = %model
			{%table}(3,!i+1) = {%model}.@displayname
			{%table}(6,!i+1) ={%model}.@R2
			{%table}(7,!i+1) ={%model}.@Rbar2
			{%table}(9,!i+1) ={%model}.@AIC
			{%table}(10,!i+1) ={%model}.@Schwarz
			{%table}(11,!i+1) ={%model}.@HQ
	
			{%model}.forecast _testyf
			%endog = @word({%model}.@varlist, 1)
			{%table}(14, !i+1) =@rmse({%endog}, _testyf)
			{%table}(15, !i+1) =@mae({%endog}, _testyf)
			{%table}(16, !i+1) =@mape({%endog}, _testyf)
			
		next

	'Embellecer con lineas horizontales 
	'Simples
	{%table}.setlines(R5C2:R5C{!maxcol}) +b
	{%table}.setlines(R13C2:R13C{!maxcol}) +b
	'Dobles
	{%table}.setlines(R4C1:R4C{!maxcol}) +d
	{%table}.setlines(R17C1:R17C{!maxcol}) +d
	' Tittle cell-merges
	{%table}.setmerge(R1C2:R1C{!maxcol})
	{%table}.setmerge(R5C2:R5C{!maxcol})
	{%table}.setmerge(R13C2:R13C{!maxcol})

	'clean
	delete(noerr) _test*
	smpl  {%current_sample}
endsub




subroutine compare_forecasters(series endog, string %models_list, string %spool)
!n_models = @wcount(%models_list)

for !i=1 to !n_models
	%baseline_model = @word(%models_list, !i)

	for !j = !i+1 to !n_models
	%competing_model = @word(%models_list, !j)

			%title = %baseline_model + "_vs_" + %competing_model


		freeze(_temp_spool) endog.fcasteval(trim=5) {%baseline_model} {%competing_model}
		{%spool}.append(name=%title) _temp_spool
		delete _temp_spool

	next
next

endsub


