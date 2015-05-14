=begin
	Equipo 4.3
	Alberto Harden Cooper a00811931
	José Elí Santiago Rodríguez a07025007
	Osmar Alan Hernandez Sanchez a01244070
=end

#Clase Marco: Los marcos se colocan en objetos de clase Memoria.rb dentro del arreglo arrMarcos.
#Para este proyecto los marcos miden 8 bytes.

class Marco
	#Constructor
	def initialize(idProceso, fueAccesado, timestampCarga)
		@idProceso = idProceso
		@fueAccesado = Integer(fueAccesado)
		@timestampCarga = Integer(timestampCarga)
	end

	if @fueAccesado == 0
		@fueAccesado = nil
	end

	#Metodos para regresar atributos del marco.
	def idProceso
		@idProceso
	end

	def fueAccesado
		@fueAccesado
	end

	def timestampCarga
		@timestampCarga
	end

	#Metodos para establecer valores del marco.
	def idProceso=(idProceso)
		@idProceso = idProceso
	end

	def fueAccesado=(fueAccesado)
		@fueAccesado = fueAccesado
	end

	def timestampCarga=(timestampCarga)
		@timestampCarga = timestampCarga
	end
end
