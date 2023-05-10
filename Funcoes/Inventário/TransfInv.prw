#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO5     บAutor  ณMicrosiga           บ Data ณ  01/18/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function TransfInv()
Local cPerg		:= "DIPTRA"
Local cSQL 		:= ""
Local nQuant    := 0
Local cProduto  := "" 
Local aAreaSD3  := {}
Local lRet		:= .F.
Local aLog		:= {}
Local nI		:= 0               
Local cEND		:= CHR(10)+CHR(13) 

Private aDadosReq := {}      
Private aRegSDA := {}                  
Private cDocSD3   := ""              

If !(Upper(U_DipUsr()) $ 'MCANUTO/DDOMINGOS/VQUEIROZ/VEGON/RBORGES')
	Aviso("Aten็a๕","Usuแrio sem permissใo para executar a rotina.",{"Ok"},1)
	Return .F.	
EndIf

If cEmpAnt+cFilAnt<>'0101'
	Aviso("Aten็a๕","Executar a rotina na filial MTZ - 01",{"Ok"},1)
	Return .F.
EndIf

AjustaSX1(cPerg)

If !Pergunte(cPerg,.T.)
	Return
EndIf

Conout("Inventario inicio -> Data-"+DtoC(ddatabase)+" Hora-"+Time())              

cSQL := " SELECT "
cSQL += " 	BF_PRODUTO, BF_LOCALIZ, B2_LOCALIZ, BF_LOTECTL, BF_QUANT, BF_LOCAL, BF_EMPENHO, BF_QUANT AS SALDO, "
cSQL += " 	BF_NUMSERI, (CASE WHEN BF_LOCALIZ = B2_LOCALIZ THEN 'COMPIC' ELSE 'SEMPIC' END) AS PICKING "
cSQL += " 	FROM "
cSQL += " 		"+RetSQLName("SBF")+" SBF "
cSQL += " 			INNER JOIN  "
cSQL += " 				"+RetSQLName("SB2")+" SB2 "
cSQL += " 				ON "
cSQL += " 					B2_FILIAL 	 = '"+xFilial("SB2")+"' "
cSQL += " 					AND B2_LOCAL = BF_LOCAL "
cSQL += " 					AND B2_COD   =  BF_PRODUTO "
cSQL += " 					AND SB2.D_E_L_E_T_ = ' ' "
cSQL += " 			WHERE "
cSQL += " 				BF_FILIAL    	 = '"+xFilial("SBF")+"' "
cSQL += " 				AND BF_LOCAL     = '01' "
  
If !Empty(mv_par01)
	cSQL += " 			AND BF_PRODUTO = '"+AllTrim(mv_par01)+"' "
EndIf

cSQL += " 				AND SBF.D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY BF_PRODUTO, PICKING , SALDO DESC, BF_LOCALIZ, BF_LOTECTL "                

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSBF",.T.,.T.)

TCSETFIELD("QRYSBF","BF_QUANT" 		, "N" , 12 , 02)
TCSETFIELD("QRYSBF","BF_EMPENHO" 	, "N" , 12 , 02)
TCSETFIELD("QRYSBF","SALDO" 		, "N" , 12 , 02)

Begin Transaction
Begin Sequence

dbSelectArea("ZZ6")
ZZ6->(dbSetOrder(1))

While !QRYSBF->(Eof())
	
	Aadd(aDadosReq,{	QRYSBF->BF_PRODUTO,;
						QRYSBF->BF_LOCAL,;
						QRYSBF->BF_LOTECTL,;
						QRYSBF->BF_LOCALIZ,;
						QRYSBF->SALDO,;
						Posicione("SB8",3,xFILIAL("SB8")+QRYSBF->BF_PRODUTO+QRYSBF->BF_LOCAL+QRYSBF->BF_LOTECTL,"B8_DTVALID"),;
						0})						

	fGeraZZ6(QRYSBF->BF_LOCAL,QRYSBF->BF_LOCALIZ,QRYSBF->BF_PRODUTO,QRYSBF->BF_NUMSERI,QRYSBF->BF_LOTECTL)
						
	QRYSBF->(dbSkip())
EndDo
QRYSBF->(dbCloseArea())

