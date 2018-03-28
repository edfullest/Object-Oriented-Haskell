module DataTypes where
import Data.Decimal
import qualified Data.HashMap.Strict as Map
-- Esta sección tiene las producciones semánticas para producir el árbol abstracto de sintaxis 
type Identifier = String
type ClassIdentifier = String

type Address = Integer
type QuadNum = Integer

-- Los primeros 4 son los contadores de variables de tipo Integers,Decimales,Strings,Bool 
type VariableCounters = (Address,Address,Address,Address,Address) 

-- Contadores de literales de integers,decimales,strings y booleanos
type LiteralCounters = (Address,Address,Address,Address) 

type TypeIdentifier = String -- Integer, Decimal, String, Bool

-- Estos tipos le sirven a ExpressionCodeGen saber qué Identifiador/Constante están mappeados en memorias con qué dirección
type IdentifierAddressMap = Map.HashMap Identifier Address
type ConstantAddressMap = Map.HashMap String Address
type ObjectAddressMap = Map.HashMap Address IdentifierAddressMap



data Program 
    = Program [Class] [Function] [Variable] Block
  deriving (Show, Eq)

data Function 
    = Function Identifier TypeFuncReturn [(Type,Identifier)] Block
  deriving (Show, Eq)

data TypeFuncReturn 
    = TypeFuncReturnPrimitive Primitive 
    | TypeFuncReturnClassId ClassIdentifier
    | TypeFuncReturnNothing
  deriving (Show, Eq)

data Primitive 
    = PrimitiveInt
    | PrimitiveDouble
    | PrimitiveMoney
    | PrimitiveString
    | PrimitiveBool
    | PrimitiveInteger
  deriving (Show)

instance Eq Primitive where 
   PrimitiveInt == PrimitiveInteger  =  True
   PrimitiveInteger == PrimitiveInt  =  True
   PrimitiveDouble == PrimitiveMoney  =  True
   PrimitiveMoney == PrimitiveDouble  =  True
   PrimitiveInt == PrimitiveInt  =  True
   PrimitiveInteger == PrimitiveInteger  =  True
   PrimitiveBool == PrimitiveBool  =  True
   PrimitiveString == PrimitiveString  =  True
   PrimitiveMoney == PrimitiveMoney  =  True
   PrimitiveDouble == PrimitiveDouble  =  True
   _ == _ = False

data Type 
    = TypePrimitive Primitive [(String,Integer,String)]
    | TypeClassId ClassIdentifier [(String,Integer,String)]
    | TypeListClassId ClassIdentifier
    | TypeListPrimitive Primitive
  deriving (Show, Eq)

data Variable 
    = VariableNoAssignment Type [Identifier]
    | VariableAssignmentLiteralOrVariable Type Identifier LiteralOrVariable
    | VariableAssignment1D Type Identifier [LiteralOrVariable]
    | VariableAssignment2D Type Identifier [[LiteralOrVariable]]
    | VariableAssignmentObject Type Identifier ObjectCreation
    | VariableListAssignment Type Identifier ListAssignment
  deriving (Show, Eq)

data ObjectCreation 
    = ObjectCreation ClassIdentifier [Params]
  deriving (Show, Eq)

data ListAssignment 
    = ListAssignmentArray [LiteralOrVariable]
    | ListAssignmentRange Integer Integer
  deriving (Show, Eq)

data Class 
    = ClassInheritance ClassIdentifier ClassIdentifier ClassBlock
    | ClassNormal ClassIdentifier ClassBlock
  deriving (Show, Eq)

data ClassBlock 
    = ClassBlock [ClassMember] ClassConstructor
    | ClassBlockNoConstructor [ClassMember]
  deriving (Show, Eq)

data ClassMember
    = ClassMemberAttribute ClassAttribute
    | ClassMemberFunction ClassFunction
  deriving (Show, Eq) 

data ClassAttribute 
    = ClassAttributePublic Variable
    | ClassAttributePrivate Variable
  deriving (Show, Eq)

data ClassFunction 
    = ClassFunctionPublic Function
    | ClassFunctionPrivate Function
  deriving (Show, Eq)

data ClassConstructor 
    = ClassConstructorEmpty
    | ClassConstructor [(Type,Identifier)] Block
  deriving (Show, Eq)

