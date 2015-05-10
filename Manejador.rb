require './Proceso'
require './Marco'
require './Pagina'

class Manejador
	def initialize()
		@listaProcesos = Array.new()
		@procesosBloqueados = Array.new()
	end

	#Metodos get
	def listaProcesos
		@listaProcesos
	end

	def timestamp
		Time.now.to_i
	end

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

	def cargarProceso(cantBytes, idProceso, memReal, memSwap)
		procesoExiste = false;

		@listaProcesos.each do
			|proceso|
			if proceso.id == idProceso
				procesoExiste = true
			end
		end

		if procesoExiste
=begin
			puts "Proceso #{idProceso} pide #{Integer(cantBytes).fdiv(memReal.tamPagina).ceil} marcos mas."
			procesoTemp = self.getProceso(idProceso)
			procesoTemp.desplegarProceso
			procesoTemp.cantBytes = procesoTemp.cantBytes + Integer(cantBytes)
			procesoTemp.cantPaginas = procesoTemp.cantBytes.fdiv(memReal.tamPagina).ceil
			procesoTemp.desplegarProceso
			puts procesoTemp.marcosRealAsig
			self.asignarMarcos(procesoTemp, memReal, memSwap)
=end
			puts "Error al cargar proceso #{idProceso}. Ya esta cargado en memoria."
		else
			procesoTemp = Proceso.new(idProceso, cantBytes, memReal.tamPagina)
			@listaProcesos.push(procesoTemp)
			self.asignarMarcos(@listaProcesos[-1], memReal, memSwap)
		end
	end
	
	def accederProceso(direccion, idProceso, bitReferencia, memReal, memSwap)
		procesoExiste = false
		numMarco = 0
		@listaProcesos.each do
			|proceso|
			if proceso.id == idProceso
				procesoExiste = true
				proceso.tablaPaginas.each do
					|item2|
					if numMarco == Integer(direccion).fdiv(memReal.tamPagina).floor && item2.marcoReal >= 0
					puts "La instruccion se encuentra cargada en marco real #{item2.marcoReal}, se ha accesado"
					memReal.arrMarcos[numMarco].fueAccesado = 1
					end
					if numMarco == Integer(direccion).fdiv(memReal.tamPagina).floor && item2.marcoSwap >= 0
					puts "La instruccion se encuentra cargado en marco swap #{item2.marcoSwap}, no se ha accesado"
					puts "Proceso #{idProceso} genera page fault."
					procesoTemp = self.getProceso(idProceso)
					procesoTemp.desplegarProceso
					puts procesoTemp.marcosRealAsig
					self.asignarMarcoPag(procesoTemp, memReal, memSwap, Integer(direccion).fdiv(memReal.tamPagina).floor)
					end
					numMarco = numMarco + 1
				end
			end
		end
		
		if !procesoExiste
			puts "El proceso #{idProceso} esta mal definido o no existe"
		end
	end

	def asignarMarcos(proceso, memReal, memSwap)
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
				self.asignarMarcos(proceso, memReal, memSwap)
			end
		end
	end

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
					memSwap.ocupMarcos = memSwap.ocupMarcos - 1
					puts "Se swappeo pagina #{indicePaginaVieja} de proceso #{procesoViejo.id}"
					puts "Quedo en marco de swap #{marcoSwap}"
					return true
				end
			end
		else
			puts "No queda memoria en swap, bloqueando proceso #{proceso.id}"
			@procesosBloqueados.push(proceso)
			return false
		end
	end

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

	def getProceso(id)
		i = 0
		@listaProcesos.size.times do
			if @listaProcesos[i].id == id
				return @listaProcesos[i]
			end
			i = i+1
		end
	end

	def liberarProceso(idProceso, memReal, memSwap)
		procesoExiste = false
		@listaProcesos.each do
			|proceso|
			if proceso.id == idProceso
				procesoExiste = true
				proceso.tablaPaginas.each do
					|item2|
					if item2.marcoReal >= 0
					puts "La instruccion se encuentra cargada en marco real #{item2.marcoReal}, se ha accesado"
					memReal.arrMarcos[item2.marcoReal].fueAccesado = 0
					memReal.arrMarcos[item2.marcoReal].idProceso = -1
					memReal.dispMarcos = memReal.dispMarcos + 1
					memReal.ocupMarcos = memReal.ocupMarcos - 1
					end
					if item2.marcoSwap >= 0
					puts "La instruccion se encuentra cargado en marco swap #{item2.marcoSwap}, no se ha accesado"
					memSwap.arrMarcos[item2.marcoReal].fueAccesado = 0
					memSwap.arrMarcos[item2.marcoReal].idProceso = -1
					memSwap.dispMarcos = memSwap.dispMarcos + 1
					memSwap.ocupMarcos = memSwap.ocupMarcos - 1
					end
				end
			end
		end

		if procesoExiste
			puts "Se ha liberado toda la memoria ocupada por el proceso #{idProceso}"
		end
		
		if !procesoExiste
			puts "El proceso #{idProceso} esta mal definido o no existe"
		end
	end

end
