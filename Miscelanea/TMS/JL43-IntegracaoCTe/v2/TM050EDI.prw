#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE 'TOPCONN.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} User Function TM050EDI
	(long_description)
	@type  Function
	@author user
	@since 04/04/2023
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/

User Function TM050EDI()

	Local nPos := 0
	Local aArea := Getarea()
	Local nCnt := Len(aCols)

	nPos := DTC->(FieldPos("DTC_TIPNFC"))    //Ascan(aHeader,{|x| AllTrim(x[2]) == 'DTC_PLACA'})
	If nPos > 0 .And. !Empty(DE5->DE5_TIPNFC)
		M->DTC_TIPNFC := DE5->DE5_TIPNFC
	Endif

	nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == 'DTC_TIPANT'})
	If nPos > 0 .And. !Empty(DE5->DE5_TIPANT)
		aCols[nCnt,nPos] := DE5->DE5_TIPANT
		__readvar:='M->'+aHeader[nPos][2]
		CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos])
	Endif

	nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == 'DTC_DPCEMI'})
	If nPos > 0 .And. !Empty(DE5->DE5_DPCEMI)
		aCols[nCnt,nPos] := DE5->DE5_DPCEMI
		__readvar:='M->'+aHeader[nPos][2]
		CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos])
	Endif


	nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == 'DTC_CTEANT'})
	If nPos > 0 .And. !Empty(DE5->DE5_CTEANT)
		aCols[nCnt,nPos] := DE5->DE5_CTEANT
		__readvar:='M->'+aHeader[nPos][2]
		CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos])
	Endif

	nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == 'DTC_CTRDPC'})
	If nPos > 0 .And. !Empty(DE5->DE5_CTRDPC)
		aCols[nCnt,nPos] := DE5->DE5_CTRDPC
		__readvar:='M->'+aHeader[nPos][2]
		CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos])
	Endif

	nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == 'DTC_SERDPC'})
	If nPos > 0 .And. !Empty(DE5->DE5_SERDPC)
		aCols[nCnt,nPos] := DE5->DE5_SERDPC
		__readvar:='M->'+aHeader[nPos][2]
		CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos])
	Endif

	nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == 'DTC_FRTSUB'})
	If nPos > 0 .And. !Empty(DE5->DE5_FRTSUB)
		aCols[nCnt,nPos] := DE5->DE5_FRTSUB
		__readvar:='M->'+aHeader[nPos][2]
		CheckSX3(aHeader[nPos][2],aCols[nCnt,nPos])
	Endif

	RestArea ( aArea )

Return
