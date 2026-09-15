module Interp where

import Grammars
import Data.List (nub, (\\))
import Data.Maybe (fromMaybe)

-- RETO 3

freeVars :: ASA -> [String]
freeVars (Id s)        = [s]
freeVars (Num _)       = []
freeVars (Boolean _)   = []
freeVars (And es)      = nub (concatMap freeVars es)
freeVars (Or es)       = nub (concatMap freeVars es)
freeVars (Add es)      = nub (concatMap freeVars es)
freeVars (Sub es)      = nub (concatMap freeVars es)
freeVars (Mul es)      = nub (concatMap freeVars es)
freeVars (Div es)      = nub (concatMap freeVars es)
freeVars (Lt es)       = nub (concatMap freeVars es)
freeVars (Gt es)       = nub (concatMap freeVars es)
freeVars (Le es)       = nub (concatMap freeVars es)
freeVars (Ge es)       = nub (concatMap freeVars es)
freeVars (Expt a b)    = nub (freeVars a ++ freeVars b)
freeVars (EqP a b)     = nub (freeVars a ++ freeVars b)
freeVars (Not a)       = freeVars a
freeVars (Add1 a)      = freeVars a
freeVars (Sub1 a)      = freeVars a
freeVars (ZeroP a)     = freeVars a
freeVars (Let bs body) =
  nub (concatMap (freeVars . snd) bs ++ (freeVars body \\ map fst bs))
freeVars (LetStar bs body) = aux bs
  where
    aux []              = freeVars body
    aux ((n, valor):bs') = nub (freeVars valor ++ (aux bs' \\ [n]))


names :: ASA -> [String]
names (Id s)        = [s]
names (Num _)       = []
names (Boolean _)   = []
names (And es)      = nub (concatMap names es)
names (Or es)       = nub (concatMap names es)
names (Add es)      = nub (concatMap names es)
names (Sub es)      = nub (concatMap names es)
names (Mul es)      = nub (concatMap names es)
names (Div es)      = nub (concatMap names es)
names (Lt es)       = nub (concatMap names es)
names (Gt es)       = nub (concatMap names es)
names (Le es)       = nub (concatMap names es)
names (Ge es)       = nub (concatMap names es)
names (Expt a b)    = nub (names a ++ names b)
names (EqP a b)     = nub (names a ++ names b)
names (Not a)       = names a
names (Add1 a)      = names a
names (Sub1 a)      = names a
names (ZeroP a)     = names a
names (Let bs body) =
  nub (map fst bs ++ concatMap (names . snd) bs ++ names body)
names (LetStar bs body) =
  nub (map fst bs ++ concatMap (names . snd) bs ++ names body)


freshName :: [String] -> String
freshName ocupados = busca 0
  where
    busca i =
      let candidato = "v" ++ show i
      in if candidato `elem` ocupados
         then busca (i + 1)
         else candidato


renombra :: ASA -> String -> String -> ASA
renombra e viejo nuevo = sust e viejo (Id nuevo)


sust :: ASA -> String -> ASA -> ASA
sust (Id y) x v
  | y == x    = v
  | otherwise = Id y
sust (Num n) _ _      = Num n
sust (Boolean b) _ _  = Boolean b
sust (And es) x v     = And (map (\e -> sust e x v) es)
sust (Or es) x v      = Or  (map (\e -> sust e x v) es)
sust (Add es) x v     = Add (map (\e -> sust e x v) es)
sust (Sub es) x v     = Sub (map (\e -> sust e x v) es)
sust (Mul es) x v     = Mul (map (\e -> sust e x v) es)
sust (Div es) x v     = Div (map (\e -> sust e x v) es)
sust (Lt es) x v      = Lt  (map (\e -> sust e x v) es)
sust (Gt es) x v      = Gt  (map (\e -> sust e x v) es)
sust (Le es) x v      = Le  (map (\e -> sust e x v) es)
sust (Ge es) x v      = Ge  (map (\e -> sust e x v) es)
sust (Expt a b) x v   = Expt (sust a x v) (sust b x v)
sust (EqP a b) x v    = EqP  (sust a x v) (sust b x v)
sust (Not a) x v      = Not   (sust a x v)
sust (Add1 a) x v     = Add1  (sust a x v)
sust (Sub1 a) x v     = Sub1  (sust a x v)
sust (ZeroP a) x v    = ZeroP (sust a x v)

