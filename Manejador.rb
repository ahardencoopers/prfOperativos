require './ListaProcesos'

class Manejador
	def initialize()
		@listaProcesos = ListaProcesos.new()
	end

	#Metodos get
	def listaProcesos
		@listaProcesos
	end

	def recibComando(comando)
			arrComando = comando.split()
			if arrComando[0] == "p" || arrComando[0] == "P"
				arrTemp = Array.new()
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
				puts comando << " No es una instruccion valida."
			end

	end

	def cargarProceso(cantBytes, idProceso)
			if @listaProcesos.listaProcesos.include?(idProceso)
				puts "Error al cargar proceso. El proceso ya esta cargado."
				return false;
			end

			@listaProcesos.listaProcesos.push(idProceso)
	end
end
