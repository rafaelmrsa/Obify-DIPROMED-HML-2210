/*====================================================================================\
|Programa  | _UMATR440a     | Autor | Reginaldo Borges           | Data | 10/12/2015   |
|=====================================================================================|
|Descri็ใo | Lista os items que atingiram o ponto de pedido                           |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | _UMATR440a                                                               |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Hist๓rico....................................|
|Borges    | DD/MM/AA - Descri็ใo                                                     |
\====================================================================================*/

#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

User Function _UMATR440a(aWork)

cWorkFlow := aWork[1]
cWCodEmp  := aWork[2]
cWCodFil  := aWork[3]


If ValType(aWork) == 'A'                                                               
	PREPARE ENVIRONMENT EMPRESA cWCodEmp FILIAL cWCodFil FUNNAME "_UMATR440a" TABLES "SB1"
EndIf

ConOut('Inicio do relatorio dos produtos em ponto de pedido '+dToc(date())+' as '+Time())

	R440ImpCO()

ConOut('Fim do relatorio dos produtos em ponto de pedido '+dToc(date())+' as '+Time())   
                 

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑณFun…o    ณ R440IMPCO  ณ Autor ณ Reginaldo Borges    ณ Data ณ 11/12/15 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Chamada do Relatorio                                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ MATR440a		                                              ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R440ImpCO()
Local nQuant 	:= 0
Local nSaldo 	:= 0
Local nPrazo 	:= 0
Local nEstSeg	:= 0
Local nNeces 	:= 0
Local cLocCQ   	:= GetMV("MV_CQ")
Local dDataRela	:= Iif(Empty(MV_PAR16),dDataBase,MV_PAR16)
Local _nEtqDias	:= 0  
Local aMsgI     := {}  
Local nQtdProg  := 0

MV_PAR01 := "      "         // Fornecedor  de?
MV_PAR02 := "ZZZZZZ"         // Fornecedor ate?
MV_PAR03 := "      "         // Produto  de?
MV_PAR04 := "ZZZZZZ"         // Produto ate?
MV_PAR05 := "   "            // Grupo  de?
MV_PAR06 := "ZZZ"            // Grupo ate? 
MV_PAR07 := " "              // Tipo  de?
MV_PAR08 := "ZZ"             // Tipo ate?
MV_PAR09 := " "              // Local  de?
MV_PAR10 := "ZZ"             // Local ate?
MV_PAR11 := 1                // Consid.Necess.Bruta?
MV_PAR12 := 1                // Saldo Neg Considera?
MV_PAR13 := 1                // Considera CQ?
MV_PAR14 := "   "            // Comprador  de?
MV_PAR15 := "ZZZ"            // Comprador ate?
MV_PAR16 := CTOD("  /  /  ") // Data Base?

cSQL := " SELECT "
cSQL += " 	SB1.B1_PROC,SA2.A2_COMPRA,SB1.B1_COD, SUM(SB1.B1_EMIN) B1_EMIN "
cSQL += " 	FROM "+RetSQLName("SB1")+" SB1, "+RetSQLName("SA2")+" SA2, "+RetSQLName("SY1")+" SY1 "  
cSQL += " 		WHERE "
cSQL += "			SB1.B1_FILIAL IN ('01','04')        AND "
cSQL += "			SA2.A2_FILIAL = '"+xFilial("SA2")+"'AND "
cSQL += "			SY1.Y1_FILIAL = '"+xFilial("SY1")+"'AND "
cSQL += " 			SB1.B1_PROC BETWEEN  '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
cSQL += " 			SB1.B1_COD BETWEEN   '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND "
cSQL += " 			SB1.B1_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' AND "
cSQL += " 			SB1.B1_TIPO BETWEEN  '"+MV_PAR07+"' AND '"+MV_PAR08+"' AND "
cSQL += "			SB1.B1_NAOIPP      <> 'N'      		AND "
cSQL += "			SB1.B1_CONTRAT     <> 'S'      		AND " 
cSQL += "			SB1.B1_TIPO        <> 'BN'     		AND " 
cSQL += "			LEFT(SB1.B1_COD,3) <> 'MOD'    		AND "  
cSQL += "			LEFT(SB1.B1_DESC,1)<> 'Z'    		AND "
cSQL += "			B1_XCODORI         =   ''	  		AND "
cSQL += "			SA2.A2_COD         =  SB1.B1_PROC   AND "
cSQL += "			SA2.A2_LOJA        =  SB1.B1_LOJPROC AND"
cSQL += "		    SY1.Y1_COD         =  SA2.A2_COMPRA AND "
cSQL += " 			SB1.D_E_L_E_T_ = ' '                AND"                                             
cSQL += " 			SA2.D_E_L_E_T_ = ' '                AND"                                             
cSQL += " 			SY1.D_E_L_E_T_ = ' '                   "                                             
cSQL += " GROUP BY SA2.A2_COMPRA,SB1.B1_PROC, SB1.B1_DESC, SB1.B1_COD "
cSQL += " ORDER BY SA2.A2_COMPRA,SB1.B1_PROC, SB1.B1_DESC, SB1.B1_COD "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSB1",.T.,.T.)     