/*
For nI := 1 to Len(aDadosReq)
	If aDadosReq[nI][6]+3 <= dDataBase .And. !Empty(DtoS(aDadosReq[nI][6]))
		aAdd(aLog, {aDadosReq[nI,1],aDadosReq[nI,3],aDadosReq[nI,4],aDadosReq[nI,5],aDadosReq[nI,6]})
	Endif
Next nI

If Len(aLog)>0
	cMsg := "### PRODUTOS VENCIDOS ###"+cEND
	cMsg += "PRODUTO     LOTE        LOCALIZ.    SALDO       VALID."+cEND
	
	For nI := 1 to Len(aLog)
     	cMsg += PADR(aLog[nI,1],12)
     	cMsg += PADR(aLog[nI,2],12)
 		cMsg += PADR(aLog[nI,3],12)
     	cMsg += PADR(Str(aLog[nI,4]),12)
     	cMsg += DtoC(aLog[nI,5])
     	cMsg += cEND     
	Next nI       
	                      
	If (Aviso("Aten็a๕",cMsg,{"Cancelar","Transferir"},3)) == 1
		Return .F.
	EndIf	
EndIf	                          
*/
                      
aAreaSD3 := SD3->(GetArea())

cDocSD3 := "INVENT000"
SD3->(DbSetOrder(8))
If SD3->(dbSeek(xFilial("SD3")+cDocSD3))
	While !SD3->(Eof()) .And. SD3->(dbSeek(xFilial("SD3")+cDocSD3))
		cDocSD3 := Soma1(cDocSD3)
		SD3->(dbSkip())
	EndDo
EndIf            
          
RestArea(aAreaSD3)

Processa({|lEnd| lRet := u_fGeraSD3("501",aDadosReq,cDocSD3)},"Efetuando a requisi็ใo do Produto...")

If lRet
	If cEmpAnt+cFilAnt == '0104'
		GetEmpr('0101')
	Else
		GetEmpr('0104')
	Endif
EndIf

If lRet
	Processa({|lEnd| lRet := u_fGeraSD3("497",aDadosReq,cDocSD3)},"Efetuando a entrada do Produto...")
EndIf

If lRet
	Processa({|lEnd| lRet := u_fEnder53(cDocSD3)},"Efetuando o endere็amento do Produto..")
EndIf

If lRet
	If cEmpAnt+cFilAnt == '0104'
		GetEmpr('0101')
	Else
		GetEmpr('0104')
	Endif
EndIf

If !lRet
	If InTransact()
		DisarmTransaction()
	EndIf
	Break
EndIf

End Sequence
End Transaction

Conout("Inventario processado -> Data-"+DtoC(ddatabase)+" Hora-"+Time())

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTRANSFINV บAutor  ณMicrosiga           บ Data ณ  01/18/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function fGeraZZ6(cLocal,cLocaliz,cProduto,cNumSeri,cLoteCTL)
Local _cDipFil   := ""
DEFAULT cLocal	 := ""
DEFAULT cLocaliz := ""
DEFAULT cProduto := ""
DEFAULT cNumSeri := ""
DEFAULT cLoteCTL := "" 

If cFilAnt == "01"
	_cDipFil := "04" 
Else 
	_cDipFil := "01" 	
EndIf  

SBF->(dbSetOrder(1))
If SBF->(dbSeek(_cDipFil+cLocal+cLocaliz+cProduto+cNumSeri+cLoteCTL))
	ZZ6->(RecLock("ZZ6",.T.))
		ZZ6->ZZ6_FILIAL  := _cDipFil
		ZZ6->ZZ6_LOCAL   := cLocal
		ZZ6->ZZ6_LOCALI := cLocaliz
		ZZ6->ZZ6_PRODUT := cProduto
		ZZ6->ZZ6_NUMSER := cNumSeri
		ZZ6->ZZ6_LOTECT := cLoteCTL
		ZZ6->ZZ6_QUANT	 := SBF->BF_QUANT
	ZZ6->(MsUnlock())
