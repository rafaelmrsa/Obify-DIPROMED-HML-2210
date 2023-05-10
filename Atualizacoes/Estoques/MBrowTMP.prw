#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MBROWTMP  ºAutor  ³Microsiga           º Data ³  12/10/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função feita com arquivo temporário para não comprometer o º±±
±±º          ³ desempenho utilizando a tabela SB8 direto.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DipAprPro()    
Local _cUM 			:= ""
Local _cDescri 		:= ""  
Local cSQL 			:= ""
Private cCadastro 	:= "Cadastro Especifico"
Private cDelFunc 	:= "AllwaysTrue"
Private aCampo 		:= {}
Private _aStruct 	:= {}
Private _cArq		:= ""
Private _cIndex		:= ""
Private _cChave		:= ""
Private aRotina 	:= {{"Enviar Promoção"    ,"u_DipEnvPro()",0,4},;
                    	{"Descartar"          ,"u_DipDesPro()",0,4},;
	                    {"Retornar p/ estoque","u_DipRetPro()",0,4},;
	                    {"Legenda"			  ,"u_DipBrwLeg()",0,4}}
Private aCores  	:= {}                     

aAdd(aCores, {'RB_XSTATUS=="1"','BR_VERDE'} )
aAdd(aCores, {'RB_XSTATUS=="2"','BR_VERMELHO'} )

_aStruct:={}
aAdd(_aStruct,{"RB_FILIAL" ,"C",02,0})   
aAdd(_aStruct,{"RB_XSTATUS","C",01,0})
aAdd(_aStruct,{"RB_PRODUTO","C",15,0})
aAdd(_aStruct,{"RB_DESCRIC","C",60,0})
aAdd(_aStruct,{"RB_UNIDADE","C",02,0})
aAdd(_aStruct,{"RB_LOTECTL","C",10,0})
aAdd(_aStruct,{"RB_QTDBLOQ","N",12,2})
aAdd(_aStruct,{"RB_DTVALID","D",08,0})

_cArq := Criatrab(_aStruct,.T.)
dbUseArea(.T.,,_cArq,"TRBBLQ")   

cSQL := " SELECT "
cSQL += " 	B8_FILIAL, B8_XSTATUS, B8_PRODUTO, B8_LOTECTL, B8_DTVALID, DD_SALDO, B8_EMPENHO "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SDD")+", "+RetSQLName("SB8")
cSQL += " 		WHERE "
cSQL += " 			DD_FILIAL  = '"+xFilial("SDD")+"' AND "
cSQL += " 			DD_SALDO   > 0 AND "
cSQL += " 			DD_MOTIVO  = 'ND' AND "
cSQL += " 			DD_FILIAL  = B8_FILIAL AND "
cSQL += " 			DD_PRODUTO = B8_PRODUTO AND "
cSQL += " 			DD_LOCAL   = B8_LOCAL AND "
cSQL += " 			DD_LOTECTL = B8_LOTECTL AND "
cSQL += " 			B8_SALDO   > 0 AND "
cSQL += " 			B8_XSTATUS <> ' ' AND "
cSQL +=  			RetSQLName("SDD")+".D_E_L_E_T_ = ' ' AND "
cSQL +=  			RetSQLName("SB8")+".D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSB8",.T.,.T.)     

TCSETFIELD("QRYSB8","B8_DTVALID"  ,"D",8,0)
TCSETFIELD("QRYSB8","DD_SALDO"    ,"N",12,2)
                            
SB1->(dbSetOrder(1))
While !QRYSB8->(Eof())      
	_cUM	 := ""
	_cDescri := ""
	
	If SB1->(dbSeek(xFilial("SB1")+QRYSB8->B8_PRODUTO))
		_cUM     := SB1->B1_UM
		_cDescri := SB1->B1_DESC
	EndIf
	
	TRBBLQ->(RecLock("TRBBLQ",.T.))
		TRBBLQ->RB_FILIAL  := QRYSB8->B8_FILIAL
		TRBBLQ->RB_XSTATUS := QRYSB8->B8_XSTATUS
		TRBBLQ->RB_PRODUTO := QRYSB8->B8_PRODUTO
		TRBBLQ->RB_DESCRIC := _cDescri
		TRBBLQ->RB_UNIDADE := _cUM
		TRBBLQ->RB_LOTECTL := QRYSB8->B8_LOTECTL
		TRBBLQ->RB_QTDBLOQ := QRYSB8->DD_SALDO
		TRBBLQ->RB_DTVALID := QRYSB8->B8_DTVALID           
		TRBBLQ->RB_REC 	   := QRYSB8->REC
	TRBBLQ->(MsUnLock())          
	
	QRYSB8->(dbSkip())
