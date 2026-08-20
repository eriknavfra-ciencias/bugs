# Laboratorio 01

## Introducción a Haskell 

### Leslie Paola Sánchez Victoria


Razonar un problema en programación funcional, como Haskell, es diferente a razonarlo en un lenguaje imperativo como Java.

En lenguajes imperativos estamos acostumbrados a describir **qué debe hacer el programa paso a paso** para llegar a una solución: recorrer una lista, guardar un resultado, modificar una variable, etc.

En un lenguaje funcional podemos pensar de una manera diferente: en lugar de describir los pasos que debe seguir el programa, podemos **definir qué resultado queremos obtener** a partir de los datos que tenemos.

Haskell favorece este estilo porque normalmente trabajamos con valores que no se modifican. Por eso resulta natural razonar los problemas de una forma cercana a las definiciones matemáticas.

Por ejemplo, ¿qué pasa si queremos obtener los números pares de una lista?

En Java podríamos recorrer la lista, comprobar cuáles elementos son pares y agregarlos a otra lista:

```java
List<Integer> resultado = new ArrayList<>();

for (int i = 0; i < lista.size(); i++) {
    if (lista.get(i) % 2 == 0) {
        resultado.add(lista.get(i));
    }
}
```

Esta forma de pensar es sencilla porque estamos describiendo un **algoritmo**: primero recorremos la lista, después comprobamos cada elemento y finalmente guardamos los que nos interesan.

En Haskell podemos expresar directamente la definición de lo que estamos buscando:

```haskell
paresLista :: [Int] -> [Int]
paresLista [] = []
paresLista (x:xs)
    | even x   = x : paresLista xs
    | otherwise = paresLista xs
```

La función recibe una lista de enteros y devuelve otra lista de enteros. Si la lista está vacía, el resultado también lo está. Si tiene un elemento `x` seguido del resto `xs`, comprobamos si `x` es par. Si lo es, lo incluimos en el resultado; si no, continuamos con el resto de la lista.

También podemos expresar la misma idea utilizando **listas de comprensión**:

```haskell
paresLista :: [Int] -> [Int]
paresLista l = [x | x <- l, even x]
```

Podemos leerlo de una manera cercana al lenguaje matemático:

> Queremos los elementos `x` tales que `x` pertenece a la lista `l` y, además, `x` es par.

---

### Firma de una función

La firma de una función nos indica qué tipos de datos recibe y qué tipo de dato devuelve. Puede darnos información sobre una función incluso antes de ver su definición. Sirve como una forma de documentación y ayuda al compilador a detectar errores de tipos. Aunque es recomendable escribirla, Haskell puede inferirla en muchos casos.


Por ejemplo:

```haskell
negativo :: Int -> Int
negativo x = -x

dosVeces :: (Int -> Int) -> Int -> Int
dosVeces f x = f (f x)
```

Podemos leer la primera firma como:

> `negativo` recibe un `Int` y devuelve un `Int`.

La segunda es un poco más interesante:

> `dosVeces` recibe una función que transforma un `Int` en otro `Int`, después recibe un `Int` y finalmente devuelve un `Int`.

La función `dosVeces` aplica la función que recibe dos veces. Por ejemplo:

```haskell
ghci> negativo 5
-5

ghci> dosVeces negativo (6 - (7 ^ 2))
-43
```

En este último caso, primero calculamos `6 - (7 ^ 2)`, que da `-43`. Después `dosVeces` aplica `negativo` dos veces:

```text
negativo (-43) = 43
negativo 43    = -43
```

Una característica importante de Haskell es que **las funciones también pueden recibirse como argumentos**, como ocurre con `dosVeces`.


---

### Operadores aritméticos y booleanos

Los operadores aritméticos suelen escribirse entre sus operandos, es decir, en **notación infija**:

```text
(+)  Suma
(-)  Resta
(*)  Multiplicación
(/)  División
(^)  Potencia
```

También podemos utilizar funciones matemáticas como:

```text
sqrt  Raíz cuadrada
```

Para trabajar con valores booleanos tenemos:

```text
True   Verdadero
False  Falso

(&&)   Conjunción (AND)
(||)   Disyunción (OR)
not    Negación
```

Por ejemplo:

```haskell
ghci> 4 * 5 + (24 - sqrt 9) / 7
23.0

ghci> not (True || False && (23 < 5))
False
```

Los paréntesis pueden utilizarse para hacer explícito el orden de evaluación. Si los omitimos, Haskell utiliza las reglas de precedencia y asociatividad de los operadores.

---

### Funciones predefinidas

Haskell proporciona muchas funciones que permiten expresar operaciones comunes sin necesidad de utilizar variables mutables.

Algunas de las más utilizadas son:

```haskell
map    :: (a -> b) -> [a] -> [b]
filter :: (a -> Bool) -> [a] -> [a]
sum    :: Num a => [a] -> a
even   :: Integral a => a -> Bool
length :: [a] -> Int
```

Podemos entenderlas de forma intuitiva:

* `map` aplica una función a todos los elementos de una lista.
* `filter` conserva únicamente los elementos que cumplen una condición.
* `sum` suma los elementos de una lista.
* `even` comprueba si un número es par.
* `length` obtiene el tamaño de una lista.

Por ejemplo:

