=begin
	Equipo 4.3
	Alberto Harden Cooper a00811931
	José Elí Santiago Rodríguez a07025007
	Osmar Alan Hernandez Sanchez a01244070
=end

#Clase Memoria: La clase Memoria.rb se encarga de ser una coleccion de marcos donde
#los procesos pueden cargar sus paginas.

require './Marco'

class Memoria
	#Constructor
	#Recibe: El tamanio de la memoria en bytes y el tamanio de las paginas.
	#Para este proyecto las paginas y los marcos miden 8 bytes.
	def initialize(cantBytes, tamPagina)
		@cantBytes = Integer(cantBytes)
		@tamPagina = Integer(tamPagina)

		#Validaciones para que no haya tamanios
		#de memoria y paginas 0.
		if @cantBytes <= 0
			@cantBytes = 1
		end

		if @tamPagina <= 0
			@tamPagina = 1
		end

		#Se calcula la cantidad de marcos de la memoria
		#dividiendo su tamanio entre el tamanio de pagina.
		@cantMarcos = @cantBytes/@tamPagina

		#Validacion para que no haya 0 marcos.
		if @cantMarcos <= 0
			@cantMarcos = 1
		end

		#Se crea un arreglo que contiene los marcos de memoria.
		#Inicialmente todos estan disponibles y esto se indica con
		#un valor de -1 en los atributos del marco.
		@arrMarcos = Array.new(@cantMarcos)
		#Se itera una cantidad de veces igual a la cantidad de marcos.
		@cantMarcos.times do
			|i|
			#Se crea un nuevo marco que se pondra en el arreglo de marcos.
			marcoTemp = Marco.new(-1, -1, -1)
			#Se pone el marco vacio en memoria.
			@arrMarcos[i] = marcoTemp
		end
		#Se calcula la cantidad de marcos disponibles usando el tamanio del arreglo
		#de marcos.
		@dispMarcos = @arrMarcos.size
		#Inicialmente hay 0 marcos ocupados.
		@ocupMarcos = 0
	end

	#Metodos para obtener los atributos de la memoria.
	def cantBytes
		@cantBytes
	end

	def tamPagina
		@tamPagina
	end

	def cantMarcos
		@cantMarcos
	end

	def arrMarcos
		@arrMarcos
	end

	def dispMarcos
		@dispMarcos
	end

	def ocupMarcos
		@ocupMarcos
	end

	#Metodo para obetener el indiec del marco mas viejo cargado en memoria.
	def indiceMarcoViejo
		#Se carga el timestamp del primer marco.
		timestampTemp = @arrMarcos[0].timestampCarga
		#Se crean 2 contadores, uno para accesar cada elemento de arrMarcos y
		#otro para indicar cual es el indice mayor.
		i=0
		iMayor=0
		#Se itera una cantidad de veces igual a la cantidad de marcos.
		@arrMarcos.size.times do
			#Se obtiene el timestamp del marco actual.
			timestampMarcoActual = @arrMarcos[i].timestampCarga
			#Se hace la comparacion de timestamps.
			if timestampMarcoActual < timestampTemp && @arrMarcos[i].idProceso != -1
				#Si es mayor, se acutaliza timestampTemp y el indice del marco mas viejo.
				iMayor = i
				timestampTemp = @arrMarcos[i].timestampCarga
			end
			#Se pasa al siguiente marco.
			i = i+1
		end
		#Se regresa el indice del marco mayor.
		return iMayor
	end

	#Metodos para esteblecer marcos disponibles y ocupados.
	def dispMarcos=(dispMarcos)
		@dispMarcos = dispMarcos
	end

	def ocupMarcos=(ocupMarcos)
		@ocupMarcos = ocupMarcos
	end
end