EndDo
QRYSB8->(dbCloseArea())

_cIndex := Criatrab(Nil,.F.)
_cChave := "RB_FILIAL+RB_XSTATUS+RB_PRODUTO+DTOS(RB_DTVALID)"
         
dbSelectArea("TRBBLQ")
Indregua("TRBBLQ",_cIndex,_cChave,,,"Selecionando Registros...")
dbSetIndex(_cIndex+Ordbagext())

aCampos:={{"Produto"  ,"RB_PRODUTO","C",15,0,"@!"},;
		  {"Descrição","RB_DESCRIC","C",50,0,"@!"},;
          {"UM"		  ,"RB_UNIDADE","C",02,0,"@!"},;
          {"Qtd."	  ,"RB_QTDBLOQ","N",12,2,"@E 9,999,999.99"},;
          {"Lote"	  ,"RB_LOTECTL","C",10,0,"@!"},;          
          {"Validade" ,"RB_DTVALID","D",08,0,"@D"}}

MBrowse( 6,1,22,75,"TRBBLQ",acampos,,,,,aCores)

dbCloseArea("TRBBLQ")
FERASE(_cArq+".DBF")
FERASE(_cIndex+Ordbagext())

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MBROWTMP  ºAutor  ³Microsiga           º Data ³  12/11/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DipEnvPro()
Alert("EnvPro")
Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MBROWTMP  ºAutor  ³Microsiga           º Data ³  12/11/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DipDesPro()
Alert("DesPro")
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MBROWTMP  ºAutor  ³Microsiga           º Data ³  12/11/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DipRetPro()

If Aviso("Atenção","Confirma o retorno do produto "+AllTrim(TRBBLQ->RB_PRODUTO)+"-"+AllTrim(TRBBLQ->RB_DESCRIC)+" para venda normal?",{"Sim","Não"},2)==1
	SB8->(dbGoTo(TRBBLQ->RB_REC))
	SB8->(RecLock("SB8",.F.))   
		SB8->B8_XSTATUS := "5" // Retornou para o Estoque
		SB8->B8_XDATVAL := STOD(dDataBase)
		SB8->B8_XUSAVAL := Upper(u_DipUsr())
	SB8->(MsUnLock())        
	Aviso("Atenção","Produto retornou para o estoque.",{"Ok"},1)
EndIf
	
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MBROWTMP  ºAutor  ³Microsiga           º Data ³  12/15/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DipBrwLeg()
Local aLegenda:={}

aAdd(aLegenda,{'BR_VERDE'	,"Validade maior do que 2 meses"})// 1
aAdd(aLegenda,{'BR_VERMELHO',"Validade menor ou igual a 2 meses"  })// 2

BrwLegenda("Avaliação de Produtos","Status",aLegenda)

Return  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MBROWTMP  ºAutor  ³Microsiga           º Data ³  12/20/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DipPromo(lConsulta,lFiltra,cTpMsg)  
Local lRet       := .T.    
Local cSQL       := ""
Local oDlg                                 
Local bOk 		 := {|| If(lConsulta,oDlg:End(),If(u_DipProOk(),oDlg:End(),nil))}
Local bCancel 	 := {|| oDlg:End()}
Local nPosProd   := aScan(aHeader,{|x|Alltrim(x[2])=="C6_PRODUTO"})
Local nPosLot    := aScan(aHeader,{|x|Alltrim(x[2])=="C6_LOTECTL"})
Private aHeadPro := {}
Private aColsPro := {}
Private oGetPromo   
DEFAULT lConsulta:= .F.      
DEFAULT lFiltra  := .F.
DEFAULT cTpMsg	 := ""


