#INCLUDE "Protheus.ch"   
#INCLUDE "TbiConn.ch"
#INCLUDE "TbiCode.ch"

/*====================================================================================\
|Programa  | ESTAPROVPV     | Autor | Rafael Rosa               | Data | 02/02/2023   |
|=====================================================================================|
|Descrição | Processamento do Job                                                     |
|          | Chamada das funcoes DIPJBEXPMDF e DIPJBEXPCTE                            |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | ESTAPROVPV                                                              |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Dev       | DD/MM/AA - Descrição                                                     |
|Rafael    | 25/08/2022 - Fonte elaborado (Em fase de testes)                         |
|Rafael    | 01/09/2022 - Reajustada funcoes de preparacao do ambiente.               |
\====================================================================================*/

User Function ESTAPROVPV(aParam)

Local cSQL		:= ""
//Local lFlag		:= .F.
//Local cDirDest	:= GetNewPar("MV_ZDIEXOM","")

DEFAULT aParam :={"01","01"}
       
    RpcSetType(3)
    RpcSetEnv(aParam[1],aParam[2],,,"FAT")
	
	Conout("Estorno de PV Liberados. Virada do dia de operacao..." + aParam[1] + "/" + aParam[2] )

	cSQL := " SELECT "
	cSQL += " 	C5_CLIENTE, C5_LOJACLI, C5_NUM "
	cSQL += " 	FROM " 
	cSQL += 		RetSQLName("SC5")		
	cSQL += " 		WHERE "
	cSQL += " 			C5_FILIAL		= '"+xFilial("SC5")+"' AND "
	cSQL += " 			 C5_XSTATUS		= 'APROVADO' AND "
	cSQL += " 			 C5_OPERADO		= '000135' AND "
	cSQL += " 			 C5_EMISSAO		= '20230202' AND "
	cSQL += " 			 C5_PRENOTA 	= 'O' AND "	
	cSQL +=  			RetSQLName("SC5")+".D_E_L_E_T_ 	= ' ' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),'QRY_',.T.,.F.)
	dbSelectArea("QRY_")

	While !QRY_->(Eof())

	//if C5_OPERADOR = maximo

	DbSelectArea("SZR")
	SZR->(DbSetOrder(3))
	SZR->(DbSeek(xFilial("SZR") + QRY_->C5_NUM))
		IF FOUND()
			//IF CTOD(SUBSTR(SZR->RZ_DTSOLIC,1,8)) < DATE() .AND. ZR_STATUS = "APROVADO"
			IF CTOD(SUBSTR(SZR->RZ_DTSOLIC,1,8)) < CTOD("03/02/23") .AND. ZR_STATUS = "APROVADO"
				SZR->(RecLock("SZR",.F.))

				DbSelectArea("SC5")
				SC5->(DbSetOrder(5))
				SC5->(DbSeek(xFilial("SC5") + QRY_->C5_CLIENTE + QRY_->C5_LOJA + QRY_->C5_NUM))   
					IF FOUND()
						SC5->(RecLock("ZZ5",.F.))

							SC5->C5_XSTATUS := ""
						
						SC5->(MsUnlock())

            			SZR->(DbDelete())

					ENDIF

				SC5->(dbSkip())
        		SZR->(MsUnlock())
			ENDIF
		ENDIF
	SZR->(dbSkip())

	QRY_->(dbSkip())

	EndDo

	QRY_->(dbCloseArea())
	
	RpcClearEnv()

Return