sust (Let bs body) x v
  | x `elem` ns =
      Let (map (\(n, exp) -> (n, sust exp x v)) bs) body
  | null colisiones =
      Let (map (\(n, exp) -> (n, sust exp x v)) bs) (sust body x v)
  | otherwise =
      let paraEvitar     = nub (names (Let bs body) ++ freeVars v)
          tablaRenombre  = creaTablaRenombre paraEvitar colisiones
          bsRenombrados  = map (\(n, exp) -> (fromMaybe n (lookup n tablaRenombre), exp)) bs
          cuerpoRenombrado = foldl (\b (old, new) -> renombra b old new) body tablaRenombre
      in Let (map (\(n, exp) -> (n, sust exp x v)) bsRenombrados)
             (sust cuerpoRenombrado x v)
  where
    ns         = map fst bs
    colisiones = filter (`elem` freeVars v) ns

sust (LetStar bs body) x v =
  let (bs', body') = sustLetStar bs body x v
  in LetStar bs' body'

creaTablaRenombre :: [String] -> [String] -> [(String, String)]
creaTablaRenombre _ [] = []
creaTablaRenombre evitar (n:ns) =
  let nuevo = freshName evitar
  in (n, nuevo) : creaTablaRenombre (nuevo : evitar) ns

sustLetStar :: [Binding] -> ASA -> String -> ASA -> ([Binding], ASA)
sustLetStar [] body x v = ([], sust body x v)
sustLetStar ((n, exp) : rest) body x v
  | x == n =
      ((n, sust exp x v) : rest, body)
  | n `elem` freeVars v =
      let evitar            = nub (names (LetStar ((n, exp) : rest) body) ++ freeVars v)
          nuevo             = freshName evitar
          rest'             = map (\(m, r) -> (m, renombra r n nuevo)) rest
          cuerpo'           = renombra body n nuevo
          (restBs, cuerpoFinal) = sustLetStar rest' cuerpo' x v
      in ((nuevo, sust exp x v) : restBs, cuerpoFinal)
  | otherwise =
      let (restBs, cuerpoFinal) = sustLetStar rest body x v
      in ((n, sust exp x v) : restBs, cuerpoFinal)

sustMany :: ASA -> [Binding] -> ASA
sustMany e [] = e
sustMany e ((n, val):bs) = sustMany (sust e n val) bs


-- RETO 4

extraeNumeros :: [ASA] -> Maybe [Int]
extraeNumeros [] = Just []
extraeNumeros (x:xs) = case bigStep x of
  Just (Num n) -> case extraeNumeros xs of
                    Just ns -> Just (n : ns)
                    Nothing -> Nothing
  _            -> Nothing

extraeBooleanos :: [ASA] -> Maybe [Bool]
extraeBooleanos [] = Just []
extraeBooleanos (x:xs) = case bigStep x of
  Just (Boolean b) -> case extraeBooleanos xs of
                        Just bs -> Just (b : bs)
                        Nothing -> Nothing
  _                -> Nothing

hayDuplicados :: Eq a => [a] -> Bool
hayDuplicados [] = False
hayDuplicados (x:xs) = x `elem` xs || hayDuplicados xs

sonOrdenados :: (Int -> Int -> Bool) -> [Int] -> Bool
sonOrdenados _ [] = True
sonOrdenados _ [_] = True
sonOrdenados op (x:y:zs) = op x y && sonOrdenados op (y:zs)

