=begin
	Equipo 4.3
	Alberto Harden Cooper a00811931
	José Elí Santiago Rodríguez a07025007
	Osmar Alan Hernandez Sanchez a01244070
=end

#Clase Proceso: Los procesos se encargan de solicitar memoria a objetos de clase Manejador.rb, la memoria que piden se indica
#como paginas dentro del proceso y marcos en memoria real.

class Proceso
	#Constructor
	#Recibe el id del proceso, el tamnio del proceso en bytes
	#y el tamanio de marcos que utiliza el proceso en bytes.
	#Para este proyecto el tamanio de los marcos que utiliza el proceso
	#son de 8 bytes.
	def initialize(id, cantBytes, tamMarcos)
		@id = id
		@cantBytes = Integer(cantBytes)

		#Validacion para que no haya proceso con tamanio 0.
		if @cantBytes <= 0
			@cantBytes = 1
		end

		#Se obtiene la cantidad de paginas que tiene le proceso
		#dividiendo su tamanio en bytes entre el tamanio de marcos que utiliza.
		@cantPaginas = @cantBytes.fdiv(Integer(tamMarcos)).ceil

		#Se crea una nueva tabla de paginas del proceso.
		@tablaPaginas = Array.new()

		@marcosRealAsig = 0
		@marcosSwapAsig = 0
		@faultsCausados = 0
		@timestampLlegada = self.timestamp

	end

	#Metodo que crea una UNIX timestamp .
	#(Cantidad de segundos desde Enero 1, 1970).
	def timestamp
		Time.now.to_i
	end

	#Metodos para obtener atributos del proceso.
	def id
		@id
	end

	def cantBytes
		@cantBytes
	end

	def cantPaginas
		@cantPaginas
	end

	def tablaPaginas
		@tablaPaginas
	end

	def marcosRealAsig
		@marcosRealAsig
	end

	def marcosSwapAsig
		@marcosSwapAsig
	end

	def faultsCausados
		@faultsCausados
	end

	def timestampLlegada
		@timestampLlegada
	end

	#Metodo para obtener una pagina del proceso sabiendo donde
	#donde esta en memoria real.
	#Recibe el indice donde se encuentra en marco real y un valor por referencia para
	#regresar el indice donde se encuentra la pagina en la tabla de procesos.
	def indicePagina(indiceMarcoReal, indiceTablaPaginas)
		i=0
		#Se itera una cantidad de veces igual al tamanio de la tabla de paginas.
		@tablaPaginas.size.times do
			#Se busca la pagina coincidiendo indices de marcos reales de memoria.
			if @tablaPaginas[i].marcoReal == indiceMarcoReal
				#Cuando se encuentra la pagina se regresa.
				indiceTablaPaginas = Integer(1)
				return @tablaPaginas[i]
			end
			i = i+1
		end
	end

	#Metodos para obtener atributos del proceso.
	def cantBytes=(cantBytes)
		@cantBytes = cantBytes
	end

	def cantPaginas=(cantPaginas)
		@cantPaginas = cantPaginas
	end

	def marcosRealAsig=(marcosRealAsig)
		@marcosRealAsig = marcosRealAsig
	end

	def marcosSwapAsig=(marcosSwapAsig)
		@marcosSwapAsig = marcosSwapAsig
	end

	def faultsCausados=(faultsCausados)
		@faultsCausados = faultsCausados
	end

	#Metodo para desplegar informacion del proceso.
	def desplegarProceso
		puts "id=#{@id} cantBytes=#{@cantBytes} cantPaginas=#{@cantPaginas}"
		puts "marcosRealAsig=#{@marcosRealAsig} marcosSwapAsig=#{@marcosSwapAsig}"
	end
end
