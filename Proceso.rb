class Proceso
	def initialize(id, cantBytes, tamMarcos)
		@id = id
		@cantBytes = Integer(cantBytes)

		if @cantBytes <= 0
			@cantBytes = 1
		end

		@cantPaginas = @cantBytes/Integer(tamMarcos)

		if @cantPaginas < 0
			@cantPaginas = 1
		end

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

	#Metodos set
	def cantBytes=(cantBytes)
		@cantBytes = cantBytes
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
end
