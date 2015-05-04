require './Marco'

class Memoria
	def initialize(cantBytes, tamPagina)
		@cantBytes = Integer(cantBytes)
		@tamPagina = Integer(tamPagina)

		if @cantBytes <= 0
			@cantBytes = 1
		end

		if @tamPagina <= 0
			@tamPagina = 1
		end

		@cantMarcos = @cantBytes/@tamPagina

		if @cantMarcos <= 0
			@cantMarcos = 1
		end


		@arrMarcos = Array.new(@cantMarcos)
		@cantMarcos.times do
			|i|
			marcoTemp = Marco.new(-1, -1, -1)
			@arrMarcos[i] = marcoTemp
		end
		@dispMarcos = @arrMarcos.size
		@ocupMarcos = 0
	end

	#Metodos get
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

	def indiceMarcoViejo
		timestampTemp = @arrMarcos[0].timestampCarga
		i=0
		iMayor=0
		@arrMarcos.size.times do
			timestampMarcoActual = @arrMarcos[i].timestampCarga
			if timestampMarcoActual < timestampTemp && @arrMarcos[i].idProceso != -1
				iMayor = i
				timestampTemp = @arrMarcos[i].timestampCarga
			end
			i = i+1
		end
		return iMayor
	end

	#Metodos set
	def dispMarcos=(dispMarcos)
		@dispMarcos = dispMarcos
	end

	def ocupMarcos=(ocupMarcos)
		@ocupMarcos = ocupMarcos
	end
end
