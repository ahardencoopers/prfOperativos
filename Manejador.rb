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
			if arrComando[0] == "p" || arrComando[0] == "P"
				arrTemp.push(arrComando[0], arrComando[1], arrComando[2])
				return arrTemp
			elsif arrComando[0] == "a" || arrComando[0] == "A"
				puts "Instr A"
			elsif arrComando[0] == "l" || arrComando[0] == "L"
				puts "Instr L"
			elsif arrComando[0] == "f" || arrComando[0] == "F"
				puts "Instr F"
			elsif arrComando[0] == "e" || arrComando[0] == "E"
				puts "Instr E"
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
			puts "Proceso #{idProceso} pide #{Integer(cantBytes)/8} marcos mas."
			procesoTemp = self.getProceso(idProceso)
			procesoTemp.desplegarProceso
			procesoTemp.cantBytes = procesoTemp.cantBytes + Integer(cantBytes)
			procesoTemp.cantPaginas = procesoTemp.cantBytes/8
			procesoTemp.desplegarProceso
			puts procesoTemp.marcosRealAsig
			self.asignarMarcos(procesoTemp, memReal, memSwap)
		else
			procesoTemp = Proceso.new(idProceso, cantBytes, 8)
			@listaProcesos.push(procesoTemp)
			self.asignarMarcos(@listaProcesos[-1], memReal, memSwap)
		end
	end

	def asignarMarcos(proceso, memReal, memSwap)
		puts "dispMarcos #{memReal.dispMarcos}"
		cantPideMarcos = proceso.cantPaginas-proceso.marcosRealAsig
		puts "cantPideMarcos #{cantPideMarcos}"
		if cantPideMarcos <= memReal.dispMarcos
			puts "Alojar marcos para proceso #{proceso.id}"
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

end