cForne   := QRYSB1->B1_PROC
cCodCo   := QRYSB1->A2_COMPRA
//_cEmCompr:= ALLTRIM(Posicione("SY1",1,xFilial("SY1")+cCodCo,"Y1_EMAIL"))//Rose pediu para enviar somente para compras@dipromed.com.br 06/04/16
_cEmCompr:= "compras@dipromed.com.br"

While !QRYSB1->(Eof())
	
	SB1->(DbSetOrder(6))
	SB1->(dbSeek(xFilial("SB1")+QRYSB1->B1_PROC))	
	
	SA2->(DbSetOrder(1))
	If SA2->(dbSeek(xFilial("SA2")+QRYSB1->B1_PROC))	
		If SA2->A2_COMPRA < mv_par14 .OR. SA2->A2_COMPRA > mv_par15 .Or. SA2->A2_NAOIPP == "N" 
			QRYSB1->(dbSkip())
			Loop			
		EndIf		          
	Else
		QRYSB1->(dbSkip())
		Loop			
	EndIf
	
	nSaldo := DiCalSld(QRYSB1->B1_COD,MV_PAR09,MV_PAR10,cLocCQ,MV_PAR13)


	nEstSeg := CalcEstSeg(SB1->B1_ESTFOR)
	nSaldo  -= nEstSeg    
	
	If nSaldo > 0 .Or. mv_par11==1	
		Do Case
			Case QRYSB1->B1_EMIN <> 0 .And. MV_PAR11 == 1
				If nSaldo < 0			
					nNeces := Abs(nSaldo)+QRYSB1->B1_EMIN
				Else 
					nNeces := QRYSB1->B1_EMIN-nSaldo
				EndIf					
			Case QRYSB1->B1_EMIN <> 0 .And. MV_PAR11 == 2
				If nSaldo < 0			
					nNeces := Abs(nSaldo)
				Else 
					nNeces := QRYSB1->B1_EMIN-nSaldo
				EndIf								
			Case (SB1->B1_LE <> 0 .And. (nSaldo < 0 .Or. mv_par11 == 2))			
				If MV_PAR10 == 2 .And. nSaldo < 0
					nNeces := Abs(nSaldo)+SB1->B1_LE
				Else
					nNeces := If( Abs(nSaldo)<SB1->B1_LE,SB1->B1_LE,if(nSaldo<0,Abs(nSaldo),0))
				EndIf
			OtherWise
				If MV_PAR11==1 .And. nSaldo < 0
					nNeces := Abs(nSaldo)
				Else                     
					nNeces := 0
				EndIf
		End Case
	Else
		If QRYSB1->B1_EMIN > 0
			nNeces := QRYSB1->B1_EMIN
		Else
			nNeces := 0
		Endif
	EndIf

	If nNeces > 0
		//ณ Verifica se o produto tem estrutura                       ณ
		dbSelectArea("SG1")
		If dbSeek( xFilial("SG1")+QRYSB1->B1_COD )
			aQtdes := CalcLote(QRYSB1->B1_COD,nNeces,"F")
		Else
			aQtdes := CalcLote(QRYSB1->B1_COD,nNeces,"C")
		Endif
		For nX := 1 to Len(aQtdes)
			nQuant += aQtdes[nX]
		Next
	EndIf        
	
	If nQuant > 0
		//ณ Pega o prazo de entrega do material         ณ
		nPrazo := CalcPrazo(QRYSB1->B1_COD,nQuant)
		
		//ณ Verifica qual dos precos e' mais recente servir de base ณ
		dData    := U_DipReDat(QRYSB1->B1_COD)
			
        SB3->( DbSetOrder(1) )
        SB3->( DbSeek(xFilial("SB3")+QRYSB1->B1_COD))
        
		_nQuant := (Round(nQuant/SB1->B1_XQE,0)*SB1->B1_XQE)
		_nQuant := IIF(_nQuant<nQuant,_nQuant+SB1->B1_XQE,_nQuant)
		
        _cProd   := SubStr(QRYSB1->B1_COD,1,6)
		_cDescP  := SubStr(SB1->B1_DESC,1,60)
		_cUm     := SB1->B1_UM
		_nSaldo  := nSaldo 
		_cfMesB3 := _fMesB3(_cProd,dDataRela,3,.F.)
		_cfMesB2 := _fMesB3(_cProd,dDataRela,2,.F.)
		_cfMesB1 := _fMesB3(_cProd,dDataRela,1,.F.)
		_cfMesB0 := _fMesB3(_cProd,dDataRela,0,.F.)
		_nPontPe := QRYSB1->B1_EMIN 
		_nQtdEmb := SB1->B1_XQE 
		_nQtdComp:= _nQuant
		_cLoteDip:= SB1->B1_LOTEDIP 
		_dData   := DtoC(dData)
		_CodCom  := QRYSB1->A2_COMPRA
		_nIPI    := SB1->B1_IPI  
        _nPrazo  := nPrazo  
		_nEtqDias:= SB1->B1_ETQDIAS        
		  
        cDipMesB33:= _DipMesB3(nil,dDataRela,3,.T.)
        cDipMesB32:= _DipMesB3(nil,dDataRela,2,.T.)
		cDipMesB31:= _DipMesB3(nil,dDataRela,1,.T.)
        cDipMesB30:= _DipMesB3(nil,dDataRela,0,.T.)
		
		_cFornecN:= ALLTRIM(Posicione("SA2",1,xFilial("SA2")+QRYSB1->B1_PROC,"A2_NOME"))
		_CodCond := ALLTRIM(Posicione("SA2",1,xFilial("SA2")+QRYSB1->B1_PROC,"A2_COND"))
		_cContato:= "Contato: "+ALLTRIM(Posicione("SA2",1,xFilial("SA2")+QRYSB1->B1_PROC,"A2_CONTATO"))
		_cTel    := "Tel: "+ALLTRIM(Posicione("SA2",1,xFilial("SA2")+QRYSB1->B1_PROC,"A2_DDD"))+" "+;
		ALLTRIM(Posicione("SA2",1,xFilial("SA2")+QRYSB1->B1_PROC,"A2_TEL"))
		_cCompra := ALLTRIM(Posicione("SA2",1,xFilial("SA2")+QRYSB1->B1_PROC,"A2_COMPRA"))
		_cNomeCo := "Comprador: "+_cCompra+" - "+ALLTRIM(Posicione("SY1",1,xFilial("SY1")+_cCompra,"Y1_NOME"))
		_CondPgto:= "Cond.Pagto.: "+ALLTRIM(Posicione("SE4",1,xFilial("SE4")+_CodCond,"E4_DESCRI"))
         
		nQtdProg := U_ProSCK(_cProd)
		_dDtEntPr:= U_EntrSCK(_cProd)
              
		If (cCodCo == _CodCom)  

            	   *       1       2     3      4       5        6        7        8       9         10      11        12        13     14      
        	aadd(aMsgI,{_cProd,_cDescP,_cUm,_nSaldo,_cfMesB3,_cfMesB2,_cfMesB1,_cfMesB0,_nPontPe,_nQtdEmb,_nQtdComp,_cLoteDip,nQtdProg,_dDtEntPr,;
                        _nIPI,_nPrazo,_cContato,_cTel,_cCompra,_cNomeCo,QRYSB1->B1_PROC,cDipMesB33,cDipMesB32,cDipMesB31,cDipMesB30,_cFornecN,;
               	   		_nEtqDias,_CondPgto,_CodCom})
               	   *      15     16       17      18     19        20            21            22         23          24         25        26  
               	   *      27         28        29
               	    
		Else
		
			If Len(aMsgI) > 0 // SE NรO POSSUIR NENHUMA LINHA NO ARRAY NรO ENVIA NADA  -  RBORGES 11/12/15
			    If Empty(_cEmCompr)
			    	_cEmCompr := "rosemeire.ferraris@dipromed.com.br"
			    EndIf
				
				cEmail :=_cEmCompr+";"+"reginaldo.borges@dipromed.com.br"//E-mail do Comprador - RBORGES 11/12/15 
				cAssunto:= EncodeUTF8('ATENวรO - PRODUTO EM PONTO DE PEDIDO!',"cp1252")//+dToc(_EntDip)+' - ' +AllTrim(SM0->M0_NOME)//+"/"+AllTrim(SM0->M0_FILIAL)
				U_EMailPP(cEmail,cAssunto,aMsgI) //RBORGES 11/12/15 - Dispara E-mail de produto em ponto de pedido por pedido e comprador
			
				aMsgI := {}                                                                                                                      
			
            	   *       1       2     3      4       5        6        7        8       9         10      11        12        13     14      
        	aadd(aMsgI,{_cProd,_cDescP,_cUm,_nSaldo,_cfMesB3,_cfMesB2,_cfMesB1,_cfMesB0,_nPontPe,_nQtdEmb,_nQtdComp,_cLoteDip,nQtdProg,_dDtEntPr,;
                        _nIPI,_nPrazo,_cContato,_cTel,_cCompra,_cNomeCo,QRYSB1->B1_PROC,cDipMesB33,cDipMesB32,cDipMesB31,cDipMesB30,_cFornecN,;
               	   		_nEtqDias,_CondPgto,_CodCom})
               	   *      15     16       17      18     19        20            21            22         23          24         25        26  
               	   *      27         28        29
               	   
           	EndIf       
		EndIf
               
	nSaldo   := 0
	nQuant   := 0
    cForne   := QRYSB1->B1_PROC
    cCodCo   := QRYSB1->A2_COMPRA
	//_cEmCompr:= ALLTRIM(Posicione("SY1",1,xFilial("SY1")+cCodCo,"Y1_EMAIL"))//Rose pediu para enviar somente para compras@dipromed.com.br 06/04/16
	_cEmCompr:= "compras@dipromed.com.br"

	Endif
   
	QRYSB1->(dbSkip())


