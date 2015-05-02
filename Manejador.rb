require './Proceso'
require './Marco'
require './Pagina'

class Manejador
	def initialize()
		@listaProcesos = Array.new()
	end

	#Metodos get
	def listaProcesos
		@listaProcesos
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
			puts "Error al cargar proceso. Ya existe."
		else
			procesoTemp = Proceso.new(idProceso, cantBytes, 8)
			@listaProcesos.push(procesoTemp)
			self.asignarMarcos(@listaProcesos[-1], memReal, memSwap)
		end
	end

	def asignarMarcos(proceso, memReal, memSwap)
		if proceso.cantPaginas <= memReal.dispMarcos
			puts "Alojar marcos"
			marcoRealActual = 0
			while proceso.marcosRealAsig < proceso.cantPaginas do
				if memReal.arrMarcos[marcoRealActual].idProceso == -1
					paginaTemp = Pagina.new(marcoRealActual)
					marcoTemp = Marco.new(proceso.id, 0, 0)
					memReal.arrMarcos[marcoRealActual] = marcoTemp
					proceso.tablaPaginas.push(paginaTemp)
					memReal.dispMarcos = memReal.dispMarcos - 1
					memReal.ocupMarcos = memReal.ocupMarcos + 1
					proceso.marcosRealAsig = proceso.marcosRealAsig + 1
				end
				marcoRealActual = marcoRealActual + 1
			end
		else
			puts "F2C"
		end
	end

end
