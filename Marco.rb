=begin 
	Equipo 4.3
	Alberto Harden Cooper a00811931
	José Elí Santiago Rodríguez a07025007
	Osmar Alan Hernandez Sanchez a01244070
=end

# Marco de 8 bytes (Total de 256 marcos para este proyecto)

class Marco
	def initialize(idProceso, fueAccesado, timestampCarga)
		@idProceso = idProceso
		@fueAccesado = Integer(fueAccesado)
		@timestampCarga = Integer(timestampCarga)
	end

	if @fueAccesado == 0
		@fueAccesado = nil
	end

	#Metodos get
	def idProceso
		@idProceso
	end

	def fueAccesado
		@fueAccesado
	end

	def timestampCarga
		@timestampCarga
	end

	#Metodos set
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