require './Memoria'
require './Marco'
require './Pagina'
require './Proceso'
require './Manejador'

def timestamp
	Time.now.to_i
end

memReal = Memoria.new(64, 8)
memSwap = Memoria.new(64, 8)
so = Manejador.new()

archivo = File.open("datos.txt","r")

archivo.each do
	|line|
	arrComando = so.recibComando(line)

	if arrComando[0] == 'p' || arrComando[0] == 'P'
		so.cargarProceso(arrComando[1], arrComando[2], memReal, memSwap)
	elsif arrComando[0] == nil
		puts "Instruccion invalida #{arrComando[1]}"
	end
end