EndDo

QRYSB1->(dbCloseArea())

If Len(aMsgI) > 0 // SE NรO POSSUIR NENHUMA LINHA NO ARRAY NรO ENVIA NADA  -  RBORGES 11/12/15
    If Empty(_cEmCompr)
    	_cEmCompr := "rosemeire.ferraris@dipromed.com.br"
    EndIf
	cEmail :=_cEmCompr+";"+"reginaldo.borges@dipromed.com.br"// E-mail do Comprador - RBORGES 11/12/15
	cAssunto:= EncodeUTF8('ATENวรO - PRODUTO EM PONTO DE PEDIDO!',"cp1252") //+dToc(_EntDip)+' - ' +AllTrim(SM0->M0_NOME)//+"/"+AllTrim(SM0->M0_FILIAL)
	U_EMailPP(cEmail,cAssunto,aMsgI) //RBORGES 11/12/15 - Dispara E-mail de produto em ponto de pedido por fornecedor e comprador
EndIf

//ณ Devolve a condicao original do arquivo principal             ณ
dbSelectArea("SB1")
Set Filter To
Set Order To 1

Return .T.

/*------------------------------------------------------------------------+
+ Funcao:EMailPP()    |  Autor: RBORGES     |      Data: 11/12/2015      +                                                     
+ Enviarแ E-mails dos produtos em ponto de pedido.                        +
-------------------------------------------------------------------------*/

