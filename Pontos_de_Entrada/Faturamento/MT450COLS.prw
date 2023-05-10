/*====================================================================================\
|Programa  | MT450COLS()  | Autor  | Reginaldo Borges   | Data |         14/08/2019   |
|=====================================================================================|
|Descrição | Ponto de entrada para alteração da linha do acols antes da               |
|          | apresentação da tela de Liberação Manual, o ponto recebe como parametro  |
|          | o aHeader e a linha do aCols e deve obrigatóriamente retornar a linha do |
|          | acols alterada.                                                          |
|=====================================================================================|
|Uso       | Especifico Financeiro.                                                       |
|=====================================================================================|
|Histórico | 																		  |
\====================================================================================*/
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'


User Function MT450COLS()
Local _aHeader := PARAMIXB[1] 
Local _aCols   := PARAMIXB[2]
Local cNomGrp  := AllTrim(Posicione('ACY',1,xFilial('ACY')+SA1->A1_GRPVEN,'ACY_DESCRI'))

_aCols[6][1]:= _aCols[7][1]
_aCols[6][2]:= _aCols[7][2]
_aCols[6][3]:= _aCols[7][3]

_aCols[7][1]:= " "
_aCols[7][2]:= " "
_aCols[7][3]:= " "

_aCols[8][1]:= "Grupo Cliente"
_aCols[8][2]:= PADC(SA1->A1_GRPVEN,27)
_aCols[8][3]:= cNomGrp

_aCols[9][1]:= " "
_aCols[9][2]:= " "
_aCols[9][3]:= " "

Return _aCols