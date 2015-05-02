class TablaPaginas
	def initialize(cantPaginas)
		@cantPaginas = Integer(cantPaginas)
		@arrPaginas = Array.new(cantPaginas)
	end

	#Metodos get
	def cantPaginas
		@cantPaginas
	end

	def arrPaginas
		@arrPaginas
	end

	#Metodos set
	def cantPaginas=(cantPaginas)
		@cantPaginas = cantPaginas
	end
end