User Function EMailPP(cEmail,cAssunto,aMsgI)

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := "protheus@dipromed.com.br"
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cEmailTo  := ""
Local cEmailCc  := ""
Local cEmailBcc := ""//"relatorios@dipromed.com.br"
Local lResult   := .F.
Local cError    := ""
Local cMsg      := ""
Local nI
Local lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
Local lAutOk	:= .F.
Local _cPedido  := aMsgI[1,1]
Local cFornec   := SA2->A2_COD
Local cCompra   := aMsgI[1,29]
Local cCodForne := ""
Local cContat   := ""
Local nEstDias  := 0
Local _cTel     := ""
Local cCondP    := ""
Local cCompr    := ""
Local nTotCom   := 0
Local cAssuntob := DecodeUTF8(cAssunto, "cp1252") 



/*=============================================================================*/
/*Definicao do cabecalho do email                                              */
/*=============================================================================*/
cMsg := ""
cMsg += '<html>'
cMsg += '<head>'
cMsg += '<title>' + cAssunto + '</title>'
cMsg += '</head>'
cMsg += '<body>'
cMsg += '<HR Width=100% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=100%>'

cMsg += '<table width="100%">'
cMsg += '<tr>'
cMsg += '<td width="100%" colspan="2" Align="Center" ><font size="4" color="red">' +cAssuntob+ '</font></td>'
cMsg += '</tr>'
cMsg += '</table>'

/*=============================================================================*/
/*Definicao do texto/detalhe do email                                          */
/*=============================================================================*/

