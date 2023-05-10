#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE 'TOPConn.ch'
#INCLUDE 'TMSAE80.ch'
#INCLUDE "FWCOMMAND.CH"  
#INCLUDE "TOPCONN.CH"      
#INCLUDE "TBICONN.CH"
#INCLUDE "XMLXFUN.CH"     

User Function TME80ALT()

	Local aArea		:= GetArea()
	Local aAreaDTC	:= DTC->(GetArea())
	Local aAreaDTP	:= DTP->(GetArea())	
	Local aAreaSA1	:= SA1->(GetArea())	

	Local aRet      := {}
	Local cAlias    := ParamIXB[1]
	Local aCabec    := ParamIXB[2]
	Local aItens    := ParamIXB[3]
	Local oXmlDE5 	:= IIF(Len(ParamIXB) >= 4, ParamIXB[4], "")
	Local aItCont	:= IIF(Len(ParamIXB) >= 5, ParamIXB[5], "")
	Local nPosSer   := 0
	Local nPos	    := 0	
	Local cServic	:= SuperGetMV('ES_SERVIC',.F.,"")
	Local vFrete	:= 0

	If cAlias == "DE5" .And. !Empty(aCabec) .And. !Empty(aItens)

		nPos := Ascan(aCabec, {|x| Alltrim(x[1]) == "DE5_SERIE"})
		cSerNfc	:= aCabec[nPos][2] 
		aCabec[nPos][2] := StrZero(Val(cSerNfc),3) 

		If ValType(oXmlDE5:_INFNFE:_DET) == "A"

			vFrete := Val(oXMLDE5:_INFNFE:_TOTAL:_ICMSTOT:_VFRETE:Text)

			Aadd(aCabec,{"DE5_VFRETE" , vFrete, Nil }) 

			If vFrete > 0 
				nPosSer := Ascan(aCabec, {|x| Alltrim(x[1]) == "DE5_SERVIC"})
				aCabec[nPosSer][2] := cServic 
			EndIf

		EndIf

		Aadd(aRet,Aclone(aCabec))
		Aadd(aRet,Aclone(aItens))

	EndIf

	RestArea(aAreaDTC)
	RestArea(aAreaDTP)
	RestArea(aAreaSA1)
	RestArea(aArea)

Return aRet