```haskell
ghci> map (*2) [1,2,3,4]
[2,4,6,8]

ghci> filter even [1,2,3,4,5,6]
[2,4,6]

ghci> sum [1,2,3,4]
10
```

Una característica importante de estas funciones es que podemos **combinarlas** para construir soluciones más complejas.

---

### Asignaciones locales

Aunque normalmente evitamos modificar valores existentes, podemos definir nombres locales para expresiones.

Con `let` podemos escribir:

```haskell
let x = <expresión>
in <expresión que utiliza x>
```

Por ejemplo:

```haskell
ghci> let l = [True, False, True] in map not l
[False,True,False]
```

También podemos utilizar `where` para definir nombres auxiliares asociados a una función:

```haskell
sumaSegundo :: [(Int, Int)] -> Int
sumaSegundo l = sum l' 
    where l' = map snd l
```

La idea importante es que estos nombres **no representan variables que vamos modificando**. Son simplemente nombres que asociamos a una expresión o valor.

---

### Guardias

Las guardias permiten elegir entre diferentes resultados dependiendo de una condición. Son una alternativa sencilla a encadenar varios `if`.

```haskell
etapa :: Int -> String
etapa n
    | n < 12 = "Infante"
    | n < 19 = "Adolescente"
    | n < 30 = "Adulto joven"
    | n < 60 = "Adulto"
    | otherwise = "Adulto mayor"
```

Las condiciones se evalúan de arriba hacia abajo. La primera condición verdadera determina el resultado.

`otherwise` representa el caso que queda cuando ninguna de las condiciones anteriores se cumple.

---

### Tipos de datos algebraicos

Haskell permite definir nuestros propios tipos de datos utilizando la palabra reservada `data`.

Por ejemplo, podemos definir un tipo para representar mascotas:

```haskell
data Mascota
    = Gato
    | Perro
    | Hamster
```

Aquí `Gato`, `Perro` y `Hamster` son los **constructores** que podemos utilizar para crear valores de tipo `Mascota`.

Los tipos de datos algebraicos también permiten construir estructuras más complejas.

Por ejemplo, podemos representar un árbol binario:

```haskell
data Arbol
    = Nodo Int
    | Arbol Int Arbol Arbol
```

Un árbol puede ser una hoja, representada por `Nodo`, o puede contener un valor y dos árboles hijos.

Podemos definir una función que obtenga las hojas del árbol:

```haskell
hojas :: Arbol -> [Int]
hojas (Nodo n) = [n]
hojas (Arbol _ hijoI hijoD) =
    hojas hijoI ++ hojas hijoD
```

Aquí aparece nuevamente una idea importante de Haskell: podemos **definir una función describiendo qué debe ocurrir para cada posible forma de los datos**.

En este caso:

* Si recibimos un `Nodo`, la hoja contiene ese único valor.
* Si recibimos un árbol con hijos, obtenemos las hojas del hijo izquierdo y del derecho y las concatenamos.

Este estilo de definición mediante los diferentes casos de una estructura aparece constantemente en Haskell y es una de las ideas fundamentales de la programación funcional.

## Reto 1 

Define una función que calcule la distancia euclidiana entre un punto `(x₁, y₁)` y el origen `(0, 0)`.

La distancia euclidiana entre dos puntos `(x₁, y₁)` y `(x₂, y₂)` se calcula mediante:

$$
d = \sqrt{(x_2-x_1)^2 + (y_2-y_1)^2}
$$


## Reto 2 

A partir de una lista de enteros, calcula la suma de los cuadrados de aquellos elementos que sean pares.

Por ejemplo:

```haskell
sumaCuadradosPares [1, 2, 3, 4]
```

debe producir:

```text
20
```

## Reto 3 

Utiliza funciones como argumentos para definir una función que permita aplicar otra función tres veces sobre un valor.

## Reto 4 

Utiliza `let` o `where` para definir una función que calcule la varianza de un conjunto de datos:

$$
\sigma^2 = \frac{\sum_{i=1}^{N}(x_i-\mu)^2}{N}
$$

## Reto 5 

Define una función que determine cómo se encuentra el clima a partir de la temperatura actual.

Considera las siguientes categorías:

* **frio extremo:** temperatura menor a `1 °C`.
* **frio:** temperatura menor o igual a `15 °C`.
* **templado:** temperatura a lo más de `25 °C`.
* **calido:** temperatura que no sobrepasa los `35 °C`.
* **calor extremo:** temperatura mayor a `36 °C`.

## Reto 6 — Recursión sobre listas

Define, utilizando recursión, una función que intercale un símbolo entre los elementos de una lista.

Por ejemplo:

```haskell
intercala " " ["hola", "mundo", ":)"]
```

debe producir:

```haskell
["hola", " ", "mundo", " ", ":)"]
```

## Reto 7 

Define una función que permita evaluar expresiones representadas mediante un tipo de dato algebraico.

Por ejemplo, si tenemos una expresión como:

```haskell
Suma (Lit 1) (Producto (Lit 1) (Lit 4))
```

la función:

```haskell
evalua (Suma (Lit 1) (Producto (Lit 1) (Lit 4)))
```

debe producir:

```text
5
```


# Ejecución de pruebas

```bash
runghc TestLaboratorio01.hs
```