require './Memoria'
require './Marco'
require './Pagina'
require './Proceso'
require './Manejador'

def timestamp
	Time.now.to_i
end

memReal = Memoria.new(64, 8)
memSwap = Memoria.new(80, 8)
so = Manejador.new()

archivo = File.open("datos.txt","r")

archivo.each do
	|line|
	arrComando = so.recibComando(line)

	if arrComando[0] == 'p' || arrComando[0] == 'P'
		puts "#{arrComando[0]} #{arrComando[1]} #{arrComando[2]}"
		so.cargarProceso(arrComando[1], arrComando[2], memReal, memSwap)
		sleep(1)
	elsif arrComando[0] == nil
		puts "Instruccion invalida #{arrComando[1]}"
	end
end

puts memReal.arrMarcos[0].fueAccesado = 1
puts memReal.arrMarcos[1].fueAccesado = 1
puts memReal.arrMarcos[2].fueAccesado = 1
puts memReal.arrMarcos[3].fueAccesado = 1

archivo = File.open("datos2.txt", "r")

archivo.each do
	|line|
	arrComando = so.recibComando(line)

	if arrComando[0] == 'p' || arrComando[0] == 'P'
		puts "#{arrComando[0]} #{arrComando[1]} #{arrComando[2]}"
		so.cargarProceso(arrComando[1], arrComando[2], memReal, memSwap)
		sleep(1)
	elsif arrComando[0] == nil
		puts "Instruccion invalida #{arrComando[1]}"
	end
end

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