data LiteralOrVariable 
    = VarIdentifier Identifier
    | IntegerLiteral Integer
    | DecimalLiteral Decimal
    | StringLiteral String
    | BoolLiteral Bool
  deriving (Eq)

  -- deriving (Show,Eq)

instance Show LiteralOrVariable where
    show (VarIdentifier identifier) = id identifier
    show (IntegerLiteral integer) =  id $ show integer
    show (DecimalLiteral dec) =  id $ show dec
    show (StringLiteral str) = id $ str
    show (BoolLiteral bool) = id $ show bool

data Block 
    = Block [Statement]
  deriving (Show, Eq)  

data ArrayAccess
    = ArrayAccessExpression Expression
  deriving (Show,Eq)



data Params
    = ParamsExpression Expression
  deriving (Show,Eq)

data Statement
    = AssignStatement Assignment
    | DisplayStatement [Display]
    | ReadStatement Reading
    | DPMStatement Assignment
    | FunctionCallStatement FunctionCall
    | ReturnStatement Return
    | VariableStatement Variable
    | ConditionStatement If
    | CycleStatement Cycle
  deriving (Show,Eq)

data Assignment
    = AssignmentExpression Identifier Expression
    | AssignmentFunctionCall Identifier FunctionCall
    | AssignmentObjectMember Identifier ObjectMember
    | AssignmentObjectMemberExpression ObjectMember Expression
    -- | AssignmentObjectFuncCall ObjectMember FunctionCall
    -- | ObjMemAssignObjMem ObjectMember ObjectMember
    | AssignmentArrayExpression Identifier [ArrayAccess] Expression
    -- | VarArrayAssignFunctionCall Identifier [ArrayAccess] FunctionCall
    -- | VarArrayAssignObjMem Identifier [ArrayAccess] ObjectMember
    -- | ObjMemArrayAssignExpression ObjectMember [ArrayAccess] Expression
    -- | ObjMemArrayAssignFunctionCall ObjectMember [ArrayAccess] FunctionCall
    -- | ObjMemArrayAssignObjMem ObjectMember [ArrayAccess] ObjectMember
  deriving(Show,Eq)

data Reading
    = Reading Identifier
  deriving(Show,Eq)

data Display
    = DisplayLiteralOrVariable LiteralOrVariable Operation 
    | DisplayObjMem ObjectMember Operation
    | DisplayFunctionCall FunctionCall Operation
    | DisplayVarArrayAccess Identifier [ArrayAccess] Operation
   deriving(Show,Eq) 

data Expression
    = ExpressionGreater Expression Expression
    | ExpressionLower Expression Expression
    | ExpressionGreaterEq Expression Expression
    | ExpressionLowerEq Expression Expression
    | ExpressionEquals Expression Expression
    | ExpressionEqEq Expression Expression 
    | ExpressionNotEq Expression Expression 
    | ExpressionAnd Expression Expression
    | ExpressionOr Expression Expression 
    | ExpressionPlus Expression Expression 
    | ExpressionMinus Expression Expression
    | ExpressionDiv Expression Expression
    | ExpressionMult Expression Expression
    | ExpressionPow Expression Expression
    | ExpressionMod Expression Expression
    | ExpressionVarArray Identifier [ArrayAccess]
    | ExpressionNot Expression 
    | ExpressionLitVar LiteralOrVariable
    | ExpressionNeg Expression 
    | ExpressionPars Expression
    | ExpressionFuncCall FunctionCall
  deriving(Show, Eq)


class ExpressionOperation a where
   (|+|) :: a -> a -> a
   (|*|) :: a -> a -> a
   (|-|) :: a -> a -> a
   (|/|) :: a -> a -> a
   (|^|) :: a -> a -> a
   (|==|) :: a -> a -> a
   (|!=|) :: a -> a -> a
   (|&&|) :: a -> a -> a
   (|-||-|) :: a -> a -> a
   (|%|) :: a -> a -> a
   (|!|) :: a -> a
   (|>|) :: a -> a -> a
   (|<|) :: a -> a -> a
   (|>=|) :: a -> a -> a
   (|<=|) :: a -> a -> a