If !("DIPAL10" $ FUNNAME()) .AND. !("TMK"$FunName()) 
	
	If !Empty(aCols[n,nPosLot])
		Aviso("Atenção","Este produto já possui um lote promocional informado",{"Ok"},1)
		lRet := .F.
	EndIf 
	
	If lRet	
		aObjects := {}
		
		aSize   := MsAdvSize()
		aAdd(aObjects, {100, 100, .T., .T.})
		
		aInfo   := {aSize[1], aSize[2], aSize[3], aSize[4], 2, 2}
		aPosObj := MsObjSize(aInfo, aObjects)          
		
		aAdd(aHeadPro,{"Código"	   		,"B8_PRODUTO","@!"			   ,15,0,"","€€€€€€€€€€€€€€","C","","" })
		aAdd(aHeadPro,{"Descrição" 		,"B1_DESC"   ,"@!"			   ,60,0,"","€€€€€€€€€€€€€€","C","","" })
		aAdd(aHeadPro,{"Lote"	   		,"B8_LOTECTL","@!"			   ,10,0,"","€€€€€€€€€€€€€€","C","","" })
		aAdd(aHeadPro,{"Validade"  		,"B8_DTVALID","@D"		       ,8 ,0,"","€€€€€€€€€€€€€€","D","","" })
		aAdd(aHeadPro,{"Qtd Disponível"	,"B8_XSALPRO","@E 9,999,999.99",12,2,"","€€€€€€€€€€€€€€","N","","" })
		aAdd(aHeadPro,{"Desconto %"		,"B8_XPERPRO","@E 999%"		   ,3 ,0,"","€€€€€€€€€€€€€€","N","","" }) 
		aAdd(aHeadPro,{"Valor"	   		,"B1_VALOR"  ,"@E 9,999,999.99",12,2,"","€€€€€€€€€€€€€€","N","","" })
		aAdd(aHeadPro,{"Com Desc" 		,"DESCONTO"  ,"@E 9,999,999.99",12,2,"","€€€€€€€€€€€€€€","N","","" }) 
		aAdd(aHeadPro,{"Comissão" 		,"COMISSAO"  ,"@E 999%"		   ,3 ,0,"","€€€€€€€€€€€€€€","N","","" }) 
		
		cSQL := " SELECT "
		cSQL += " 	B8_PRODUTO, B1_DESC, B8_LOTECTL, B8_DTVALID, B8_XSALPRO, CASE WHEN B1_PRVSUPE>0 AND B1_PRVSUPE<B1_PRVMINI THEN B1_PRVSUPE ELSE B1_PRVMINI END "
		cSQL += "  	B1_VALOR, B8_XPERPRO "
		cSQL += " 	FROM "
		cSQL += 		RetSQLName("SB8")+", "+RetSQLName("SB1")
		cSQL += " 		WHERE "
		cSQL += " 			B8_FILIAL 	= '"+xFilial("SB8")+"' AND "  
		If !lConsulta .Or. lFiltra
			cSQL += " 			B8_PRODUTO 	= '"+aCols[n,nPosProd]+"' AND "
		EndIf
		//cSQL += " 			B8_XSTATUS 	= '3' AND "
		cSQL += " 			B8_XSALPRO	> 0 AND "    
		cSQL += "			B1_FILIAL 	= B8_FILIAL AND "		
		cSQL += "			B1_COD 		= B8_PRODUTO AND "
		cSQL +=  			RetSQLName("SB1")+".D_E_L_E_T_ = ' ' AND "
		cSQL +=  			RetSQLName("SB8")+".D_E_L_E_T_ = ' ' "
		cSQL += " ORDER BY B1_DESC, B8_DTVALID "	
		
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYPRO",.T.,.T.)     
	
		TCSETFIELD("QRYPRO","B8_DTVALID","D",8,0)
		                       
		If !QRYPRO->(Eof())          
			If cTpMsg=="1"
				Aviso("Atenção","Existem itens, com validade entre 2 e 6 meses, em promoção no sistema."+CHR(10)+CHR(13)+;
								"Comissão fixada em 10% para a venda de qualquer lote contido na lista."+CHR(10)+CHR(13)+;
								"Os descontos variam de 10% a 40%."+CHR(10)+CHR(13)+;
								"Para escolher um lote em promoção, informe o produto desejado e pressione F11 na linha de itens do pedido.",{"Ok"},3)
			ElseIf cTpMsg=="2"
				Aviso("Atenção","Este produto, possui lote(s) em promoção no sistema."+CHR(10)+CHR(13)+;
								"Comissão fixada em 10% para a venda de qualquer lote contido na lista."+CHR(10)+CHR(13)+;
								"Os descontos variam de 10% a 40%."+CHR(10)+CHR(13)+;
								"Para escolher um lote em promoção, pressione F11.",{"Ok"},3)
			EndIf   
			
			While !QRYPRO->(Eof())  
			
				aAdd(aColsPro,{ QRYPRO->B8_PRODUTO,;
								QRYPRO->B1_DESC,;   
							 	QRYPRO->B8_LOTECTL,;				 				 				
							 	QRYPRO->B8_DTVALID,;               
							 	QRYPRO->B8_XSALPRO,;
							 	QRYPRO->B8_XPERPRO,;
							 	QRYPRO->B1_VALOR,;						 	
						 		QRYPRO->B1_VALOR-(QRYPRO->B1_VALOR*QRYPRO->B8_XPERPRO/100),;
						 		10,;
							 	.F.})                          
							 
				QRYPRO->(dbSkip())
			EndDo 
				
			DEFINE MSDIALOG oDlg TITLE "Lotes em promoção" From aSize[7],005 TO aSize[6],aSize[5] OF oMainWnd PIXEL      
				oGetPromo:=MsNewGetDados():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4],0,'AllWaysTrue','AllWaysTrue',,,/*freeze*/,999,'AllWaysTrue',/*superdel*/,/*delok*/,oDlg,@aHeadPro,@aColsPro)
				oGetPromo:oBrowse:bAdd    := {|| .F. }      // Nao Permite a inclusao de Linhas
				oGetPromo:oBrowse:bDelete := {|| .F. }	     // Nao Permite a deletar Linhas
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel)
		EndIf                                                           
		QRYPRO->(dbcloseArea())
	EndIf	   
