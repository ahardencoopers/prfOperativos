=begin
	Equipo 4.3
	Alberto Harden Cooper a00811931
	José Elí Santiago Rodríguez a07025007
	Osmar Alan Hernandez Sanchez a01244070
=end

#Clase Manejador: Clase encargada de la administracion de memoria.
#Estoy incluye alojar, desalojar y marcos e intercambiarlos de memoria
#real y swap.
#La clase manejador utiliza FIFO 2nd Chance como politica de reemplazo de marcos.

#Includes necesarios para clase Manejador.rb
require './Proceso'
require './Marco'
require './Pagina'

class Manejador
	#Constructor
	def initialize()
		#Se crea una nueva lista de procesos.
		@listaProcesos = Array.new()
	end

	#Metodo para obtener la lista de procesos.
	def listaProcesos
		@listaProcesos
	end

	#Metodo que crea una UNIX timestamp .
	#(Cantidad de segundos desde Enero 1, 1970).
	def timestamp
		Time.now.to_i
	end

	#Metodo que recibe una linea de texto y trata de regresar un
	#string con formato de una solicitud de memoria.
	def recibComando(comando)
		#Se parte la linea de texto por espacios y se almacena en un arreglo.
		#Normalmente toda la informacion necesaria para una solicitud de memoria
		#Se encuentra en los primeros 3 indices del arreglo, dependiendo de la
		#solicitud.
		arrComando = comando.split()
		#Arreglo temporal donde se regresa el resultado.
		arrTemp = Array.new()
		#Checar que tipo de solicitud es y regresar un arreglo con los datos
		#necesarios para atender esa solicutud.
		if arrComando[0] != nil
			if arrComando[0].upcase == 'P'  # Existe
				arrTemp.push(arrComando[0], arrComando[1], arrComando[2])
				return arrTemp
			elsif arrComando[0].upcase == 'A' # Existe
				# MODIFICADO
				arrTemp.push(arrComando[0], arrComando[1], arrComando[2], arrComando[3])
				return arrTemp
				#puts "Instr A"
			elsif arrComando[0].upcase == 'L' # Liberar - No Existe
				arrTemp.push(arrComando[0], arrComando[1])
				return arrTemp
			elsif arrComando[0].upcase == 'F' # Fin - No Existe
				arrTemp.push(arrComando[0])
				return arrTemp
			elsif arrComando[0].upcase == 'E' # Exit - No Existe
				arrTemp.push(arrComando[0])
				return arrTemp
			else
				#Si no se pudo crear una solicitud regresar un arreglo nulo.
				return arrTemp.push(nil, arrComando[0])
			end
		end
	end

	#Metodo para Cargar un Proceso en memoria.
	#Recibe: el tamanio del proceso en bytes, su id unico, la memoria real donde
	#quiere cargar el proceso y la memoria swap donde pondran marcos intercambiados en caso
	#de no haber suficiente memoria real.
	def cargarProceso(cantBytes, idProceso, memReal, memSwap)
		#Se checa si el proceso ya esta cargado.
		procesoExiste = false;

		@listaProcesos.each do
			|proceso|
			if proceso.id == idProceso
				procesoExiste = true
			end
		end

		#Si ya esta cargado se indica un error.
		if procesoExiste
			puts "Error al cargar proceso #{idProceso}. Ya esta cargado en memoria."
		else
		#Si el proceso no ha sido cargado se carga en memoria.
		#Se checa que haya suficiente memoria real para cargar el proceso.
			if Integer(cantBytes) <= memReal.cantBytes
				#Se crea un nuevo proceso temporal que se pondra en la lista de procesos del manejador.
				procesoTemp = Proceso.new(idProceso, cantBytes, memReal.tamPagina)
				#Se agrega el nuevo proceso a la lista.
				@listaProcesos.push(procesoTemp)
				#Se llama el metodo de manejador que asigna marcos para el proceso recien agregado a la lista.
				self.asignarMarcos(@listaProcesos[-1], memReal, memSwap)
			else
				#Si el tamaño del proceso excede la memoria real se indica un error.
				puts "El proceso no puede ser cargado, excede el tamaño de memoria real"
			end
		end
	end


	#Metodo para Acceder una direccion virtual de un proceso.
	#Recibe: direccion virtual del proceso, id del proceso a acceder, si escribir o no en la direccion, y
	#las memorias donde podria encontrar la direccion virtual.
	#Se cambia del bit de referencia del Proceso cada vez que se accede a el
	def accederProceso(direccion, idProceso, bitReferencia, memReal, memSwap)
		procesoExiste = false
		#Contador para indicar el marco actual de memoria real.
		numMarco = 0
		#Se itera sobre cada proceso cargado en memoria.
		@listaProcesos.each do
			#Se carga el proceso en un "chute".
			|proceso|
			#Se checa si el proceso existe
			if proceso.id == idProceso
				procesoExiste = true
				#Se checa que la direccion virtual que se desea accesar este dentro el rango de direcciones del proceso.
				if proceso.cantBytes >= Integer(direccion)
					#Se itera sobre cada pagina del proceso.
					proceso.tablaPaginas.each do
						#Se pone la pagina en un "chute".
						|item2|
						indiceTablaPagina = Integer(direccion).fdiv(memReal.tamPagina).floor
						#Se calcula el marco de memoria real para la pagina y se checa si coinciden.
						#Si coinciden se cambia el bit de referencia.
						if numMarco == indiceTablaPagina && item2.marcoReal >= 0
							puts "La instruccion se encuentra cargada en marco real #{item2.marcoReal}, se ha accesado"
							memReal.arrMarcos[numMarco].fueAccesado = 1
						end
						#Se checa adicionalmente si esta en memoria swap en caso de no estarlo en memoria real.
						if numMarco == indiceTablaPagina && item2.marcoSwap >= 0
							puts "La instruccion se encuentra cargada en marco swap #{item2.marcoSwap}"
							puts "Proceso #{idProceso} genera page fault."
							puts "La pagina sera cargada en memoria real para intentar accesarla"
							#Si se encuentra en memoria swap se indica que que el proceso causo un page fault y se carga en memoria real.
							proceso.faultsCausados = proceso.faultsCausados + 1
							if memReal.dispMarcos > 0
								memSwap.arrMarcos[item2.marcoSwap].idProceso = -1
								memSwap.arrMarcos[item2.marcoSwap].fueAccesado = -1
								memSwap.arrMarcos[item2.marcoSwap].timestampCarga = -1
							end
							procesoTemp = self.getProceso(idProceso)
							if procesoTemp != false
								self.asignarMarcoPag(procesoTemp, memReal, memSwap, indiceTablaPagina)
							end
						end
						#Se cambia al siguiente marco de memoria de real
						numMarco = numMarco + 1
					end
				else
				#Si la direccion virtual recibida no esta dentro del rango de direcciones virtual del proceso se indica un error.
				puts "La direcion no esta dentro del rango maximo para el proceso #{idProceso}"
				end
			end
		end

		if !procesoExiste
			#Si el proceso no existe se indica un error.
			puts "El proceso #{idProceso} esta mal definido o no existe"
		end
	end

	#Metodo para asignar marcos a un proceso.
	#Recibe: el proceso al cual se le asignaran marcos, la memoria real donde se
	#almacenaran los marcos y la memoria swap donde se pondran paginas intercambiadas en caso
	#de no haber suficiente memoria real.
	def asignarMarcos(proceso, memReal, memSwap)
		puts "Asignando marcos para proceso #{proceso.id}"
		puts "Marcos Disponibles: #{memReal.dispMarcos}"
		#Se calcula la cantidad de marcos que necesita el proceso restando los marcos que ya tiene asignados
		#y su cantidad total de paginas.
		cantPideMarcos = proceso.cantPaginas-proceso.marcosRealAsig
		marcosSwapLibres = memSwap.dispMarcos
		puts "Marcos Solicitados: #{cantPideMarcos}"
		#Se checa si hay suficientes marcos disponibles para el proceso.
		if cantPideMarcos <= memReal.dispMarcos
			puts "Marcos Actuales: "
			#Se comienza a buscar marcos disponibles desde el primer marco de memoria real.
			marcoRealActual = 0
			#Se hace un ciclo que busca y asigna marcos disponibles al proceso hasta que es cargado por completo en memoria real.
			while proceso.marcosRealAsig < proceso.cantPaginas && marcoRealActual < memReal.arrMarcos.size do
				#Si el id del proceso del marco es el numero entero -1, significa que el marco esta disponible
				#y por lo tanto se le asigna al proceso.
				if memReal.arrMarcos[marcoRealActual].idProceso == -1
					#Se crea una nueva pagina que se pondra en el marco.
					paginaTemp = Pagina.new(marcoRealActual)
					#Se crea un nuevo marco que se pondra en memoria real.
					#El marco es cargado con el id del proceso, bit de modificacion en 0 y un
					#timestamp de UNIX.
					marcoTemp = Marco.new(proceso.id, 0, self.timestamp())
					#Se coloca el marco en memoria real.
					memReal.arrMarcos[marcoRealActual] = marcoTemp
					#Se coloca la pagina en la tabla de paginas del proceso.
					proceso.tablaPaginas.push(paginaTemp)
					#Se indica que hay un marco disponible menos.
					memReal.dispMarcos = memReal.dispMarcos - 1
					#Se indica que hay marco ocupado mas.
					memReal.ocupMarcos = memReal.ocupMarcos + 1
					#Se indica que al proceso tiene una marco de memoria real asignado.
					proceso.marcosRealAsig = proceso.marcosRealAsig + 1
					puts "Se alojo marco real #{marcoRealActual} para pagina #{proceso.marcosRealAsig-1}"
				end
				#Se cambia al siguiente marco de memoria real.
				marcoRealActual = marcoRealActual + 1
			end
			puts""
		else
			#En caso de no haber suficiente memorial real para el proceso se aplica
			#politica de reemplzao FIFO 2nd chance.
			puts ""
			puts "F2C"
			#Se crea una variable con la cantidad de marcos necesitados por el proceso.
			marcosNecesitados = cantPideMarcos
			#Se hace una llamada a metodo que manda marcos de memoria real a swap hasta que hay suficiente
			#espacio para el proceso.
			#Se checa si hay suficientes marcos en memoria swap para realizar swapping.
			if marcosSwapLibres >= marcosNecesitados
				self.mandarSwap(proceso, memReal, memSwap, marcosNecesitados)
				#Despues de liberar suficiente memoria real se hace una llamada recursiva a este metodo
				#para asignar marcos.
				self.asignarMarcos(proceso, memReal, memSwap)
			else
				puts "No queda memoria en swap para proceso #{proceso.id}"
			end
		end
	end

	#Metodo para asignar 1 marco de proceso que está en memoria swap.
	#Recibe: el proceso al cual se le asignaran marcos, la memoria real donde se
	#almacenaran los marcos y la memoria swap donde se pondran paginas intercambiadas en caso
	#de no haber suficiente memoria real.
	def asignarMarcoPag(proceso, memReal, memSwap, pagina)
		proceso.desplegarProceso
		puts "Marcos Disponibles: #{memReal.dispMarcos}"
		#Se pide 1 marco de memoria real
		cantPideMarcos = 1
		marcosSwapLibres = memSwap.dispMarcos
		puts "Marcos Solicitados: #{cantPideMarcos}"
		#Se checa si hay suficientes marcos disponibles para el proceso.
		if cantPideMarcos <= memReal.dispMarcos
			puts "Marcos Actuales: "
			#Se comienza a buscar marcos disponibles desde el primer marco de memoria real.
			marcoRealActual = 0
			#Se hace un ciclo que busca y asigna marcos disponibles al proceso hasta que es cargado por completo en memoria real.
			while proceso.marcosRealAsig < proceso.cantPaginas && marcoRealActual < memReal.arrMarcos.size && cantPideMarcos != 0 do
				#Si el id del proceso del marco es el numero entero -1, significa que el marco esta disponible
				#y por lo tanto se le asigna al proceso.
				if memReal.arrMarcos[marcoRealActual].idProceso == -1
					#Se crea una nueva pagina que se pondra en el marco.
					paginaTemp = Pagina.new(marcoRealActual)
					#Se crea un nuevo marco que se pondra en memoria real.
					#El marco es cargado con el id del proceso, bit de modificacion en 1 por que este método se llama sólo desde accederProceso; y un
					#timestamp de UNIX.
					marcoTemp = Marco.new(proceso.id, 1, self.timestamp())
					#Se coloca el marco en memoria real.
					memReal.arrMarcos[marcoRealActual] = marcoTemp
					#Se coloca la pagina en la tabla de paginas del proceso.
					proceso.tablaPaginas.push(paginaTemp)
					#Se indica que hay un marco disponible menos.
					memReal.dispMarcos = memReal.dispMarcos - 1
					#Se indica que hay marco ocupado mas.
					memReal.ocupMarcos = memReal.ocupMarcos + 1
					#Se indica que al proceso tiene una marco de memoria real asignado.
					proceso.marcosRealAsig = proceso.marcosRealAsig + 1
					proceso.marcosSwapAsig = proceso.marcosSwapAsig - 1
					puts "Se alojo marco real #{marcoRealActual} para pagina #{Integer(pagina)}"
					#Se actualiza la informacion de la pagina que se acaba de mandar a memoria real.
					proceso.tablaPaginas[Integer(pagina)].marcoReal = marcoRealActual
					proceso.tablaPaginas[Integer(pagina)].marcoSwap = -1
					proceso.tablaPaginas[Integer(pagina)].cargada = 1
					#Se actualiza la cantidad de marcos ocupados y disponibles en memoria
					#swap.
					memSwap.dispMarcos = memSwap.dispMarcos + 1
					memSwap.ocupMarcos = memSwap.ocupMarcos - 1
					cantPideMarcos = cantPideMarcos - 1
				end
				#Se cambia al siguiente marco de memoria real.
				marcoRealActual = marcoRealActual + 1
				proceso.desplegarProceso

			end
			puts""
		else
			#En caso de no haber suficiente memorial real para el proceso se aplica
			#politica de reemplzao FIFO 2nd chance.
			puts ""
			puts "F2C"
			#Se crea una variable con la cantidad de marcos necesitados por el proceso.
			marcosNecesitados = cantPideMarcos
			#Se hace una llamada a metodo que manda marcos de memoria real a swap hasta que hay suficiente
			#espacio para el proceso.
			if marcosSwapLibres >= marcosNecesitados
			self.mandarSwap(proceso, memReal, memSwap, marcosNecesitados)
			#Despues de liberar suficiente memoria real se hace una llamada recursiva a este metodo
			#para asignar marcos.
			self.asignarMarcoPag(proceso, memReal, memSwap, pagina)
			else
			puts "No queda memoria en swap para proceso #{proceso.id}"
			end
		end
	end

	#Metodo que manda marcos de memoria real a swap hasta que hay suficiente memoria
	#para cargar un proceso.
	#Recibe: El proceso a cargar en memoria, la memoria real donde se quiere hacer espacio, la memoria
	#donde se pondran los marcos intercambiados y los marcos necesitados por el proceso para ser cargado.
	def mandarSwap(proceso, memReal, memSwap, marcosNecesitados)
		puts "Se necesita realizar swapping para proceso #{proceso.id}"
		#Se checa si hay suficientes marcos en memoria swap para realizar swapping.
		if memSwap.dispMarcos >= marcosNecesitados
			#Se hace un ciclo mientras la cantidad de marcos necesitados sea mayor que la cantidad
			#de marcos disponibles en memoria real.
			while marcosNecesitados > memReal.dispMarcos do
				#Se obtiene el indice del marco mas viejo en memoria, es decir, el que llego primero.
				iViejo = memReal.indiceMarcoViejo
				#Se obtiene el id del proceso al que pertenece el marco mas viejo.
				idProcesoViejo = memReal.arrMarcos[iViejo].idProceso
				puts "Checando marco viejo p=#{idProcesoViejo} m=#{iViejo} a=#{memReal.arrMarcos[iViejo].fueAccesado}"
				#Se checa si el marco mas viejo ha sido referenciado, en caso de haber sido referenciado
				#no se manda a memoria swap (2nd chance), pero se apaga su bit de referencia.
				if memReal.arrMarcos[iViejo].fueAccesado == 1 && memReal.arrMarcos[iViejo].idProceso != -1
					puts "Marco mas viejo habia sido referenciado, 2nd chance"
					memReal.arrMarcos[iViejo].fueAccesado = 0
					#Se actualiza el timestamp del proceso ya que fue accesado para modificarlo.
					memReal.arrMarcos[iViejo].timestampCarga = self.timestamp
				#Si el marco mas viejo no ha sido referenciado se manda a memoria swap por ser candidato en politica FIFO.
				elsif memReal.arrMarcos[iViejo].fueAccesado == 0 && memReal.arrMarcos[iViejo].idProceso != -1
					puts "Marco mas viejo no ha sido referenciado, swappeando"
					#Se obtiene el proceso al que pertenece el marco mas viejo
					#para actualizar su informacion de marcos y paginas.
					procesoViejo = self.getProceso(idProcesoViejo)
					#Se indica que tiene un marco real asignado menos.
					procesoViejo.marcosRealAsig = procesoViejo.marcosRealAsig - 1
					#Se indica que tiene un marco de swap asignado mas.
					procesoViejo.marcosSwapAsig = procesoViejo.marcosSwapAsig + 1
					#Se crea un marco nuevo que se pondra en memoria swap con la informacion
					#del proceso viejo.
					marcoTemp = Marco.new(procesoViejo.id, 0, self.timestamp)
					#Se coloca el marco en memoria swap.
					marcoSwap = self.ponerMarco(marcoTemp, memSwap)
					#Variable que se manda por referencia a metodo de Proceso.rb indicePagina
					#para obtener que pagina del proceso es.
					contadorProvisional = 0
					indicePaginaVieja = 0
					procesoViejo.tablaPaginas.each do
						|item2|
						#Se calcula el marco de memoria real para la pagina y se checa si coinciden.
						#Si coinciden se obtiene el indice de pagina que se swappeo
						if item2.marcoReal == iViejo
							indicePaginaVieja = contadorProvisional
						end
						contadorProvisional = contadorProvisional + 1
					end
					#Se busca el la pagina que estaba en el marco mas viejo.
					paginaActualizar = procesoViejo.indicePagina(iViejo, indicePaginaVieja)
					#Se actualiza la informacion de la pagina que se acaba de mandar a swap.
					paginaActualizar.marcoReal = -1
					paginaActualizar.marcoSwap = marcoSwap
					paginaActualizar.cargada = -1
					#Se actualiza el marco de memoria real.
					memReal.arrMarcos[iViejo].idProceso = -1
					memReal.arrMarcos[iViejo].fueAccesado = -1
					memReal.arrMarcos[iViejo].timestampCarga = self.timestamp
					#Se actualiza el marco de memoria Swap
					memSwap.arrMarcos[marcoSwap].idProceso = idProcesoViejo
					memSwap.arrMarcos[marcoSwap].fueAccesado = -1
					memSwap.arrMarcos[marcoSwap].timestampCarga = self.timestamp
					#Se actualiza la cantidad de marcos ocupados y disponibles en memoria
					#real y memoria swap.
					memReal.dispMarcos = memReal.dispMarcos + 1
					memReal.ocupMarcos = memReal.ocupMarcos - 1
					memSwap.dispMarcos = memSwap.dispMarcos - 1
					memSwap.ocupMarcos = memSwap.ocupMarcos + 1
					puts "Se swappeo pagina #{indicePaginaVieja} de proceso #{procesoViejo.id}"
					puts "Quedo en marco de swap #{marcoSwap}"
				end
			end
		end
	end

	#Metodo que coloca un marco en un lugar disponible de memoria.
	def ponerMarco(marco, memoria)
		i=0
		#Ciclo para iterar todos los marcos de memoria.
		memoria.arrMarcos.size.times do
			#Si el marco de memoria es disponible (-1), se coloca el marco
			if memoria.arrMarcos[i].idProceso == -1
				memoria.arrMarcos[i] = marco
				#Se regresa el indice donde se cargo el marco en memoria.
				return i
			end
			i = i+1
		end
	end

	#Metodo para calcular el turnaround de un proceso.
	#Recibe el id del proceso.
	def turnaroundProceso(idProceso)
		idProceso = Integer(idProceso)
		proceso = self.getProceso(idProceso)
		if proceso != false
			puts "Turnaround para proceso #{idProceso} es #{self.timestamp - proceso.timestampLlegada}"
			return self.timestamp - proceso.timestampLlegada
		end
	end

	#Metodo que obtiene un proceso de la lista de procesos del manejador dando
	#el id del proceso.
	def getProceso(id)
		i = 0
		encontroProceso = false #Se itera sobre toda la lista de procesos.
		@listaProcesos.size.times do
			#Si coinciden los ids, se regresa el proceso.
			if Integer(@listaProcesos[i].id) == Integer(id)
				return @listaProcesos[i]
				encontroProceso = true
			end
			i = i+1
		end

		if !encontroProceso
			return false
		end
	end

	#Metodo para librerar las paginas de un proceso.
	#Recibe el id del proceso que quiere liberar sus paginas, y las memorias
	#donde pueden estar sus paginas.
	def liberarProceso(idProceso, memReal, memSwap)
		procesoExiste = false
		#Se itera sobre cada proceso para encontrarlo.
		@listaProcesos.each do
			|proceso|
			#Cuando se encuentra el proceso coincidiendo los ids, se liberan sus paginas.
			if proceso.id == idProceso
				procesoExiste = true
				#Se itera sobre cada pagina del proceso.
				proceso.tablaPaginas.each do
					|item2|
					#Liberar paginas del proceso de memoria real
					if item2.marcoReal >= 0
					puts "La pagina en marco real #{item2.marcoReal} de proceso #{idProceso} fue liberada"
					#Se actualiza la informacion del marco para indicar que esta vacio (-1)
					memReal.arrMarcos[item2.marcoReal].timestampCarga = -1
					memReal.arrMarcos[item2.marcoReal].fueAccesado = -1
					memReal.arrMarcos[item2.marcoReal].idProceso = -1
					#Se actualiza la cantidad de marcos disponibles y ocupados en memoria real.
					memReal.dispMarcos = memReal.dispMarcos + 1
					memReal.ocupMarcos = memReal.ocupMarcos - 1
					end
					#Liberar paginas del proceso de memoria swap
					#Se hace el mismo proceso pero en memoria swap.
					if item2.marcoSwap >= 0
					puts "La pagina en marco swap #{item2.marcoSwap} de proceso #{idProceso} fue liberada"
					memSwap.arrMarcos[item2.marcoSwap].timestampCarga = -1
					memSwap.arrMarcos[item2.marcoSwap].fueAccesado = -1
					memSwap.arrMarcos[item2.marcoSwap].idProceso = -1
					memSwap.dispMarcos = memSwap.dispMarcos + 1
					memSwap.ocupMarcos = memSwap.ocupMarcos - 1
					end
				end
			end
		end

		#Despues de liberar la memoria se borra el proceso de la lista de
		#de proceso del manejador.
		if procesoExiste
			counter = 0
			#Se busca en que indice de la lista de procesos se encuentra el proceso a borrar.
			@listaProcesos.each do
				|proceso|
				if proceso.id == idProceso
					#Se borra el proceso en la lista de procesos.
					puts "Proceso #{proceso.id} genero #{proceso.faultsCausados} page faults"
					@listaProcesos.delete_at(counter)
				end
				counter = counter + 1
			end
			puts "Se ha liberado toda la memoria ocupada por el proceso #{idProceso}"
			puts ""
		end

		if !procesoExiste
			puts "El proceso #{idProceso} esta mal definido o no existe"
			puts ""
		end
	end

	#Muestra el estado actual desplegando informacion de memoria real, memoria swap
	#y la lista de procesos del manejador.
	def mostrarSistema(memReal, memSwap)
		puts "Memoria Real"
		#Se itera sobre cada marco de la memoria real.
		memReal.arrMarcos.each do
			|item|
			puts " #{item.idProceso}  #{item.timestampCarga}   #{item.fueAccesado}"
		end

		puts ""

		puts "Memoria Swap"
		#Se itera sobre cada marco de la memoria swap.
		memSwap.arrMarcos.each do
			|item|
			puts item.idProceso
		end

		puts ""

		puts "Lista de Procesos"
		#Se itera sobre cada proceso de la lista de procesos.
		@listaProcesos.each do
			|item|
			puts "Proceso #{item.id}"
			puts "marcoReal marcoSwap"
			item.tablaPaginas.each do
				|item2|
				puts "#{item2.marcoReal} 		#{item2.marcoSwap}"
			end
		end
	end

	#Metodo para poner el sistema en su estado inicial (memoria real y swap vacia, ningun proceso en la lista de procesos).
	def reiniciarSistema(memReal, memSwap)
		puts "Reiniciando sistema"
		#Ya que el metodo liberar procesos libera marcos de memoria y real y swap y despues borra el proceso, basta con llamar liberar
		#memoria para cada proceso.

		cantVeces = @listaProcesos.size + 1
		cantVeces.times do
			|i|
			@listaProcesos.each do
				|proceso|
					liberarProceso(proceso.id, memReal, memSwap)
			end
		end
		self.purgarMemoria(memReal)
		self.purgarMemoria(memSwap)
	end

	#Metodo para purgar toda la memoria y dejarla vacia.
	#Recibe una memoria para purgar.
	def purgarMemoria(memoria)
		memoria.arrMarcos.each do
			|item|
			puts item.class
			item.idProceso = -1
			item.fueAccesado = -1
			item.timestampCarga = -1
		end
	end


end