instance ExpressionOperation Expression where
   a |+| b = (ExpressionPlus a b)
   a |*| b = (ExpressionMult a b)
   a |-| b = (ExpressionMinus a b)
   a |/| b = (ExpressionDiv a b)
   a |^| b = (ExpressionPow a b)
   a |==| b = (ExpressionEqEq a b)
   a |!=| b = (ExpressionNotEq a b)
   a |&&| b = (ExpressionAnd a b)
   a |-||-| b = (ExpressionOr a b)
   a |>| b = (ExpressionGreater a b)
   a |<| b = (ExpressionLower a b)
   a |>=| b = (ExpressionGreaterEq a b)
   a |<=| b = (ExpressionLowerEq a b)
   a |%| b = (ExpressionMod a b)
   (|!|) a   = (ExpressionNot a)
   

data If
    = If Expression Block
    | IfElse Expression Block Block
  deriving(Show,Eq)


data Cycle
    = CycleWhile While
    | CycleFor For
    | CycleForVar [Statement]
  deriving(Show,Eq)

data While
    = While Expression Block
  deriving(Show,Eq)

data For
    = For Integer Integer Block
  deriving(Show,Eq)


data FunctionCall
    = FunctionCallObjMem ObjectMember [Params]
    | FunctionCallVar Identifier [Params]
  deriving(Show,Eq)

data ObjectMember
    = ObjectMember Identifier Identifier
  deriving(Show,Eq)

data Return
    = ReturnFunctionCall FunctionCall
    | ReturnExp Expression 
  deriving(Show,Eq)

startIntGlobalMemory = 1
endIntGlobalMemory = 100000000000000000000000000000000000000000000000000

startDecimalGlobalMemory = 100000000000000000000000000000000000000000000000001
endDecimalGlobalMemory = 200000000000000000000000000000000000000000000000000

startStringGlobalMemory = 200000000000000000000000000000000000000000000000001
endStringGlobalMemory = 300000000000000000000000000000000000000000000000000

startBoolGlobalMemory = 300000000000000000000000000000000000000000000000001
endBoolGlobalMemory = 400000000000000000000000000000000000000000000000000

startIntLocalMemory = 400000000000000000000000000000000000000000000000001
endIntLocalMemory = 500000000000000000000000000000000000000000000000000

startDecimalLocalMemory = 500000000000000000000000000000000000000000000000001
endDecimalLocalMemory = 600000000000000000000000000000000000000000000000000

startStringLocalMemory = 600000000000000000000000000000000000000000000000001
endStringLocalMemory = 700000000000000000000000000000000000000000000000000

startBoolLocalMemory = 700000000000000000000000000000000000000000000000001
endBoolLocalMemory = 800000000000000000000000000000000000000000000000000

startIntLiteralMemory = 800000000000000000000000000000000000000000000000001
endIntLiteralMemory = 900000000000000000000000000000000000000000000000000

startDecimalLiteralMemory = 900000000000000000000000000000000000000000000000001
endDecimalLiteralMemory = 1000000000000000000000000000000000000000000000000000

startStringLiteralMemory = 1000000000000000000000000000000000000000000000000001
endStringLiteralMemory = 1100000000000000000000000000000000000000000000000000

startBoolLiteralMemory = 1100000000000000000000000000000000000000000000000001
endBoolLiteralMemory = 1200000000000000000000000000000000000000000000000000

startObjectLocalMemory = 1200000000000000000000000000000000000000000000000001
endObjectLocalMemory = 1300000000000000000000000000000000000000000000000000

startObjectGlobalMemory = 1300000000000000000000000000000000000000000000000001
endObjectGlobalMemory = 1400000000000000000000000000000000000000000000000000

-- startIntGlobalMemory = 1
-- endIntGlobalMemory = 4000

-- startDecimalGlobalMemory = 4001
-- endDecimalGlobalMemory = 8000

-- startStringGlobalMemory = 8001
-- endStringGlobalMemory = 12000

-- startBoolGlobalMemory = 12001
-- endBoolGlobalMemory = 16000

-- startIntLocalMemory = 16001
-- endIntLocalMemory = 20000

-- startDecimalLocalMemory = 20001
-- endDecimalLocalMemory = 24000

