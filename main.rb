# Clase main a ejecutar

=begin 
	Equipo 4.3
	Alberto Harden Cooper a00811931
	José Elí Santiago Rodríguez a07025007
	Osmar Alan Hernandez Sanchez a01244070
=end

require './Memoria'
require './Marco'
require './Pagina'
require './Proceso'
require './Manejador'

def timestamp
	Time.now.to_i
end

# Se crean la Memoria Real y Memoria Swapp
# Memoria Real: Memoria en la que se encontraran los procesos
# Memoria Swapp: Memoria de reserva para los procesos
memReal = Memoria.new(64, 8)
memSwap = Memoria.new(80, 8)
bExit = false

so = Manejador.new()

# Documneto con los procesos
# Desde aqui se podran hacer las solicitude de memoria
archivo = File.open("datos.txt","r")


while !bExit do
	# Acciones de los comanos ingresadoes en el Documento datos.txt
	archivo.each do
		|line|
		arrComando = so.recibComando(line)

		# La funcionalidad de cada comando se encuentra en la clase Manejador
		case arrComando[0].upcase
		when 'P'
			puts "#{arrComando[0].upcase} #{arrComando[1]} #{arrComando[2]}"
			so.cargarProceso(arrComando[1], arrComando[2], memReal, memSwap)
			sleep(1)
			#No se nos olvide quitar ese sleep porque nos inflaría los benchmarks
		when 'A'
			puts ""
			puts "#{arrComando[0].upcase} #{arrComando[1]} #{arrComando[2]} #{arrComando[3]}"
			so.accederProceso(arrComando[1], arrComando[2], arrComando[3], memReal, memSwap)
			puts ""
		when 'L'
			puts ""
			puts "#{arrComando[0].upcase} #{arrComando[1]}"
			puts "Liberando proceso #{arrComando[1]}"
			so.liberarProceso(arrComando[1], memReal, memSwap)
			puts ""
		when 'F'
			puts 'F'
			puts ""
			so.reiniciarSistema(memReal, memSwap)
			so.mostrarSistema(memReal, memSwap)
		when 'E'
			puts 'E'
			bExit=true
		else
			puts "Instruccion invalida #{arrComando[1]}"
		end
	end
end