EndIf                               

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTRANSFINV บAutor  ณMicrosiga           บ Data ณ  01/18/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User function fGeraSD3(cTM,aDadosReq,cDocSD3,cDesc)
Local aArea_SB8 := SB8->(GetArea())
Local aArea     := GetArea()
Local lRet		:= .T.
Local cNumseq   := 0
Local _cLocaliz := ''
Local _NumLote  := ''
Local _cGera    := ''
Local _cEST     := ''
Local _DtValid  := cTod('')                 
Local _TesDev  	:= ""               
Local nId       := 0                    
Private aRegSD3 := {}
Private aCabSD3 := {}
DEFAULT aDadosReq := {}                     
DEFAULT cDocSD3   := ""
DEFAULT cDesc     := "TRANSFERENCIA AUTOMATICA ENTRE CD'S."
For nId := 1 to len(aDadosReq)

	Begin Sequence
	   
		cNumseq := ProxNum()         
		
		SB1->( Dbsetorder(1) )
		SB1->(Dbseek(xFilial("SB1")+aDadosReq[nId,1]))	
		If cTm == '501'
			 aDadosReq[nId,7]  := SB1->B1_CUSDIP * aDadosReq[nId,5] 
		Endif
				
		aadd(aRegSD3,{	{"D3_ITEM"		, StrZero(nId,2)    				   				,Nil},;      
						{"D3_COD"       , aDadosReq[nId,1]                  				,Nil},;      
						{"D3_LOCAL"     , aDadosReq[nId,2]                			       	,Nil},;
						{"D3_NUMSEQ"    , cNumSeq                            				,Nil},;
						{"D3_QUANT"     , aDadosReq[nId,5]                 				   	,Nil},;
						{"D3_CF"        , "RE0"                                           	,Nil},;
						{"D3_UM"        , SB1->B1_UM                              			,Nil},;
						{"D3_TIPO"     	, SB1->B1_TIPO                                      ,Nil},;
						{"D3_GRUPO"    	, SB1->B1_GRUPO                                   	,Nil},;
						{"D3_CUSTO1"   	, If(cTm=='501',0, aDadosReq[nId,7] )     			,Nil},;
						{"D3_CHAVE"    	, "E0"                                              ,Nil},;
						{"D3_USUARIO"  	, UPPER(U_DipUsr())    								,Nil},;    
						{"D3_ESTCIS"   	, "S"                                               ,Nil},;
						{"D3_CONTA"    	, SB1->B1_CONTA                                   	,Nil},;
						{"D3_SEGUM"    	, SB1->B1_SEGUM                                   	,Nil},;
						{"D3_QTSEGUM"  	, ConvUm(aDadosReq[nId,1], aDadosReq[nId,5] ,0,2 )	,Nil},;         
						{"D3_LOTECTL"   , aDadosReq[nId,3]                                  ,Nil},;
						{"D3_NUMLOTE"   , _NumLote                                          ,Nil},;
						{"D3_DTVALID"   , aDadosReq[nId,6]                                  ,Nil},;
						{"D3_LOCALIZ"   , aDadosReq[nId,4]                                  ,Nil},;
						{"D3_EXPLIC"    , If(cTm=='501',"", Alltrim(aDadosReq[nId,4])  +"    - ") + cDesc  ,Nil}})//Giovani Zago 23/04/12
		
		aCabSD3 :=  {	{"D3_FILIAL"    , xFILIAL("SB1")                       				,Nil},;
						{"D3_DOC"       , cDocSD3        									,Nil},;
						{"D3_TM"        , cTM                                               ,Nil},;
						{"D3_EMISSAO"   , dDatabase                                         ,Nil},;
						{"D3_CC"        , ""                                                ,Nil}}		            	
		
   End Sequence    
   
Next nId

If len(aCabSD3) > 0

    lMsErroAuto := .F.
    //MSExecAuto({|x,y,z| MATA240(x,y,z)},aReg,,3)   
    MSExecAuto({|x,y,z| MATA241(x,y,z)},aCabSD3,aRegSD3,3) 

    If lMsErroAuto 
    	DisarmTransaction()
    	MostraErro()   
    	lRet := .F.
    EndIf     

	If cTm == '501'       
		aRegSDA:= {}
    	aCabSD3 := {} // JBS 21/08/2010 - Limpa para nao gerar mais 
	    aRegSD3 := {} // JBS 21/08/2010 - Limpa para nao gerar mais 
	Endif
    
EndIf

SB8->(RestArea(aArea_SB8))
RestArea(aArea)
     
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTRANSFINV บAutor  ณMicrosiga           บ Data ณ  01/18/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function fEnder53(cDocSDA)
Local lRet    := .T.
Local cSeek   := ''
Local cLoteSDA:= ''
Local lRastro := ''
Local cItens  := '0000'                    
Local cLocaliz := ""
Local aArea     := GetArea()

Private aCabec:= {}
Private aItem := {}
Private aItens := {}

SDA->(dbSetFilter({|| SDA->DA_DOC== cDocSDA},"SDA->DA_DOC== cDocSDA"))

SDA->( DbGoTop() ) 