evaluaRelacion :: (Int -> Int -> Bool) -> [ASA] -> Maybe ASA
evaluaRelacion op xs = case extraeNumeros xs of
  Just ns -> if length ns < 2
             then Just (Boolean True)
             else Just (Boolean (sonOrdenados op ns))
  Nothing -> Nothing

evaluaBindingsParalelos :: [Binding] -> Maybe [Binding]
evaluaBindingsParalelos [] = Just []
evaluaBindingsParalelos ((n, exp):bs) = case bigStep exp of
  Just v  -> case evaluaBindingsParalelos bs of
               Just rest -> Just ((n, v) : rest)
               Nothing   -> Nothing
  Nothing -> Nothing


bigStep :: ASA -> Maybe ASA
bigStep (Num n)     = Just (Num n)
bigStep (Boolean b) = Just (Boolean b)
bigStep (Id _)      = Nothing

bigStep (And xs) = case extraeBooleanos xs of
  Just bs -> Just (Boolean (and bs))
  Nothing -> Nothing

bigStep (Or xs) = case extraeBooleanos xs of
  Just bs -> Just (Boolean (or bs))
  Nothing -> Nothing

bigStep (Add xs) = case extraeNumeros xs of
  Just ns -> Just (Num (sum ns))
  Nothing -> Nothing

bigStep (Sub []) = Nothing
bigStep (Sub (x:xs)) = case bigStep x of
  Just (Num n) -> case extraeNumeros xs of
                    Just ns -> if null xs
                               then Just (Num (-n))
                               else Just (Num (foldl (-) n ns))
                    Nothing -> Nothing
  _            -> Nothing

bigStep (Mul xs) = case extraeNumeros xs of
  Just ns -> Just (Num (product ns))
  Nothing -> Nothing

bigStep (Div []) = Nothing
bigStep (Div (x:xs)) = case bigStep x of
  Just (Num n) -> case extraeNumeros xs of
                    Just ns -> if null xs
                               then Just (Num n)
                               else if 0 `elem` ns
                                    then Nothing
                                    else Just (Num (foldl div n ns))
                    Nothing -> Nothing
  _            -> Nothing

bigStep (Lt xs) = evaluaRelacion (<) xs
bigStep (Gt xs) = evaluaRelacion (>) xs
bigStep (Le xs) = evaluaRelacion (<=) xs
bigStep (Ge xs) = evaluaRelacion (>=) xs

bigStep (Expt a b) = case bigStep a of
  Just (Num n1) -> case bigStep b of
                     Just (Num n2) -> Just (Num (n1 ^ n2))
                     _             -> Nothing
  _             -> Nothing

bigStep (EqP a b) = case (bigStep a, bigStep b) of
  (Just (Num n1), Just (Num n2))         -> Just (Boolean (n1 == n2))
  (Just (Boolean b1), Just (Boolean b2)) -> Just (Boolean (b1 == b2))
  _                                      -> Nothing

bigStep (Not a) = case bigStep a of
  Just (Boolean b) -> Just (Boolean (not b))
  Just (Num _)     -> Just (Boolean False)
  _                -> Nothing

bigStep (Add1 a) = case bigStep a of
  Just (Num n) -> Just (Num (n + 1))
  _            -> Nothing

bigStep (Sub1 a) = case bigStep a of
  Just (Num n) -> Just (Num (max 0 (n - 1)))
  _            -> Nothing

bigStep (ZeroP a) = case bigStep a of
  Just (Num n) -> Just (Boolean (n == 0))
  _            -> Nothing

bigStep (Let bs body) =
  let variables = map fst bs
  in if hayDuplicados variables
     then Nothing
     else case evaluaBindingsParalelos bs of
            Just paresEvaluados -> bigStep (sustMany body paresEvaluados)
            Nothing             -> Nothing

bigStep (LetStar [] body) = bigStep body
bigStep (LetStar ((x, e) : bs) body) = case bigStep e of
  Just v  -> let bs'   = map (\(n, exp) -> (n, sust exp x v)) bs
                 body' = sust body x v
             in bigStep (LetStar bs' body')
  Nothing -> Nothing