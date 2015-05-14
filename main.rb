#Clase main a ejecutar.

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

#Metodo para determinar si un objeto es un numero.
def is_numeric?(obj)
	#Expresion regular que hace match con numeros enteros
	#Se utiliza un if ternario para regresar el resultado
	obj.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
end

=begin
En seguida se declaran los objetos de memoria real y memoria swap,
el primer parámetro indica el tamaño en bytes y el segundo parámetro indica el tamaño de página en bytes.
=end

memReal = Memoria.new(2048, 8)
memSwap = Memoria.new(4096, 8)
arrTiempos = Array.new()
bExit = false

#Se crea una nueva instancia de la clase Manejador.rb que actua como el manejador de memoria.
#Tambien se le puede ver como el sistema operativo.
so = Manejador.new()

#Abrir el archivo de texto con solicitudes de memoria de los procesos.
archivo = File.open("datos.txt","r")

while !bExit do
	#Se recorre cada linea del archivo de texto datos.txt.
	archivo.each do
		#Se pone la linea en un "chute".
		|line|
		#Se manda la linea al manejador y se almacena el comando resultante en
		#en un arreglo.
		arrComando = so.recibComando(line)

		#La funcionalidad de cada comando se encuentra en la clase Manejador.
		#Si los parametros del comando no son numeros enteros se indica un error, de lo contrario
		#se sigue procesando el comando.
		if archivo.eof?
			puts "Fin de archivo."
			puts "Cerrando programa."
			puts "Goodbye."
			exit
		end
		if ((is_numeric? arrComando[1]) || arrComando[1] == nil ) && (arrComando[2]==nil || (is_numeric? arrComando[2]) ) && (arrComando[3]==nil || (is_numeric? arrComando[3]))
		case arrComando[0].upcase
		when 'P'
			#Se llama metodo de manejador para instruccion P
			puts "#{arrComando[0].upcase} #{arrComando[1]} #{arrComando[2]}"
			so.cargarProceso(arrComando[1], arrComando[2], memReal, memSwap)
			sleep(1)
			#No se nos olvide quitar ese sleep porque nos inflaría los benchmarks
		when 'A'
			#Se llama metodo de manejador para instruccion A.
			puts ""
			puts "#{arrComando[0].upcase} #{arrComando[1]} #{arrComando[2]} #{arrComando[3]}"
			so.accederProceso(arrComando[1], arrComando[2], arrComando[3], memReal, memSwap)
			puts ""
		when 'L'
			#Se llama metodo de manejador para instruccion L.
			puts ""
			puts "#{arrComando[0].upcase} #{arrComando[1]}"
			puts "Liberando proceso #{arrComando[1]}"
			tiempoTemp = so.turnaroundProceso(arrComando[1])
			arrTiempos.push(tiempoTemp)
			so.liberarProceso(arrComando[1], memReal, memSwap)
			puts ""
		when 'F'
			#Se llama metodo de manejador para instruccion F.
			puts 'F'
			puts ""
			so.listaProcesos.each do
				|proceso|
				idTemp = proceso.id
				tiempoTemp = so.turnaroundProceso(idTemp)
				arrTiempos.push(tiempoTemp)
			end
			acumTiempos = 0
			arrTiempos.size.times do
				|i|
				if arrTiempos[i] != nil
					acumTiempos = arrTiempos[i] + acumTiempos
				end
			end
			puts "Turnaround promedio #{acumTiempos.fdiv(arrTiempos.size)}"
			so.reiniciarSistema(memReal, memSwap)
			so.mostrarSistema(memReal, memSwap)
		when 'E'
			#Se llama metodo de manejador para instruccion E.
			puts 'E'
			bExit=true
		else
			#Si el comando no existe se indica un error.
			puts "Instruccion invalida #{arrComando[1]}"
		end
		else
			#Si el comando no tiene el formato correcto se indica un error.
			puts "Los argumentos de las instrucciones deben ser números enteros"
		end
	end
end
