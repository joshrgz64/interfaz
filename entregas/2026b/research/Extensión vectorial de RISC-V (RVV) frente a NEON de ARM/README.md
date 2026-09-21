# Extensión vectorial de RISC-V (RVV) frente a NEON de ARM
## Introducción
Las arquitecturas que constituyen a los procesadores cumplen múltiples funciones que la mayoría de gente pasa por alto, es que son necesarias para formar las reglas y métodos que una computadora utilizará para almacenar información, mostrar imágenes en una pantalla e interactuar con el usuario; desde sus inicios más primitivos con tarjetas perforadas hasta la actualidad que han llegado a avances como la ejecución de LLMs, los procesadores han logrado esto gracias a sus complejas arquitecturas que les dan forma.
## Desarrollo Técnico
### RISC-V
Es una arquitectura relativamente reciente (lanzada en 2014) cuyas siglas en inglés significan "Computadora por Conjunto de Instrucciones Reducidas", esto significa que Risc-V es una arquitectura de procesadores que gestiona los bits de memoria a partir de pocas instrucciones que van directo a la memoria. Es una ISA, una Arquitectura de Conjunto de Instrucciones, lo cual es una interfaz abstracta entre el procesador y el software que corre que define las instrucciones de memoria, tipos de datos, registros, modelos de acceso a memoria, y el manejo de entrada y salida.\
Risc-V es de código abierto. Opera tanto en espacios de direcciones de 32 bits como de 64 bits, y tiene soporte para su  implementación en procesadores multicore (2 - 16 nucleos) o manycore (hasta miles de nucleos simples).\
La V en Risc-V significa que es la 5ta generación de arquitecturas RISC ISA por la Universidad de Berkeley, la V también significa "Vectorial" y "Variaciones",  los enfoques principales de esta arquitectura como veremos más adelantes.
#### Extensión Vectorial RVV
Como su nombre lo indica, Risc-V Vectorial Extension es una extensión de la ISA de Risc-V con el propósito de añadir soporte para operaciones vectoriales. Con vectores nos referimos a conjuntos dinámicos de datos (arrays) que pueden ser manipulados con gran facilidad a diferencia de los arrays tradicionales. Estas operaciones complementan las que el ISA base ejecuta para la gestión de memoria. Algunas de sus funciones incluyen el registro de vectores, la operación con vectores, su configuración, trabajar con "mascaras", y las operaciones de carga y almacenamiento.\
RVV maneja dos variables clave,\
Una es denominada **ELEN**, longitud del elemento, es el tamaño máximo en bits de un vector, debe ser una potencia de 2.\
denominado **VLEN** el cual representa la longitud del registro de un solo vector en bits, utilizado en lugar de un valor constante. VLEN tiene que ser cualquier potencia de 2 no mayor a 16 y además debe ser mayor o igual a ELEN.\
RVV maneja 32 registros vectoriales desde **v0 hasta v31**. Por defecto cada registro tiene un valor VLEN de 128, pero para implementaciones alternativas este valor puede ser cambiado permitiendo abarcar más información en menos registros, por ejemplo:

```
VLEN = 128
v0 = 128
v1 = 128
v2 = 128
v3 = 128
```

```
VLEN = 256
v0 = 256
v1 = 256
```

**SEW**, el ancho del elemento elegido define con cuántos elementos dentro de un vector se puede trabajar a partir de su VLEN.\
Digamos que tenemos un VLEN de 128 bits y queremos trabajar con 32 bits cada elemento, para eso SEW será igual a 32 bits.
```
VLEN = 128 bits
SEW = 32 bits
VLEN / SEW = 4 elementos
```
Por lo tanto, cada elemento denominado a0 - a3 tendrá un valor de 32 bits, esto facilita el trabajo con múltiples datos al dividirlos en partes, especialmente si se trabaja con el máximo de $2^{16}$.\
**VL** nos dice con cuántos elementos se trabajará a la vez una vez definida la cantidad de estos, este valor en este caso es el número de elementos al que llegamos anteriormente, este sería el vector $[a0,a1,a2,a3]$.\

Crear codigo para la manipulación de multiples elementos puede parecer tedioso si asumimos que se tendría que hacer esto para cada uno de ellos individualmente // Terminar mañana explicación sobre stripmining

### Arm NEON

#### Modelo SIMD

## Conclusión

## Bibliografía 
* https://www.arm.com/glossary/isa
* https://www.digikey.com.mx/es/resources/risc-v
* https://docs.riscv.org/reference/isa/v20260120/unpriv/intro.html
* 
