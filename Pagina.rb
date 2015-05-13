=begin 
	Equipo 4.3
	Alberto Harden Cooper a00811931
	José Elí Santiago Rodríguez a07025007
	Osmar Alan Hernandez Sanchez a01244070
=end

class Pagina
	def initialize(marcoReal)
		@marcoReal = Integer(marcoReal)
		@marcoSwap = -1
		@cargada = 1
		@modificada = 0
	end

	#Metodos get

	def marcoReal
		@marcoReal
	end

	def marcoSwap
		@marcoSwap
	end

	def cargada
		@cargada
	end

	def modificada
		@modificada
	end

	#Metodos set

	def marcoReal=(marcoReal)
		@marcoReal = Integer(marcoReal)
	end

	def marcoSwap=(marcoSwap)
		@marcoSwap = Integer(marcoSwap)
	end

	def cargada=(cargada)
		@cargada = cargada
	end

	def modificada=(modificada)
		@modificada = modificada
	end
end
