{
module Grammars where

import Lexer (Token(..), lexer)
}

%name parse
%tokentype { Token }
%error { parseError }

%token
      nat             { TokenNum $$ }
      bool            { TokenBool $$ }
      '+'             { TokenSuma }
      '-'             { TokenResta }
      '*'             { TokenMul }
      '/'             { TokenDiv }
      "and"           { TokenAnd }
      "or"            { TokenOr }
      "not"           { TokenNot }
      "add1"          { TokenAdd1 }
      "sub1"          { TokenSub1 }
      "zero?"         { TokenZeroP }
      "expt"          { TokenExpt }
      '<'             { TokenLT }
      '>'             { TokenGT }
      "<="            { TokenLE }
      ">="            { TokenGE }
      "eq"            { TokenEq }
      '('             { TokenPA }
      ')'             { TokenPC }

%%

ASA : nat                      { Num $1 }
    | bool                     { Boolean $1 }

-- RETO 2:
-- Agrega las producciones para:
--   * operadores n-arios con al menos dos argumentos;
--   * operadores estrictamente binarios: expt y eq;
--   * operadores unarios: not, add1, sub1, zero?.

ASA : '(' "add1" ASA ')'      {Add1 $3}  
    | '(' "sub1" ASA ')'  {Sub1 $3}
    | '(' "zero?" ASA ')'  { ZeroP $3}
    | '(' "not" ASA ')'  { Not $3}
    | '(' "expt" ASA ASA ')'  { Expt $3 $4}
    | '(' "eq" ASA ASA ')'  { EqP $3 $4}
    | '(' '-' Lista ')'  { Sub $3}
    |'(' '+' Lista ')'  { Add $3}
    |'(' '*' Lista ')'  { Mul $3}
    | '(' '/' Lista ')'  { Div $3}
    | '(' "and" Lista ')'  { And $3}
    | '(' "or" Lista ')'  { Or $3}
    | '(' '<' Lista ')'  { Lt $3}
    | '(' '>' Lista ')'  { Gt $3}
    | '(' "<=" Lista ')'  { Le $3}
    | '(' ">=" Lista ')'  { Ge $3}

-- RETO 3:
-- Agrega un no terminal para representar dos o mas argumentos.
-- El resultado debe ser una lista de ASA.
Lista : ASA ASA { [ $1 , $2 ]}
      | Lista ASA { $1 ++ [ $2]}

{
parseError :: [Token] -> a
parseError toks = error ("Parse error: " ++ show toks)

data ASA
  = Num Int
  | Boolean Bool
  | And [ASA]
  | Or [ASA]
  | Add [ASA]
  | Sub [ASA]
  | Mul [ASA]
  | Div [ASA]
  | Lt [ASA]
  | Gt [ASA]
  | Le [ASA]
  | Ge [ASA]
  | Expt ASA ASA
  | EqP ASA ASA
  | Not ASA
  | Add1 ASA
  | Sub1 ASA
  | ZeroP ASA
  deriving (Eq, Show)
}