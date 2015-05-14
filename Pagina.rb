=begin
	Equipo 4.3
	Alberto Harden Cooper a00811931
	José Elí Santiago Rodríguez a07025007
	Osmar Alan Hernandez Sanchez a01244070
=end

#Clase Pagina: La clase pagina es utilizada por los objetos de la clase Proceso.rb en su tabla de procesos.

class Pagina
	#Constructor.
	#Recibe el marco real donde quedo la pagina.
	def initialize(marcoReal)
		@marcoReal = Integer(marcoReal)
		@marcoSwap = -1
		#Si indica que la pagina esta cargada en memoria real y no en swap.
		@cargada = 1
		@modificada = 0
	end

	#Metodos para obtener atributos de la pagina.
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

	#Metodos para establecer atributos de la pagina.
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
