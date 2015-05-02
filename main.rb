require './ListaProcesos'
require './Memoria'
require './Marco'
require './Pagina'
require './Proceso'
require './Manejador'

memReal = Memoria.new(32, 8)
memSwap = Memoria.new(64, 8)
so = Manejador.new()

archivo = File.open("datos.txt","r")