-- startStringLocalMemory = 24001
-- endStringLocalMemory = 26000

-- startBoolLocalMemory = 26001
-- endBoolLocalMemory = 30000

-- startIntLiteralMemory = 64001
-- endIntLiteralMemory = 68000

-- startDecimalLiteralMemory = 68001
-- endDecimalLiteralMemory = 72000

-- startStringLiteralMemory = 76001
-- endStringLiteralMemory = 80000

-- startBoolLiteralMemory = 80001
-- endBoolLiteralMemory = 84000

-- startObjectLocalMemory = 84001
-- endObjectLocalMemory = 88000

-- startObjectGlobalMemory = 100001
-- endObjectGlobalMemory = 104000


-- Operation dice la operacion que hará el cuádruplo
data Operation = 
        -- Expression Operators
          GT_
        | LT_
        | GTEQ_
        | LTEQ_
        | EQ_
        | NOTEQ_
        | AND_
        | OR_      
        | ADD_
        | SUB_ 
        | MULTIPLY_
        | DIVIDE_
        | NEG_
        | NOT_
        | MOD_
        | POWER_
        -- Assignment Operators
        | ASSIGNMENT
        -- Flow Control Operators
        | GOTO
        | GOTO_IF_FALSE
        | GOTO_IF_TRUE
        | GOTO_NORMAL
        | DISPLAY
        | DISPLAY_LINE
        | READ
        | NOP
        | FOR
        | INT_64
        | DOUBLE
        | BOUNDS
        | ADD_INDEX
        | ACCESS_INDEX -- ACCESS_INDEX (2002) _ ADDRESS Esto sirve para que el valor que haya en 2002 se ponga a dentro de address
        | PUT_INDEX -- PUT_INDEX ADDRESS_VALOR _ (2002) Esto sirve para que el valor se ponga a dentro del 2002
        | DISPLAY_VALUE_IN_INDEX
      deriving(Eq)

instance Show Operation where
    show op = case op of
        GT_  -> id ">"
        LT_  -> id "<"
        GTEQ_  -> id ">="
        LTEQ_  -> id "<=" 
        EQ_  -> id "=="
        NOTEQ_  -> id "!="
        AND_  -> id "&&"
        OR_  -> id "||"
        ADD_  -> id "+" 
        SUB_  -> id "-"
        MULTIPLY_  -> id "*"
        DIVIDE_  -> id "/"
        NEG_  -> id "NEG"
        NOT_  -> id "!" 
        MOD_  -> id "%"
        POWER_  -> id "POW"
        GOTO  -> id "GOTO"
        GOTO_IF_FALSE  -> id "GOTO_F"
        GOTO_IF_TRUE  -> id  "GOTO_T" 
        ASSIGNMENT  -> id  "="
        DISPLAY -> id "PRINT"
        DISPLAY_LINE -> id "PRINTLN"
        READ -> id "READ"
        NOP -> id "NOP"
        FOR -> id "FOR"
        INT_64 -> id "INT_64"
        DOUBLE -> id "DOUBLE"
        BOUNDS -> id "BOUNDS"
        ADD_INDEX -> id "ADD_INDEX"
        ACCESS_INDEX -> id "ASSIGNMENT_FROM_INDEX"
        PUT_INDEX -> id "PUT_INDEX"
        DISPLAY_VALUE_IN_INDEX -> id "DISPLAY_VAL_IN_INDEX"

intToDecimal :: Integer -> Decimal
intToDecimal int = let num = show(int)
                    in (strToDecimal num)

strToDecimal :: String -> Decimal
strToDecimal str = read str :: Decimal

decToDouble :: (DecimalRaw Integer) -> Double 
decToDouble dec = let num = show(dec)
                    in (strToDouble num)

strToDouble :: String -> Double
strToDouble str = read str :: Double

intToDouble :: Integer -> Double
intToDouble int = let num = show(int)
                  in (strToDouble num)


doubleToDecimal :: Double -> Decimal
doubleToDecimal doub = let num = show(doub)
                        in (strToDecimal num)

decToInt :: Decimal -> Integer
decToInt dec = let num = show(roundTo 0 dec)
                  in (strToInt num)

strToInt :: String -> Integer
strToInt str = read str :: Integer 