For nI := 1 to Len(aMsgI)
	
	nLin := nI
	
	If cFornec <> aMsgI[nLin,21]
		
		If nI <> 1
			
			cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="white">'
			cMsg += '<tr>'
			cMsg += '<td width="100%">-</td>'
			cMsg += '</tr>'
			cMsg += '</font></table>'
			cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="DarkRed">'
			cMsg += '<tr>'
			cMsg += '<td Width="30%" Align="LEFT">O'+cCodForne+'</td>'
			cMsg += '<td Width="20%" Align="LEFT">'+cContat+'</td>'
			cMsg += '<td Width="20%" Align="LEFT">Est.para Qtde.Dias: '+nEstDias+'</td>'
			cMsg += '<td Width="15%" Align="LEFT">'+_cTel+'</td>'
			cMsg += '<td Width="15%" Align="Center">'+cCondP+'</td>'
			cMsg += '</tr>'
			cMsg += '<tr>'
			cMsg += '<td Width="30%" Align="LEFT">Comprador: '+cCompr+'</td>'
			cMsg += '<td Width="20%" Align="LEFT"></td>'
			cMsg += '<td Width="20%" Align="LEFT"></td>'
			cMsg += '<td Width="15%" Align="LEFT">Total a Comprar: '+cValToChar(nTotCom)+'</td>'
			cMsg += '<td Width="15%" Align="LEFT"></td>'
			cMsg += '</tr>'
			cMsg += '</font></table>'
			cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="white">'
			cMsg += '<tr>'
			cMsg += '<td width="100%">-</td>'
			cMsg += '</tr>'
			cMsg += '</font></table>' 
			
			nTotCom := 0
			
		EndIf
		
		cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
		cMsg += '<tr>'
		cMsg += '<td>==========================================================================================================================================================================================</td>'
		cMsg += '</tr>'
		cMsg += '</font></table>'
		cMsg += '<table width="100%" Border="0" cellspacing="0" cellpadding="0"><font size="2" color="DarkBlue">'
		cMsg += '<tr>'
		cMsg += '<td width="5% " Align="Left"><b>Codigo</b></td>'
		cMsg += '<td width="32%" Align="Left"><b>Descricao</b></td>'
		cMsg += '<td width="3% " Align="Left"><b>Um</b></td>'
		cMsg += '<td width="4% " Align="Center"><b>Saldo</b></td>'
		cMsg += '<td width="5% " Align="Left"><b>'+aMsgI[nLin,22]+'</b></td>'
		cMsg += '<td width="5% " Align="Left"><b>'+aMsgI[nLin,23]+'</b></td>'
		cMsg += '<td width="5% " Align="Left"><b>'+aMsgI[nLin,24]+'</b></td>'
		cMsg += '<td width="5% " Align="Left"><b>'+aMsgI[nLin,25]+'</b></td>'
		cMsg += '<td width="4%" Align="Center"><b>Ponto de</b></td>'
		cMsg += '<td width="4%" Align="Center"><b>Qtd.</b></td>'
		cMsg += '<td width="4%" Align="Center"><b>Qtd.</b></td>'
		cMsg += '<td width="4%" Align="Center"><b>Lote</b></td>'
		cMsg += '<td width="4%" Align="Center"><b>Qtd. da</b></td>'
		cMsg += '<td width="4%" Align="Center"><b>Data da</b></td>'
		cMsg += '<td width="4%" Align="Center"><b>%</b></td>'
		cMsg += '<td width="3%" Align="Center"><b>Prz. Ent.</b></td>'
		cMsg += '</tr>'
		cMsg += '<tr>'
		cMsg += '<td width="5% " Align="Center"><b></b></td>'
		cMsg += '<td width="32%" Align="Center"><b></b></td>'
		cMsg += '<td width="3% " Align="Center"><b></b></td>'
		cMsg += '<td width="4% " Align="Center"><b>Disponivel</b></td>'
		cMsg += '<td width="5% " Align="Center"><b>( -3 )</b></td>'
		cMsg += '<td width="5% " Align="Center"><b>( -2 )</b></td>'
		cMsg += '<td width="6% " Align="Center"><b>( -1 )</b></td>'
		cMsg += '<td width="5% " Align="Center"><b>(  0 )</b></td>'
		cMsg += '<td width="4% " Align="Center"><b>Pedido</b></td>'
		cMsg += '<td width="4%" Align="Center"><b>Embal.</b></td>'
		cMsg += '<td width="4%" Align="Center"><b>Comprar</b></td>'
		cMsg += '<td width="4%" Align="Center"><b>Dipro</b></td>'
		cMsg += '<td width="4%" Align="Center"><b>Progr.</b></td>'
		cMsg += '<td width="4%" Align="Center"><b>Entrega</b></td>'
		cMsg += '<td width="4%" Align="Center"><b>IPI</b></td>'
		cMsg += '<td width="3%" Align="Center"><b>Em Dias</b></td>'
		cMsg += '</tr>'
		cMsg += '</font></table>'
		cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
		cMsg += '<tr>'
		cMsg += '<td>==========================================================================================================================================================================================</td>'
		cMsg += '</tr>'
		cMsg += '</font></table>'
		
		If nI = 1
			cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="white">'
			cMsg += '<tr>'
			cMsg += '<td width="100%">-</td>'
			cMsg += '</tr>'
			cMsg += '</font></table>'
		EndIf
		
	EndIf
	
	If cCompra == aMsgI[nLin,29]
		
		cCodForne := aMsgI[nLin,21]+"-"+aMsgI[nLin,26]
		cContat   := aMsgI[nLin,17]
		nEstDias  := cValToChar(aMsgI[nLin,27])
		_cTel     := aMsgI[nLin,18]
		cCondP    := aMsgI[nLin,28]
		cCompr    := aMsgI[nLin,19]
		
		If Mod(nLin,2) == 0
			
			cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
			cMsg += '<tr bgcolor="#F8F8FF">'
			cMsg += '<td width="5% " Align="Left"><font  size="2">'+aMsgI[nLin,1]+'</font></td>'
			cMsg += '<td width="32%" Align="Left"><font  size="2">'+aMsgI[nLin,2]+'</font></td>'
			cMsg += '<td width="3% " Align="Left"><font  size="2">'+aMsgI[nLin,3]+ '</font></td>'
			cMsg += '<td width="5% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,4])+'</font></td>'
			cMsg += '<td width="5% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,5])+'</font></td>'
			cMsg += '<td width="5% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,6])+'</font></td>'
			cMsg += '<td width="5% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,7])+'</font></td>'
			cMsg += '<td width="5% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,8])+'</font></td>'
			cMsg += '<td width="5% " Align="Left"><font size="2" color="Blue">'+Transform(aMsgI[nLin,9],"@E 999,999,999")+'</font></td>'
			cMsg += '<td width="3% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,10])+'</font></td>'
			cMsg += '<td width="4% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,11])+'</font></td>'
			cMsg += '<td width="4% " Align="Center"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,12])+'</font></td>'
			cMsg += '<td width="4% " Align="Center"><font  size="2" color="Blue">'+Transform(aMsgI[nLin,13],"@E 999,999,999")+'</font></td>'
			cMsg += '<td width="4% " Align="Left"><font    size="2" color="Blue">'+(aMsgI[nLin,14])+'</font></td>'
			cMsg += '<td width="4% " Align="Center"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,15])+'</font></td>'
			cMsg += '<td width="3% " Align="Center"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,16])+'</font></td>'
			cMsg += '</tr>'
			cMsg += '</table>'
			
			Else
			
			cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
			cMsg += '<tr bgcolor="#FFFAFA">'
			cMsg += '<td width="5% " Align="Left"><font  size="2">'+aMsgI[nLin,1]+'</font></td>'
			cMsg += '<td width="32%" Align="Left"><font  size="2">'+aMsgI[nLin,2]+'</font></td>'
			cMsg += '<td width="3% " Align="Left"><font  size="2">'+aMsgI[nLin,3]+ '</font></td>'
			cMsg += '<td width="5% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,4])+'</font></td>'
			cMsg += '<td width="5% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,5])+'</font></td>'
			cMsg += '<td width="5% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,6])+'</font></td>'
			cMsg += '<td width="5% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,7])+'</font></td>'
			cMsg += '<td width="5% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,8])+'</font></td>'
			cMsg += '<td width="5% " Align="Left"><font size="2" color="Blue">'+Transform(aMsgI[nLin,9],"@E 999,999,999")+'</font></td>'
			cMsg += '<td width="3% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,10])+'</font></td>'
			cMsg += '<td width="4% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,11])+'</font></td>'
			cMsg += '<td width="4% " Align="Center"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,12])+'</font></td>'
			cMsg += '<td width="4% " Align="Center"><font  size="2" color="Blue">'+Transform(aMsgI[nLin,13],"@E 999,999,999")+'</font></td>'
			cMsg += '<td width="4% " Align="Left"><font  size="2" color="Blue">'+(aMsgI[nLin,14])+'</font></td>'
			cMsg += '<td width="4% " Align="Center"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,15])+'</font></td>'
			cMsg += '<td width="3% " Align="Center"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,16])+'</font></td>'
			cMsg += '</tr>'
			cMsg += '</table>'
			
		EndIf
		
	Else
		
		cCodForne := cCodForne
		cContat   := cContat
		nEstDias  := nEstDias
		_cTel     := _cTel
		cCondP    := cCondP
		cCompr    := cCompr
		
		If Mod(nLin,2) == 0
			
			cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
			cMsg += '<tr bgcolor="#F8F8FF">'
			cMsg += '<td width="5% " Align="Left"><font  size="2">'+aMsgI[nLin,1]+'</font></td>'
			cMsg += '<td width="32%" Align="Left"><font  size="2">'+aMsgI[nLin,2]+'</font></td>'
			cMsg += '<td width="3% " Align="Left"><font  size="2">'+aMsgI[nLin,3]+ '</font></td>'
			cMsg += '<td width="5% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,4])+'</font></td>'
			cMsg += '<td width="5% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,5])+'</font></td>'
			cMsg += '<td width="5% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,6])+'</font></td>'
			cMsg += '<td width="5% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,7])+'</font></td>'
			cMsg += '<td width="5% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,8])+'</font></td>'
			cMsg += '<td width="5% " Align="Left"><font size="2" color="Blue">'+Transform(aMsgI[nLin,9],"@E 999,999,999")+'</font></td>'
			cMsg += '<td width="3% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,10])+'</font></td>'
			cMsg += '<td width="4% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,11])+'</font></td>'
			cMsg += '<td width="4% " Align="Center"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,12])+'</font></td>'
			cMsg += '<td width="4% " Align="Center"><font  size="2" color="Blue">'+Transform(aMsgI[nLin,13],"@E 999,999,999")+'</font></td>'
			cMsg += '<td width="4% " Align="Left"><font  size="2" color="Blue">'+(aMsgI[nLin,14])+'</font></td>'
			cMsg += '<td width="4% " Align="Center"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,15])+'</font></td>'
			cMsg += '<td width="3% " Align="Center"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,16])+'</font></td>'
			cMsg += '</tr>'
			cMsg += '</table>'
			
			Else
			
			cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
			cMsg += '<tr bgcolor="#FFFAFA">'
			cMsg += '<td width="5% " Align="Left"><font  size="2">'+aMsgI[nLin,1]+'</font></td>'
			cMsg += '<td width="32%" Align="Left"><font  size="2">'+aMsgI[nLin,2]+'</font></td>'
			cMsg += '<td width="3% " Align="Left"><font  size="2">'+aMsgI[nLin,3]+ '</font></td>'
			cMsg += '<td width="5% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,4])+'</font></td>'
			cMsg += '<td width="5% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,5])+'</font></td>'
			cMsg += '<td width="5% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,6])+'</font></td>'
			cMsg += '<td width="5% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,7])+'</font></td>'
			cMsg += '<td width="5% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,8])+'</font></td>'
			cMsg += '<td width="5% " Align="Left"><font size="2" color="Blue">'+Transform(aMsgI[nLin,9],"@E 999,999,999")+'</font></td>'
			cMsg += '<td width="3% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,10])+'</font></td>'
			cMsg += '<td width="4% " Align="Left"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,11])+'</font></td>'
			cMsg += '<td width="4% " Align="Center"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,12])+'</font></td>'
			cMsg += '<td width="4% " Align="Center"><font  size="2" color="Blue">'+Transform(aMsgI[nLin,13],"@E 999,999,999")+'</font></td>'
			cMsg += '<td width="4% " Align="Left"><font  size="2" color="Blue">'+(aMsgI[nLin,14])+'</font></td>'
			cMsg += '<td width="4% " Align="Center"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,15])+'</font></td>'
			cMsg += '<td width="3% " Align="Center"><font  size="2" color="Blue">'+cValToChar(aMsgI[nLin,16])+'</font></td>'
			cMsg += '</tr>'
			cMsg += '</table>'
			
		EndIf
		  
	EndIf
	
	cFornec := aMsgI[nLin,21]
	cCompra := aMsgI[nLin,29]
	nTotCom += aMsgI[nLin,11]		
	
	nLin    += 1
	
