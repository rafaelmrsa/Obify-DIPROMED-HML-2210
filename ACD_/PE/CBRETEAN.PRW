#INCLUDE 'RWMAKE.CH'
#INCLUDE 'APVT100.CH'
#INCLUDE "TOPCONN.CH"
/*                                                                                                                                                                       fonte
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CBRETEAN  ºAutor  ³ Emerson Leal Bruno º Data ³  11/11/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada no momento da separacao/enderecamento     º±±
±±º          ³ para validar o  codigo de barra                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ACD                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/            
User Function CBRETEAN()
Local lRet     := .F.
Local aRet     := {}
Local aArea    := GetArea()
Local aAreaSB1 := SB1->(GetArea())
Local aAreaSLK := SLK->(GetArea())
Local cCodBar  := Alltrim(PARAMIXB[1])
Local cProduto := Space(15)
Local cLote    := Space(10)
Local dDtValid := CTOD("  /  /  ")
Local nQtde    := 1      
Local lCodMaio := .F.

IF Empty(cCodBar)
   Return (aRet)
Endif             

If len(cCodBar) > 16     	
	lCodMaio := .T.
EndIf                  
             
If ! lCodMaio 
	// Pesquisa pelo B1_CODBAR
	DBSelectArea("SB1")
	DBSetOrder(5) //B1_FILIAL+B1_CODBAR
	IF DBSeek(xFilial("SB1")+cCodBar)
	   lRet     := .T.
	   cProduto := SB1->B1_COD
	Endif 
	
	// Pesquisa pelo B1_COD
	IF !lRet
	   DBSelectArea("SB1")
	   DBSetOrder(1) //B1_FILIAL+B1_COD
	   IF DBSeek(xFilial("SB1")+cCodBar)
	      lRet     := .T.
	      cProduto := SB1->B1_COD
	   Endif
	Endif      

	// Pesquisa pela Tabela de Codigos de Barra
	IF !lRet
	   DBSelectArea("SLK")
	   DBSetOrder(1) //1 LK_FILIAL+LK_CODBAR                            
	   IF DBSeek(xFilial("SLK")+cCodBar)
	      lRet     := .T.
	      cProduto := SLK->LK_CODIGO
	   Endif
	Endif
EndIf

IF lCodMaio 								//Tratamento para Adezan produto + lote                                                     
	If FunName() == "DLGV001" 				// conferencia pelo coletor pelo wms
	  	cProduto 	:= Substr(cCodBar,1,15)
	  	cLote 		:= Substr(cCodBar,16,10)
	  	nQtde 		:= 0  					//Substr(cCodBar,26,6)
	  	lRet		:= .T.
	Else 									//tratamento para leiturado no ACD para codigo de barra mair que 15, retornando 1 na qtde para o operar informar a qtde de quer.
	  	cProduto 	:= Substr(cCodBar,1,15)
	  	cLote 		:= Substr(cCodBar,16,10) //Tomar cuidado com o tamanho do lote vindo da leitura da etiqueta
	  	nQtde 		:= 1  					 //Substr(cCodBar,26,6)
	  	lRet		:= .T.
	EndIf                         
	
Else  							//tem que informar o codigo de barra do produto e informar a qtde passando abaixo como "0" e o operador coloca a qtde no coletor.                  
	If FunName() == "DLGV001" //Enderecamento pelo acd retorna 1 para informar a qtde a enderecar via coletor
		nQtde 		:= 0
	  	cLote 		:= Substr(cCodBar,16,10) //Tomar cuidado com o tamanho do lote vindo da leitura da etiqueta
	Else                                                                                                       
		nQtd  		:= 1   //Retorna 0 por causa da conferencia pelos wms para os Packs colombo.                   
	  	cLote 		:= Substr(cCodBar,16,10) //Tomar cuidado com o tamanho do lote vindo da leitura da etiqueta
	EndIf       
Endif  

//DLVTAviso('1', Padr(cProduto,15))
//DLVTAviso('2', str(len(Padr(cProduto,15))))
//DLVTAviso('3', Padr(cLote,10))      
//DLVTAviso('4', str(len(Padr(cLote,10))))      
      
IF lRet
   //codigo do produto,quantidade,lote,data de validade, numero de serie
   AAdd(aRet,Padr(cProduto,15))       	 //Codigo do produto
   AAdd(aRet,nQtde)			  			 //Quantidade
   AAdd(aRet,Padr(cLote,10))             //Lote
   AAdd(aRet,dDtValid)        			 //Data de validade
   AAdd(aRet,Space(20))       			 //Numero de Serie
//Else
//   cCodBar := Space(48)
Endif
   

// Tecla enter na conferencia ao informar produto+lote para nao ficar parando na tela do lote e validade.
If FunName() == "T_ACDV120" .AND. len(cCodBar) > 15
   VtKeyBoard(chr(13)) 
EndIf

RestArea(aAreaSB1)
RestArea(aAreaSLK)
RestArea(aArea)

Return (aRet)