# Clase Manejador: Es el constructor del proyecto

=begin 
	Equipo 4.3
	Alberto Harden Cooper a00811931
	José Elí Santiago Rodríguez a07025007
	Osmar Alan Hernandez Sanchez a01244070
=end

require './Proceso'
require './Marco'
require './Pagina'

class Manejador
	def initialize()
		@listaProcesos = Array.new()
		@procesosBloqueados = Array.new()
	end

	# Metodos get
	def listaProcesos
		@listaProcesos
	end

	def timestamp
		Time.now.to_i
	end

	# Instrucciones a ejecutar dependiendo del comando ingresado en datos.txt
	# Comando P: Cargar un Proceso	;	Comando A: Accesar a un Proceso	;
	# Comando L: Libera las Paginas del Proceso	;	Comando F: Fin	;	Comando E: Exit	;
	def recibComando(comando)
		arrComando = comando.split()
		arrTemp = Array.new()
		if arrComando[0].upcase == 'P'  # Existe
			arrTemp.push(arrComando[0], arrComando[1], arrComando[2])
			return arrTemp
		elsif arrComando[0].upcase == 'A' # Existe
			# MODIFICADO
			arrTemp.push(arrComando[0], arrComando[1], arrComando[2], arrComando[3])
			return arrTemp
			#puts "Instr A"
		elsif arrComando[0].upcase == 'L' # Liberar - No Existe
			arrTemp.push(arrComando[0], arrComando[1])
			return arrTemp
		elsif arrComando[0].upcase == 'F' # Fin - No Existe
			arrTemp.push(arrComando[0])
			return arrTemp
		elsif arrComando[0].upcase == 'E' # Exit - No Existe
			arrTemp.push(arrComando[0])
			return arrTemp
		else
			return arrTemp.push(nil, arrComando[0])
		end
	end

	# Metodo para Cargar un Proceso con los parametros necesarios
	# Verifica la existencia del Proceso para poder crearlo
	def cargarProceso(cantBytes, idProceso, memReal, memSwap)
		procesoExiste = false;

		@listaProcesos.each do
			|proceso|
			if proceso.id == idProceso
				procesoExiste = true
			end
		end

		if procesoExiste
			puts "Error al cargar proceso #{idProceso}. Ya esta cargado en memoria."
		else
			if Integer(cantBytes) <= memReal.cantBytes
				procesoTemp = Proceso.new(idProceso, cantBytes, memReal.tamPagina)
				@listaProcesos.push(procesoTemp)
				self.asignarMarcos(@listaProcesos[-1], memReal, memSwap)
			else 
				puts "El proceso no puede ser cargado, excede el tamaño de memoria real"
			end
		end
	end

	# Metodo para Acceder a un Proceso con los parametros necesarios
	# Se cambia del bit de referencia del Proceso cada vez que se accede a el
	def accederProceso(direccion, idProceso, bitReferencia, memReal, memSwap)
		procesoExiste = false
		numMarco = 0
		@listaProcesos.each do
			|proceso|
			if proceso.id == idProceso
				procesoExiste = true
				if proceso.cantBytes >= Integer(direccion)
					proceso.tablaPaginas.each do
						|item2|
						if numMarco == Integer(direccion).fdiv(memReal.tamPagina).floor && item2.marcoReal >= 0
						puts "La instruccion se encuentra cargada en marco real #{item2.marcoReal}, se ha accesado"
						memReal.arrMarcos[numMarco].fueAccesado = 1
						end
						if numMarco == Integer(direccion).fdiv(memReal.tamPagina).floor && item2.marcoSwap >= 0
						puts "La instruccion se encuentra cargada en marco swap #{item2.marcoSwap}, se ha cargado en memoria real y accesado"
						puts "Proceso #{idProceso} genera page fault."
						proceso.faultsCausados = proceso.faultsCausados + 1
						procesoTemp = self.getProceso(idProceso)
						procesoTemp.desplegarProceso
						puts procesoTemp.marcosRealAsig
						self.asignarMarcoPag(procesoTemp, memReal, memSwap, Integer(direccion).fdiv(memReal.tamPagina).floor)
						memReal.arrMarcos[numMarco].fueAccesado = 1
						end
						numMarco = numMarco + 1
					end
				else
				puts "La direccion referenciada no es valida para el proceso #{idProceso}"
				end
			end
		end

		if !procesoExiste
			puts "El proceso #{idProceso} esta mal definido o no existe"
		end
	end

	# Metodo para asignar un Marco a un Proceso
	def asignarMarcos(proceso, memReal, memSwap)
		puts "Asignando marcos para proceso #{proceso.id}"
		puts "Marcos Disponibles: #{memReal.dispMarcos}"
		cantPideMarcos = proceso.cantPaginas-proceso.marcosRealAsig
		puts "Marcos Solicitados: #{cantPideMarcos}"
		if cantPideMarcos <= memReal.dispMarcos
			puts "Marcos Actuales: "
			marcoRealActual = 0
			while proceso.marcosRealAsig < proceso.cantPaginas && marcoRealActual < memReal.arrMarcos.size do
				puts marcoRealActual
				if memReal.arrMarcos[marcoRealActual].idProceso == -1
					paginaTemp = Pagina.new(marcoRealActual)
					marcoTemp = Marco.new(proceso.id, 0, self.timestamp())
					memReal.arrMarcos[marcoRealActual] = marcoTemp
					proceso.tablaPaginas.push(paginaTemp)
					memReal.dispMarcos = memReal.dispMarcos - 1
					memReal.ocupMarcos = memReal.ocupMarcos + 1
					proceso.marcosRealAsig = proceso.marcosRealAsig + 1
					puts "Se alojo marco real #{marcoRealActual} para pagina #{proceso.marcosRealAsig-1}"
				end
				marcoRealActual = marcoRealActual + 1
			end
			puts""
		else
			puts "F2C"
			marcosNecesitados = cantPideMarcos
			if self.mandarSwap(proceso, memReal, memSwap, marcosNecesitados)
				self.asignarMarcos(proceso, memReal, memSwap)
			end
		end
	end
	
	# "Falta Comentar"
	def asignarMarcoPag(proceso, memReal, memSwap, pagina)
		puts "Marcos Disponibles: #{memReal.dispMarcos}"
		cantPideMarcos = 1
		puts "Marcos Solicitados: #{cantPideMarcos}"
		if cantPideMarcos <= memReal.dispMarcos
			puts "Marcos Actuales: "
			marcoRealActual = 0
			while proceso.marcosRealAsig < proceso.cantPaginas && marcoRealActual < memReal.arrMarcos.size do
				puts marcoRealActual
				if memReal.arrMarcos[marcoRealActual].idProceso == -1
					paginaTemp = Pagina.new(marcoRealActual)
					marcoTemp = Marco.new(proceso.id, 0, self.timestamp())
					memReal.arrMarcos[marcoRealActual] = marcoTemp
					proceso.tablaPaginas.push(paginaTemp)
					memReal.dispMarcos = memReal.dispMarcos - 1
					memReal.ocupMarcos = memReal.ocupMarcos + 1
					proceso.marcosRealAsig = proceso.marcosRealAsig + 1
					puts "Se alojo marco real #{marcoRealActual} para pagina #{proceso.marcosRealAsig-1}"
				end
				marcoRealActual = marcoRealActual + 1
			end
			puts""
		else
			puts "F2C"
			marcosNecesitados = cantPideMarcos
			if self.mandarSwap(proceso, memReal, memSwap, marcosNecesitados)
				self.asignarMarcoPag(proceso, memReal, memSwap, pagina)
			end
		end
	end

	def asignarMarcoPag(proceso, memReal, memSwap, pagina)
		puts "Marcos Disponibles: #{memReal.dispMarcos}"
		cantPideMarcos = 1
		puts "Marcos Solicitados: #{cantPideMarcos}"
		if cantPideMarcos <= memReal.dispMarcos
			puts "Marcos Actuales: "
			marcoRealActual = 0
			while proceso.marcosRealAsig < proceso.cantPaginas && marcoRealActual < memReal.arrMarcos.size do
				puts marcoRealActual
				if memReal.arrMarcos[marcoRealActual].idProceso == -1
					paginaTemp = Pagina.new(marcoRealActual)
					marcoTemp = Marco.new(proceso.id, 0, self.timestamp())
					memReal.arrMarcos[marcoRealActual] = marcoTemp
					proceso.tablaPaginas.push(paginaTemp)
					memReal.dispMarcos = memReal.dispMarcos - 1
					memReal.ocupMarcos = memReal.ocupMarcos + 1
					proceso.marcosRealAsig = proceso.marcosRealAsig + 1
					puts "Se alojo marco real #{marcoRealActual} para pagina #{Integer(pagina)}"
				end
				marcoRealActual = marcoRealActual + 1
			end
			puts""
		else
			puts "F2C"
			marcosNecesitados = cantPideMarcos
			if self.mandarSwap(proceso, memReal, memSwap, marcosNecesitados)
				self.asignarMarcoPag(proceso, memReal, memSwap, pagina)
			end
		end
	end

	#El metodo mandarSwap solo sirve sacar marcos de memoria
	#real a swap cuando se quiere cargar un proceso a memoria
	#Se necesitan un nuevo metodo similar a ponerMarco que lo que hace es
	#sacar un solo marco de swap y ponerlo en memoria real
	def mandarSwap(proceso, memReal, memSwap, marcosNecesitados)
		puts "Se necesita realizar swapping para proceso #{proceso.id}"
		if memSwap.dispMarcos >= marcosNecesitados
			while marcosNecesitados > memReal.dispMarcos do
				iViejo = memReal.indiceMarcoViejo
				idProcesoViejo = memReal.arrMarcos[iViejo].idProceso
				puts "fueAccesado p=#{idProcesoViejo} m=#{iViejo} a=#{memReal.arrMarcos[iViejo].fueAccesado}"
				if memReal.arrMarcos[iViejo].fueAccesado == 1 && memReal.arrMarcos[iViejo].idProceso != -1
					puts "2nd chance"
					memReal.arrMarcos[iViejo].fueAccesado = 0
					memReal.arrMarcos[iViejo].timestampCarga = self.timestamp
				elsif memReal.arrMarcos[iViejo].fueAccesado == 0 && memReal.arrMarcos[iViejo].idProceso != -1
					puts "swap"
					procesoViejo = self.getProceso(idProcesoViejo)
					procesoViejo.marcosRealAsig = procesoViejo.marcosRealAsig - 1
					procesoViejo.marcosSwapAsig = procesoViejo.marcosSwapAsig + 1
					marcoTemp = Marco.new(procesoViejo.id, 0, self.timestamp)
					marcoSwap = self.ponerMarco(marcoTemp, memSwap)
					indicePaginaVieja = 0
					paginaActualizar = procesoViejo.indicePagina(iViejo, indicePaginaVieja)
					paginaActualizar.marcoReal = -1
					paginaActualizar.marcoSwap = marcoSwap
					paginaActualizar.cargada = 0
					paginaActualizar.cargada = -1
					memReal.arrMarcos[iViejo].idProceso = -1
					memReal.arrMarcos[iViejo].fueAccesado = 0
					memReal.arrMarcos[iViejo].timestampCarga = self.timestamp
					memReal.dispMarcos = memReal.dispMarcos + 1
					memReal.ocupMarcos = memReal.ocupMarcos - 1
					memSwap.dispMarcos = memSwap.dispMarcos - 1
					memSwap.ocupMarcos = memSwap.ocupMarcos + 1 #como es que estaba funcionando entonces?
					puts "Se swappeo pagina #{indicePaginaVieja} de proceso #{procesoViejo.id}"
					puts "Quedo en marco de swap #{marcoSwap}"
					return true
				end
				if memReal.arrMarcos[iViejo].idProceso == -1
					memReal.dispMarcos = memReal.dispMarcos + 1
					memReal.ocupMarcos = memReal.ocupMarcos - 1
					return true
				end
			end
		else
			puts "No queda memoria en swap, bloqueando proceso #{proceso.id}"
			@procesosBloqueados.push(proceso)
			return false
		end
	end

	# "FALTA COMENTAR"
	def ponerMarco(marco, memoria)
		i=0
		memoria.arrMarcos.size.times do
			if memoria.arrMarcos[i].idProceso == -1
				memoria.arrMarcos[i] = marco
				return i
			end
			i = i+1
		end
	end

	# "FALTA COMENTAR"
	def getProceso(id)
		i = 0
		@listaProcesos.size.times do
			if @listaProcesos[i].id == id
				return @listaProcesos[i]
			end
			i = i+1
		end
	end

	# "FALTA COMENTAR"
	def liberarProceso(idProceso, memReal, memSwap)
		procesoExiste = false
		@listaProcesos.each do
			|proceso|
			if proceso.id == idProceso
				procesoExiste = true
				proceso.tablaPaginas.each do
					|item2|
					#Liberar paginas del proceso de memoria real
					if item2.marcoReal >= 0
					puts "La pagina en marco real #{item2.marcoReal} de proceso #{idProceso} fue liberada"
					memReal.arrMarcos[item2.marcoReal].timestampCarga = -1
					#Voy a poner que cuando se libere un marco fueAccesado sea -1 para que se parezca a un estado inicial
					#Si no funciona volver a poner valor de 0 en la linea de abajo
					memReal.arrMarcos[item2.marcoReal].fueAccesado = -1
					memReal.arrMarcos[item2.marcoReal].idProceso = -1
					memReal.dispMarcos = memReal.dispMarcos + 1
					memReal.ocupMarcos = memReal.ocupMarcos - 1
					end
					#Liberar paginas del proceso de memoria swap
					if item2.marcoSwap >= 0
					puts "La pagina en marco swap #{item2.marcoSwap} fue liberada"
					memSwap.arrMarcos[item2.marcoReal].fueAccesado = 0
					memSwap.arrMarcos[item2.marcoReal].idProceso = -1
					memSwap.dispMarcos = memSwap.dispMarcos + 1
					memSwap.ocupMarcos = memSwap.ocupMarcos - 1
					end
				end
			end
		end

		if procesoExiste
			counter = 0
			@listaProcesos.each do
				|proceso|
				if proceso.id == idProceso
					@listaProcesos.delete_at(counter)
				end
				counter = counter + 1
			end
			puts "Se ha liberado toda la memoria ocupada por el proceso #{idProceso}"
		end

		if !procesoExiste
			puts "El proceso #{idProceso} esta mal definido o no existe"
		end
	end

	# Muestra el estado actual del Sistema tanto la Memoria Real y la Memoria Swap
	def mostrarSistema(memReal, memSwap)
		puts "Memoria Real"
		memReal.arrMarcos.each do
			|item|
			puts " #{item.idProceso}  #{item.timestampCarga}   #{item.fueAccesado}"
		end

		puts ""

		puts "Memoria Swap"
		memSwap.arrMarcos.each do
			|item|
			puts item.idProceso
		end

		puts ""

		puts "Lista de Procesos"
		@listaProcesos.each do
			|item|
			puts "Proceso #{item.id}"
			puts "marcoReal marcoSwap"
			item.tablaPaginas.each do
				|item2|
				puts "#{item2.marcoReal} 		#{item2.marcoSwap}"
			end
		end
	end

	# "FALTA COMENTAR"
	def reiniciarSistema(memReal, memSwap)
		puts "Reiniciando sistema"
		@listaProcesos.each do
			|proceso|
			idProcesoTemp = proceso.id
			self.liberarProceso(idProcesoTemp, memReal, memSwap)
		end
	end
end