Next
cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="white">'
cMsg += '<tr>'
cMsg += '<td width="100%">-</td>'
cMsg += '</tr>'
cMsg += '</font></table>'
cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="DarkRed">'
cMsg += '<tr>'
cMsg += '<td Width="30%" Align="LEFT">'+cCodForne+'</td>'
cMsg += '<td Width="20%" Align="LEFT">'+cContat+'</td>'
cMsg += '<td Width="20%" Align="LEFT">Est.para Qtde.Dias: '+nEstDias+'</td>'
cMsg += '<td Width="15%" Align="LEFT">'+_cTel+'</td>'
cMsg += '<td Width="15%" Align="Center">'+cCondP+'</td>'
cMsg += '</tr>'
cMsg += '<tr>'
cMsg += '<td Width="30%" Align="LEFT">Comprador: '+cCompr+'</td>'
cMsg += '<td Width="20%" Align="LEFT"></td>'
cMsg += '<td Width="20%" Align="LEFT"></td>'
cMsg += '<td Width="15%" Align="LEFT">Total a Comprar: '+cValToChar(nTotCom)+' </td>'
cMsg += '<td Width="15%" Align="LEFT"></td>'
cMsg += '</tr>'
cMsg += '</font></table>'
cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="white">'
cMsg += '<tr>'
cMsg += '<td width="100%">-</td>'
cMsg += '</tr>'
cMsg += '</font></table>'

cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<tr>'
cMsg += '<td>==========================================================================================================================================================================================</td>'
cMsg += '</tr>'
cMsg += '</font></table>'     

nTotCom := 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao do rodape do email                                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cMsg += '</Table>'
cMsg += '<HR Width=100% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<table width="100%" Align="Center" border="0">'
cMsg += '<tr align="center">'
cMsg += '<td colspan="10"><font color="BLUE" size="2">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="BLUE" size="1">(UMAT440a.PRW)</td>'
cMsg += '</tr>'
cMsg += '</table>'
cMsg += '</body>'
cMsg += '</html>'

If GetNewPar("ES_ATIVJOB",.T.)   
	u_UEnvMail(AllTrim(cEmail),cAssunto,nil,"",cFrom,"EMailPP(UMATR440A.prw)",cMsg)
EndIf


Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ_UMATR440a  บAutor  ณMicrosiga           บ Data ณ  11/12/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DiCalSld(cCod,cLocIni,cLocFim,cLocCQ,nImpCQ)
Local cSQL   := ""
Local nSaldo := 0
 
cSQL := " SELECT "
cSQL += " 	SUM(((B2_QATU - B2_RESERVA)+B2_SALPEDI)-B2_QPEDVEN) SALDO "
cSQL += " 	FROM "
cSQL += 		RetSQLName("SB2")
cSQL += " 		WHERE "
cSQL += " 			B2_FILIAL IN('01','04') AND "
cSQL += " 			B2_COD = '"+cCod+"' AND "
cSQL += " 			(B2_LOCAL BETWEEN '"+cLocIni+"' AND '"+cLocFim+"' "
If nImpCQ == 1
	cSQL += " 		OR B2_LOCAL = '"+cLocCQ+"' "
Else
	cSQL += " 		AND B2_LOCAL = '01'"
EndIf
cSQL += " 			) AND D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSB2",.T.,.T.)

If !QRYSB2->(Eof())
	nSaldo := QRYSB2->SALDO
EndIf
QRYSB2->(dbCloseArea())
	
Return nSaldo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ_UMATR440a  บAutor  ณMicrosiga          บ Data ณ  11/12/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipReDat(cCodigo)
Local cSQL 	  := ""
Local dDatRet := StoD("")

cSQL := " SELECT "
cSQL += " 	B1_FILIAL, B1_UCOM, B1_DATREF "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SB1")
cSQL += " 		WHERE "
cSQL += " 			B1_FILIAL IN ('01','04') AND "
cSQL += " 			B1_COD = '"+cCodigo+"' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYUCOM",.T.,.T.)     

TCSETFIELD("QRYUCOM","B1_UCOM"  ,"D",8,0)
TCSETFIELD("QRYUCOM","B1_DATREF","D",8,0)

While !QRYUCOM->(Eof())              
	
    If Empty(dDatRet)
		If QRYUCOM->B1_UCOM > QRYUCOM->B1_DATREF
			dDatRet := QRYUCOM->B1_UCOM
		Else 
			dDatRet := QRYUCOM->B1_DATREF
		EndIf
	Else                                        
		If QRYUCOM->B1_UCOM > QRYUCOM->B1_DATREF
			If QRYUCOM->B1_UCOM > dDatRet
				dDatRet := QRYUCOM->B1_UCOM
			EndIf
		ElseIf QRYUCOM->B1_DATREF > dDatRet 
			dDatRet := QRYUCOM->B1_DATREF
		EndIf	
	EndIf		

	QRYUCOM->(dbSkip())
EndDo
QRYUCOM->(dbCloseArea())

Return dDatRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ_DipMesB3()  บAutor  ณReginaldo Borgesบ   Data ณ  11/12/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Retorna a quantidade da data atual menos quantidade de    บฑฑ
ฑฑบ          ณ  meses.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Camporas Dipromed                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function _DipMesB3(cCodPro,dData,nMes,lDesc) 
Local nMesB3 := Month(dData) - nMes
Local cMes   := ''
Local aMeses := {'Janeiro','Fevereiro','Mar็o','Abril','Maio','Junho','Julho','Agosto','Setembro','Outubro','Novembro','Dezembro'}

If nMesB3<1
	nMesB3 := 12+nMesB3
EndIf
             
If lDesc
    cMes := Padl(aMeses[nMesB3],9)
