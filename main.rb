require './Memoria'
require './Marco'
require './Pagina'
require './Proceso'
require './Manejador'

def timestamp
	Time.now.to_i
end

=begin 
En seguida se declaran los objetos de memoria real y memoria swap, 
el primer parámetro indica el tamaño en bytes y el segundo parámetro indica el tamaño de página en bytes. 
=end

memReal = Memoria.new(64, 8)
memSwap = Memoria.new(80, 8)
bExit = false

so = Manejador.new()

archivo = File.open("datos.txt","r")

while !bExit do

	archivo.each do
		|line|
		arrComando = so.recibComando(line)

		case arrComando[0].upcase 
		when 'P'
			puts "#{arrComando[0]} #{arrComando[1]} #{arrComando[2]}"
			so.cargarProceso(arrComando[1], arrComando[2], memReal, memSwap)
			sleep(1)
			#No se nos olvide quitar ese sleep porque nos inflaría los benchmarks
		when 'A'
			puts "Instruccion A, falta programar accesos, se accesaron los primeros 4 marcos harcoded"
			puts memReal.arrMarcos[0].fueAccesado = 1
			puts memReal.arrMarcos[1].fueAccesado = 1
			puts memReal.arrMarcos[2].fueAccesado = 1
			puts memReal.arrMarcos[3].fueAccesado = 1
		when 'L'
			puts "Instruccion L, falta programar liberacion"
		when 'F'
			puts 'F'
			puts "memReal"
			memReal.arrMarcos.each do
				|item|
				puts "#{item.idProceso} #{item.timestampCarga} #{item.fueAccesado}"
			end


			puts ""
			puts ""


			puts "memSwap"
			memSwap.arrMarcos.each do
				|item|
				puts item.idProceso
			end

			so.listaProcesos.each do
				|item|
				puts "Proceso #{item.id}"
				item.tablaPaginas.each do
					|item2|
					puts item2.marcoReal
					puts item2.marcoSwap
				end
			end
		when 'E'
			puts 'E'
			bExit=true
		else
			puts "Instruccion invalida #{arrComando[1]}"
		end
	end
end