EndIf
                                                         
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MBROWTMP  ºAutor  ³Microsiga           º Data ³  12/21/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DipProOk()  
Local lRet    	 := .F.
Local nPosLot 	 := aScan(aHeader, {|x|Alltrim(x[2])=="C6_LOTECTL"}) 
Local nPosPrc    := aScan(aHeader, {|x|Alltrim(x[2])=="C6_PRCVEN" }) 
Local nPosQtd    := aScan(aHeader, {|x|Alltrim(x[2])=="C6_QTDVEN" })  
Local nPosTot    := aScan(aHeader, {|x|Alltrim(x[2])=="C6_VALOR"  })
Local nPosTAB  	 := aScan(aHeader, {|x|Alltrim(x[2])=="C6_PRUNIT" }) 
Local nPosCSis   := aScan(aHeader, {|x|Alltrim(x[2])=="C6_XCALCSI"})
Local nPosComis  := aScan(aHeader, {|x|Alltrim(x[2])=="C6_COMIS1"})
Local nPosQtdPro := aScan(aHeadPro,{|x|Alltrim(x[2])=="B8_XSALPRO"})
Local nPosLotPro := aScan(aHeadPro,{|x|Alltrim(x[2])=="B8_LOTECTL"})
Local nPosLotVal := aScan(aHeadPro,{|x|Alltrim(x[2])=="DESCONTO"})
Local aBoxParam  := {}
Local aRetParam  := {}

aAdd(aBoxParam,{1,"Informe a Quantidade:",0,"@E 99,999,999","","","",80,.T.})  

If ParamBox(aBoxParam,"Informe a Quantidade",@aRetParam,,,,,,,,.F.)
	If mv_par01 > aColsPro[oGetPromo:nAt,nPosQtdPro]
		Aviso("Atenção","Quantidade maior do que a do lote escolhido",{"Ok"},1)
	ElseIf u_VldCxFech(aCols,aHeader,n,mv_par01)
		aCols[n,nPosQtd]  := mv_par01 
		aCols[n,nPosLot]  := aColsPro[oGetPromo:nAt,nPosLotPro]    
		aCols[n,nPosPrc]  := aColsPro[oGetPromo:nAt,nPosLotVal]
		aCols[n,nPosTAB]  := aCols[n,nPosPrc]
		aCols[n,nPosTot]  := Round(aCols[n,nPosPrc]*aCols[n,nPosQtd],2)
		aCols[n,nPosCSis] := aCols[n,nPosPrc]
		aCols[n,nPosComis]:= 10
			
		Ma410Rodap(,,0)
		
		If ( Type("l410Auto") == "U" .OR. !l410Auto )
			oGetDad:oBrowse:Refresh()
		EndIf   
			
		lRet := .T.
	EndIf
EndIf

Return lRet   