Else
	cSQL := " SELECT "
	cSQL += " 	SUM(B3_Q01) B3_Q01, SUM(B3_Q02) B3_Q02, SUM(B3_Q03) B3_Q03, "
	cSQL += " 	SUM(B3_Q04) B3_Q04, SUM(B3_Q05) B3_Q05, SUM(B3_Q06) B3_Q06, "
	cSQL += " 	SUM(B3_Q07) B3_Q07, SUM(B3_Q08) B3_Q08, SUM(B3_Q09) B3_Q09, "
	cSQL += " 	SUM(B3_Q10) B3_Q10, SUM(B3_Q11) B3_Q11, SUM(B3_Q12) B3_Q12 "
	cSQL += " 	FROM "
	cSQL +=  		RetSQLName("SB3")
	cSQL += " 		WHERE "
	cSQL += " 			B3_FILIAL IN ('01','04') AND "
	cSQL += " 			B3_COD = '"+cCodPro+"' AND "
	cSQL += " 			D_E_L_E_T_ = ' ' "
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSB3",.T.,.T.)
	
	If !QRYSB3->(Eof())
		If nMesB3 < 1
		   nMesB3 := 12 - abs(nMesB3) 
		EndIf    
	    cMes := &('QRYSB3->B3_Q' + StrZero(nMesB3,2))
	EndIf		
	QRYSB3->(dbCloseArea())
EndIf
 
Return(cMes)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ_fMesB3()  บAutor  ณReginaldo Borgesบ    Data ณ  11/12/15    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Retorna a quantidade da data atual menos quantidade de    บฑฑ
ฑฑบ          ณ  meses.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Camporas Dipromed                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                     
Static Function _fMesB3(cCodPro,dData,nMes,lDesc) 
Local nMesB3 := Month(dData) - nMes
Local cMes   := ''
Local aMeses := {'Janeiro','Fevereiro','Mar็o','Abril','Maio','Junho','Julho','Agosto','Setembro','Outubro','Novembro','Dezembro'}

If nMesB3<1
	nMesB3 := 12+nMesB3
EndIf
             
If lDesc
    cMes := Padl(aMeses[nMesB3],9)
Else
	cSQL := " SELECT "
	cSQL += " 	SUM(B3_Q01) B3_Q01, SUM(B3_Q02) B3_Q02, SUM(B3_Q03) B3_Q03, "
	cSQL += " 	SUM(B3_Q04) B3_Q04, SUM(B3_Q05) B3_Q05, SUM(B3_Q06) B3_Q06, "
	cSQL += " 	SUM(B3_Q07) B3_Q07, SUM(B3_Q08) B3_Q08, SUM(B3_Q09) B3_Q09, "
	cSQL += " 	SUM(B3_Q10) B3_Q10, SUM(B3_Q11) B3_Q11, SUM(B3_Q12) B3_Q12 "
	cSQL += " 	FROM "
	cSQL +=  		RetSQLName("SB3")
	cSQL += " 		WHERE "
	cSQL += " 			B3_FILIAL IN ('01','04') AND "
	cSQL += " 			B3_COD = '"+cCodPro+"' AND "
	cSQL += " 			D_E_L_E_T_ = ' ' "
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSB3",.T.,.T.)
	
	If !QRYSB3->(Eof())
		If nMesB3 < 1
		   nMesB3 := 12 - abs(nMesB3) 
		EndIf    
	    cMes := &('QRYSB3->B3_Q' + StrZero(nMesB3,2))
	EndIf		
	QRYSB3->(dbCloseArea())
EndIf

Return(cMes)  

/*
+=============================================================+
| Query retornarแ o total do produto com programa็ใo.         |
+=============================================================+
*/

User Function ProSCK(_cProduto)

Local nProgr := 0 
Local cQRY   := ""

cQRY := " SELECT "
cQRY += " 	SUM(CK_QTDVEN) AS QTDVEN"
cQRY += " 	FROM "
cQRY += RetSQLName("SCK")
cQRY += " 		WHERE "
cQRY += "			CK_FILIAL IN ('01','04')      "
cQRY += " 		AND	CK_PRODUTO = '"+_cProduto+"' "                                             
cQRY += " 		AND	D_E_L_E_T_ = ' '   "                                             

cQRY := ChangeQuery(cQRY) 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQRY),"QRYSCK",.T.,.T.)     
                          

nProgr := QRYSCK->QTDVEN 

QRYSCK->(dbCloseArea())

Return (nProgr) 

/*
+===============================================================+
| Query retornarแ a data mais pr๓xima de entrega da programa็ใo.|
+===============================================================+
*/

User Function EntrSCK(_cProduto)

Local nProgr := 0 
Local cQRY   := ""

cQRY := " SELECT "
cQRY += " 	MIN(CK_ENTREG) DTENTR"
cQRY += " 	FROM "
cQRY += RetSQLName("SCK")
cQRY += " 		WHERE "
cQRY += "			CK_FILIAL IN ('01','04')      "
cQRY += " 		AND	CK_PRODUTO = '"+_cProduto+"' "                                             
cQRY += " 		AND	D_E_L_E_T_ = ' '   "                                             

cQRY := ChangeQuery(cQRY) 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQRY),"QRSCK",.T.,.T.)     

nProgr := QRSCK->DTENTR 

QRSCK->(dbCloseArea())

Return (_dData)