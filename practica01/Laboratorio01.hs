module Laboratorio01 where

distanciaOrigen :: Double -> Double -> Double
distanciaOrigen x y = sqrt( (x^2) + (y^2) )

sumaCuadradosPares :: [Int] -> Int
sumaCuadradosPares xs = sum (map (^2) (filter even xs))

--Reto 3:
--Utiliza funciones como argumentos para definir una función que permita aplicar otra función tres veces sobre un valor.

aplicaTresVeces :: (a -> a) -> a -> a
aplicaTresVeces f x = f (f (f x))

--Reto 4: 
--Utiliza `let` o `where` para definir una función que calcule la varianza de un conjunto de datos:

-- $$ \sigma^2 = \frac{\sum_{i=1}^{N}(x_i-\mu)^2}{N} $$

varianza2 :: Double -> Double -> Double
varianza2 x y =
    let media = (x + y) / 2
        d1    = x - media
        d2    = y - media
    in (d1 * d1 + d2 * d2) / 2

clasificaTemperatura :: Int -> String
clasificaTemperatura t | t <= 0 = "frio extremo"
                       | t <= 15 = "frio"
                       | t <= 25 = "templado"
                       | t <= 35 = "calido"
                       | otherwise = "calor extremo"

intercala :: a -> [a] -> [a]
intercala y [] = []
intercala y [x] = [x]
intercala y (x:xs) = [x] ++ [y] ++ intercala y xs

data Expr
  = Lit Int
  | Suma Expr Expr
  | Producto Expr Expr
  deriving (Eq, Show)

evalua :: Expr -> Int
evalua (Lit n) = n
evalua (Producto p q) = evalua p * evalua q
evalua (Suma p q) = evalua p + evalua q