While !SDA->(Eof()) .And. lRet
	SB2->(dbSetFilter({|| SB2->B2_COD     == SDA->DA_PRODUTO},"SB2->B2_COD         ==SDA->DA_PRODUTO"))
	SBF->(dbSetFilter({|| SBF->BF_PRODUTO == SDA->DA_PRODUTO},"SBF->BF_PRODUTO==SDA->DA_PRODUTO"))
	SB8->(dbSetFilter({|| SB8->B8_PRODUTO == SDA->DA_PRODUTO},"SB8->B8_PRODUTO==SDA->DA_PRODUTO"))
	
	aCabec := {}
	aItem  := {}
	
	Aadd(aCabec, {"DA_PRODUTO"   , SDA->DA_PRODUTO          , nil})
	Aadd(aCabec, {"DA_QTDORI"      , SDA->DA_QTDORI           , nil})
	Aadd(aCabec, {"DA_SALDO"       , SDA->DA_SALDO            , nil})
	Aadd(aCabec, {"DA_DATA"         , SDA->DA_DATA             , nil})	
	Aadd(aCabec, {"DA_LOTECTL"      , SDA->DA_LOTECTL          , nil})
	Aadd(aCabec, {"DA_NUMLOTE"     , SDA->DA_NUMLOTE          , nil})	
	Aadd(aCabec, {"DA_LOCAL"        , SDA->DA_LOCAL            , nil})
	Aadd(aCabec, {"DA_DOC"            , SDA->DA_DOC              , nil})
	Aadd(aCabec, {"DA_SERIE"          , SDA->DA_SERIE            , nil})
	Aadd(aCabec, {"DA_CLIFOR"       , SDA->DA_CLIFOR           , nil})
	Aadd(aCabec, {"DA_LOJA"           , SDA->DA_LOJA             , nil})
	Aadd(aCabec, {"DA_TIPONF"        , SDA->DA_TIPONF           , nil})
	Aadd(aCabec, {"DA_ORIGEM"       , SDA->DA_ORIGEM           , nil})
	Aadd(aCabec, {"DA_NUMSEQ"      , SDA->DA_NUMSEQ           , nil})
	Aadd(aCabec, {"DA_QTSEGUM"    , SDA->DA_QTSEGUM          , nil})
	Aadd(aCabec, {"DA_QTDORI2"      , SDA->DA_QTDORI2          , nil})
	
	aITem  := {}
	aITens := {}
	cItens := '0'
	aNfeITE := {}
	
	cItens := STRZERO(VAL(cItens)+1,4)
	
	cLocaliz := substr(Alltrim(Posicione("SD3",8,xFilial("SD3")+SDA->DA_DOC+SDA->DA_NUMSEQ,"D3_EXPLIC")),1,8)
	
	AAdd(aNfeIte,{	{"DB_ITEM"     , cItens        , NIL},;
					{"DB_LOCALIZ"  , cLocaliz      , NIL},;
					{"DB_NUMSERI"  , ''            , nil},;
					{"DB_QUANT"    , SDA->DA_SALDO , NIL},;
					{"DB_HRINI"    , Time()        , NIL},;
					{"DB_DATA"     , ddatabase     , NIL},;
					{"DB_ESTORNO"  , ''            , NIL},;
					{"DB_QTSEGUM"  , 0             , NIL} } )
	
	lMsErroAuto := .F.
	
	MsExecAuto({|x,y,z| mata265(x,y,z)}, aCabec, aNfeITE, 3 ) // 3-Distribui, 4-Estorna
	
	IF lMsErroAuto
		DisarmTransaction()
		MostraErro()
		lRet := .F.
	Endif
	
	SB2->(dbSetFilter({|| .t.},".t."))
	SBF->(dbSetFilter({|| .t.},".t."))
	SB8->(dbSetFilter({|| .t.},".t."))
	
	SDA->(Dbskip())	
EndDo                                   

SDA->(dbSetFilter({|| .t.},".t."))
aCabSD3 := {}
aRegSD3 := {}                     

RestArea(aArea)

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAjustaSX1 บAutor  ณMicrosiga           บ Data ณ  10/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjustaSX1(cPerg)
Local aRegs 	:= {}
DEFAULT cPerg 	:= ""

dbSelectArea("SX1")
dbSetOrder(1)

aAdd(aRegs,{cPerg,"01","Produto?","","","mv_ch1","C",15,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","",""})

PlsVldPerg( aRegs )       

Return