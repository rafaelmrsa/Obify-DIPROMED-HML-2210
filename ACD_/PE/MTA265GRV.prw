#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

/*/{Protheus.doc} MTA265GRV
//TODO Descrição auto-gerada.
@author dfern
@since 21/06/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function MTA265GRV()

EmpOrdSep()
 
Return 

/*/{Protheus.doc} EmpOrdSep
//TODO Descrição auto-gerada.
@author dfern
@since 21/06/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function EmpOrdSep()

local nPosQuant := AScan(aHeader,{|x| AllTrim(x[2]) == "DB_QUANT"})
local nPosEst   := AScan(aHeader,{|x| AllTrim(x[2]) == "DB_ESTORNO"})
Local aDados    := {}
Local aEmp      := {}
Local aMata380  := {}
Local aEmpen    := {}
Local lRet      := .T.
Local _nOpc     := 3
Local cOp       := ""

private cOrdSep := "" //Compatibilidade com a separacao que usa a mesma funcao de empenho
 
IF !(SDA->DA_ORIGEM = "SD3" )
	Return
EndIF
//--------------------------------
// Gravar os registros na SD3 
//--------------------------------
aAreaSDB := SDB->(GetArea())
dbSelectArea("SDB")
SDB->(dbSetOrder(1))
SDB->(dbSeek(xFilial("SDB")+ SDA->DA_PRODUTO + SDA->DA_LOCAL + SDA->DA_NUMSEQ)) 
While !SDB->(EOF()) .And. SDB->DB_FILIAL = xFilial("SDB") .And. SDB->DB_PRODUTO =  SDA->DA_PRODUTO  .And.  SDB->DB_LOCAL = SDA->DA_LOCAL .And. SDB->DB_NUMSEQ = SDA->DA_NUMSEQ

	dbselectArea("SD3")
	dbSetOrder(4)
	
	If MsSeek(xFilial("SD3")+SDA->DA_NUMSEQ)
 
		IF SDB->DB_ESTORNO <> "S"
			If !Empty( SD3->D3_OP )
				
				_cQuery :=  " SELECT D4_OP, R_E_C_N_O_ AS RECSD4 " 
				_cQuery +=  " FROM "+RetSqlName("SD4")+"  "
				_cQuery +=  " WHERE D4_OPORIG = '"+SD3->D3_OP+"' "				
				_cQuery +=  " AND D_E_L_E_T_ = '' "
				_cQuery +=  " AND D4_FILIAL ='"+xFilial("SD4")+"' " 
				
				If ( Select("TSQL") > 0 )
					TSQL->(DbCloseArea())
				Endif
				
				TcQuery _cQuery New Alias "TSQL"
				
				dbSelectArea("TSQL")
				TSQL->(dbGotop())
				
				If TSQL->(!Eof())
					cOp :=  TSQL->D4_OP
					
					dbSelectArea("SD4")
					dbGoto( TSQL->RECSD4 )
					
					SD4->(RecLock("SD4",.F.))
						SD4->D4_XLOGSEP := ""
					SD4->(MsUnLock())
					
					nPos := aScan(aEmp,{|X| x[1]+x[2]+x[3]+x[4]+x[6] == SDB->DB_PRODUTO+ SDB->DB_LOTECTL+SDB->DB_LOCALIZ+SDB->DB_LOCAL+cOp})
								
					If nPos == 0
						AADD( aEmp, { SDB->DB_PRODUTO, SDB->DB_LOTECTL, SDB->DB_LOCALIZ, SDB->DB_LOCAL, SDB->DB_QUANT, cOp, TSQL->RECSD4, SD4->D4_LOTECTL, SD4->D4_TRT, SD4->D4_OPORIG, SD4->D4_PRODUTO } ) //Guardo o lote e o TRT do SD4 para poder excluir o empenho
					Else
						aEmp[nPos][5] += SDB->DB_QUANT
					EndIf
					
					
				EndIf

			EndIf 
		EndIF
	
	EndIf 
	SDB->(dbSkip())
End

If Len( aEmp ) > 0
	
	For nY := 1 To Len( aEmp )
	
		cProduto := aEmp[nY][1]
		cLocal   := aEmp[nY][4]
		cOp		 := aEmp[nY][6]
		nQuant	 := aEmp[nY][5]
		cLote	 := aEmp[nY][2]
		cEnder   := aEmp[nY][3]
		cRecno   := aEmp[nY][7]
		cLoteSD4 := aEmp[nY][8]
		cTRTSD4  := aEmp[nY][9]
		cOpOrig  := aEmp[nY][10]
		cProdPa  := aEmp[nY][11]

		//Excluo o Empenho sem lote no SD4
		_lEmp := u_DDGrvEmp( 5, cProduto, cLocal, cOp, nQuant, cLoteSD4, ""    , cRecno, cTRTSD4, cOpOrig, cProdPa ) //Excluio o empenho sem lote
		_lEmp := u_DDGrvEmp( 3, cProduto, cLocal, cOp, nQuant, cLote   , cEnder, 0     , ""     , cOpOrig, cProdPa, "" ) //Empenho o lote produzido e enderecado
				
		/*
		aAdd(aMata380,{"D4_COD"    , cProduto 			,NIL})
		aAdd(aMata380,{"D4_LOCAL"  , cLocal				,NIL})
		aAdd(aMata380,{"D4_OP"     , cOp				,NIL})
		aAdd(aMata380,{"D4_DATA"   , dDataBase			,NIL})
		aAdd(aMata380,{"D4_QTDEORI", nQuant				,NIL})
		aAdd(aMata380,{"D4_QUANT"  , nQuant				,NIL})
		aAdd(aMata380,{"D4_LOTECTL", cLote				,NIL})
		aAdd(aMata380,{"D4_NUMLOTE", CriaVar("D4_NUMLOTE"),NIL})
		aAdd(aMata380,{"D4_XEMPMAN", "S"				,NIL})
		aAdd(aMata380,{"D4_XLOGSEP", "S"				,NIL})
		aAdd(aMata380,{"D4_POTENCI", CriaVar("D4_POTENCI"),NIL})
				
		lMSErroAuto := .F.
		lMSHelpAuto := .F.
		
		AADD(aEmpen,{   nQuant                 ,;   // SD4->D4_QUANT
		                cEnder,;  // DC_LOCALIZ
		                ""                 ,;  // DC_NUMSERI
		                0                  ,;  // D4_QTSEGUM
		                .F.}) 
		        		
		MsExecAuto({|x,y,z|MATA380(x,y,z)},aMata380,_nOpc, aEmpen )
		
		If lMSErroAuto
			lRet  := .F. 
			MostraErro()
			DisarmTransaction()
		EndIf
		*/	

	Next 
EndIf

RestArea(aAreaSDB)	

Return		