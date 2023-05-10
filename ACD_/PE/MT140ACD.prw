/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT140ACD   ºAutor  ³Emerson Leal Bruno  Data ³  02/05/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada na inclusao  da pre nota para validar o   º±±
±±º          ³ produto que nao controla endereco a nem lote, para nao     º±±
±±º          ³ efetuar conferencia via pre nota							  		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ACD                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MT140ACD()

Local aArea    		:= GetArea()
Local aAreasSF1 	:= SF1->(GetArea())
Local aAreasSB1 	:= SB1->(GetArea())
Local I				:= 1
Local lExisteConf   :=.F.   

IF ALLTRIM((cFilAnt)) $ ('01|04')
	FOR I := 1 TO LEN(ACOLS)		
		DBSELECTAREA("SB1")
		DBSETORDER(1)  //B1_FILIAL+B1_COD
		DBSEEK(XFILIAL("SB1")+ACOLS[I][1])		

		IF SB1->B1_LOCALIZ == 'S' //.AND. SB1->B1_RASTRO == 'L'		
			lExisteConf:=.T.			
		ENDIF
		
	NEXT
EndIf

IF !lExisteConf //.f.
	SF1->F1_STATCON := '1' //Conferido
ENDIF

RestArea(aAreasSB1)
RestArea(aAreasSF1)
RestArea(aArea)

Return