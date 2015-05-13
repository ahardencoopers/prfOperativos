=begin 
	Equipo 4.3
	Alberto Harden Cooper a00811931
	José Elí Santiago Rodríguez a07025007
	Osmar Alan Hernandez Sanchez a01244070
=end

class Proceso
	def initialize(id, cantBytes, tamMarcos)
		@id = id
		@cantBytes = Integer(cantBytes)

		if @cantBytes <= 0
			@cantBytes = 1
		end

		@cantPaginas = @cantBytes.fdiv(Integer(tamMarcos)).ceil

		@tablaPaginas = Array.new()

		@marcosRealAsig = 0
		@marcosSwapAsig = 0
		@faultsCausados = 0

	end

	#Metodos get
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

	def indicePagina(indiceMarcoReal, indiceTablaPaginas)
		i=0
		@tablaPaginas.size.times do
			if @tablaPaginas[i].marcoReal == indiceMarcoReal
				indiceTablaPaginas = i
				return @tablaPaginas[i]
			end
			i = i+1
		end
	end

	#Metodos set
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

	def desplegarProceso
		puts "id=#{@id} cB=#{@cantBytes} cP=#{@cantPaginas}"
		puts "mR=#{@marcosRealAsig} mS=#{@marcosSwapAsig}"
	end
end
